/*********************************************************************************************************************************************************
Name: INPATIENT_ENCOUNTER_DETAIL
Description: Details for the inpatient encounters to be used by the product layer. 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220504	bs234    56879    Initial version
*********************************************************************************************************************************************************/

SELECT
  INPATIENT_ENCOUNTER_DETAIL_ID
, PATIENT_ID
, PATIENT_ENCOUNTER_ID
, ADMISSION_EFFECTIVE_DTS
, ADMISSION_DT
, ADMISSION_FISCAL_YEAR_NBR
, ADMISSION_DEPARTMENT_ID
, ADMISSION_DEPARTMENT_NM
, ADMISSION_REVENUE_LOCATION_ID
, ADMISSION_REVENUE_LOCATION_NM
, ADMISSION_HOSPITAL_PARENT_LOCATION_ID
, ADMISSION_HOSPITAL_PARENT_LOCATION_NM
, ADMISSION_PATIENT_CLASS_CD
, ADMISSION_PATIENT_CLASS_DSC
, ADMISSION_PATIENT_SERVICE_CD
, ADMISSION_PATIENT_SERVICE_DSC
, ADMISSION_SERVICE_GROUP_NM
, MEDICINE_SURGERY_ADMISSION_FLG
, INPATIENT_CENSUS_PATIENT_SERVICE_CD
, INPATIENT_CENSUS_PATIENT_SERVICE_DSC
, INPATIENT_SERVICE_GROUP_NM 
, INPATIENT_PATIENT_CLASS_FLG
, INPATIENT_CENSUS_DAY_CNT
, OBSERVATION_PATIENT_CLASS_FLG
, OBSERVATION_SERVICE_GROUP_NM   
, OBSERVATION_MINUTE_NBR -- mapped
, POST_PROCEDURE_RECOVERY_PATIENT_CLASS_FLG
, POST_PROCEDURE_RECOVERY_SERVICE_GROUP_NM   
, POST_PROCEDURE_RECOVERY_MINUTE_NBR -- mapped
, DISCHARGE_DT
, DISCHARGE_FISCAL_YEAR_NBR
, DISCHARGE_TIME_TXT
, DISCHARGE_DEPARTMENT_ID
, DISCHARGE_DEPARTMENT_NM
, DISCHARGE_SERVICE_CD
, DISCHARGE_SERVICE_GROUP_NM
, ELIGIBLE_DISCHARGE_FLG
, DISCHARGE_PATIENT_CLASS_DSC
, ADMIT_SOURCE_CD
, ADMIT_SOURCE_DSC
, ADMIT_SOURCE_GROUP_NM
, BOARDER_FLG
, BOARDER_DURATION_MINUTE_NBR
, ED_ARRIVAL_DT
, ED_ARRIVAL_FISCAL_YEAR_NBR
, ELIGIBLE_MEDSURG_PATIENTCLASS_DISCHARGE_FLG
FROM
			SAM.EAMInpatient.InpatientEncounterDetailProductLayer