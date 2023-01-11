/*********************************************************************************************************************************************************
Name: InpatientEncounterMetricAggregateObservationLengthOfStay
Description: Summarizes length of stay for observation. 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220504	bs234    56879    Initial version
*********************************************************************************************************************************************************/

SELECT
  CAST(34 AS INT) AS METRIC_ID
, 'Observation Length Of Stay'	AS METRIC_NM
, DISCHARGE_DT AS REPORTING_DT
, DISCHARGE_FISCAL_YEAR_NBR AS REPORTING_FISCAL_YEAR_NBR
, ADMISSION_DEPARTMENT_NM AS DEPARTMENT_NM
, ADMISSION_REVENUE_LOCATION_NM AS REVENUE_LOCATION_NM
, ADMISSION_HOSPITAL_PARENT_LOCATION_NM AS HOSPITAL_PARENT_LOCATION_NM
, NULL AS OCCUPANCY_DEPARTMENT_GROUP_NM
, NULL AS PATIENT_CLASS_DSC
, OBSERVATION_SERVICE_GROUP_NM AS SERVICE_GROUP_DSC
, NULL AS ADMISSION_SOURCE_GROUP_NM
, CURRENT_TIMESTAMP AS EDW_LAST_MODIFIED_DTS
, SUM(OBSERVATION_MINUTE_NBR)/60 AS NUMERATOR_NBR
, SUM(OBSERVATION_PATIENT_CLASS_FLG) AS DENOMINATOR_NBR
FROM
	SAM.EAMInpatient.InpatientEncounterDetailProductLayer
WHERE
  ELIGIBLE_DISCHARGE_FLG = 1
GROUP BY 
  DISCHARGE_DT 
, DISCHARGE_FISCAL_YEAR_NBR
, ADMISSION_DEPARTMENT_NM
, ADMISSION_REVENUE_LOCATION_NM 
, ADMISSION_HOSPITAL_PARENT_LOCATION_NM
, OBSERVATION_SERVICE_GROUP_NM