/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: InpatientEncounterMetricAggregateProductLayerPriorYear
Description: This binding collects the Prior Year data for matching against Current Year for target purposes
History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
SELECT
  cYr.METRIC_ID	
, cYr.METRIC_NM	
, DATEADD(year,1,cYr.REPORTING_DT) AS REPORTING_DT
, cYr.REPORTING_FISCAL_YEAR_NBR	+ 1 AS REPORTING_FISCAL_YEAR_NBR
, cYr.DEPARTMENT_NM	
, cYr.REVENUE_LOCATION_NM	
, cYr.HOSPITAL_PARENT_LOCATION_NM	
, cYr.OCCUPANCY_DEPARTMENT_GROUP_NM	
, cYr.PATIENT_CLASS_DSC	
, cYr.SERVICE_GROUP_DSC	
, cYr.ADMISSION_SOURCE_GROUP_NM	
, NULL AS NUMERATOR_NBR
, NULL AS DENOMINATOR_NBR
, SUM(cYr.NUMERATOR_NBR) AS PRIOR_YEAR_NUMERATOR_NBR
, SUM(cYr.DENOMINATOR_NBR) AS PRIOR_YEAR_DENOMINATOR_NBR
FROM
	SAM.EAMInpatient.InpatientEncounterMetricAggregateProductLayerStage cYr
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