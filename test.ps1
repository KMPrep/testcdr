function Send-LineByLine {
    param (
        [String] $FolderName,
        [String] $DomainName,
        [String] $Token,
        [String] $FilterName,
        [int] $TimeOut
    )

    #Write-Output $FolderName
    #Write-Output $DomainName
    #Write-Output $Token
    #Write-Output $FilterName
    #Write-Output $TimeOut
    
    Get-ChildItem $FolderName -Filter $FilterName |
    ForEach-Object{
        Write-Output ([String]::Format("Processing File: {0}", $_.FullName))

        foreach($line in Get-Content $_.FullName) {
            $dict = New-Object System.Collections.Generic.Dictionary"[String,String]"
            $splitData = $line.Split(",")
            $count = 0

            foreach($data in $splitData){
                $dict_key = ([String]::Format("Data{0}", $count))
                $dict.Add($dict_key, $data)
                $count = $count + 1
            }

            $text = (ConvertTo-Json $dict -Compress ) 
            $bytes = [System.Text.Encoding]::Unicode.GetBytes($text)
            $encoded = [Convert]::ToBase64String($bytes)
            $uri = 'https://' + $DomainName + '/api/courses'

            Invoke-WebRequest -Uri $uri -Headers @{'Accept' = 'application/json'; 'BearerToken' = $encoded; 'cnty' = $Token; 'User-Agent' = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36' }

            Start-Sleep -Seconds (Get-Random -Minimum 0 -Maximum $TimeOut)
        }
    }

}


function Send-File {
    param (
        [String] $FolderName,
        [String] $DomainName,
        [String] $Token,        
        [int] $TimeOut
    )
    
    Get-ChildItem $FolderName | ForEach-Object{
        Write-Output ([String]::Format("Uploading {0} ...........", $_))

        $uri = [String]::Format('https://{0}/api/courses?test={1}', $DomainName, $Token);

        $fileBytes = [System.IO.File]::ReadAllBytes($_);
        $fileEnc = [System.Text.Encoding]::GetEncoding('UTF-8').GetString($fileBytes);
        $boundary = [System.Guid]::NewGuid().ToString(); 
        $LF = "`r`n";

        $bodyLines = ( 
            "--$boundary",
            ( [String]::Format("Content-Disposition: form-data; name=`"Logo`"; filename=`"{0}`"", $_.Name)),
            "Content-Type: application/octet-stream$LF",
            $fileEnc,
            "--$boundary--$LF",
            "Content-Disposition: form-data; name=`"Token`"",
            $Token,
            "--$boundary--$LF"
        ) -join $LF

        #Write-Output $bodyLines
        Invoke-RestMethod -Uri $uri -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines



    }

}
