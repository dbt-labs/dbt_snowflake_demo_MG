/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: BedBlocksDepartmentDate
Description: This binding counts all blocked beds by department and date

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
		SELECT
			CalendarDate
			,CalendarDateAt7AM
			,DepartmentID
			,COUNT(Distinct BedID)	AS BlockedBedAt7amCNT	/*there are occasionally overlapping Blocked Bed records, we only want to count the bed one time*/
		FROM
			SAM.EAMInpatient.BedBLocksDateStage
		GROUP BY
			CalendarDate
			,CalendarDateAt7AM
			,DepartmentID
