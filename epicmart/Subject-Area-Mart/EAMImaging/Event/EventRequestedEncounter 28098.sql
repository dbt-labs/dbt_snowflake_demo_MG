/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: EventAppointmentRequest
Description: Encounters exist which included no images, however some metrics go beyond imaging into appointment status.

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/

SELECT 
AppointmentRequestUnlinked.RequestID, 
AppointmentRequestUnlinked.LineNBR, 
AppointmentRequestUnlinked.CommunityPhysicalOwnerID, 
AppointmentRequestUnlinked.CommunityLogicalOwnerID, 
PatientEncounter.PatientEncounterID, 
AppointmentRequestUnlinked.UnlinkContactDTS, 
AppointmentRequestUnlinked.EDWLastModifiedDTS,
[Procedure].ProcedureDSC AS ProcedureNM
FROM   Epic.Orders.[Procedure]
LEFT JOIN Epic.Encounter.AppointmentRequestUnlinked
ON [Procedure].OrderProcedureID = AppointmentRequestUnlinked.RequestID 
LEFT JOIN  Epic.Encounter.PatientEncounter
ON AppointmentRequestUnlinked.PatientEncounterID = PatientEncounter.AppointmentSerialNBR
/* AppointmentSerialNBR is the initial appointment */
INNER JOIN SAM.EAMImaging.DomainResource
ON DomainResource.ResourceID = PatientEncounter.EncounterEpicProviderID
AND DomainResource.MetricInclusionFLG = 'Y'

/* Domain resource here means a machine */