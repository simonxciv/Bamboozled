<#
.SYNOPSIS
Returns the photo of the user or users passed as input in bytes.

.DESCRIPTION
Retrieves the photo of the employee by size, which can be original, large, medium, small, xs, or tiny.
The photo is returned as a PSObject and can be used to set the thumbnailPhoto in Active Directory, for example.

Example use:

$photo = Get-BambooHRPhoto -apikey fakeapi -subdomain fakecompany -employeeid 39 -size xs
$photo = [byte[]]$photo
set-aduser f.user -Replace @{thumbnailPhoto=$photo}

BambooHR documentation for employee photos: https://documentation.bamboohr.com/reference#photos-1

.PARAMETER apiKey
Specifies BambooHR API key.  

.PARAMETER subDomain
Specifies the BambooHR Subdomain.

.PARAMETER size
Specifices of the size of the photo.

Original = original size
large = 340x340 px
medium = 170x170 px
small = 150x150 px
xs = 50x50 px
tiny = 20x20 px

.PARAMETER employeeID
The employee ID number.

.EXAMPLE
Get-BambooHRPhoto -api RanD03mAPi -subDomain company1 -size xs -id 39
#>

function Get-BambooHRPhoto{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$apikey,
        [Parameter(Mandatory=$true)]
        [string]$subdomain,
        [Parameter(Mandatory=$true)]
        [string]$size,
        [Parameter(Mandatory=$true,ValueFromPipeline)]
        [string[]]$employeeID
    )

    BEGIN{
        # Force use of TLS1.2 for compatibility with BambooHR's API server. Powershell on Windows defaults to 1.1, which is unsupported
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    }
    PROCESS{
        # Build a BambooHR credential object using the provided API key
        $bambooHRAuth = Get-BambooHRAuth -ApiKey $apiKey

        # Attempt to connect to the BambooHR API Service
        try
        {   
            $results = @()

            foreach($id in $employeeID){

                # Define the URL to perform the request to
                $photoUrl = 'https://api.bamboohr.com/api/gateway.php/{0}/v1/employees/{1}/photo/{2}' -f $subdomain,$id,$size

                Write-Verbose "[PROCESS] Calling web request.." 
                # Perform the API query
                $bambooHRPhoto = Invoke-WebRequest $photoUrl -method GET -Credential $bambooHRAuth -Headers @{"accept"="application/json"} -UseBasicParsing

                Write-Verbose "[PROCESS] Saving photo" 
                # Savethe photo? What next?
                $photo = $bambooHRPhoto.Content | ConvertFrom-Json

                Write-Verbose "[PROCESS] Add photo to results" 
                $results += [PSCustomObject]@{
                employeeID = $id
                thumbnailPhoto = $photo
                }
            }

            $results
        }
        # If the above failed, throw an error
        catch
        {
            throw "Failed to download user details."
        }
    }
    END{}
}