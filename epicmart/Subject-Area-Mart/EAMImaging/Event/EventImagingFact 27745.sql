/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: EventImagingFact
Description: Used instead of Caboodle ImagingFact but only for specified MRI and CT resources

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/

SELECT
ImagingFact.ImagingKey,
CAST(ImagingFact.ExamStartInstant AS DATE) AS [DATE],
ImagingFact.PatientKey,
ImagingFact.PerformingEncounterKey,
ImagingFact.PerformingDepartmentKey,
CAST(ImagingFact.AccessionNumber AS VARCHAR(255)) AS AccessionNumber,
ImagingFact.ImagingOrderEpicId,
ImagingFact.FirstProcedureDurableKey,
ProcedureDim.[Name] AS ProcedureName,
ImagingFact.FirstProcedureKey,
ImagingFact.ResourceKey,
CAST(ImagingFact.PatientClass AS VARCHAR(255)) AS PatientClass,
CAST(ImagingFact.BasePatientClass AS VARCHAR(255)) AS BasePatientClass,
ImagingFact.ScheduledExamInstant,
ImagingFact.OrderingInstant,
ImagingFact.CheckInInstant,
ImagingFact.ExamStartInstant,
ImagingFact.ExamEndInstant,
ImagingFact.PreliminaryInstant,
ImagingFact.FinalizingInstant,
ImagingFact.CancelingInstant,
CAST(ImagingFact.StudyStatus AS VARCHAR(255)) AS StudyStatus,
ImagingFact.[Count],
DomainResource.ModalityDSC,
ImagingFact.IsDeleted,
ImagingFact.EDWLastModifiedDTS
FROM EpicMart.Caboodle.ImagingFact
INNER JOIN EpicMart.Caboodle.ResourceDim
ON ResourceDIm.ResourceKey = ImagingFact.ResourceKey
INNER JOIN SAM.EAMImaging.DomainResource 
ON DomainResource.ResourceID = ResourceDim.ResourceEpicID
AND DomainResource.MetricInclusionFLG = 'Y'
LEFT JOIN EpicMart.Caboodle.ProcedureDim
ON ImagingFact.FirstProcedureKey = ProcedureDim.ProcedureKey
/* In our domain, there is only ever one procedure that needs joined */
WHERE
/* Universal Exclusions for Domain Build Requirements */
   ExamStartInstant IS NOT NULL
  AND ExamEndInstant IS NOT NULL
  AND ExamEndInstant > ExamStartInstant
  AND ExamEndInstant <> ExamStartInstant
  
	