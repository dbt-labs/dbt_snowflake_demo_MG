/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: PopulationEncounter
Description: Captures all encounters relevant to the domain, no encounter will contribute to metrics if it is not in this list.

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/
SELECT 
EventEncounterFact.EncounterKey, EventEncounterFact.EncounterEpicCsn AS PatientEncounterID
FROM   SAM.EAMImaging.EventEncounterFact
WHERE 
EventEncounterFact.[DATE] <= (SELECT MAX(DATE) FROM [SAM].[EAMImaging].[EventImagingFact])
/* We exclude future dates by limiting date to whatever is available in actual images */
AND NOT EXISTS
(SELECT 'Test Patient Exclusion'
FROM SAM.EAMImaging.RuleExcludeTestPatient
WHERE EventEncounterFact.PatientDurableKey = RuleExcludeTestPatient.PatientDurableKey)
AND 
(
EXISTS
(SELECT 'Include Appointment Requests'
FROM SAM.EAMImaging.RuleIncludeAppointment
WHERE EventEncounterFact.EncounterEpicCsn = RuleIncludeAppointment.PatientEncounterID
)
OR 
EXISTS
(SELECT 'Include Imaging Encounters'
FROM SAM.EAMImaging.RuleIncludeImaging
WHERE EventEncounterFact.EncounterKey = RuleIncludeImaging.PerformingEncounterKey
/* While technically some imaging is excluded, no impacts to metrics were found when they aren't excluded here */
)
)

/*
The cardinality of Key to ID is exactly 1 to 1 on this table
*/