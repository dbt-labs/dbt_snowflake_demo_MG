/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: PopulationImaging
Description: Some exclusions are applied at the event level from configuration table, otherwise filters are applied here

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/

SELECT ImagingKey  
FROM 
SAM.EAMImaging.RuleIncludeImaging
WHERE NOT EXISTS
(SELECT 'Imaging Exclusions'
FROM SAM.EAMImaging.RuleExcludeImaging
WHERE RuleIncludeImaging.ImagingKey = RuleExcludeImaging.ImagingKey)