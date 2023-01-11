/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: RuleIncludeImaging
Description: A domain inclusion list, including patient class

Originally copied from Carmin and Margaret's department binding.
Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
20221122  Adam Proctor    !12657  Expanded Patient Class list beyond original 3
*********************************************************************************************************************************************************/

SELECT ImagingKey
	  ,PerformingEncounterKey

From SAM.EAMImaging.EventImagingFact
WHERE EventImagingFact.PatientClass IN 
(
SELECT
ConfigurationValueTXT
FROM SAM.EAMImaging.DomainConfiguration
WHERE ConfigurationItemDSC = 'Patient Class Mapping'
AND ConfigurationColumnNM = 'PatientClass'
)