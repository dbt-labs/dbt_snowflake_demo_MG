/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: IMAGING_ENCOUNTER_DETAIL_TBL
Description: Bring all necessary columns together for metric calculation and also for analysis.

According to the architectural pattern given as guidance, use data types that lend well to the cloud implementation.

This creates significant disagreement with the on-prem model and performance.

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
20221024  Adam Proctor    !12262  Change datatype on encounterkey to support incremental load performance
20221122  Adam Proctor    !12657  PatientClass mapping for encounter and image
*********************************************************************************************************************************************************/

SELECT 
CAST(EventEncounterFact.EncounterKey AS DECIMAL(28,0))                         AS PATIENT_ENCOUNTER_KEY,
CAST(EventEncounterFact.EncounterEpicCSN AS VARCHAR(300))                      AS PATIENT_ENCOUNTER_ID,
CAST(EventPatientEncounter.PatientID AS VARCHAR(300))                          AS PATIENT_ID,
CAST(EventPatient.PMRN  AS VARCHAR(300))                                       AS PATIENT_MRN_NBR,
EventEncounterFact.[Date]                                                      AS ENCOUNTER_DT,
CAST(EventEncounterFact.DerivedEncounterStatus AS VARCHAR(300))                AS ENCOUNTER_CALCULATED_STATUS_DSC,
CAST(EncounterMappedPatientClass.ConfigurationMappedValueTXT AS VARCHAR(300))  AS ENCOUNTER_PATIENT_CLASS_NM,
CAST(EventPatientEncounter.AppointmentStatusCD AS VARCHAR(300))                AS ENCOUNTER_STATUS_CD,
CAST(EventPatientEncounter.AppointmentStatusDSC AS VARCHAR(300))               AS ENCOUNTER_STATUS_DSC,
EventPatientEncounter.AppointmentCancelTimeDTS                                 AS ENCOUNTER_CANCELLED_DTS,
EventPatientEncounter.AppointmentDTS                                           AS ENCOUNTER_DTS,
CAST(MetricEncounterProcedureStatus.EncounterLabStatusCD AS VARCHAR(300))      AS ENCOUNTER_LAB_STATUS_CD,
CAST(EncounterDepartment.DepartmentID AS VARCHAR(300))                         AS ENCOUNTER_DEPARTMENT_ID,
CAST(EncounterDepartment.DepartmentName AS VARCHAR(300))                       AS ENCOUNTER_DEPARTMENT_NM,
CAST(EncounterDepartment.RevenueLocationID AS VARCHAR(300))                    AS ENCOUNTER_REVENUE_LOCATION_ID,
CAST(EncounterDepartment.RevenueLocationNM AS VARCHAR(300))                    AS ENCOUNTER_REVENUE_LOCATION_NM,
CAST(EncounterDepartment.HospitalParentLocationID AS VARCHAR(300))             AS ENCOUNTER_PARENT_LOCATION_ID,
CAST(EncounterDepartment.HospitalParentLocationNM AS VARCHAR(300))             AS ENCOUNTER_PARENT_LOCATION_NM,
CAST(EventPatientEncounter.EncounterEpicProviderID AS VARCHAR(300))            AS RESOURCE_ID,
CAST(DomainResource.ResourceNM AS VARCHAR(300))                                AS RESOURCE_NM,
CAST(DomainResource.ModalityDSC AS VARCHAR(300))                               AS MODALITY_DSC,
MetricEncounterImaging.[Date]                                                  AS EXAMINATION_DT,
MetricEncounterImaging.ExaminationTimeScheduledDTS                             AS EXAMINATION_DTS,
MetricEncounterImaging.ExaminationOrderDTS                                     AS EXAMINATION_ORDER_DTS,
MetricEncounterImaging.ExaminationCheckInInDTS                                 AS EXAMINATION_CHECKIN_DTS,
MetricEncounterImaging.ExaminationStartDTS                                     AS EXAMINATION_START_DTS,
MetricEncounterImaging.ExaminationFirstEndDTS                                  AS EXAMINATION_FIRST_END_DTS,
MetricEncounterImaging.ExaminationLastEndDTS                                   AS EXAMINATION_LAST_END_DTS,
MetricEncounterImaging.ExaminationPreliminaryReadDTS                           AS EXAMINATION_PRELIMINARY_READ_DTS,
MetricEncounterImaging.ExaminationFinalizingReadDTS                            AS EXAMINATION_FINAL_READ_DTS,
MetricEncounterImaging.ExaminationCancelledDTS                                 AS EXAMINATION_CANCELLED_DTS,
MetricEncounterImaging.ExaminationFinalFLG                                     AS EXAMINATION_FINAL_FLG,
MetricEncounterImaging.ExaminationReadDTS                                      AS EXAMINATION_CALCULATED_READ_DTS,
MetricEncounterImaging.ExaminationImagingCNT                                   AS EXAMINATION_IMAGING_CNT,
CAST(ExaminationMappedPatientClass.ConfigurationMappedValueTXT AS VARCHAR(300))AS EXAMINATION_PATIENT_CLASS_NM,
MetricEncounterImaging.ValidExamDurationFLG                                    AS EXAMINATION_DURATION_VALID_FLG,
CAST(ExamDepartment.DepartmentID AS VARCHAR(300))                              AS EXAMINATION_DEPARTMENT_ID,
CAST(ExamDepartment.DepartmentName AS VARCHAR(300))                            AS EXAMINATION_DEPARTMENT_NM,
CAST(ExamDepartment.RevenueLocationID AS VARCHAR(300))                         AS EXAMINATION_REVENUE_LOCATION_ID,
CAST(ExamDepartment.RevenueLocationNM AS VARCHAR(300))                         AS EXAMINATION_REVENUE_LOCATION_NM,
CAST(ExamDepartment.HospitalParentLocationID AS VARCHAR(300))                  AS EXAMINATION_PARENT_LOCATION_ID,
CAST(ExamDepartment.HospitalParentLocationNM AS VARCHAR(300))                  AS EXAMINATION_PARENT_LOCATION_NM,
IncrementalHelper_ENCOUNTER_DETAIL.EDWLastModifiedDTS                          AS EDW_LAST_MODIFIED_DTS

