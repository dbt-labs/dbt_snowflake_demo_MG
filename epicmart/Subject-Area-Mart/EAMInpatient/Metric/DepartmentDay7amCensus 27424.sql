/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: DepartmentDay7amCensus
Description: This binding creates a flag to indicate occupancy at 7am
History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
	SELECT
			CalendarDate
			,CalendarDateAt7AM
			,DepartmentID
			,SUM(OccupiedAt7amFLG)	AS OccupiedAt7amCNT
		FROM
			SAM.EAMInpatient.DailyOccupancyAt7am
		GROUP BY
			CalendarDate
			,CalendarDateAt7AM
			,DepartmentID
