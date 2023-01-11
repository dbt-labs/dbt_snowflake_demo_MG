/*********************************************************************************************************************************************************
Name: InpatientEncounterMetricAggregateMedSurgVolume
Description: Summarizes med/surg volume. 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220504	bs234    56879    Initial version
*********************************************************************************************************************************************************/

SELECT
  CAST(32 AS INT) AS METRIC_ID
, 'MedSurg Admission Volume'	AS METRIC_NM
, ADMISSION_DT AS REPORTING_DT
, ADMISSION_FISCAL_YEAR_NBR AS REPORTING_FISCAL_YEAR_NBR
, ADMISSION_DEPARTMENT_NM AS DEPARTMENT_NM
, ADMISSION_REVENUE_LOCATION_NM AS REVENUE_LOCATION_NM
, ADMISSION_HOSPITAL_PARENT_LOCATION_NM AS HOSPITAL_PARENT_LOCATION_NM
, NULL AS OCCUPANCY_DEPARTMENT_GROUP_NM
, ADMISSION_PATIENT_CLASS_DSC AS PATIENT_CLASS_DSC
, ADMISSION_SERVICE_GROUP_NM AS SERVICE_GROUP_DSC
, ADMIT_SOURCE_GROUP_NM AS ADMISSION_SOURCE_GROUP_NM
, CURRENT_TIMESTAMP AS EDW_LAST_MODIFIED_DTS
, SUM(MEDICINE_SURGERY_ADMISSION_FLG) AS NUMERATOR_NBR
, NULL AS DENOMINATOR_NBR
FROM
	SAM.EAMInpatient.InpatientEncounterDetailProductLayer
GROUP BY 
  ADMISSION_DT 
, ADMISSION_FISCAL_YEAR_NBR
, ADMISSION_DEPARTMENT_NM
, ADMISSION_REVENUE_LOCATION_NM 
, ADMISSION_HOSPITAL_PARENT_LOCATION_NM 
, ADMISSION_PATIENT_CLASS_DSC 
, ADMISSION_SERVICE_GROUP_NM 
, ADMIT_SOURCE_GROUP_NM 