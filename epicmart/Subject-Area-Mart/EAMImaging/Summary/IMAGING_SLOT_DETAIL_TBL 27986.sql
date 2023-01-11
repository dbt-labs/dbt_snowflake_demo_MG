/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: IMAGING_SLOT_DETAIL_TBL
Description: Bring all necessary columns together for metric calculation and also for analysis.

Attempts to fit this work into a Health Catalyst framework resulted in very poor performance.

According to the architectural pattern given as guidance, use data types that lend well to the cloud implementation.

This cloud implementation is in significant disagreement with the on-prem model and performance.

Date      User            ADO#    Description
20220926  Adam Proctor    !10981  Initial creation
20221019  Adam Proctor    !12120  Slot Use and Availability definition changing, table change of grain to 2 columns (slot begin and provider/resource)
20221031  Adam Proctor    !12262  Availability change for metric calculation change
*********************************************************************************************************************************************************/
SELECT 
	AvailableUtilization.SlotBeginDTS                                                                          AS SLOT_BEGIN_DTS,	
  AvailableUtilization.DepartmentID                                                                          AS DEPARTMENT_ID,
  CAST(AvailableUtilization.ProviderID AS VARCHAR(300))                                                      AS PROVIDER_ID,
  AvailableUtilization.AppointmentSEQ                                                                        AS APPOINTMENT_SEQ,
	CAST (AvailableUtilization.SlotBeginDTS AS DATE)                                                           AS CALENDAR_DT,
	AvailableUtilization.PatientEncounterID                                                                    AS PATIENT_ENCOUNTER_ID,
	CAST(AvailableUtilization.VisitTypeID AS VARCHAR(300))                                                     AS VISIT_TYPE_ID,
	CAST(DomainResource.ResourceID AS VARCHAR(300))                                                            AS RESOURCE_ID,
	CAST(DomainResource.ResourceNM AS VARCHAR(300))                                                            AS RESOURCE_NM,
	CAST(DomainResource.ModalityDSC AS VARCHAR(300))                                                           AS MODALITY_DSC,
	CAST(DomainResource.TwentyFourHourUtilizationFLG AS CHAR(1))                                               AS TWENTY_FOUR_HOUR_UTILIZATION_FLG,
	CAST(AvailableUtilization.DepartmentDSC AS VARCHAR(300))                                                   AS DEPARTMENT_NM,
	CAST(Department.RevenueLocationID AS VARCHAR(300))                                                         AS REVENUE_LOCATION_EPIC_ID,
	CAST([Location].RevenueLocationNM AS VARCHAR(300))                                                         AS REVENUE_LOCATION_NM,
	CAST(ParentLocation.LocationID AS VARCHAR(300))                                                            AS HOSPITAL_PARENT_LOCATION_ID,
	CAST(ParentLocation.RevenueLocationNM AS VARCHAR(300))                                                     AS HOSPITAL_PARENT_LOCATION_NM,	
	CAST(PatientEncounter.AppointmentStatusCD AS VARCHAR(300))                                                 AS APPOINTMENT_STATUS_CD,	
	CAST(PatientEncounter.AppointmentStatusDSC AS VARCHAR(300))                                                AS APPOINTMENT_STATUS_DSC,	
	CAST(DATENAME(WEEKDAY, AvailableUtilization.SlotBeginDTS) AS VARCHAR(300))                                 AS DAY_OF_WEEK_NM,	
	DATEADD(MINUTE, AvailableUtilization.SlotLengthMinuteNBR, AvailableUtilization.SlotBeginDTS)               AS SLOT_END_DTS,
	AvailableUtilization.SlotLengthMinuteNBR                                                                   AS SLOT_LENGTH_MINUTE_NBR,
	CAST(
    IIF( (DATEPART(WEEKDAY, AvailableUtilization.SlotBeginDTS) BETWEEN 2 AND 6) /* WeekDay */
		AND ((CONVERT(VARCHAR, AvailableUtilization.SlotBeginDTS, 8) >= '08:00:00')
		AND (CONVERT(VARCHAR, AvailableUtilization.SlotBeginDTS, 8) < '18:00:00'))  /* 8AM - 6PM */
	,'Y','N')
    AS VARCHAR(300))                                                                                          AS PRIME_TIME_SLOT_FLG,
	CAST(AvailableUtilization.UnavailableReasonCD AS VARCHAR(300))                                              AS UNAVAILABLE_REASON_CD,	
	CAST(AvailableUtilization.UnavailableReasonDSC AS VARCHAR(300))                                             AS UNAVAILABLE_REASON_DSC,



  CASE 
	WHEN  PatientEncounter.AppointmentStatusCD IN (6 /*Arrived*/, 2 /*Completed*/) 
	OR
	AvailableUtilization.UnavailableReasonCD IS NULL  /* available */
	THEN 1
	ELSE 0
	END                                                                                                       AS SLOT_AVAILABILITY_FLG,




	CAST(	CASE 
	WHEN  PatientEncounter.AppointmentStatusCD IN (6 /*Arrived*/, 2 /*Completed*/) 
	OR
	AvailableUtilization.UnavailableReasonCD IS NULL  /* available */
	THEN 'Available'
	ELSE 'Unavailable'
  
	END  
    AS VARCHAR(300))                                                                                          AS SLOT_AVAILABILITY_DSC,




	CAST(CASE WHEN PatientEncounter.AppointmentStatusCD IN (6 /*Arrived*/, 2 /*Completed*/) 
			THEN 1
     		ELSE 0
	 END 
    AS VARCHAR(300))                                                                                          AS SLOT_USED_FLG,
	CAST(CASE WHEN PatientEncounter.AppointmentStatusCD IN (6 /*Arrived*/, 2 /*Completed*/) 
			THEN 'Utilized'
		 ELSE 'Not Utilized' 
	 END
   AS VARCHAR(300))
                                                                                                              AS SLOT_USED_DSC,
	CAST(CASE WHEN AvailableUtilization.TimeUnavailableFLG = 'Y' AND AvailableUtilization.DayUnavailableFLG='Y' 
			THEN 'Day and Time Unavailable'
		  WHEN AvailableUtilization.TimeUnavailableFLG = 'N' AND AvailableUtilization.DayUnavailableFLG='Y' 
			THEN 'Day Unavailable'
          WHEN AvailableUtilization.TimeUnavailableFLG = 'Y' AND AvailableUtilization.DayUnavailableFLG='N' 
			THEN 'Time Unavailable'
          ELSE NULL
	END
   AS VARCHAR(300))                                                                                           AS SLOT_UNAVAILABILITY_DSC,
  IncrementalHelper_SLOT_DETAIL.EDWLastModifiedDTS                                                            AS EDW_LAST_MODIFIED_DTS
