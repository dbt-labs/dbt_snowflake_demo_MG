/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: Population7AMCensus
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

  SELECT
		 Dates.CalendarDate
		,Dates.CalendarDateAt7AM
		,EventADTRecords.PatientEncounterID
    ,EventADTRecords.PatientID
		,EventADTRecords.EventID
		,EventADTRecords.EffectiveDTS
		,EventADTRecords.NextEventEffectiveDTS
		,EventADTRecords.ADTEventTypeCD
		,EventADTRecords.ADTEventTypeDSC
		,EventADTRecords.DepartmentID
    ,EventDepartments.DepartmentName
		,EventDepartments.HospitalParentLocationID
		,EventADTRecords.BedID		/*included for validation, and not needed at the final level*/
		,EventADTRecords.RoomID		/*included for validation, and not needed at the final level*/
		,1 AS OccupiedAt7amFLG /*this is the 7am census and we need to join this to get the IP Med Surg Occupancy at 7am metric*/
    ,EventADTRecords.EDWLastModifiedDTS
	FROM
		SAM.EAMBehavioral.EventADTRecords
	LEFT JOIN SAM.EAMBehavioral.EventDepartments
		ON EventDepartments.DepartmentEpicId = EventADTRecords.DepartmentID
		/*Need to report record on each eligible day for the encounter at 7am*/
		CROSS APPLY (
			SELECT 
				EventDateDimension.CalendarDate
				,EventDateDimension.CalendarDateAt7AM
			FROM 
				SAM.EAMBehavioral.EventDateDimension
			WHERE 
				EventDateDimension.CalendarDateAt7AM >= EventADTRecords.EffectiveDTS AND EventDateDimension.CalendarDateAt7AM < EventADTRecords.NextEventEffectiveDTS
				) AS Dates
	WHERE EventADTRecords.Excludein7amCensusFLG = 0 /*excludes event types that would skew the 7am Census*/
  
  AND NOT EXISTS 
  	(SELECT 'Exclude Test Patient'
  	FROM SAM.EAMBehavioral.RuleExcludeTestPatient
  	WHERE EventADTRecords.PatientID = RuleExcludeTestPatient.PatientID)
  