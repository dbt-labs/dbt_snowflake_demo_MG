/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: EventDepartments
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT DISTINCT
	DepartmentDim.DepartmentEpicId
	,CASE WHEN DepartmentDim.DepartmentName = 'UNSPECIFIED DEPARTMENT'
	      THEN CAST(Department42CFR.DepartmentNM AS varchar(255))
	      ELSE CAST(DepartmentDim.DepartmentName AS varchar(255))
	  END       AS DepartmentName
	,DepartmentDim.ServiceAreaEpicId
	,CAST(DepartmentDim.DepartmentSpecialty AS varchar(255)) AS DepartmentSpecialty
	,DepartmentDim.DepartmentLevelOfCareGrouper
  ,DepartmentDim.LocationEpicId AS RevenueLocationID
	,DepartmentDim.LocationName AS RevenueLocationNM
	,DepartmentDim.ParentLocationEpicId AS HospitalParentLocationID
	,DepartmentDim.ParentLocationName AS HospitalParentLocationNM
	,DepartmentDim.DepartmentKey
  ,(SELECT MAX(v) FROM (VALUES 
		(DepartmentDim.EDWLastModifiedDTS), 
		(Department42CFR.EDWLastModifiedDTS) 
		) AS VALUE(v) ) AS EDWLastModifiedDTS 
FROM EpicMart.Caboodle.DepartmentDim 
LEFT OUTER JOIN Epic.Reference.Department42CFR ON
	Department42CFR.DepartmentID = DepartmentDim.DepartmentEpicId
WHERE DepartmentDim.IsDepartment <> '0'


	