<# ---------------------------------------------------------------------------------------------------------------------------------------
    UPDATE-BAMBOOHRUSER
--------------------------------------------------------------------------------------------------------------------------------------- #>

function Update-BambooHRUser {
    param(
        [Parameter(Mandatory=$true,Position=0)]$apiKey,
        [Parameter(Mandatory=$true,Position=1)]$subDomain,
        [Parameter(Mandatory=$false,Position=2)]$id,
        [Parameter(Mandatory=$false,Position=3)]$emailAddress,
        [Parameter(Mandatory=$true,Position=4)]$fields
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
    $userUrl = "https://api.bamboohr.com/api/gateway.php/{0}/v1/employees/{1}" -f $subDomain,$id

    # Attempt to connect to the BambooHR API Service
    try
    {
        # Perform the API query
        $updateUser = Invoke-WebRequest $userUrl -method POST -Credential $bambooHRAuth -body $query -Headers @{"accept"="application/json"}
    }
    catch
    {
        throw "User update failed."
    }

    if($updateUser.StatusCode -ne 200)
    {
        throw "User update failed."
    }
    else 
    {
        return $true    
    }
}