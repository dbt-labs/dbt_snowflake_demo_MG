/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: BedBlockStage
Description: This binding determines the start and end windows for blocked beds within departments

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
	SELECT
		BedBlock.BedID
		,BedBlock.DepartmentID
		,BedBlockAdded.StatusUpdateDTS AS BedBlockAddedDTS
		,ISNULL(BedBlockRemoved.StatusUpdateDTS, CAST(GETDATE() AS DATE)) AS BedBlockRemovedDTS	/*If Bed Block is still active, populate the remove date with today's date*/
	FROM SAM.EAMInpatient.BedBlockAdded
	LEFT OUTER JOIN SAM.EAMInpatient.BedBlockRemoved 
		ON BedBlockAdded.RecordID = BedBlockRemoved.RecordID
	LEFT OUTER JOIN Epic.Encounter.BedBlock 
		ON BedBlockAdded.RecordID = BedBlock.RecordID
	LEFT OUTER JOIN SAM.EAMInpatient.Departments
		ON BedBlock.DepartmentID = Departments.DepartmentID
        AND Departments.RecordStatusCD IS NULL	/*Exclude Deleted Departments*/
	LEFT OUTER JOIN Epic.Reference.Bed
		ON BedBlock.BedID = Bed.BedID
		AND Bed.BedContactDateRealNBR = Bed.EndContactDateRealNBR 	/* The most recent contact date for the bed record*/
	WHERE
		/*Only include Blocks for Bed Records that are not Inactive - this is not tracked over time and is reflective of the Bed in the current state*/
		Bed.RecordStatusDSC IS NULL /* Active bed records have a value of NULL, alternative values are Deleted, Inactive, Inactive and Hidden */
		/*Only include departments that are considered MedSurg or ICU for Licensed Bed Counts*/
		AND ( Departments.DepartmentIsICUFLG = 1
			OR Departments.DepartmentIsMedSurgFLG = 1 )