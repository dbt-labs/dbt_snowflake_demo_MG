/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: BedBlocksDateStage
Description: This binding crosses all bed blocks across all dates to give one row per date/bed block

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
		SELECT 
			Dates.CalendarDate,	
			Dates.CalendarDateAt7AM,
			BedBlocksStage.BedID,
			BedBlocksStage.DepartmentID,
			BedBlocksStage.BedBlockAddedDTS,
			BedBlocksStage.BedBlockRemovedDTS,
			1 AS BlockedBedAt7amFLG
		FROM SAM.EAMInpatient.BedBlocksStage
		CROSS APPLY (
			SELECT 
				CalendarDate
				,CalendarDateAt7AM
			FROM 
				SAM.EAMInpatient.DateDimension
			WHERE 
				CalendarDateAt7AM >= BedBlockAddedDTS AND  CalendarDateAt7AM < BedBlockRemovedDTS
			) AS Dates