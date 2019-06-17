<# ---------------------------------------------------------------------------------------------------------------------------------------
    GET-BAMBOOHRUSERID
--------------------------------------------------------------------------------------------------------------------------------------- #>

function Get-BambooHRUserID {
    param (
        [Parameter(Mandatory=$true,Position=0)]$ApiKey,
        [Parameter(Mandatory=$true,Position=1)]$subDomain,
        [Parameter(Mandatory=$false,Position=2)]$emailAddress
    )
    # Get the user directory
    $allStaff = Get-BambooHRDirectory -apiKey $apiKey -subDomain $subDomain -fields 'id,workEmail'

    # Filter the directory by the provided email address
    $employeeID = $allStaff | Where-Object {$_.workEmail -eq $emailAddress}

    # Get the ID from the user object
    return $employeeID.id
}