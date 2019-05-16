# Bamboozled!

A simple PowerShell module to extract user reports from [BambooHR](https://www.bamboohr.com/). For more information about this module, see the [Bamboozled article on my personal blog](https://smnbkly.co/blog/bamboozled-powershell-and-the-bamboohr-api).

## Installation

1. Download and unzip the module.
2. Copy to PowerShell's modules folder in your environment. See [this article](https://docs.microsoft.com/en-us/powershell/developer/module/installing-a-powershell-module) for details.
3. That's it!

## Getting Started

**Basic usage**

Once installed, you can call the Get-BambooHRDirectory function from any script you need it in, like below:

```
Get-BambooHRDirectory -ApiKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxx" -subDomain "companyname"
```

The above command will output the module's default fields (first name, last name, email address, status) for all users in the BambooHR directory, active or not. 

**Active users only**

To filter by active users, use the 'active' flag:

```
Get-BambooHRDirectory -ApiKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxx" -subDomain "companyname" -active
```

**Customising fields**

To adjust the fields returned in the results, you can use the fields flag:

```
Get-BambooHRDirectory -ApiKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxx" -subDomain "companyname" -fields "firstName,lastName,workEmail,supervisorEid"
```

A list of available fields can be found in [BambooHR's API documentation](https://www.bamboohr.com/api/documentation/employees.php). This module expects the field names to be provided as written in BambooHR's documentation, separated by commas (no spaces).

**Filtering by "Changed since"**

To find a list of user records that have changed since a specified date, you can use the 'since' flag as below. The module expects the time to be provided in [ISO 8601 format](https://www.iso.org/iso-8601-date-and-time-format.html).

```
Get-BambooHRDirectory -ApiKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxx" -subDomain "companyname" -since "2018-10-22T15:00:00Z"
```
