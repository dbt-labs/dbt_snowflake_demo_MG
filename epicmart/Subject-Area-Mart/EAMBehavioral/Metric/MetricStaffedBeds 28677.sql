
WITH StaffedBedStage AS
(
SELECT 
	 Dates.CalendarDate
	,Dates.CalendarDateAt7AM
	,EventEDEvents.DepartmentID
	,EventEDEvents.DepartmentNM
	,EventEDEvents.EventID
	,EventEDEvents.EventTypeCD
	,EventEDEvents.LineNBR
	,EventEDEvents.EventNM
	,EventEDEvents.StaffedBedStartDTS
	,EventEDEvents.NextStaffedBedStartDTS
	,EventEDEvents.StaffedBedNBR
	,EventEDEvents.FullyStaffedFLG

FROM SAM.EAMBehavioral.EventEDEvents
CROSS APPLY 
	(
	SELECT CalendarDate, CalendarDateAt7AM
	FROM SAM.EAMBehavioral.EventDateDimension
	WHERE CalendarDateAt7AM >= StaffedBedStartDTS AND  CalendarDateAt7AM < NextStaffedBedStartDTS
	) AS Dates
)

SELECT 
	StaffedBedStage.CalendarDate, 
	StaffedBedStage.CalendarDateAt7AM, 
	StaffedBedStage.DepartmentID, 
	StaffedBedStage.DepartmentNM, 
	StaffedBedStage.StaffedBedStartDTS, 
	StaffedBedStage.NextStaffedBedStartDTS,
	StaffedBedStage.FullyStaffedFLG,
	CASE WHEN StaffedBedNBR IS NULL and FullyStaffedFLG = 'Y'
		THEN MetricLicensedBedCount.LicensedBedCNT
		ELSE StaffedBedStage.StaffedBedNBR
	END AS StaffedBedCNT

FROM StaffedBedStage
LEFT JOIN SAM.EAMBehavioral.MetricLicensedBedCount 
	ON MetricLicensedBedCount.CalendarDate = StaffedBedStage.CalendarDate
	AND MetricLicensedBedCount.DepartmentEpicId = StaffedBedStage.DepartmentID