/* IsDeletedFLG: Planned to handle as soft deletions, so they will replicate, but will be marked as deleted.

However, in the full validation there were no records marked as deleted.
*/

FROM 
SAM.EAMImaging.PopulationEncounter
INNER JOIN SAM.EAMImaging.IncrementalHelper_ENCOUNTER_DETAIL
    ON PopulationEncounter.EncounterKey = IncrementalHelper_ENCOUNTER_DETAIL.EncounterKey
INNER JOIN SAM.EAMImaging.EventEncounterFact
    ON PopulationEncounter.EncounterKey = EventEncounterFact.EncounterKey
INNER JOIN SAM.EAMImaging.EventPatientEncounter
    ON PopulationEncounter.PatientEncounterID = EventPatientEncounter.PatientEncounterID
INNER JOIN SAM.EAMImaging.DomainResource
    ON DomainResource.ResourceID = EventPatientEncounter.EncounterEpicProviderID
INNER JOIN SAM.EAMImaging.EventPatient
    ON EventEncounterFact.PatientDurableKey = EventPatient.PatientDurableKey
LEFT OUTER JOIN SAM.EAMImaging.MetricEncounterImaging
    ON PopulationEncounter.EncounterKey = MetricEncounterImaging.PerformingEncounterKey
LEFT OUTER JOIN SAM.EAMImaging.MetricEncounterProcedureStatus
    ON PopulationEncounter.PatientEncounterID = MetricEncounterProcedureStatus.PatientEncounterID
LEFT OUTER  JOIN SAM.EAMImaging.RuleIncludeDepartment EncounterDepartment
    ON EventEncounterFact.DepartmentKey = EncounterDepartment.DepartmentKey
LEFT OUTER  JOIN SAM.EAMImaging.RuleIncludeDepartment ExamDepartment
    ON MetricEncounterImaging.ExaminationDepartmentKey = ExamDepartment.DepartmentKey
LEFT OUTER JOIN SAM.EAMImaging.DomainConfiguration EncounterMappedPatientClass
    ON EncounterMappedPatientClass.ConfigurationItemDSC = 'Patient Class Mapping'
    AND EncounterMappedPatientClass.ConfigurationColumnNM = 'PatientClass'
    AND EventEncounterFact.PatientClass = EncounterMappedPatientClass.ConfigurationValueTXT
LEFT OUTER JOIN SAM.EAMImaging.DomainConfiguration ExaminationMappedPatientClass
    ON ExaminationMappedPatientClass.ConfigurationItemDSC = 'Patient Class Mapping'
    AND ExaminationMappedPatientClass.ConfigurationColumnNM = 'PatientClass'
    AND MetricEncounterImaging.ExaminationPatientClass = ExaminationMappedPatientClass.ConfigurationValueTXT