/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: BedBlockAdded
Description: This binding collects all required bed block events that have been added

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
SELECT 
		RecordID
		,StatusCD
		,StatusDSC
		,StatusUpdateDTS
	FROM Epic.Encounter.BedBlockEvent
	WHERE StatusCD = 10 /*Added [10]*/
