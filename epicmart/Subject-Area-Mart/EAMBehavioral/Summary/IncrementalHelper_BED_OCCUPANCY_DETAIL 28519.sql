/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: IncrementalHelper_BED_OCCUPANCY_DETAIL

Incremental logic is finalized here.

Date      User            ADO#    Description
20221025  Adam Proctor            Initial creation
*********************************************************************************************************************************************************/

SELECT 
	  EventDepartments.DepartmentEpicId AS DepartmentID
	  ,GETDATE() AS EDWLastModifiedDTS
  FROM SAM.EAMBehavioral.EventDepartments
    /* INNER JOIN
    A technically perfect incremental helper would look at occupancy, licensed beds, and blocked beds
    These lineages do not currently support an EDWLastModifiedDTS   
    */