/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: IncrementalHelper_PSYCHBOARDERS_DETAIL

Incremental logic is finalized here.

Date      User            ADO#    Description
20221025  Adam Proctor            Initial creation
*********************************************************************************************************************************************************/
SELECT
EncounterKey,
MAX(EDWLastModifiedDTS) AS EDWLastModifiedDTS
FROM
(
SELECT 
/* IP Psych Boarders */
PopulationPsychBoarders.EncounterKey
  ,(SELECT MAX(v) FROM (VALUES 
  (Departmentdim.EDWLastModifiedDTS), 
  (Department.EDWLastModifiedDTS), 
  (RevenueLocation.EDWLastModifiedDTS), 
  (ParentLocation.EDWLastModifiedDTS), 
  (MetricPCP_Psych.EDWLastModifiedDTS)
  ) AS VALUE(v) ) AS EDWLastModifiedDTS

FROM SAM.EAMBehavioral.PopulationPsychBoarders

LEFT JOIN EpicMart.Caboodle.DepartmentDim 
  ON PopulationPsychBoarders.DepartmentKey = DepartmentDim.DepartmentKey
INNER JOIN Epic.Reference.Department
  ON DepartmentDim.DepartmentEpicId = CAST(Department.DepartmentID AS VARCHAR(255))
LEFT OUTER JOIN Epic.Reference.[Location] RevenueLocation
  ON Department.RevenueLocationID = RevenueLocation.LocationID
LEFT OUTER JOIN Epic.Reference.[Location] ParentLocation
  ON RevenueLocation.ADTParentID = ParentLocation.LocationID
  
LEFT JOIN SAM.EAMBehavioral.MetricPCP_Psych
  ON MetricPCP_Psych.EncounterKey = PopulationPsychBoarders.EncounterKey
  
UNION

SELECT 
/* ED Psych Boarders */
EventEDPsychBoarders.EncounterKey
  ,(SELECT MAX(v) FROM (VALUES 
  (EventEDPsychBoarders.EDWLastModifiedDTS), 
  (DepartmentDim.EDWLastModifiedDTS), 
  (Department.EDWLastModifiedDTS), 
  (RevenueLocation.EDWLastModifiedDTS), 
  (ParentLocation.EDWLastModifiedDTS), 
  (MetricPCP_EDBoarders.EDWLastModifiedDTS), 
  (MetricCoverage_EDBoarders.EDWLastModifiedDTS)
  ) AS VALUE(v) ) AS EDWLastModifiedDTS

FROM SAM.EAMBehavioral.EventEDPsychBoarders

LEFT JOIN EpicMart.Caboodle.DepartmentDim 
  ON EventEDPsychBoarders.DepartmentKey = DepartmentDim.DepartmentKey
  INNER JOIN Epic.Reference.Department
  ON DepartmentDim.DepartmentEpicId = CAST(Department.DepartmentID AS VARCHAR(255))
  LEFT OUTER JOIN Epic.Reference.[Location] RevenueLocation
  ON Department.RevenueLocationID = RevenueLocation.LocationID
  LEFT OUTER JOIN Epic.Reference.[Location] ParentLocation
  ON RevenueLocation.ADTParentID = ParentLocation.LocationID
  
LEFT JOIN SAM.EAMBehavioral.MetricPCP_EDBoarders
  ON MetricPCP_EDBoarders.EncounterKey = EventEDPsychBoarders.EncounterKey

LEFT JOIN SAM.EAMBehavioral.MetricCoverage_EDBoarders
  ON MetricCoverage_EDBoarders.EncounterKey = EventEDPsychBoarders.EncounterKey
 ) MaximumColumn

GROUP BY EncounterKey