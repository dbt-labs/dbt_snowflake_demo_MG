/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: BedBlockRemoved
Description: This binding collects all required bed block events that have been removed

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
	SELECT 
		RecordID
		,StatusUpdateDTS
	FROM Epic.Encounter.BedBlockEvent
	WHERE StatusCD = 11 /*Removed [11]*/