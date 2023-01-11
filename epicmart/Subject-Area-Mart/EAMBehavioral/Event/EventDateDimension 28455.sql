/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: EventDateDimension
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT 
		CAST(CalendarDTS AS DATE) AS CalendarDate
		,DATEADD(HOUR, 7, CalendarDTS) AS CalendarDateAt7AM
	  FROM 
		Epic.Reference.DateDimension
	 
	 WHERE CalendarDTS >= (SELECT MIN(EffectiveDTS) FROM SAM.EAMBehavioral.EventADTRecords)
	   AND CalendarDTS <= GETDATE()
     