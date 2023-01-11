/*********************************************************************************************************************************************************
Name: InpatientOccupancyMetricAggregateBlockedBedsAt7am
Description: Summarizes discharge time. 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220504	ms2    56879    Initial version
*********************************************************************************************************************************************************/

SELECT
  CAST(31 AS INT) AS METRIC_ID
, 'Blocked Beds at 7am'	AS METRIC_NM
, CalendarDate AS REPORTING_DT
, CalendarFiscalYear AS REPORTING_FISCAL_YEAR_NBR
, DepartmentNM AS DEPARTMENT_NM
, RevenueLocationNM AS REVENUE_LOCATION_NM
, HospitalParentLocationNM AS HOSPITAL_PARENT_LOCATION_NM
, NewMedSurgICUFlg AS OCCUPANCY_DEPARTMENT_GROUP_NM
, CAST(NULL AS VARCHAR) AS PATIENT_CLASS_DSC
, CAST(NULL AS VARCHAR) AS SERVICE_GROUP_DSC
, CAST(NULL AS VARCHAR) AS ADMISSION_SOURCE_GROUP_NM
, CURRENT_TIMESTAMP AS EDW_LAST_MODIFIED_DTS
, CAST(SUM(BlockedBedAt7amCNT) AS DECIMAL(19,5)) AS NUMERATOR_NBR
, CAST(NULL AS DECIMAL(19,5)) AS DENOMINATOR_NBR
FROM
	SAM.EAMInpatient.OccupancyDepartmentCalendarDateDetail
GROUP BY 
  CalendarDate 
, CalendarFiscalYear 
, DepartmentNM 
, RevenueLocationNM 
, HospitalParentLocationNM 
, NewMedSurgICUFlg 
