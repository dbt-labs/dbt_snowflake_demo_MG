/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: MetricLicensedBedCount
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
SELECT 
	Dates.CalendarDate,	
	PopulationLicensedBeds.DepartmentEpicId,
	PopulationLicensedBeds.DepartmentName,
	PopulationLicensedBeds.LicensedBedStartDTS,
	PopulationLicensedBeds.NextLicensedBedStartDTS,
	CASE 
		WHEN PopulationLicensedBeds.DepartmentEpicId = '10040010053' /* This department has a mix of Behavioral and non behavioral patients, 8 of which are behavioral */
		THEN 8
		ELSE PopulationLicensedBeds.LicensedBedCNT
	END												AS LicensedBedCNT

FROM SAM.EAMBehavioral.PopulationLicensedBeds
CROSS APPLY (
	SELECT 
		EventDateDimension.CalendarDate
	FROM 
		SAM.EAMBehavioral.EventDateDimension
	WHERE 
		EventDateDimension.CalendarDateAt7AM >= PopulationLicensedBeds.LicensedBedStartDTS AND EventDateDimension.CalendarDateAt7AM < PopulationLicensedBeds.NextLicensedBedStartDTS
	          ) AS Dates