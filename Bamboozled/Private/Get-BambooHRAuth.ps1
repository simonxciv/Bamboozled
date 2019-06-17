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