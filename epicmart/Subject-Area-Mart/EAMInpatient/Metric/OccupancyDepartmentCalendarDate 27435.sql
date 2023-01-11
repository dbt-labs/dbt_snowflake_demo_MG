/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: OccupancyDepartmentCalendarDate
Description: This binding crosses all collected department occupancy against relevant dates

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
20220602	bs234		169071  Added department exclusion
*********************************************************************************************************************************************************/
		SELECT 
			Dates.CalendarDate
			,OccupancyDepartmentList.DepartmentID
			,Departments.DepartmentNM
			,Departments.RevenueLocationID
			,Departments.RevenueLocationNM
			,Departments.HospitalParentLocationID
			,Departments.HospitalParentLocationNM	/*this is the version we will use in reporting on the dashboard*/
			,Departments.ReportGrouper10CD
			,Departments.ReportGrouper10DSC
			,CASE WHEN Departments.DepartmentIsICUFLG =1 THEN 'ICU'
					WHEN Departments.DepartmentIsMedSurgFLG =1 THEN 'MedSurg'
					ELSE NULL
					END AS 'NewMedSurgICUFlg'
			,Departments.ServiceAreaID
		FROM
			SAM.EAMInpatient.OccupancyDepartmentList
			INNER JOIN SAM.EAMInpatient.Departments
				ON OccupancyDepartmentList.DepartmentID = Departments.DepartmentID
			CROSS APPLY (
					SELECT 
						CalendarDate
					FROM 
						SAM.EAMInpatient.DateDimension
					WHERE CalendarDate >= (SELECT FirstDate FROM SAM.EAMInpatient.FirstDate) 
                AND CalendarDate <= (SELECT LastDate FROM SAM.EAMInpatient.LastDate) 
					) AS Dates
    WHERE
      Departments.LocationExclusionFLG = 0