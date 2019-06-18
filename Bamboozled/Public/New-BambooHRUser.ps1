<# ---------------------------------------------------------------------------------------------------------------------------------------
    NEW-BAMBOOHRUSER
--------------------------------------------------------------------------------------------------------------------------------------- #>

function New-BambooHRUser {
    param(
        [Parameter(Mandatory=$true,Position=0)]$apiKey,
        [Parameter(Mandatory=$true,Position=1)]$subDomain,
        [Parameter(Mandatory=$false,Position=4)]$fields
    )
    # Force use of TLS1.2 for compatibility with BambooHR's API server. Powershell on Windows defaults to 1.1, which is unsupported
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    # Create a new blank array to work with
    $fieldsArray = @()

    # For each field provided, create the XML required
    foreach($field in $fields.Keys)
    {
        $item = '<field id="{0}">{1}</field>' -f $field,$fields[$field]
        $fieldsArray += $item
    }

    # Join the array to create a single string
    $fields = $fieldsArray -join ''

    # Construct a query string to use for the API request
    $query = @(
        '<employee>'
            $fields
        '</employee>'
    )

    # Join the above array to create a string
    $query = $query -join ''

    # Build a BambooHR credential object using the provided API key
    $bambooHRAuth = Get-BambooHRAuth -ApiKey $apiKey

    # API endpoint URL
    $userUrl = "https://api.bamboohr.com/api/gateway.php/{0}/v1/employees" -f $subDomain

    # Attempt to connect to the BambooHR API Service
    try
    {
        # Perform the API query
        $newUser = Invoke-WebRequest $userUrl -method POST -Credential $bambooHRAuth -body $query -Headers @{"accept"="application/json"}
    }
    catch
    {
        throw "New user creation failed."
    }

    if($newUser.StatusCode -ne 201)
    {
        throw "New user creation failed."
    }
    else 
    {
        return $true
    }
}
