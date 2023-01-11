/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: BEHAVIORAL_BED_OCCUPANCY_DTL_TBL
Description: Bed occupancy at the department-date grain

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
WITH OccupancyDepartmentList AS
(
	/*Our Denominator needs to include all departments that meet the "MedSurg" or "ICU" Department definition*/
SELECT EventDepartments.DepartmentEpicId, ISNULL(MAX(Metric7AMOccupancyCount.EDWLastModifiedDTS), GETDATE()) AS EDWLastModifiedDTS
  FROM sam.EAMBehavioral.EventDepartments
  LEFT JOIN SAM.EAMBehavioral.Metric7AMOccupancyCount
    ON Metric7AMOccupancyCount.DepartmentID = EventDepartments.DepartmentEpicId
 WHERE EXISTS 
	 (
	  SELECT 'Behavioral Health Departments'
		FROM SAM.EAMBehavioral.DomainConfiguration
	   WHERE DomainConfiguration.ConfigurationItemDSC = 'DepartmentEpicId'
		 AND DomainConfiguration.ConfigurationValueTXT = EventDepartments.DepartmentEpicId
	  )
GROUP BY EventDepartments.DepartmentEpicId
)
, OccupancyDepartmentCalendarDate AS
(
SELECT Dates.CalendarDate
	  ,OccupancyDepartmentList.DepartmentEpicId
	  ,EventDepartments.DepartmentName
	  ,EventDepartments.RevenueLocationID
	  ,EventDepartments.RevenueLocationNM
	  ,EventDepartments.HospitalParentLocationID
	  ,EventDepartments.HospitalParentLocationNM	/*this is the version we will use in reporting on the dashboard*/
	  ,OccupancyDepartmentList.EDWLastModifiedDTS
  FROM OccupancyDepartmentList
 INNER JOIN SAM.EAMBehavioral.EventDepartments
	ON OccupancyDepartmentList.DepartmentEpicId = EventDepartments.DepartmentEpicId
	
 CROSS APPLY (SELECT EventDateDimension.CalendarDate
			    FROM SAM.EAMBehavioral.EventDateDimension) AS Dates
)
 SELECT
		OccupancyDepartmentCalendarDate.CalendarDate										                  AS CALENDAR_DT 
		,CAST(OccupancyDepartmentCalendarDate.DepartmentEpicId			    AS varchar(50)) 	AS DEPARTMENT_EPIC_ID 
		,CAST(OccupancyDepartmentCalendarDate.DepartmentName			      AS varchar(300))	AS DEPARTMENT_NM 
		,CAST(OccupancyDepartmentCalendarDate.RevenueLocationID			    AS varchar(50))		AS REVENUE_LOCATION_ID 
		,CAST(OccupancyDepartmentCalendarDate.RevenueLocationNM			    AS varchar(300))	AS REVENUE_LOCATION_NM 
		,CAST(OccupancyDepartmentCalendarDate.HospitalParentLocationID	AS varchar(50))		AS HOSPITAL_PARENT_LOCATION_ID 
		,CAST(OccupancyDepartmentCalendarDate.HospitalParentLocationNM	AS varchar(300))	AS HOSPITAL_PARENT_LOCATION_NM 
		,OccupancyDepartmentCalendarDate.EDWLastModifiedDTS							                  AS EDW_LAST_MODIFIED_DTS 
		,Metric7AMOccupancyCount.OccupiedAt7amCNT	/*Numerator*/					                  AS OCCUPIED_AT_7AM_CNT 
		,MetricLicensedBedCount.LicensedBedCNT	/*Denominator for LicensedBedOccupancy*/	AS LICENSED_BED_CNT 
		,MetricBlockedBedsCount.BlockedBedAt7amCNT											                  AS BLOCKED_BED_AT_7AM_CNT
    ,MetricStaffedBeds.StaffedBedCNT                                                  AS STAFFED_BED_CNT 	
		/*Denominator for Occupational (Licensed - Blocked) Bed Occupancy - likely a better way to handle this calculation at an earlier stage*/
		,(ISNULL(MetricLicensedBedCount.LicensedBedCNT,0) - ISNULL(MetricBlockedBedsCount.BlockedBedAt7amCNT,0)) AS OCCUPATIONAL_BED_CNT	
    ,(ISNULL(MetricLicensedBedCount.LicensedBedCNT,0) - ISNULL(MetricStaffedBeds.StaffedBedCNT,0)) AS UNSTAFFED_BED_CNT
    
	FROM 
		OccupancyDepartmentCalendarDate

  INNER JOIN
SAM.EAMBehavioral.IncrementalHelper_BED_OCCUPANCY_DETAIL
ON OccupancyDepartmentCalendarDate.DepartmentEpicId = IncrementalHelper_BED_OCCUPANCY_DETAIL.DepartmentID

		LEFT OUTER JOIN sam.EAMBehavioral.MetricBlockedBedsCount				
			ON OccupancyDepartmentCalendarDate.DepartmentEpicId = MetricBlockedBedsCount.DepartmentID 
			AND OccupancyDepartmentCalendarDate.CalendarDate = MetricBlockedBedsCount.CalendarDate
		LEFT OUTER JOIN sam.EAMBehavioral.MetricLicensedBedCount		
			ON OccupancyDepartmentCalendarDate.DepartmentEpicId = MetricLicensedBedCount.DepartmentEpicId 
			AND OccupancyDepartmentCalendarDate.CalendarDate = MetricLicensedBedCount.CalendarDate
		LEFT OUTER JOIN sam.EAMBehavioral.Metric7AMOccupancyCount			
			ON OccupancyDepartmentCalendarDate.DepartmentEpicId = Metric7AMOccupancyCount.DepartmentID 
			AND OccupancyDepartmentCalendarDate.CalendarDate = Metric7AMOccupancyCount.CalendarDate
    LEFT OUTER JOIN SAM.EAMBehavioral.MetricStaffedBeds
      ON OccupancyDepartmentCalendarDate.DepartmentEpicId = MetricStaffedBeds.DepartmentID
     AND OccupancyDepartmentCalendarDate.CalendarDate = MetricStaffedBeds.CalendarDate

