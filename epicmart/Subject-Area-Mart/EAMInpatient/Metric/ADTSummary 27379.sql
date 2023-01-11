/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: ADTSummary
Description: This binding summarizes ADT events to the encounter level

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
20220513	cdunn9		167029	Update to exclude Medicine and Surgical serivces and to use renamed columns including "Qualifying"
*********************************************************************************************************************************************************/
SELECT PatientEncounterID
		,SUM(ADTSource.QualifyingObservationPatientClassFLG * /*Observation [104] and Medicine or Surgical Hospital Service*/
			DATEDIFF(MINUTE, ADTSource.EffectiveDTS, ADTSource.NextEventEffectiveDTS)) AS ObservationEventMinutesNBR
		,SUM(ADTSource.QualifyingPostProcedureRecoveryPatientClassFLG * /*Post Procedure Recovery [124] and Medicine or Surgical Hospital Service*/
			DATEDIFF(MINUTE, ADTSource.EffectiveDTS, ADTSource.NextEventEffectiveDTS)) AS PostProcedureRecoveryEventMinutesNBR
		,MAX(ADTSource.QualifyingObservationPatientClassFLG) AS  ObservationPatientClassFLG
		,MAX(CASE WHEN ADTSource.IsFirstQualifyingPatientClassEvent*ADTSource.QualifyingObservationPatientClassFLG=1 THEN ADTSource.EAMServiceGrouping END) AS  ObservationPatientServiceGrouping
		,MAX(ADTSource.QualifyingPostProcedureRecoveryPatientClassFLG) AS  PostProcedureRecoveryPatientClassFLG
		,MAX(CASE WHEN ADTSource.IsFirstQualifyingPatientClassEvent*ADTSource.QualifyingPostProcedureRecoveryPatientClassFLG=1 THEN ADTSource.EAMServiceGrouping END) AS  PostProcedureRecoveryPatientServiceGrouping
		,MAX(ADTSource.IsQualifyingInpatientCensusEvent) as InpatientPatientClassFLG
		,SUM(ADTSource.IsQualifyingInpatientCensusEvent) as InpatientCensusDaysCNT
		,MAX(ADTSource.IsFirstQualifyingInpatientCensusEvent) AS IsInpatientCensusEncounter
		,MAX(CASE WHEN ADTSource.IsFirstQualifyingInpatientCensusEvent=1 THEN ADTSource.PatientServiceCD END ) AS InpatientCensusPatientServiceCD
		,MAX(CASE WHEN ADTSource.IsFirstQualifyingInpatientCensusEvent=1 THEN ADTSource.PatientServiceDSC END) AS InpatientCensusPatientServiceDSC
		,MAX(CASE WHEN ADTSource.IsFirstQualifyingInpatientCensusEvent=1 THEN ADTSource.PatientClassCD END ) AS InpatientCensusPatientClassCD
		,MAX(CASE WHEN ADTSource.IsFirstQualifyingInpatientCensusEvent=1 THEN ADTSource.PatientClassDSC END) AS InpatientCensusPatientClassDSC
		,MAX(CASE WHEN ADTSource.IsFirstQualifyingInpatientCensusEvent=1 THEN ADTSource.EAMServiceGrouping END) AS InpatientCensusServiceGrouping
		,MAX(ADTSource.IsFirstQualifyingAdmitEvent) as IsFirstQualifyingAdmitEvent
    /**************  next columns for investigation purposes ********************/
		,COUNT(DISTINCT CASE WHEN PatientServiceDSC <> 'Emergency Medicine' THEN  ADTSource.PatientServiceCD END) AS  HospitalServiceCount
		,COUNT(DISTINCT CASE WHEN NOT(EAMServiceGrouping IN('Medicine','Surgical')) AND PatientServiceDSC <> 'Emergency Medicine' THEN  ADTSource.PatientServiceCD END) AS  NonMedSurgEmergencyHospitalServiceCount
	FROM SAM.EAMInpatient.ADTSource AS ADTSource
	GROUP BY ADTSource.PatientEncounterID
