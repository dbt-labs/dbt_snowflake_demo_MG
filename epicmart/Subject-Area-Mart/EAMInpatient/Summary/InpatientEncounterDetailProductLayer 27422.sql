/*********************************************************************************************************************************************************
Name: InpatientEncounterDetailProductLayer
Description: Details for the inpatient encounters to be used by the product layer. 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220504	bs234    56879    Initial version
20220608  bs234    169545   Adding flag for discharge metrics
20221130  KG312   !12451    Bring in EDDepartureDate
*********************************************************************************************************************************************************/

SELECT
  ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INPATIENT_ENCOUNTER_DETAIL_ID -- adjust
, PatientEncounterID AS PATIENT_ENCOUNTER_ID
, PatientID AS PATIENT_ID
, EffectiveDTS AS ADMISSION_EFFECTIVE_DTS
, AdmissionCalendarDate AS ADMISSION_DT
, AdmissionFiscalYearNBR AS ADMISSION_FISCAL_YEAR_NBR
, AdmissionDepartmentID AS ADMISSION_DEPARTMENT_ID
, DepartmentNM AS ADMISSION_DEPARTMENT_NM
, RevenueLocationID AS ADMISSION_REVENUE_LOCATION_ID
, RevenueLocationNM AS ADMISSION_REVENUE_LOCATION_NM
, HospitalParentLocationID AS ADMISSION_HOSPITAL_PARENT_LOCATION_ID
, HospitalParentLocationNM AS ADMISSION_HOSPITAL_PARENT_LOCATION_NM
, AdmissionPatientClassCD AS ADMISSION_PATIENT_CLASS_CD
, AdmissionPatientClassDSC AS ADMISSION_PATIENT_CLASS_DSC
, AdmissionPatientServiceCD AS ADMISSION_PATIENT_SERVICE_CD
, AdmissionPatientServiceDSC AS ADMISSION_PATIENT_SERVICE_DSC
, AdmissionServiceGrouping AS ADMISSION_SERVICE_GROUP_NM
, MedSurgAdmissionFLG AS MEDICINE_SURGERY_ADMISSION_FLG
, InpatientCensusPatientServiceCD AS INPATIENT_CENSUS_PATIENT_SERVICE_CD
, InpatientCensusPatientServiceDSC AS INPATIENT_CENSUS_PATIENT_SERVICE_DSC
, InpatientCensusServiceGrouping AS INPATIENT_SERVICE_GROUP_NM -- mapped
, InpatientPatientClassFLG AS INPATIENT_PATIENT_CLASS_FLG
, InpatientCensusDaysCNT AS INPATIENT_CENSUS_DAY_CNT
, ObservationPatientClassFLG AS OBSERVATION_PATIENT_CLASS_FLG
, ObservationEventMinutesNBR AS OBSERVATION_MINUTE_NBR -- mapped
, PostProcedureRecoveryPatientClassFLG AS POST_PROCEDURE_RECOVERY_PATIENT_CLASS_FLG
, ObservationPatientServiceGrouping AS OBSERVATION_SERVICE_GROUP_NM   
, PostProcedureRecoveryPatientServiceGrouping AS POST_PROCEDURE_RECOVERY_SERVICE_GROUP_NM   
, PostProcedureRecoveryEventMinutesNBR AS POST_PROCEDURE_RECOVERY_MINUTE_NBR -- mapped
, DischargeDate AS DISCHARGE_DT
, DischargeTime AS DISCHARGE_TIME_TXT
, DischargeDeptID AS DISCHARGE_DEPARTMENT_ID
, DischargeFiscalYearNBR AS DISCHARGE_FISCAL_YEAR_NBR
, DischargeDept AS DISCHARGE_DEPARTMENT_NM
, DischargeService AS DISCHARGE_SERVICE_CD
, DischargeServiceGrouping AS DISCHARGE_SERVICE_GROUP_NM
, IsEligibleDischargedFLG AS ELIGIBLE_DISCHARGE_FLG
, DischargePatientClassDSC AS DISCHARGE_PATIENT_CLASS_DSC
, AdmitSourceCD AS ADMIT_SOURCE_CD
, AdmitSourceDSC AS ADMIT_SOURCE_DSC
, AdmitSourceGrouping AS ADMIT_SOURCE_GROUP_NM
, EDArrivalDate AS ED_ARRIVAL_DT
, EDArrivalFiscalYearNBR AS ED_ARRIVAL_FISCAL_YEAR_NBR
, IsBoarder AS BOARDER_FLG
, BoarderDurationInMinutes AS BOARDER_DURATION_MINUTE_NBR
, IsMedSurgEligiblePatientClassDischargedFLG AS ELIGIBLE_MEDSURG_PATIENTCLASS_DISCHARGE_FLG 
, EDDepartureDate AS ED_DEPARTURE_DT
, EDDepartureFiscalYearNBR AS ED_DEPARTURE_FISCAL_YEAR_NBR
FROM
			SAM.EAMInpatient.InpatientEncounterDetail