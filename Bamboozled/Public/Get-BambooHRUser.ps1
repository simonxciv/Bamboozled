<# ---------------------------------------------------------------------------------------------------------------------------------------
    GET-BAMBOOHRUSER
--------------------------------------------------------------------------------------------------------------------------------------- #>

function Get-BambooHRUser {
    param(
        [Parameter(Mandatory=$true,Position=0)]$apiKey,
        [Parameter(Mandatory=$true,Position=1)]$subDomain,
        [Parameter(Mandatory=$false,Position=2)]$id,
        [Parameter(Mandatory=$false,Position=3)]$emailAddress,
        [Parameter(Mandatory=$false,Position=4)]$fields
    )
    # Force use of TLS1.2 for compatibility with BambooHR's API server. Powershell on Windows defaults to 1.1, which is unsupported
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    # If an ID is provided, set the employeeID variable
    if($null -ne $id)
    {
        $employeeID = $id
    }

    # If the email address is provided, lookup the directory to find the user's ID
    elseif($null -ne $emailAddress)
    {
        # Lookup the user's ID using the provided email address
        $employeeId = Get-BambooHRUserID -ApiKey $apiKey -subDomain $subDomain -emailAddress $emailAddress
    }

    # If no parameters were provided, fail
    elseif($null -eq $emailAddress -and $null -eq $id)
    {
        throw "No parameter was provided. Please provide an email address or employee ID."
    }

    # If user does not provide a list of fields, set the defaults.
    if($null -eq $fields)
    {
        $fields = Set-BambooHRVariables
    }
    
    # Define the URL to perform the request to
    $userUrl = 'https://api.bamboohr.com/api/gateway.php/{0}/v1/employees/{1}?fields={2}' -f $subDomain,$employeeID,$fields

    # Build a BambooHR credential object using the provided API key
    $bambooHRAuth = Get-BambooHRAuth -ApiKey $apiKey

    # Attempt to connect to the BambooHR API Service
    try
    {
        # Perform the API query
        $bambooHRUser = Invoke-WebRequest $userUrl -method GET -Credential $bambooHRAuth -Headers @{"accept"="application/json"}

        # Convert the output to a PowerShell object
        $bambooHRUser = $bambooHRUser.Content | ConvertFrom-JSON
    }

    # If the above failed, throw an error
    catch
    {
        throw "Failed to download user details."
    }

    # Return the powershell object
    return $bambooHRUser
}
