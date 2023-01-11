/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: IncrementalHelper_INPATIENT_DETAIL

Incremental logic is finalized here.

Date      User            ADO#    Description
20221025  Adam Proctor            Initial creation
*********************************************************************************************************************************************************/
select
EncounterKey,
MAX(EDWLastModifiedDTS) AS EDWLastModifiedDTS
FROM
(
SELECT 
EventIPVisitFact.EncounterKey
  ,(SELECT MAX(v) FROM (VALUES 
  (EventIPVisitFact.EDWLastModifiedDTS), 
  (Department.EDWLastModifiedDTS), 
  (RevenueLocation.EDWLastModifiedDTS), 
  (ParentLocation.EDWLastModifiedDTS), 
  (EventOrders.EDWLastModifiedDTS), 
  (MetricCoverage_IP.EDWLastModifiedDTS),
  (MetricPCP_IP.EDWLastModifiedDTS) 
  ) AS VALUE(v) ) AS EDWLastModifiedDTS

FROM SAM.EAMBehavioral.EventIPVisitFact
 
INNER JOIN Epic.Reference.Department
  ON CAST(Department.DepartmentID AS VARCHAR(255)) = EventIPVisitFact.DepartmentEpicId

LEFT OUTER JOIN Epic.Reference.[Location] RevenueLocation
  ON Department.RevenueLocationID = RevenueLocation.LocationID

LEFT OUTER JOIN Epic.Reference.[Location] ParentLocation
  ON RevenueLocation.ADTParentID = ParentLocation.LocationID
  
LEFT OUTER JOIN SAM.EAMBehavioral.EventOrders
  ON EventOrders.EncounterKey = EventIPVisitFact.EncounterKey
  
LEFT JOIN SAM.EAMBehavioral.MetricCoverage_IP
  ON MetricCoverage_IP.EncounterKey = EventIPVisitFact.EncounterKey
  
LEFT JOIN SAM.EAMBehavioral.MetricPCP_IP
  ON MetricPCP_IP.EncounterKey = EventIPVisitFact.EncounterKey
  
LEFT JOIN SAM.EAMBehavioral.MetricReAdmissions_IP
  ON MetricReAdmissions_IP.InpatientPatientDurableKey = EventIPVisitFact.PatientDurableKey
 AND MetricReAdmissions_IP.InpatientEncounterKey = EventIPVisitFact.EncounterKey
 ) MaximumColumn
  GROUP BY EncounterKey