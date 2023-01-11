/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: MetricBlockedBedsCount
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
	SELECT
			 PopulationBlockedBeds.CalendarDate
			,PopulationBlockedBeds.CalendarDateAt7AM
			,PopulationBlockedBeds.DepartmentID
			,COUNT(Distinct PopulationBlockedBeds.BedID)	AS BlockedBedAt7amCNT	
      /*there are occasionally overlapping Blocked Bed records, we only want to count the bed one time*/
		FROM
			SAM.EAMBehavioral.PopulationBlockedBeds
		GROUP BY
			 PopulationBlockedBeds.CalendarDate
			,PopulationBlockedBeds.CalendarDateAt7AM
			,PopulationBlockedBeds.DepartmentID