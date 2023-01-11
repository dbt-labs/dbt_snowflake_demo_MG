/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: LicensedBedDepartmentDate
Description: This binding crosses all collected licensed beds against relevant dates
History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
		SELECT 
			Dates.CalendarDate,	
			LicensedBedEvent.DepartmentID,
			LicensedBedEvent.LicensedBedStartDTS,
			LicensedBedEvent.NextLicensedBedStartDTS,
			LicensedBedCNT
		FROM SAM.EAMInpatient.LicensedBedEvent
		CROSS APPLY (
			SELECT 
				CalendarDate
			FROM 
				SAM.EAMInpatient.DateDimension
			WHERE 
				CalendarDateAt7AM >= LicensedBedStartDTS AND  CalendarDateAt7AM < NextLicensedBedStartDTS
			) AS Dates
