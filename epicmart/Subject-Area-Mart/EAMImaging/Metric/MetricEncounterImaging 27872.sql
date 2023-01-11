/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: MetricEncounterImaging
Description: Wrap up all imaging into its encounter

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/
SELECT 	
  EventImagingFact.PerformingEncounterKey,
  MIN(EventImagingFact.ImagingKey) AS ReferenceImagingKey,
  MIN(EventImagingFact.PerformingDepartmentKey) AS ExaminationDepartmentKey,
  MIN(EventImagingFact.PatientClass) AS ExaminationPatientClass,
  MIN(PopulationEncounter.PatientEncounterID) AS PatientEncounterID,
  MIN(EventImagingFact.[Date]) AS [Date],
  MIN(EventImagingFact.CheckInInstant) AS ExaminationCheckInInDTS,
  MIN(EventImagingFact.ScheduledExamInstant) AS ExaminationTimeScheduledDTS,
  MIN(EventImagingFact.OrderingInstant) AS ExaminationOrderDTS,
	MIN(EventImagingFact.ExamStartInstant) AS ExaminationStartDTS,
  MIN(EventImagingFact.ExamEndInstant) AS ExaminationFirstEndDTS,
	MAX(EventImagingFact.ExamEndInstant) AS ExaminationLastEndDTS,
  MIN(EventImagingFact.CancelingInstant) AS ExaminationCancelledDTS,
  MIN(EventImagingFact.PreliminaryInstant) AS ExaminationPreliminaryReadDTS,
  MIN(EventImagingFact.FinalizingInstant) AS ExaminationFinalizingReadDTS,
  MIN(MetricRead.CalculatedReadDTS) AS ExaminationReadDTS,
  MIN(EventImagingFact.FirstProcedureKey) AS ReferenceProcedureKey,
  MAX(CASE WHEN EventImagingFact.StudyStatus = 'Final' THEN 1 ELSE NULL END) AS ExaminationFinalFLG,
  SUM(EventImagingFact.[Count]) as ExaminationImagingCNT,
  CASE  
		WHEN MIN(EventImagingFact.ModalityDSC) = 'Computed Tomography'
		and DATEDIFF(MINUTE, MIN(EventImagingFact.ExamStartInstant), MAX(EventImagingFact.ExamEndInstant)) > 30
			THEN 0
		WHEN MIN(EventImagingFact.ModalityDSC) = 'Magnetic Resonance'
		and DATEDIFF(MINUTE, MIN(EventImagingFact.ExamStartInstant), MAX(EventImagingFact.ExamEndInstant)) > 120
			THEN 0
		ELSE 1
	END AS 'ValidExamDurationFLG',
  MAX(EventImagingFact.EDWLastModifiedDTS) EDWLastModifiedDTS

FROM  SAM.EAMImaging.PopulationEncounter
INNER JOIN SAM.EAMImaging.EventImagingFact
ON PopulationEncounter.EncounterKey = EventImagingFact.PerformingEncounterKey 
INNER JOIN SAM.EAMImaging.PopulationImaging
ON EventImagingFact.ImagingKey = PopulationImaging.ImagingKey
LEFT JOIN SAM.EAMImaging.MetricRead
ON EventImagingFact.ImagingKey = MetricRead.ImagingKey

GROUP BY EventImagingFact.PerformingEncounterKey