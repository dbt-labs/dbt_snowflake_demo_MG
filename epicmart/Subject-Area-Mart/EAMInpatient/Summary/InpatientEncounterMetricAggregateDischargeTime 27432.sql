/*********************************************************************************************************************************************************
Name: InpatientEncounterMetricAggregateDischargeTime
Description: Summarizes discharge time. 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220504	bs234    56879    Initial version
20220608  bs234    169545   Adjusted filter for discharge and added revenue location exclusion filter
*********************************************************************************************************************************************************/

SELECT
  CAST(36 AS INT) AS METRIC_ID
, 'Discharge Time'	AS METRIC_NM
, DISCHARGE_DT AS REPORTING_DT
, DISCHARGE_FISCAL_YEAR_NBR AS REPORTING_FISCAL_YEAR_NBR
, DISCHARGE_DEPARTMENT_NM AS DEPARTMENT_NM
, ADMISSION_REVENUE_LOCATION_NM AS REVENUE_LOCATION_NM
, ADMISSION_HOSPITAL_PARENT_LOCATION_NM AS HOSPITAL_PARENT_LOCATION_NM
, NULL AS OCCUPANCY_DEPARTMENT_GROUP_NM
, DISCHARGE_PATIENT_CLASS_DSC AS PATIENT_CLASS_DSC
, DISCHARGE_SERVICE_GROUP_NM AS SERVICE_GROUP_DSC
, NULL AS ADMISSION_SOURCE_GROUP_NM
, CURRENT_TIMESTAMP AS EDW_LAST_MODIFIED_DTS
, SUM(DATEDIFF(MINUTE,0,DISCHARGE_TIME_TXT)) AS NUMERATOR_NBR
, SUM(ELIGIBLE_DISCHARGE_FLG) AS DENOMINATOR_NBR
FROM
	SAM.EAMInpatient.InpatientEncounterDetailProductLayer
WHERE
    ELIGIBLE_MEDSURG_PATIENTCLASS_DISCHARGE_FLG  = 1
GROUP BY 
  DISCHARGE_DT 
, DISCHARGE_FISCAL_YEAR_NBR
, DISCHARGE_DEPARTMENT_NM
, ADMISSION_REVENUE_LOCATION_NM 
, ADMISSION_HOSPITAL_PARENT_LOCATION_NM 
, DISCHARGE_PATIENT_CLASS_DSC
, DISCHARGE_SERVICE_GROUP_NM