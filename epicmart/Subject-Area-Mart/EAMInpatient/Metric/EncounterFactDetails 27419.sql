/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: EncounterFactDetails
Description: This binding calculates flags for encounters

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
20220607  bs234   169545  Adding flag for discharge metrics
20220609	cx127		169482  Pass through updates from EncounterFactStage. 
                          Add joins to EDVisitFactStage & TransferCenterTransferIn
                          Add columns IsBoarder & BoarderDurationInMinutes at this stage (previously added in InpatientEncounterDetail
20221130  KG312   !12451  Bring in EDDepartureDate                          
*********************************************************************************************************************************************************/
SELECT
	EncounterFactStage.PatientEncounterID
	,EncounterFactStage.PatientID
	,EncounterFactStage.IsDischargedFLG
	,CASE WHEN EncounterFactStage.IsDischargedFLG = 1 AND EncounterFactStage.DischargeDipositionExclusionFLG = 0 
		THEN 1
		ELSE 0 
		END AS IsEligibleDischargedFLG
  ,CASE WHEN EncounterFactStage.IsDischargedFLG = 1
    AND EncounterFactStage.DischargeDipositionExclusionFLG = 0
    AND EncounterFactStage.PatientClass IN('Inpatient', 'Observation', 'Post Procedure Recovery')
    AND EncounterFactStage.DischargeServiceGrouping IN('Medicine', 'Surgical')
    AND EncounterFactStage.DischargeLocationExclusionFLG = 0
    THEN 1
    ELSE 0
   END AS IsMedSurgEligiblePatientClassDischargedFLG
	,EncounterFactStage.DischargeInstant
	,EncounterFactStage.DischargeDeptId
	,EncounterFactStage.DischargeDept
	,EncounterFactStage.DischargeService
	,EncounterFactStage.DischargeServiceGrouping
	,CASE WHEN 
		EncounterFactStage.IsDischargedFLG = 1 AND EncounterFactStage.DischargeDipositionExclusionFLG = 0 
		THEN FORMAT(EncounterFactStage.DischargeInstant, 'HH:mm') 
		ELSE NULL END AS DischargeTime
	,CASE WHEN 
		EncounterFactStage.IsDischargedFLG = 1 AND EncounterFactStage.DischargeDipositionExclusionFLG = 0 
		THEN CAST(EncounterFactStage.DischargeInstant AS Date)
		ELSE NULL END AS DischargeDate
	,CASE WHEN EncounterFactStage.IsDischargedFLG = 1 AND EncounterFactStage.DischargeDipositionExclusionFLG = 0 
		THEN EncounterFactStage.PatientClass 
		ELSE NULL END AS DischargePatientClassDSC
	,EncounterFactStage.AdmitSourceCD	
	,EncounterFactStage.AdmitSourceDSC
	,CASE 
		WHEN EDVisitFactStage.ArrivedtoED = 1
			THEN 'ED'
		WHEN EncounterFactStage.UseTransferCenterModuleFLG = 0 AND EncounterFactStage.EAMTransferInFLG = 1
			THEN 'Transfer'
		WHEN EncounterFactStage.UseTransferCenterModuleFLG = 1 AND TransferCenterTransferIn.TransferCenterTransferInFLG = 1
			THEN 'Transfer'
		ELSE 'Other'
		END AS AdmitSourceGrouping
	,EncounterFactStage.AdmissionServiceGrouping
  ,EDVisitFactStage.EDArrivalDate
  ,EDVisitFactStage.IsBoarder
	,EDVisitFactStage.BoarderDurationInMinutes
  ,EDVisitFactStage.EDDepartureDate
FROM
	SAM.EAMInpatient.EncounterFactStage
	LEFT OUTER JOIN SAM.EAMInpatient.EDVisitFactStage
		ON EncounterFactStage.PatientEncounterID = EDVisitFactStage.PatientEncounterID
	LEFT OUTER JOIN SAM.EAMInpatient.TransferCenterTransferIn
		ON EncounterFactStage.PatientEncounterID = TransferCenterTransferIn.PatientEncounterID