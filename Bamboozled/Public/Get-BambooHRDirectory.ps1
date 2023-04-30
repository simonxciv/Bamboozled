<# ---------------------------------------------------------------------------------------------------------------------------------------
    GET-BAMBOOHRDIRECTORY
--------------------------------------------------------------------------------------------------------------------------------------- #>

function Get-BambooHRDirectory {
    param(
        [Parameter(Mandatory=$true,Position=0)]$apiKey,
        [Parameter(Mandatory=$true,Position=1)]$subDomain,
        [Parameter(Mandatory=$false,Position=2)]$since,
        [Parameter(Mandatory=$false,Position=3)]$fields,
        [Parameter(Mandatory=$false,Position=4)][switch]$active,
        [Parameter(Mandatory=$false,Position=5)][bool]$onlyCurrent = $false
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

    # If user does not provide a list of fields, set the default field list.
    if($null -eq $fields)
    {
        $fields = Set-BambooHRVariables
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

    # Add onlyCurrent URI parameter if requested
    if (!$onlyCurrent) {
        $directoryUrl += '&onlyCurrent=false'
    }

    # Build a BambooHR credential object using the provided API key
    $bambooHRAuth = Get-BambooHRAuth -ApiKey $apiKey

    # Attempt to connect to the BambooHR API Service
    try
    {
        # Perform the API query
        $bambooHRDirectory = Invoke-WebRequest $directoryUrl -method POST -Credential $bambooHRAuth -body $query -UseBasicParsing

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