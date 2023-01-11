/*********************************************************************************************************************************************************
Name: InpatientEncounterMetricAggregateProductLayer
Description: Prepares aggregates for the product layer. 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220504	bs234    56879    Initial version
*********************************************************************************************************************************************************/

SELECT
  ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INPATIENT_METRIC_AGGREGATE_ID
, cYr.METRIC_ID	
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
, CURRENT_TIMESTAMP AS EDW_LAST_MODIFIED_DTS
, SUM(cYr.NUMERATOR_NBR) AS NUMERATOR_NBR
, SUM(cYr.DENOMINATOR_NBR) AS DENOMINATOR_NBR
, SUM(cYr.PRIOR_YEAR_NUMERATOR_NBR) AS PRIOR_YEAR_NUMERATOR_NBR
, SUM(cYr.PRIOR_YEAR_DENOMINATOR_NBR) AS PRIOR_YEAR_DENOMINATOR_NBR
FROM
			SAM.EAMInpatient.InpatientEncounterMetricAggregateProductLayerSummaryStaging cYr
WHERE
  cYr.REPORTING_DT BETWEEN '2018-10-01' AND (SELECT MAX(REPORTING_DT) FROM SAM.EAMInpatient.InpatientEncounterMetricAggregateProductLayerSummaryStaging where (COALESCE(NUMERATOR_NBR,0)+COALESCE(DENOMINATOR_NBR,0) > 1))
GROUP BY
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