FROM SAM.EAMImaging.EventAvailableUtilization AvailableUtilization

INNER JOIN SAM.EAMImaging.IncrementalHelper_SLOT_DETAIL
ON 	IncrementalHelper_SLOT_DETAIL.SlotBeginDTS = AvailableUtilization.SlotBeginDTS
AND IncrementalHelper_SLOT_DETAIL.ProviderID  = AvailableUtilization.ProviderID

INNER JOIN SAM.EAMImaging.PopulationSlot
ON 	PopulationSlot.SlotBeginDTS = AvailableUtilization.SlotBeginDTS
AND PopulationSlot.DepartmentID = AvailableUtilization.DepartmentID
AND PopulationSlot.ProviderID   = AvailableUtilization.ProviderID
AND PopulationSlot.AppointmentSEQ = AvailableUtilization.AppointmentSEQ

LEFT JOIN Epic.Encounter.PatientEncounter
	ON PatientEncounter.PatientEncounterID = AvailableUtilization.PatientEncounterID
INNER JOIN SAM.EAMImaging.DomainResource	
	ON DomainResource.ResourceID = AvailableUtilization.ProviderID
  AND DomainResource.MetricInclusionFLG = 'Y'
LEFT JOIN Epic.Reference.Department
	ON AvailableUtilization.DepartmentID = Department.DepartmentID
LEFT JOIN Epic.Reference.[Location]
	ON Location.LocationID = Department.RevenueLocationID
LEFT JOIN Epic.Reference.[Location] ParentLocation
	ON Location.ADTParentID = ParentLocation.LocationID
WHERE
NOT EXISTS
(SELECT 'Test Patient Exclusion'
FROM SAM.EAMImaging.RuleExcludeTestPatient
WHERE PatientEncounter.PatientID = RuleExcludeTestPatient.PatientEpicID)
AND NOT EXISTS
(
SELECT 'Exclude Non-Templated Machine'
FROM SAM.EAMImaging.DomainConfiguration
WHERE AvailableUtilization.ProviderID = ConfigurationValueTXT 
AND DomainConfiguration.ConfigurationItemDSC = 'Exclude Non-Templated Machine'
)

