/*********************************************************************************************************************************************************
Name: INPATIENT_ENCOUNTER_DETAIL
Description: Details for Occupancy metrics 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220504	bs234    56879    Initial version
20220617	bs234    170595   Added operational bed count
*********************************************************************************************************************************************************/

SELECT
    ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INPATIENT_OCCUPANCY_DETAIL_ID /* Snowflake type: NUMBER */
    ,CALENDAR_DT = CAST(OccupancyDepartmentCalendarDateDetail.CalendarDate AS DATE) /* Snowflake type: DATE */
	 ,CALENDAR_FISCAL_YEAR_NBR = CAST(DateDim.FiscalYear AS DECIMAL(38,0)) /* Snowflake type: NUMBER */
    ,DEPARTMENT_ID = CAST(OccupancyDepartmentCalendarDateDetail.DepartmentID AS VARCHAR(50)) /* Snowflake type: VARCHAR(50) */
    ,DEPARTMENT_NM = CAST(OccupancyDepartmentCalendarDateDetail.DepartmentNM AS VARCHAR(255)) /* Snowflake type: VARCHAR(255) */
    ,REVENUE_LOCATION_ID = CAST(OccupancyDepartmentCalendarDateDetail.RevenueLocationID AS VARCHAR(50)) /* Snowflake type: VARCHAR(50) */
    ,REVENUE_LOCATION_NM = CAST(OccupancyDepartmentCalendarDateDetail.RevenueLocationNM AS VARCHAR(255)) /* Snowflake type: VARCHAR(255) */
    ,HOSPITAL_PARENT_LOCATION_ID = CAST(OccupancyDepartmentCalendarDateDetail.HospitalParentLocationID AS VARCHAR(50)) /* Snowflake type: VARCHAR(50) */
    ,HOSPITAL_PARENT_LOCATION_NM = CAST(OccupancyDepartmentCalendarDateDetail.HospitalParentLocationNM AS VARCHAR(255)) /* Snowflake type: VARCHAR(255) */
    ,OCCUPANCY_DEPARTMENT_GROUP_NM = CAST(OccupancyDepartmentCalendarDateDetail.NewMedSurgICUFlg AS VARCHAR(50)) /* Snowflake type: VARCHAR(50) */
    ,OCCUPIED_BED_7AM_CNT = CAST(OccupancyDepartmentCalendarDateDetail.OccupiedAt7amCNT AS DECIMAL(38,0)) /* Snowflake type: NUMBER */
    ,LICENSED_BED_CNT = CAST(OccupancyDepartmentCalendarDateDetail.LicensedBedCNT AS DECIMAL(38,0)) /* Snowflake type: NUMBER */
    ,BLOCKED_BED_7AM_CNT = CAST(OccupancyDepartmentCalendarDateDetail.BlockedBedAt7amCNT AS DECIMAL(38,0)) /* Snowflake type: NUMBER */
    ,OCCUPATIONAL_BED_CNT = CAST(OccupancyDepartmentCalendarDateDetail.OccupationalBedCNT AS DECIMAL(38,0)) /* Snowflake type: NUMBER */
    ,OPERATIONAL_BED_CNT = CAST(OccupancyDepartmentCalendarDateDetail.OperationalBedCNT AS DECIMAL(38,0)) /* Snowflake type: NUMBER */
    FROM SAM.EAMInpatient.OccupancyDepartmentCalendarDateDetail
    INNER JOIN EpicMart.Curated.DateDim ON DateDim.DateValue = OccupancyDepartmentCalendarDateDetail.CalendarDate
