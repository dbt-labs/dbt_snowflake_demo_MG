/*********************************************************************************************************************************************************
Name: INPATIENT_METRIC_DETAIL
Description: Details for the metrics requiring median calculations. 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220504	bs234    56879    Initial version
*********************************************************************************************************************************************************/

SELECT
    ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INPATIENT_METRIC_DETAIL_ID /* Snowflake type: NUMBER */
    ,METRIC_ID = CAST(cYr.METRIC_ID	 AS DECIMAL(38,0)) /* Snowflake type: NUMBER */
    ,METRIC_NM = CAST(cYr.METRIC_NM AS VARCHAR(255)) /* Snowflake type: VARCHAR(255) */
    ,SOURCE_EPIC_ID = CAST(cYr.SOURCE_EPIC_ID AS DECIMAL(38,0)) /* Snowflake type: NUMBER */
    ,PATIENT_ID = CAST(cYr.PATIENT_ID AS VARCHAR(30)) /* Snowflake type: NUMBER */
	  ,REPORTING_DT = CAST(cYr.REPORTING_DT AS DATE) /* Snowflake type: DATE */
    ,REPORTING_FISCAL_YEAR_NBR = CAST(cYr.REPORTING_FISCAL_YEAR_NBR AS DECIMAL(38,0)) /* Snowflake type: NUMBER */
    ,DEPARTMENT_NM = CAST(cYr.DEPARTMENT_NM	 AS VARCHAR(255)) /* Snowflake type: VARCHAR(255) */
    ,REVENUE_LOCATION_NM = CAST(cYr.REVENUE_LOCATION_NM AS VARCHAR(255)) /* Snowflake type: VARCHAR(255) */
    ,HOSPITAL_PARENT_LOCATION_NM = CAST(cYr.HOSPITAL_PARENT_LOCATION_NM	 AS VARCHAR(255)) /* Snowflake type: VARCHAR(255) */
    ,OCCUPANCY_DEPARTMENT_GROUP_NM = CAST(cYr.OCCUPANCY_DEPARTMENT_GROUP_NM AS VARCHAR(50)) /* Snowflake type: VARCHAR(50) */
    ,PATIENT_CLASS_DSC = CAST(cYr.PATIENT_CLASS_DSC AS VARCHAR(5000)) /* Snowflake type: VARCHAR(5000) */
    ,SERVICE_GROUP_DSC = CAST(cYr.SERVICE_GROUP_DSC AS VARCHAR(5000)) /* Snowflake type: VARCHAR(5000) */
    ,ADMISSION_SOURCE_GROUP_NM = CAST(cYr.ADMISSION_SOURCE_GROUP_NM AS VARCHAR(50)) /* Snowflake type: VARCHAR(50) */
    ,NUMERATOR_NBR = CAST(cYr.NUMERATOR_NBR AS DECIMAL(38,4)) /* Snowflake type: NUMBER(38,4) */
    ,DENOMINATOR_NBR = CAST(cYr.DENOMINATOR_NBR AS DECIMAL(38,4)) /* Snowflake type: NUMBER(38,4) */
    ,PRIOR_YEAR_NUMERATOR_NBR = CAST(NULL AS DECIMAL(38,4)) /* Snowflake type: NUMBER(38,4) */
    ,PRIOR_YEAR_DENOMINATOR_NBR = CAST(NULL AS DECIMAL(38,4)) /* Snowflake type: NUMBER(38,4) */
    --,ED_ARRIVAL_FISCAL_YEAR_NBR = CAST(cYr.ED_ARRIVAL_FISCAL_YEAR_NBR AS DECIMAL(38,0)) /* Snowflake type: NUMBER */
    --,ED_ARRIVAL_DT = CAST(cYr.ED_ARRIVAL_DT AS DATE) /* Snowflake type: DATE */
	FROM
			SAM.EAMInpatient.InpatientEncounterMetricDetailProductLayer cYr
