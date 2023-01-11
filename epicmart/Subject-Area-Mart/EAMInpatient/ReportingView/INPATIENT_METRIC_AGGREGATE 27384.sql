/*********************************************************************************************************************************************************
Name: INPATIENT_METRIC_AGGREGATE
Description: Inpatient metrics aggregated. 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220504	bs234    56879    Initial version
*********************************************************************************************************************************************************/

SELECT
  INPATIENT_METRIC_AGGREGATE_ID
, METRIC_ID	
, METRIC_NM	
, REPORTING_DT	
, REPORTING_FISCAL_YEAR_NBR	
, DEPARTMENT_NM	
, REVENUE_LOCATION_NM	
, HOSPITAL_PARENT_LOCATION_NM	
, OCCUPANCY_DEPARTMENT_GROUP_NM	
, PATIENT_CLASS_DSC	
, SERVICE_GROUP_DSC	
, ADMISSION_SOURCE_GROUP_NM	
, EDW_LAST_MODIFIED_DTS	
, NUMERATOR_NBR	
, DENOMINATOR_NBR
, PRIOR_YEAR_NUMERATOR_NBR	
, PRIOR_YEAR_DENOMINATOR_NBR 
FROM
			SAM.EAMInpatient.InpatientEncounterMetricAggregateProductLayer

--SELECT
--    ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INPATIENT_METRIC_AGGREGATE_ID /* Snowflake type: NUMBER */
--    ,METRIC_ID = CAST(NULL AS DECIMAL(38,0)) /* Snowflake type: NUMBER */
--    ,METRIC_NM = CAST(NULL AS VARCHAR(255)) /* Snowflake type: VARCHAR(255) */
--    ,REPORTING_DT = CAST(NULL AS DATE) /* Snowflake type: DATE */
--    ,REPORTING_FISCAL_YEAR_NBR = CAST(NULL AS DECIMAL(38,0)) /* Snowflake type: NUMBER */
--    ,DEPARTMENT_NM = CAST(NULL AS VARCHAR(255)) /* Snowflake type: VARCHAR(255) */
--    ,REVENUE_LOCATION_NM = CAST(NULL AS VARCHAR(255)) /* Snowflake type: VARCHAR(255) */
--    ,HOSPITAL_PARENT_LOCATION_NM = CAST(NULL AS VARCHAR(255)) /* Snowflake type: VARCHAR(255) */
--    ,OCCUPANCY_DEPARTMENT_GROUP_NM = CAST(NULL AS VARCHAR(50)) /* Snowflake type: VARCHAR(50) */
--    ,PATIENT_CLASS_DSC = CAST(NULL AS VARCHAR(5000)) /* Snowflake type: VARCHAR(5000) */
--    ,SERVICE_GROUP_DSC = CAST(NULL AS VARCHAR(5000)) /* Snowflake type: VARCHAR(5000) */
--    ,ADMISSION_SOURCE_GROUP_NM = CAST(NULL AS VARCHAR(50)) /* Snowflake type: VARCHAR(50) */
--    ,NUMERATOR_NBR = CAST(NULL AS DECIMAL(38,4)) /* Snowflake type: NUMBER(38,4) */
--    ,DENOMINATOR_NBR = CAST(NULL AS DECIMAL(38,4)) /* Snowflake type: NUMBER(38,4) */
--    ,PRIOR_YEAR_NUMERATOR_NBR = CAST(NULL AS DECIMAL(38,4)) /* Snowflake type: NUMBER(38,4) */
--    ,PRIOR_YEAR_DENOMINATOR_NBR = CAST(NULL AS DECIMAL(38,4)) /* Snowflake type: NUMBER(38,4) */