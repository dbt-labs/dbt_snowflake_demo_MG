/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: InpatientEncounterMetricAggregateProductLayerCurrentYear
Description: This binding collects the Current Year data for matching against Prior Year for target purposes
History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
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
, SUM(cYr.NUMERATOR_NBR) AS NUMERATOR_NBR
, SUM(cYr.DENOMINATOR_NBR) AS DENOMINATOR_NBR
, NULL AS PRIOR_YEAR_NUMERATOR_NBR
, NULL AS PRIOR_YEAR_DENOMINATOR_NBR
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