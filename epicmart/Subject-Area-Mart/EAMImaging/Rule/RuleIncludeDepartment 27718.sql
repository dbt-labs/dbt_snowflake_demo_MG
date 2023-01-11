/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: RuleIncludeDepartment
Description: Department with its revenue location and parent location.

Originally copied from Carmin and Margaret's department binding.
Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/  
    SELECT
      DepartmentKey,
      DepartmentName,
      DepartmentEpicId AS DepartmentID,
      LocationEpicId AS RevenueLocationID,
	  LocationName AS RevenueLocationNM,
      ParentLocationEpicId as HospitalParentLocationID,
      ParentLocationName as HospitalParentLocationNM,(
        SELECT
          MAX(v)
        FROM
          (
            VALUES
              (EDWLastModifiedDTS)
          ) AS VALUE(v)
      ) AS EDWLastModifiedDTS
    FROM
      EpicMart.Caboodle.DepartmentDim