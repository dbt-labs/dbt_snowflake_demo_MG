/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: MetricEncounterProcedureStatus
Description: Wrap up linked and unlinked procedure status and order time into an encounter.

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/
SELECT PatientEncounterID,
 MAX(LabStatusCD) AS EncounterLabStatusCD,
 MIN(OrderTimeDTS) AS EncounterOrderDTS,
 MAX(EDWLastModifiedDTS) AS EDWLastModifiedDTS
 FROM
 (
SELECT
AppointmentRequestUnlinked.PatientEncounterID, LabStatusCD, OrderTimeDTS, EventOrdersProcedure.EDWLastModifiedDTS
FROM Epic.Encounter.AppointmentRequestUnlinked
INNER JOIN Epic.Orders.[Procedure] EventOrdersProcedure
ON AppointmentRequestUnlinked.RequestID = EventOrdersProcedure.OrderProcedureID 
INNER JOIN SAM.EAMImaging.PopulationEncounter
ON AppointmentRequestUnlinked.PatientEncounterID = PopulationEncounter.PatientEncounterID

UNION ALL

SELECT
PopulationEncounter.PatientEncounterID, LabStatusCD, OrderTimeDTS, EventOrdersProcedure.EDWLastModifiedDTS
FROM SAM.EAMImaging.EventImagingFact
INNER JOIN SAM.EAMImaging.PopulationImaging
ON EventImagingFact.ImagingKey = PopulationImaging.ImagingKey
INNER JOIN Epic.Orders.[Procedure] EventOrdersProcedure
ON EventImagingFact.ImagingOrderEpicId = EventOrdersProcedure.OrderProcedureID
INNER JOIN SAM.EAMImaging.PopulationEncounter
ON EventImagingFact.PerformingEncounterKey = PopulationEncounter.EncounterKey
) LinkedAndUnlinked

GROUP BY  PatientEncounterID