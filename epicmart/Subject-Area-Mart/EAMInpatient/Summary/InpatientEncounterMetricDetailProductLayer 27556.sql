/*********************************************************************************************************************************************************
Name: InpatientEncounterMetricDetailProductLayer
Description: Prepares aggregates for the product layer. 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220516	ms2    56879    Initial version
*********************************************************************************************************************************************************/

SELECT
  ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INPATIENT_METRIC_AGGREGATE_ID
, cYr.METRIC_ID	
, cYr.METRIC_NM	
, cYr.SOURCE_EPIC_ID	
, cYR.PATIENT_ID
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
, null	AS PRIOR_YEAR_NUMERATOR_NBR
, null AS PRIOR_YEAR_DENOMINATOR_NBR
, cYr.ED_ARRIVAL_FISCAL_YEAR_NBR
, cYr.ED_ARRIVAL_DT
FROM
			SAM.EAMInpatient.InpatientEncounterMetricDetailProductLayerStage cYr
WHERE cYr.REPORTING_DT >= (SELECT FirstReportedDate FROM SAM.EAMInpatient.FirstDate) 
  AND cYr.REPORTING_DT <= (SELECT LastDate FROM SAM.EAMInpatient.LastDate) 