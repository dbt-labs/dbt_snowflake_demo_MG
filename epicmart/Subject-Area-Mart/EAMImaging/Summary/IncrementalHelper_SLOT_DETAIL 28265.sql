/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: IncrementalHelper_ENCOUNTER_DETAIL

Incremental logic is finalized here.

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
20221019  Adam Proctor    !12120  Table change of grain to 2 columns (slot begin and provider/resource)
*********************************************************************************************************************************************************/
SELECT
  SlotBeginDTS,
  ProviderID,
MAX(EDWLastModifiedDTS) AS EDWLastModifiedDTS
FROM
(
SELECT 
	EventAvailableUtilization.SlotBeginDTS,
	EventAvailableUtilization.ProviderID,
  (SELECT MAX(v) FROM (VALUES 
  (EventAvailableUtilization.EDWLastModifiedDTS), 
  (PatientEncounter.EDWLastModifiedDTS), 
  (Department.EDWLastModifiedDTS)
  ) AS VALUE(v) ) AS EDWLastModifiedDTS

FROM SAM.EAMImaging.EventAvailableUtilization
LEFT JOIN Epic.Encounter.PatientEncounter
	ON PatientEncounter.PatientEncounterID = EventAvailableUtilization.PatientEncounterID
LEFT JOIN Epic.Reference.Department
	ON EventAvailableUtilization.DepartmentID = Department.DepartmentID
LEFT JOIN Epic.Reference.[Location]
	ON Location.LocationID = Department.RevenueLocationID
LEFT JOIN Epic.Reference.[Location] ParentLocation
	ON Location.ADTParentID = ParentLocation.LocationID

WHERE SlotBeginDTS <= GETDATE()
    ) MaximumColumn
    
GROUP BY 
  SlotBeginDTS,
  ProviderID