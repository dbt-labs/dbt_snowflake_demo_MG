/*********************************************************************************************************************************************************
Name: INPATIENT_METRIC_AGG_DISCHARGE_TIME_BY_FISCAL_YR
Description: Summarizes length of stay for post procedure recovery. 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220504	bs234    56879    Initial version
*********************************************************************************************************************************************************/

SELECT
  cYr.METRIC_ID	
, cYr.METRIC_NM	
, cYr.REPORTING_DT	
, cYr.REPORTING_FISCAL_YEAR_NBR	
, cYr.DEPARTMENT_NM	
, cYr.REVENUE_LOCATION_NM	
, cYr.HOSPITAL_PARENT_LOCATION_NM	
, cYr.OCCUPANCY_DEPARTMENT_GROUP_NM	
, cYr.PATIENT_CLASS_DSC	
, cYr.SERVICE_GROUP_DSC	
, cYr.ADMISSION_SOURCE_GROUP_NM	
, cYr.EDW_LAST_MODIFIED_DTS	
, cYr.NUMERATOR_NBR	
, cYr.DENOMINATOR_NBR
, pYr.NUMERATOR_NBR	AS PRIOR_YEAR_NUMERATOR_NBR
, pYr.DENOMINATOR_NBR AS PRIOR_YEAR_DENOMINATOR_NBR
FROM
			EAMInpatient.INPATIENT_METRIC_AGG_BY_FISCAL_YEAR cYr
LEFT JOIN	EAMInpatient.INPATIENT_METRIC_AGG_BY_FISCAL_YEAR pYr
	ON cYr.METRIC_ID = pYr.METRIC_ID
	AND cYr.REPORTING_DT = DATEADD(year,-1,pYr.REPORTING_DT)
	AND cYr.DEPARTMENT_NM = pYr.DEPARTMENT_NM
	AND cYr.REVENUE_LOCATION_NM = pYr.REVENUE_LOCATION_NM
	AND cYr.HOSPITAL_PARENT_LOCATION_NM = pYr.HOSPITAL_PARENT_LOCATION_NM
	AND COALESCE(cYr.OCCUPANCY_DEPARTMENT_GROUP_NM,'NA') = COALESCE(pYr.OCCUPANCY_DEPARTMENT_GROUP_NM,'NA')
	AND COALESCE(cYr.PATIENT_CLASS_DSC,'NA') = COALESCE(pYr.PATIENT_CLASS_DSC,'NA')
	AND COALESCE(cYr.SERVICE_GROUP_DSC,'NA') = COALESCE(pYr.SERVICE_GROUP_DSC,'NA')
	AND COALESCE(cYr.ADMISSION_SOURCE_GROUP_NM,'NA') = COALESCE(pYr.ADMISSION_SOURCE_GROUP_NM,'NA')