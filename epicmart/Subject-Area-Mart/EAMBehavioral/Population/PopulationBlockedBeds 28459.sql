/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: PopulationBlockedBeds
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

WITH BedBlockAdded AS
(
	SELECT 
		RecordID
		,StatusCD
		,StatusDSC
		,StatusUpdateDTS
	FROM Epic.Encounter.BedBlockEvent
	WHERE StatusCD = 10 /*Added [10]*/
)

,BedBlockRemoved AS
(
	/* FIND ALL BLOCKED BEDS REMOVED */
	SELECT 
		RecordID
		,StatusUpdateDTS
	FROM Epic.Encounter.BedBlockEvent
	WHERE StatusCD = 11 /*Removed [11]*/
)

,BedBlockStaging AS
(
	/* COMBINE BLOCKS ADDED AND BLOCKS REMOVED	*/
	SELECT
		BedBlock.BedID
		,BedBlock.DepartmentID
		,BedBlockAdded.StatusUpdateDTS AS BedBlockAddedDTS
		,ISNULL(BedBlockRemoved.StatusUpdateDTS, CAST(GETDATE() AS DATE)) AS BedBlockRemovedDTS	/*If Bed Block is still active, populate the remove date with today's date*/

	FROM BedBlockAdded
	LEFT OUTER JOIN BedBlockRemoved 
		ON BedBlockAdded.RecordID = BedBlockRemoved.RecordID
	LEFT OUTER JOIN Epic.Encounter.BedBlock 
		ON BedBlockAdded.RecordID = BedBlock.RecordID
	LEFT OUTER JOIN Epic.Reference.Bed
		ON BedBlock.BedID = Bed.BedID
		AND Bed.BedContactDateRealNBR = Bed.EndContactDateRealNBR 	/* The most recent contact date for the bed record*/
	WHERE 1=1
		/*Only include Blocks for Bed Records that are not Inactive - this is not tracked over time and is reflective of the Bed in the current state*/
		AND Bed.RecordStatusDSC IS NULL /* Active bed records have a value of NULL, alternative values are Deleted, Inactive, Inactive and Hidden */
		AND EXISTS  
	(
  SELECT 'Behavioral Health Departments'
    FROM SAM.EAMBehavioral.DomainConfiguration
   WHERE DomainConfiguration.ConfigurationItemDSC = 'DepartmentEpicId'
     AND DomainConfiguration.ConfigurationValueTXT = BedBlock.DepartmentID
	)
)

	/*BREAK OUT ALL THE BLOCKS INTO CALENDAR DAYS
		Need to find out on every calendar date at 7am if the bed is blocked
		want to get to a "BlockedBedAt7amFLG"
	*/

		SELECT 
			Dates.CalendarDate,	
			Dates.CalendarDateAt7AM,
			BedBlockStaging.BedID,
			BedBlockStaging.DepartmentID,
			BedBlockStaging.BedBlockAddedDTS,
			BedBlockStaging.BedBlockRemovedDTS,
			1 AS BlockedBedAt7amFLG
		FROM BedBlockStaging
		CROSS APPLY (
			SELECT 
				EventDateDimension.CalendarDate
				,EventDateDimension.CalendarDateAt7AM
			FROM 
				SAM.EAMBehavioral.EventDateDimension
			WHERE 
				EventDateDimension.CalendarDateAt7AM >= BedBlockStaging.BedBlockAddedDTS AND  EventDateDimension.CalendarDateAt7AM < BedBlockStaging.BedBlockRemovedDTS
			) AS Dates