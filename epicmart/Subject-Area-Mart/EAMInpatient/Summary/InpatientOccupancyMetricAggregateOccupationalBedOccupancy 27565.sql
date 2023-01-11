/*********************************************************************************************************************************************************
Name: InpatientOccupancyMetricAggregateOccupationalBedOccupancy
Description: Summarizes discharge time. 
History:
Date		  User	  TFS#		  Description
--------	------	--------	-------------------------------------------------------------------------------------------------------------------------------
20220504	ms2    56879    Initial version
20220617	bs234  170595   Added operational bed count
*********************************************************************************************************************************************************/

SELECT
  CAST(30 AS INT) AS METRIC_ID
, 'Operational Bed Occupancy'	AS METRIC_NM
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
, CAST(SUM(OccupiedAt7amCNT) AS DECIMAL(19,5)) AS NUMERATOR_NBR
, CAST(SUM(OperationalBedCNT) AS DECIMAL(19,5)) AS DENOMINATOR_NBR
FROM
	SAM.EAMInpatient.OccupancyDepartmentCalendarDateDetail
GROUP BY 
  CalendarDate 
, CalendarFiscalYear 
, DepartmentNM 
, RevenueLocationNM 
, HospitalParentLocationNM 
, NewMedSurgICUFlg 
