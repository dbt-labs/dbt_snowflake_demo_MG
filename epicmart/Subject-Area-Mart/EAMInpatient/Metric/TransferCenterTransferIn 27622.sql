/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: TransferCenterTransferIn
Description: This binding joins to Transfer Center to identify Transfer In encounters to contribute to Admission Source dimension
			 This logic aligns with the approach taken for ED Domain

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220609	cx127	  169482  New binding to source data needed from TransferCenterRequestFact for metrics overlapping domains
*********************************************************************************************************************************************************/
	SELECT 
		 EncounterFactStage.PatientEncounterID
		,MAX(TransferCenterRequestFact.IsIncludedInCompletedVolume) AS TransferCenterTransferInFLG
	FROM SAM.EAMInpatient.EncounterFactStage EncounterFactStage
		INNER JOIN EpicMart.Curated.TransferCenterRequestFact 
			ON EncounterFactStage.EncounterKey = TransferCenterRequestFact.ResultantEncounterKey
	WHERE 
		TransferCenterRequestFact.IsIncludedInRequestVolume = 1	
		AND	TransferCenterRequestFact.IsIncludedInCompletedVolume = 1
	GROUP BY 
		EncounterFactStage.PatientEncounterID