/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: RuleExcludeImaging
Description: 

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/

SELECT ImagingKey
FROM [SAM].[EAMImaging].[EventImagingFact]
WHERE  ProcedureName  LIKE '%3D%'
OR ProcedureName  LIKE '%OUTSIDE%'

/* 
There is not a maintained grouper list of 3D and OUTSIDE encounters
Further a configuration table entry would not allow dynamic evaluation 
Compare to the same concern in another exclusion of appointment
*/