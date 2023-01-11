/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: LicensedBedEvent
Description: This binding collects all licensed beds by department
History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
	SELECT
		Departments.DepartmentID
		,Departments.DepartmentNM
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
		SAM.EAMInpatient.Departments 
		LEFT OUTER JOIN Epic.Reference.DepartmentHistory
			ON DepartmentHistory.DepartmentID = Departments.DepartmentID
        AND Departments.RecordStatusCD IS NULL	/*Exclude Deleted Departments*/
			  AND DepartmentHistory.ContactTypeCD = '7000'	/*ADT Info [7000]*/
	WHERE
		/*Only include departments that are considered MedSurg or ICU for Licensed Bed Counts*/
		Departments.DepartmentIsICUFLG = 1
		OR Departments.DepartmentIsMedSurgFLG = 1