/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: OccupancyDepartmentList
Description: This binding collects all departments to be included in 7am Census

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
SELECT 
		DepartmentID
	FROM
		SAM.EAMInpatient.DepartmentDay7amCensus
	UNION
	/*Our Denominator needs to include all departments that meet the "MedSurg" or "ICU" Department definition*/
	SELECT 
		DepartmentID
	FROM
		SAM.EAMInpatient.Departments
	WHERE 
		DepartmentIsICUFLG = 1
		or DepartmentIsMedSurgFLG = 1