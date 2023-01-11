/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: InpatientEncounterDetail
Description: This binding filters encounters to those with MedSurg qualifying events and adds department and encounter details.

History:

Date		  User		 TFS#	  Description
20220502	ms2			164957  Initial script creation
20220516  bs234   164706  added ED arrival fiscal year
20220622  bs234   169071  Added department exclusion
20220607  bs234   169545  Adding flag for discharge metrics and department exclusion to a flag to be used in later bindings
20220609	cx127		169482	Remove join from EDVisitFact and source columns from EncounterFactDetails
20220728  Adam Proctor    Left join on department changed to inner join in order to apply specialty exclusions downstream.
20221130  KG312   !12451  Bring in EDDepartureDate
*********************************************************************************************************************************************************/
SELECT
	ADTSource.PatientEncounterID
	,ADTSource.PatientID
	,ADTSource.EffectiveDTS	
	,CAST(ADTSource.EffectiveDTS AS date) AS AdmissionCalendarDate	
  ,AdmitDateDim.FiscalYear AS AdmissionFiscalYearNBR
	,ADTSource.DepartmentID AS AdmissionDepartmentID
	,Departments.DepartmentNM
	,Departments.RevenueLocationID
	,Departments.RevenueLocationNM
	,Departments.HospitalParentLocationID
	,Departments.HospitalParentLocationNM
	,ADTSource.PatientClassCD AS AdmissionPatientClassCD	
	,ADTSource.PatientClassDSC AS AdmissionPatientClassDSC	
	,ADTSource.PatientServiceCD AS AdmissionPatientServiceCD	
	,ADTSource.PatientServiceDSC AS AdmissionPatientServiceDSC
	,ADTSource.EAMServiceGrouping AS AdmissionServiceGrouping
	,ADTSource.IsFirstQualifyingAdmitEvent AS MedSurgAdmissionFLG
	,ADTSummary.InpatientCensusPatientServiceCD
	,ADTSummary.InpatientCensusPatientServiceDSC
	,ADTSummary.InpatientCensusServiceGrouping
	,ADTSummary.IsInpatientCensusEncounter
	,ADTSummary.InpatientPatientClassFLG
	,ADTSummary.InpatientCensusDaysCNT 
	,ADTSummary.ObservationPatientClassFLG
	,ADTSummary.ObservationEventMinutesNBR
	,ADTSummary.ObservationPatientServiceGrouping
	,ADTSummary.PostProcedureRecoveryPatientClassFLG
	,ADTSummary.PostProcedureRecoveryEventMinutesNBR
	,ADTSummary.PostProcedureRecoveryPatientServiceGrouping
	/*Encounter Level details*/
	,EncounterFactDetails.DischargeTime
	,EncounterFactDetails.DischargeDate
  ,DischargeDateDim.FiscalYear AS DischargeFiscalYearNBR
	,EncounterFactDetails.IsEligibleDischargedFLG
	,EncounterFactDetails.DischargePatientClassDSC
	,EncounterFactDetails.DischargeService
	,EncounterFactDetails.DischargeDeptID
	,EncounterFactDetails.DischargeDept
	,EncounterFactDetails.DischargeServiceGrouping
	,EncounterFactDetails.AdmitSourceCD
	,EncounterFactDetails.AdmitSourceDSC
  ,EncounterFactDetails.AdmitSourceGrouping
	/*These metrics are part of the EAM ED Domain - consider if we should completely exclude, and Dashboard should just use ED metrics*/
	,EncounterFactDetails.EDArrivalDate
  ,EDArrivalDateDim.FiscalYear AS EDArrivalFiscalYearNBR
	,EncounterFactDetails.IsBoarder
	,EncounterFactDetails.BoarderDurationInMinutes
  ,EncounterFactDetails.IsMedSurgEligiblePatientClassDischargedFLG
  ,EncounterFactDetails.EDDepartureDate
  ,EDDepartureDateDim.FiscalYear AS EDDepartureFiscalYearNBR
FROM
	SAM.EAMInpatient.ADTSource	AS ADTSource
	LEFT OUTER JOIN SAM.EAMInpatient.ADTSummary AS ADTSummary
	ON ADTSummary.PatientEncounterID=ADTSource.PatientEncounterID
	LEFT OUTER JOIN SAM.EAMInpatient.EncounterFactDetails	EncounterFactDetails 
		ON ADTSource.PatientEncounterID = EncounterFactDetails.PatientEncounterID	
  INNER JOIN SAM.EAMInpatient.Departments /* Exclusions apply */
		ON Departments.DepartmentID = ADTSource.DepartmentID
  LEFT JOIN	EpicMart.Curated.DateDim AdmitDateDim
		ON CAST(ADTSource.EffectiveDTS AS DATE) = AdmitDateDim.DateValue
  LEFT JOIN	EpicMart.Curated.DateDim EDArrivalDateDim
		ON CAST(EncounterFactDetails.EDArrivalDate AS DATE) = EDArrivalDateDim.DateValue
  LEFT JOIN	EpicMart.Curated.DateDim DischargeDateDim
		ON CAST(EncounterFactDetails.DischargeDate AS DATE) = DischargeDateDim.DateValue
  LEFT JOIN	EpicMart.Curated.DateDim EDDepartureDateDim
		ON CAST(EncounterFactDetails.EDDepartureDate AS DATE) = EDDepartureDateDim.DateValue
WHERE ADTSource.IsFirstQualifyingAdmitEvent=1
AND ADTSource.EAMServiceGrouping IN ('Medicine','Surgical')
AND Departments.LocationExclusionFLG = 0