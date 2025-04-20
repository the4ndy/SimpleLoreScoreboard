param(
    [Parameter()]
    [int]$Port = 8080 # Default port
)

$file1 = "P1Score.txt"
$file2 = "P2Score.txt"



# Initialize files if they don't exist
if (-not (Test-Path $file1)) {
    "0" | Out-File $file1 -Encoding UTF8
}
if (-not (Test-Path $file2)) {
    "0" | Out-File $file2 -Encoding UTF8
}

function Get-Numbers {
    $number1 = Get-Content $file1
    $number2 = Get-Content $file2
    return @{ number1 = [int]$number1; number2 = [int]$number2 }
}

function Update-Number {
    param(
        [int]$numberId,
        [int]$newNumber
    )

    $oldNumbers = Get-Numbers # Get old numbers for comparison
    if ($numberId -eq 1) {
        $newNumber | Out-File $file1 -Encoding UTF8
        Write-Host "P1Score updated from $($oldNumbers.number1) to $newNumber" # Log change
    } elseif ($numberId -eq 2) {
        $newNumber | Out-File $file2 -Encoding UTF8
        Write-Host "P2Score updated from $($oldNumbers.number2) to $newNumber" # Log change
    }
}



Add-Type -AssemblyName System.Web

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$Port/")

# Get the IP addresses of the current machine.
function Get-LocalIPAddresses {
    $addresses = @()

    # Use Get-NetIPAddress, which is available in PowerShell 3.0 and later
    try {
        $netIpAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -NotLike "vEthernet*"}

        if ($netIpAddresses) {
            foreach ($netIpAddress in $netIpAddresses) {
                $ip = $netIpAddress.IPAddress.ToString()
                # Exclude 169.254.x.x (link-local) and 127.0.0.1 (loopback)
                if ( ($ip -notlike "169.254.*") -and ($ip -ne "127.0.0.1") ) {
                    # Check if it's a private IP address
                    if ( ($ip -like "10.*") -or
                         ($ip -like "172.16.*") -or ($ip -like "172.17.*") -or ($ip -like "172.18.*") -or ($ip -like "172.19.*") -or ($ip -like "172.20.*") -or ($ip -like "172.21.*") -or ($ip -like "172.22.*") -or ($ip -like "172.23.*") -or ($ip -like "172.24.*") -or ($ip -like "172.25.*") -or ($ip -like "172.26.*") -or ($ip -like "172.27.*") -or ($ip -like "172.28.*") -or ($ip -like "172.29.*") -or ($ip -like "172.30.*") -or ($ip -like "172.31.*") -or
                         ($ip -like "192.168.*") ) {
                        $addresses += $ip
                    }
                }
            }
        }
        else {
            Write-Warning "No IPv4 addresses found."
        }
    }
    catch {
        # Handle errors, for example if Get-NetIPAddress is not available
        Write-Error "Error getting IP addresses: $($_.Exception.Message)"
    }

    return $addresses
}

try {
    $listener.Start()
    # Display the IP addresses and the port.
    $ipAddresses = Get-LocalIPAddresses
    if ($ipAddresses.Count -gt 0) {
        Write-Host "Server started on the following addresses and port: "
        foreach ($ip in $ipAddresses) {
            Write-Host "  http://${ip}:${Port}/"
        }
    }
    else
    {
        Write-Host "Server started on http://+:$Port/"
    }


    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response

            if ($request.Url.AbsolutePath -eq "/") {
                $html = Get-Content "index.html" -Raw
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($html)
                $response.ContentType = "text/html"
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } elseif ($request.Url.AbsolutePath -eq "/style.css") {
                $css = Get-Content "style.css" -Raw
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($css)
                $response.ContentType = "text/css"  # Set content type for CSS
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } elseif ($request.Url.AbsolutePath -eq "/script.js") {
                $js = Get-Content "script.js" -Raw
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($js)
                $response.ContentType = "text/javascript" # Set content type for JavaScript
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } elseif ($request.Url.AbsolutePath -eq "/updateNumber" -and $request.HttpMethod -eq "POST") {
                $reader = New-Object System.IO.StreamReader($request.InputStream)
                $body = $reader.ReadToEnd()
                $reader.Close()

                $params = $body -split "&"
                $numberId = ($params | Where-Object { $_ -like "numberId=*" }) -replace "numberId=", ""
                $newNumber = ($params | Where-Object { $_ -like "newNumber=*" }) -replace "newNumber=", ""

                Update-Number -numberId $numberId -newNumber $newNumber
                $response.StatusCode = 200
            } elseif ($request.Url.AbsolutePath -eq "/getNumbers") {
                $numbers = Get-Numbers | ConvertTo-Json
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($numbers)
                $response.ContentType = "application/json"
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } elseif ($request.Url.AbsolutePath -eq "/resetScores" -and $request.HttpMethod -eq "POST") {
                "0" | Out-File $file1 -Encoding UTF8
                "0" | Out-File $file2 -Encoding UTF8
                Write-Host "Scores have been reset to 0"
                $response.StatusCode = 200
            } else {
                $response.StatusCode = 404
            }

            $response.Close()
        }
        catch {
            Write-Error $_
        }
    }
}
catch {
    Write-Error $_
}
finally {
    if ($listener.IsListening) {
        $listener.Stop()
        Write-Host "Server stopped."
    }
}
