	/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: DateDimension
Description: This binding provides the framework used in spreading census across all dates

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
SELECT 
		CAST(CalendarDTS AS DATE) AS CalendarDate
		,DATEADD(HOUR, 7, CalendarDTS) AS CalendarDateAt7AM
	FROM 
		Epic.Reference.DateDimension

