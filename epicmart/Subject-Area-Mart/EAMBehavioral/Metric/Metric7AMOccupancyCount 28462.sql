/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: Metric7AMOccupancyCount
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
SELECT
			 Population7AMCensus.CalendarDate
			,Population7AMCensus.CalendarDateAt7AM
			,Population7AMCensus.DepartmentID
			,SUM(Population7AMCensus.OccupiedAt7amFLG)	AS OccupiedAt7amCNT
      ,MAX(Population7AMCensus.EDWLastModifiedDTS) AS EDWLastModifiedDTS
		FROM
			SAM.EAMBehavioral.Population7AMCensus
		GROUP BY
			 Population7AMCensus.CalendarDate
			,Population7AMCensus.CalendarDateAt7AM
			,Population7AMCensus.DepartmentID