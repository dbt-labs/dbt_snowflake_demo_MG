/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: PopulationLicensedBeds
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

/*******************
	LICENSED BEDS SECTION
	*********************/
	SELECT
		EventDepartments.DepartmentEpicId
		,EventDepartments.DepartmentName
		,ContactDateRealNBR
		,ContactDTS AS LicensedBedStartDTS
		,ISNULL(
			LAG(ContactDTS, 1) 
			OVER(PARTITION BY DepartmentHistory.DepartmentID 
			ORDER BY ContactDateRealNBR DESC)
			, CAST(GETDATE() AS DATE)
			) AS NextLicensedBedStartDTS
		,DepartmentHistory.LicensedBedCNT

	FROM 
		SAM.EAMBehavioral.EventDepartments 
		LEFT OUTER JOIN Epic.Reference.DepartmentHistory
			ON DepartmentHistory.DepartmentID = EventDepartments.DepartmentEpicId
			AND DepartmentHistory.ContactTypeCD = '7000'	/*ADT Info [7000]*/

	WHERE EXISTS  
	(
  SELECT 'Behavioral Health Departments'
    FROM SAM.EAMBehavioral.DomainConfiguration
   WHERE DomainConfiguration.ConfigurationItemDSC = 'DepartmentEpicId'
     AND DomainConfiguration.ConfigurationValueTXT = EventDepartments.DepartmentEpicId
  )
