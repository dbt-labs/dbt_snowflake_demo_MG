/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: IncrementalHelper_ENCOUNTER_DETAIL

Incremental logic is finalized here.

Note the RuleIncludeDepartment us causing full load behavior, as the Rule currently depends on a full load table

For enhancement: consider department hierarchy.

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/
SELECT
EncounterKey, 
MAX(EDWLastModifiedDTS) AS EDWLastModifiedDTS
FROM
(
SELECT 
EventEncounterFact.EncounterKey
  ,(SELECT MAX(v) FROM (VALUES 
  (EventEncounterFact.EDWLastModifiedDTS), 
  (EventPatientEncounter.EDWLastModifiedDTS), 
  (EventPatient.EDWLastModifiedDTS),
  (MetricEncounterImaging.EDWLastModifiedDTS), 
  (MetricEncounterProcedureStatus.EDWLastModifiedDTS), 
  (EncounterDepartment.EDWLastModifiedDTS),
   (ExamDepartment.EDWLastModifiedDTS) 
  ) AS VALUE(v) ) AS EDWLastModifiedDTS

FROM 
SAM.EAMImaging.PopulationEncounter 
LEFT OUTER JOIN SAM.EAMImaging.EventEncounterFact
    ON PopulationEncounter.EncounterKey = EventEncounterFact.EncounterKey
LEFT OUTER JOIN SAM.EAMImaging.EventPatientEncounter
    ON PopulationEncounter.PatientEncounterID = EventPatientEncounter.PatientEncounterID
LEFT OUTER JOIN SAM.EAMImaging.DomainResource
    ON DomainResource.ResourceID = EventPatientEncounter.EncounterEpicProviderID
LEFT OUTER JOIN SAM.EAMImaging.EventPatient
    ON EventEncounterFact.PatientDurableKey = EventPatient.PatientDurableKey
LEFT OUTER JOIN SAM.EAMImaging.MetricEncounterImaging
    ON PopulationEncounter.EncounterKey = MetricEncounterImaging.PerformingEncounterKey
LEFT OUTER JOIN SAM.EAMImaging.MetricEncounterProcedureStatus
    ON PopulationEncounter.PatientEncounterID = MetricEncounterProcedureStatus.PatientEncounterID
LEFT OUTER  JOIN SAM.EAMImaging.RuleIncludeDepartment EncounterDepartment
    ON EventEncounterFact.DepartmentKey = EncounterDepartment.DepartmentKey
LEFT OUTER  JOIN SAM.EAMImaging.RuleIncludeDepartment ExamDepartment
    ON MetricEncounterImaging.ExaminationDepartmentKey = ExamDepartment.DepartmentKey
    ) MaximumColumn

GROUP BY EncounterKey