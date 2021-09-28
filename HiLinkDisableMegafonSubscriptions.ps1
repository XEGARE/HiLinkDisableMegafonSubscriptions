#Requires -Version 7.1

function SendSMS {

    param (
        $IP,
        $Phone,
        $Message
    )

    $response = Invoke-WebRequest "http://$IP/api/webserver/SesTokInfo"
    $responseXMLdata = [XML]($response.Content)

    $errorCode = $responseXMLdata.error.code
    if(-Not $errorCode)
    {
        $token = $responseXMLdata.response.TokInfo
        $sessionID = $responseXMLdata.response.SesInfo

        $client = New-Object System.Net.WebClient
        $client.Headers.Add("Content-Type", "text/xml; charset=UTF-8")

        if($token) {
            $client.Headers.Add("__RequestVerificationToken", $token)
        }

        if($sessionID) {
            $client.Headers.Add("Cookie", $sessionID)
        }

        $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        $content = "
        <?xml version=""1.0"" encoding=""UTF-8""?>
        <request>
            <Index>-1</Index>
            <Phones><Phone>$Phone</Phone></Phones>
            <Sca></Sca>
            <Content>$Message</Content>
            <Length>${$Message.length}</Length>
            <Reserved>1</Reserved>
            <Date>$date</Date>
        </request>
        "

        $response = $client.UploadString("http://$IP/api/sms/send-sms", $content)
        $responseXMLdata = [XML]($response)
        $result = $responseXMLdata.response
        return $result
    }

    return $errorCode
}

$megafonCommands = "УСТЗАПРЕТ1", "УСТЗАПРЕТСП", "УСТЗАПРЕТВП", "НЕТКЛИК1", "УСТПБК1"

foreach ($item in $megafonCommands) {
    $result = SendSMS -IP "192.168.8.1" -Phone 5151 -Message $item
    Write-Host "Результат ${item}: $result"
    Start-Sleep -Seconds 2
}