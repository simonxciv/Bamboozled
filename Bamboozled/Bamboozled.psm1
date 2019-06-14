<# ---------------------------------------------------------------------------------------------------------------------------------------
    GLOBAL VARIABLES
--------------------------------------------------------------------------------------------------------------------------------------- #>

# BambooHR's default list of fields
$defaultFields = 'address1,address2,age,bestEmail,birthday,city,country,dateOfBirth,department,division,eeo,employeeNumber,employmentHistoryStatus,ethnicity,exempt,firstName,flsaCode,fullName1,fullName2,fullName3,fullName4,fullName5,displayName,gender,hireDate,originalHireDate,homeEmail,homePhone,id,jobTitle,lastChanged,lastName,location,maritalStatus,middleName,mobilePhone,payChangeReason,payGroup,payGroupId,payRate,payRateEffectiveDate,payType,payPer,paidPer,paySchedule,payScheduleId,payFrequency,includeInPayroll,timeTrackingEnabled,preferredName,ssn,sin,state,stateCode,status,supervisor,supervisorId,supervisorEId,terminationDate,workEmail,workPhone,workPhonePlusExtension,workPhoneExtension,zipcode,isPhotoUploaded,acaStatus,standardHoursPerWeek,bonusDate,bonusAmount,bonusReason,bonusComment,commissionDate,commisionDate,commissionAmount,commissionComment,employmentStatus,nickname,payPeriod,photoUploaded,nin,nationalId,nationality'

<# ---------------------------------------------------------------------------------------------------------------------------------------
    GET-BAMBOOHRAUTH
--------------------------------------------------------------------------------------------------------------------------------------- #>

function Get-BambooHRAuth {
    param(
        [Parameter(Mandatory=$true,Position=0)]$ApiKey
    )

    $apiPassword = ConvertTo-SecureString 'x' -AsPlainText -Force
    $bambooHRAuth = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $apiKey, $apipassword

    Return $bambooHRAuth
}

<# ---------------------------------------------------------------------------------------------------------------------------------------
    GET-BAMBOOHRFIELDS
--------------------------------------------------------------------------------------------------------------------------------------- #>

function Get-BambooHRFields {
    param(
        [Parameter(Mandatory=$true,Position=0)]$ApiKey,
        [Parameter(Mandatory=$true,Position=1)]$subDomain
    )

    # Force use of TLS1.2 for compatibility with BambooHR's API server. Powershell on Windows defaults to 1.1, which is unsupported
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    
    # API endpoint URL
    $fieldsUrl = "https://api.bamboohr.com/api/gateway.php/{0}/v1/meta/fields" -f $subDomain

    # Build a BambooHR credential object using the provided API key
    $bambooHRAuth = Get-BambooHRAuth -ApiKey $apiKey

    # Attempt to connect to the BambooHR API Service
    try
    {
        # Perform the API query
        $bambooHRFields = Invoke-WebRequest $fieldsUrl -method GET -Credential $bambooHRAuth -Headers @{"accept"="application/json"}

        # Convert the output to a PowerShell object
        $bambooHRFields = $bambooHRFields.Content | ConvertFrom-Json
    }
    catch
    {
        throw "Failed to retrieve a list of fields."
    }

    Return $bambooHRFields
}

<# ---------------------------------------------------------------------------------------------------------------------------------------
    GET-BAMBOOHRDIRECTORY
--------------------------------------------------------------------------------------------------------------------------------------- #>

function Get-BambooHRDirectory {
    param(
        [Parameter(Mandatory=$true,Position=0)]$apiKey,
        [Parameter(Mandatory=$true,Position=1)]$subDomain,
        [Parameter(Mandatory=$false,Position=2)]$since,
        [Parameter(Mandatory=$false,Position=3)]$fields,
        [Parameter(Mandatory=$false,Position=4)][switch]$active
    )

    # Force use of TLS1.2 for compatibility with BambooHR's API server. Powershell on Windows defaults to 1.1, which is unsupported
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    # If user provides a filter date, construct the XML. Otherwise, leave blank
    if($since -ne '')
    {
        $sinceXML = '<filters><lastChanged includeNull="no">{0}</lastChanged></filters>' -f $since
    }
    else
    {
        $sinceXML = ''
    }

    # If user does not provide a set the default field list.
    if($null -eq $fields)
    {
        $fields = $defaultFields
    }

    # Split the comma separated fields by the comma
    $fields = $fields.split(",")

    # Create a new blank array to work with
    $fieldsArray = @()

    # For each field provided, create the XML required
    foreach($field in $fields)
    {
        $item = '<field id="{0}" />' -f $field
        $fieldsArray += $item
    }

    # Join the array to create a single string
    $fields = $fieldsArray -join ''

    # Construct a query string to use for the employee directory report
    $query = @(
        '<report>'
            '<title>Bamboozled Employee Directory</title>'
            $sinceXML
            '<fields>'
                $fields
                '<field id="status" />'
            '</fields>'
        '</report>'
    )

    # Join the above array to create a string
    $query = $query -join ''

    # API endpoint URL
    $directoryUrl = "https://api.bamboohr.com/api/gateway.php/{0}/v1/reports/custom?format=json" -f $subDomain

    # Build a BambooHR credential object using the provided API key
    $bambooHRAuth = Get-BambooHRAuth -ApiKey $apiKey

    # Attempt to connect to the BambooHR API Service
    try
    {
        # Perform the API query
        $bambooHRDirectory = Invoke-WebRequest $directoryUrl -method POST -Credential $bambooHRAuth -body $query

        # Convert the output to a PowerShell object
        $bambooHRDirectory = $bambooHRDirectory.Content | ConvertFrom-Json
    }
    catch
    {
        throw "Directory download failed."
    }

    # If the 'active' switch is used, filter the results to show only active employees
    if ($active)
    {
       $bambooHRDirectory = $bambooHRDirectory.employees | Where-Object {$_.status -eq 'Active'}
    }
    else {
        $bambooHRDirectory = $bambooHRDirectory.employees
    }

    # Return the powershell object
    return $bambooHRDirectory
}

<# ---------------------------------------------------------------------------------------------------------------------------------------
    GET-BAMBOOHRUSER
--------------------------------------------------------------------------------------------------------------------------------------- #>

function Get-BambooHRUser {
    param(
        [Parameter(Mandatory=$true,Position=0)]$apiKey,
        [Parameter(Mandatory=$true,Position=1)]$subDomain,
        [Parameter(Mandatory=$false,Position=2)]$emailAddress,
        [Parameter(Mandatory=$false,Position=3)]$id
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

        # Get the user directory
        $allStaff = Get-BambooHRDirectory -apiKey $apiKey -subDomain $subDomain -fields 'workEmail'

        # Filter the directory by the provided email address
        $employeeID = $allStaff | Where-Object {$_.workEmail -eq $emailAddress}

        # Get the ID from the user object
        $employeeID = $employeeID.id
    }

    # If no parameters were provided, fail
    elseif($null -eq $emailAddress -and $null -eq $id)
    {
        throw "No parameter was provided. Please provide an email address or employee ID."
    }

    # Set the fields to be used by the API call
    $fields = $defaultFields
    
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

Export-ModuleMember -Function Get-BambooHRDirectory, Get-BambooHRUser, Get-BambooHRFields