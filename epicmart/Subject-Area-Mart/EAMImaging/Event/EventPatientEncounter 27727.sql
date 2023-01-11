/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: EventPatientEncounter
Description: Used instead of Clarity Patient Encounter but only for specified MRI and CT resources

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/

SELECT
 PatientEncounter.PatientEncounterID,
 PatientEncounter.PatientID,
 PatientEncounter.EncounterEpicProviderID,
 PatientEncounter.DepartmentID,
 PatientEncounter.AppointmentDTS,
 CAST(PatientEncounter.AppointmentDTS AS DATE) AS AppointmentDateDTS,
 PatientEncounter.AppointmentStatusCD,
 PatientEncounter.AppointmentStatusDSC,
 PatientEncounter.AppointmentCancelDTS,
 PatientEncounter.AppointmentSerialNBR,
 PatientEncounter.AppointmentCancelTimeDTS,
 PatientEncounter.EDWLastModifiedDTS
FROM   Epic.Encounter.PatientEncounter

WHERE  EXISTS 
(SELECT 'Domain Encounter'
FROM   SAM.EAMImaging.EventEncounterFact
WHERE  PatientEncounter.PatientEncounterID = EventEncounterFact.EncounterEpicCsn
)
/*There are cases where patient encounter doesn't have the domain resource, it is null */