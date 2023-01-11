/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: LastDate
Description: This binding calculates the last date to use wherever a date range is needed

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220518	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
SELECT
	MAX(CalendarDate) AS LastDate
FROM SAM.EAMInpatient.DailyOccupancyAt7am