/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: EventEncounterFact
Description: Used instead of Caboodle EncounterFact but only for specified Domain Machines

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/

SELECT
  CAST(EncounterFact.[Date] AS DATE) AS [DATE],
  CAST(EncounterFact.PatientKey AS DECIMAL(28,0)) AS PatientKey,
  CAST(EncounterFact.PatientClass AS VARCHAR(255)) AS PatientClass,
  /* Source has ambiguous data types, and varchar max */
	CAST(EncounterFact.DerivedEncounterStatus AS VARCHAR(255)) DerivedEncounterStatus,
  EncounterFact.EncounterKey,
  EncounterFact.EncounterEpicCsn,
  EncounterFact.PatientDurableKey,
  EncounterFact.DepartmentKey,
  CAST(EncounterFact.VisitType AS VARCHAR(255)) AS VisitType,
  EncounterFact.IsDeleted,
  EncounterFact.EDWLastModifiedDTS
   
FROM EpicMart.Caboodle.EncounterFact
WHERE EXISTS
(SELECT 'Domain Encounter'
FROM SAM.EAMImaging.EventDomainEncounterKey
WHERE EncounterFact.EncounterKey = EventDomainEncounterKey.EncounterKey)
/* Domain Encounter here means either an image or an appointment request exists for the encounter */