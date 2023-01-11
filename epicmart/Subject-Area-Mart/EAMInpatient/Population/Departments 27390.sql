/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: Departments
Description: This binding collects all relevant department attributes

History:

Date		  User		 TFS#	  Description
20220502	ms2			164957  Initial script creation
20220602  bs234   169071  Added exclusion flag
20220609	cx127		169482	Added TransferCenterModuleStartDTS
20220725  jj1068          Excluded specialty departments via configuration table and NOT EXISTS
20220726  Adam Proctor    Removed BWF reference to transfer center.
*********************************************************************************************************************************************************/
SELECT
		Department.DepartmentID, 
		Department.DepartmentNM, 
		Department.RevenueLocationID, 
		Location.RevenueLocationNM,
		ParentLocation.LocationID as HospitalParentLocationID,
		ParentLocation.RevenueLocationNM as HospitalParentLocationNM,	/*this is the version we will use in reporting on the dashboard*/
		Department.ReportGrouper10CD,
		Department.ReportGrouper10DSC,
		Department4.LevelOfCareGrouperCD,
        Department4.LevelOfCareGrouperDSC,
		CASE WHEN Department.ReportGrouper10CD ='100003' /*Inpatient-ICU*/
		and Department4.LevelOfCareGrouperCD ='103'/*Critical care*/
		and Department.DepartmentSpecialtyCD <> '110' /*Pediatric Intensive Care*/
			THEN 1
			ELSE 0
			END AS DepartmentIsICUFLG,
		CASE WHEN Department.ReportGrouper10CD IN ('100004' /*Inpatient-Medical*/ , '100005' /*Inpatient-Surgical*/)
		and Department4.LevelOfCareGrouperCD ='101'/*Acute*/
		and Department.DepartmentSpecialtyCD <> '32' /*Pediatrics*/
			THEN 1
			ELSE 0
			END AS DepartmentIsMedSurgFLG,
		CASE WHEN Department4.LevelOfCareGrouperCD NOT IN 
		/*This might be refined based on business definitions to include more departments.*/
		/*It should also include Urgent Care (doesn’t exist yet, but it will)*/
			(114 /*Procedural*/
			,117 /*Not Applicable*/
			,109 /*Research*/
			,113 /*Virtual*/
			)
			THEN 1
			ELSE 0
			END AS InpatientDepartmentInclusionFLG,
			Department.ServiceAreaID,
      Department.RecordStatusCD,
	  CASE
		  WHEN DepartmentExclusionConfiguration.CD IS NOT NULL THEN 1
		  ELSE 0
	    END AS LocationExclusionFLG,

	  CASE 
      WHEN ParentLocation.LocationID = '1002999'	/*MGH Parent [1002999]*/
			  THEN '8/12/2019'
		  WHEN ParentLocation.LocationID = '1003999'	/*BWH Parent [1003999]*/
			  THEN '6/22/2020'
    /* BWF was incorrect here and removed */
		  WHEN ParentLocation.LocationID = '1005999'	/*SLM (NSM) Parent [1005999]*/
			  THEN '3/1/2022'
		  WHEN ParentLocation.LocationID = '1001999'	/*NWH Parent [1001999]*/
			  THEN '3/14/2022'
		  ELSE NULL
		  END AS TransferCenterModuleStartDTS,
      /* For validation */
      Department.DepartmentSpecialtyCD
  FROM  
		/*alternative option to use EpicMart.Curated tables: DepartmentDim, DepartmentDimExtensionGroupers ,RevenueLocationDim, HospitalParentLocationDim*/
		Epic.Reference.Department
		/*removing the Department42CFR piece because we don't need to report the department names in the dashboard, so the masked names should be a non-issue*/
		LEFT JOIN Epic.Reference.Location
			ON Location.LocationID = Department.RevenueLocationID
		LEFT JOIN Epic.Reference.Department4
			ON	Department4.DepartmentID = Department.DepartmentID
		LEFT JOIN Epic.Reference.Location ParentLocation
			ON Location.ADTParentID = ParentLocation.LocationID
		LEFT JOIN SAM.EAMInpatient.Configuration DepartmentExclusionConfiguration
			ON Department.RevenueLocationID = DepartmentExclusionConfiguration.CD
			AND DepartmentExclusionConfiguration.ConfigurationDSC = 'DepartmentExclusion'
    WHERE NOT EXISTS
    (SELECT 'Domain Specialty Exclusion'
    FROM  SAM.EAMInpatient.[Configuration]
    WHERE Department.DepartmentSpecialtyCD = [Configuration].CD
    AND [Configuration].ConfigurationDSC = 'DepartmentSpecialtyExclusion')    

