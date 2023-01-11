/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: IncrementalHelper_EMERGENCY_DETAIL

Incremental logic is finalized here.

Date      User            ADO#    Description
20221024  Adam Proctor            Initial creation
*********************************************************************************************************************************************************/
SELECT
EncounterKey,
MAX(EDWLastModifiedDTS) AS EDWLastModifiedDTS
FROM
(
SELECT 
PopulationEDVisit.EncounterKey
  ,(SELECT MAX(v) FROM (VALUES 
  (EventEDVisitFact.EDWLastModifiedDTS), 
  (Department.EDWLastModifiedDTS), 
  (RevenueLocation.EDWLastModifiedDTS), 
  (ParentLocation.EDWLastModifiedDTS), 
  (MetricCoverage_ED.EDWLastModifiedDTS), 
  (MetricPCP_ED.EDWLastModifiedDTS),
  (DepartmentDim.EDWLastModifiedDTS) 
  ) AS VALUE(v) ) AS EDWLastModifiedDTS
  
FROM SAM.EAMBehavioral.EventEDVisitFact
INNER JOIN SAM.EAMBehavioral.PopulationEDVisit
  ON PopulationEDVisit.EncounterKey = EventEDVisitFact.EncounterKey

LEFT JOIN EpicMart.Caboodle.DepartmentDim 
  ON EventEDVisitFact.EdDepartmentKey = DepartmentDim.DepartmentKey

INNER JOIN Epic.Reference.Department
  ON DepartmentDim.DepartmentEpicId = CAST(Department.DepartmentID AS VARCHAR(255))
LEFT OUTER JOIN Epic.Reference.[Location] RevenueLocation
  ON Department.RevenueLocationID = RevenueLocation.LocationID
LEFT OUTER JOIN Epic.Reference.[Location] ParentLocation
  ON RevenueLocation.ADTParentID = ParentLocation.LocationID
  
LEFT JOIN SAM.EAMBehavioral.MetricCoverage_ED
  ON MetricCoverage_ED.EncounterKey = EventEDVisitFact.EncounterKey
  
LEFT JOIN SAM.EAMBehavioral.MetricPCP_ED
  ON MetricPCP_ED.EncounterKey = EventEDVisitFact.EncounterKey
  
LEFT JOIN SAM.EAMBehavioral.MetricReAdmissions_ED
  ON MetricReAdmissions_ED.PatientDurableKey = EventEDVisitFact.PatientDurableKey
 AND MetricReAdmissions_ED.EncounterKey = EventEDVisitFact.EncounterKey
  ) MaximumColumn
  GROUP BY EncounterKey