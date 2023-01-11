/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: EncounterFactStage
Description: This binding joins ADT events to encounters

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
20220502	bs234		169545  Added DischargeLocationExclusionFLG
20220609	cx127		169482	Remove EDVisitFact join and columns - will be added at later stage
                          Remove AdmitSourceGrouping - will be added with new logic at a later stage
                          Add EAMTransferInFLG to contribute to AdmitSourceGrouping logic at a later stage		
                          Add UseTransferCenterModuleFLG to identify if encounter is eligible to use the Transfer Center module
                          Add EncounterKey to utilize in TransferCenter binding
*********************************************************************************************************************************************************/
	SELECT 
  DISTINCT
     MedSurgAdmissionEncounter.PatientEncounterID
    ,EncounterFact.EncounterKey
		,EncounterFact.DischargeInstant
		,CASE 
			WHEN EncounterFact.DischargeInstant IS NOT NULL
				THEN 1
			ELSE 0
			END AS IsDischargedFLG
		,PatientEncounterHospital.PatientId
		,EncounterFact.PatientClass
		,PatientEncounterHospital.DepartmentID AS DischargeDeptId
		,PatientEncounterHospital.DepartmentDSC AS DischargeDept
		,PatientEncounterHospital.HospitalServiceCD AS DischargeService
    ,Departments.LocationExclusionFLG AS DischargeLocationExclusionFLG
		,CASE 
			WHEN PatientEncounterHospital.DischargeDispositionCD IN (
					'7'
					,'20'
					) /*Left Against Medical Advice [7], Expired [20] */
				THEN 1
			ELSE 0
			END AS DischargeDipositionExclusionFLG
		,PatientEncounterHospital.AdmitSourceCD
		,PatientEncounterHospital.AdmitSourceDSC
    ,CASE 
			WHEN TransferInConfiguration.CD IS NOT NULL
				THEN 1
			ELSE 0
			END AS EAMTransferInFLG
		,CASE 
			WHEN MedSurgAdmissionEncounter.EffectiveDTS >= Departments.TransferCenterModuleStartDTS
				THEN 1
			ELSE 0
			END AS UseTransferCenterModuleFLG
		,MedSurgAdmissionEncounter.EAMServiceGrouping AS  AdmissionServiceGrouping
		,HospitalServiceGroupDim.HospitalServiceGroupName AS DischargeServiceGrouping
		,ADTSummary.ObservationEventMinutesNBR
		,ADTSummary.PostProcedureRecoveryEventMinutesNBR
		,ADTSummary.ObservationPatientClassFLG
		,ADTSummary.PostProcedureRecoveryPatientClassFLG
	FROM SAM.EAMInpatient.ADTSource MedSurgAdmissionEncounter
	INNER JOIN EpicMart.Caboodle.EncounterFact ON MedSurgAdmissionEncounter.PatientEncounterID = EncounterFact.EncounterEpicCsn
	INNER JOIN Epic.Encounter.PatientEncounterHospital ON MedSurgAdmissionEncounter.PatientEncounterID = PatientEncounterHospital.PatientEncounterID
	LEFT JOIN SAM.EAMInpatient.ADTSummary ON ADTSummary.PatientEncounterID = MedSurgAdmissionEncounter.PatientEncounterID
	INNER JOIN EpicMart.Curated.HospitalServiceGroupFact ON HospitalServiceGroupFact.HospitalServiceEpicId = PatientEncounterHospital.HospitalServiceCD
	INNER JOIN EpicMart.Curated.HospitalServiceGroupDim ON HospitalServiceGroupDim.HospitalServiceGroupKey = HospitalServiceGroupFact.HospitalServiceGroupKey
	  AND HospitalServiceGroupDim.HospitalServiceGroupTypeId = 14 /* EAM MedSurg grouping */
  LEFT JOIN SAM.EAMInpatient.Departments ON PatientEncounterHospital.DepartmentID = Departments.DepartmentID
  LEFT JOIN SAM.EAMInpatient.Configuration TransferInConfiguration ON PatientEncounterHospital.AdmitSourceCD = TransferInConfiguration.CD
    AND TransferInConfiguration.ConfigurationDSC = 'TransferIn'
  WHERE MedSurgAdmissionEncounter.IsFirstQualifyingAdmitEvent = 1