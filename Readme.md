# Bamboozled!

A simple PowerShell module to extract user information from [BambooHR](https://www.bamboohr.com/). For more information about this module, see the [Bamboozled article on my personal blog](https://smnbkly.co/blog/bamboozled-powershell-and-the-bamboohr-api).

## Installation

1. Download and unzip the module.
2. Copy to PowerShell's modules folder in your environment. See [this article](https://docs.microsoft.com/en-us/powershell/developer/module/installing-a-powershell-module) for details.
3. That's it!

## Getting Started

**Available functions**

- Get-BambooHRDirectory: Gets a directory of users from BambooHR
- Get-BambooHRUser: Gets a single user from BambooHR

## Get-BambooHRDirectory

### The basics

The basic syntax for the Get-BambooHRDirectory commandlet is below. This commandlet also provides a few options, detailed later.

```powershell
Get-BambooHRDirectory -ApiKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxx" -subDomain "companyname"
```

When run, this command will output a list of all employees, past and present, including all fields available from BambooHR's API. For a full list of these fields, see [this link](https://www.bamboohr.com/api/documentation/employees.php#listFields).

### Active users only

To filter by active users, use the 'active' flag:

```powershell
Get-BambooHRDirectory -ApiKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxx" -subDomain "companyname" -active
```

### Customising fields

To adjust the fields returned in the results, you can use the fields flag:

```powershell
Get-BambooHRDirectory -ApiKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxx" -subDomain "companyname" -fields "firstName,lastName,workEmail,supervisorEid"
```

A list of available fields can be found in [BambooHR's API documentation](https://www.bamboohr.com/api/documentation/employees.php). This module expects the field names to be provided as written in BambooHR's documentation, separated by commas (no spaces).

### Filtering by "Changed since"

To find a list of user records that have changed since a specified date, you can use the 'since' flag as below. The module expects the time to be provided in [ISO 8601 format](https://www.iso.org/iso-8601-date-and-time-format.html).

```powershell
Get-BambooHRDirectory -ApiKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxx" -subDomain "companyname" -since "2018-10-22T15:00:00Z"
```

## Get-BambooHRUser

### The basics

The basic syntax for the Get-BambooHRUser commandlet is below. This commandlet also provides a few options, detailed later.

```powershell
Get-BambooHRUser -ApiKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxx" -subDomain "companyname" -id 300
```

The above command will output BambooHR's information related to the employee with a unique ID of '300'.

### By email address

If you don't have the employee's ID, you can use their email address instead. Note however, this performs a full directory lookup first, extracts the user's ID, and then performs an API request for that user's ID. If you have the employee's unique ID, the command above will be considerably quicker.

```powershell
Get-BambooHRUser -ApiKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxx" -subDomain "companyname" -emailAddress "test@example.com"
```
