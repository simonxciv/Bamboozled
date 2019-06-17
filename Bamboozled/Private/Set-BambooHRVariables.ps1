<# ---------------------------------------------------------------------------------------------------------------------------------------
    GLOBAL VARIABLES
--------------------------------------------------------------------------------------------------------------------------------------- #>

# BambooHR's default list of fields
function Set-BambooHRVariables {
    $defaultFields = 'address1,address2,age,bestEmail,birthday,city,country,dateOfBirth,department,division,eeo,employeeNumber,employmentHistoryStatus,ethnicity,exempt,firstName,flsaCode,fullName1,fullName2,fullName3,fullName4,fullName5,displayName,gender,hireDate,originalHireDate,homeEmail,homePhone,id,jobTitle,lastChanged,lastName,location,maritalStatus,middleName,mobilePhone,payChangeReason,payGroup,payGroupId,payRate,payRateEffectiveDate,payType,payPer,paidPer,paySchedule,payScheduleId,payFrequency,includeInPayroll,timeTrackingEnabled,preferredName,ssn,sin,state,stateCode,status,supervisor,supervisorId,supervisorEId,terminationDate,workEmail,workPhone,workPhonePlusExtension,workPhoneExtension,zipcode,isPhotoUploaded,acaStatus,standardHoursPerWeek,bonusDate,bonusAmount,bonusReason,bonusComment,commissionDate,commisionDate,commissionAmount,commissionComment,employmentStatus,nickname,payPeriod,photoUploaded,nin,nationalId,nationality'
    return $defaultFields
}
