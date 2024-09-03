# Function to obtain the Access Token
function Get-AccessToken {
    param (
        [string]$tokenUrl,
        [string]$clientId,
        [string]$clientSecret,
        [string]$scope = "all"
    )

    $body = @{
        grant_type    = "client_credentials"
        client_id     = $clientId
        client_secret = $clientSecret
        scope         = $scope
    }

    $bodyString = ($body.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" }) -join "&"

    $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $bodyString -ContentType "application/x-www-form-urlencoded"
    
    if ($response.error) {
        Write-Error "Error: $($response.error)"
        Write-Error "Error Description: $($response.error_description)"
        return $null
    }

    return $response.access_token
}

function Invoke-ApiRequest {
    param (
        [string]$apiUrl,
        [string]$accessToken,
        [string]$method = "Get",
        [hashtable]$headers = @{ Accept = "application/json" },
        [hashtable]$body = $null
    )

    $headers.Authorization = "Bearer $accessToken"

    if ($body) {
        $bodyString = ($body.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" }) -join "&"
    } else {
        $bodyString = $null
    }

    $response = Invoke-RestMethod -Uri $apiUrl -Method $method -Headers $headers -Body $bodyString -ContentType "application/x-www-form-urlencoded"
    
    return $response
}

function Find-ItemByProperty {
    param (
        [array]$items,
        [string]$propertyName,
        [string]$propertyValue
    )

    $item = $items | Where-Object { $_.$propertyName -eq $propertyValue }
    
    if ($item) {
        Write-Output "Item with $propertyName '$propertyValue' found:"
        $item | ConvertTo-Json -Depth 3
    } else {
        Write-Output "Item with $propertyName '$propertyValue' not found."
    }
}

$tokenUrl = ""
$clientId = ""
$clientSecret = ""

$accessToken = Get-AccessToken -tokenUrl $tokenUrl -clientId $clientId -clientSecret $clientSecret

if (-not $accessToken) {
    exit 1
}

$apiUrl = ""
$response = Invoke-ApiRequest -apiUrl $apiUrl -accessToken $accessToken

$response
