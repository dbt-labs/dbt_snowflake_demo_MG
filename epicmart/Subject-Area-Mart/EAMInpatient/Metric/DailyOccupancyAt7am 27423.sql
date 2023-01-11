/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: DailyOccupancyAt7am
Description: This binding creates a 7am census by spreading ADT events encompassing 7am across all days
History:

Date		  User		     TFS#	          Description
20220502	ms2			     164957         Initial script creation
20220525	ms2			     167885         Redefine census - count INP class in all departments but only count OBS, PPR classes if in a MedSurg or ICU department
20221117  KG312        ADO PR !12451  Remove class filter on MedSurg Bed include NonMedSurg service in a MedSurg bed
*********************************************************************************************************************************************************/
	SELECT
		 Dates.CalendarDate
		,Dates.CalendarDateAt7AM
		,ADT.PatientEncounterID
		,ADT.EventID
		,ADT.EffectiveDTS
		,ADT.NextEventEffectiveDTS
		,ADT.ADTEventTypeCD
		,ADT.ADTEventTypeDSC
		,ADT.DepartmentID
		,ADT.EAMServiceGrouping
		,Departments.HospitalParentLocationID
		,CASE WHEN Departments.DepartmentIsICUFLG =1 THEN 'ICU'
		      WHEN Departments.DepartmentIsMedSurgFLG =1 THEN 'MedSurg'
		      ELSE NULL
		  END AS 'NewMedSurgICUFlg'
		,ADT.BedID		/*included for validation, and not needed at the final level*/
		,ADT.RoomID		/*included for validation, and not needed at the final level*/
		,1 AS OccupiedAt7amFLG /*this is the 7am census and we need to join this to get the IP Med Surg Occupancy at 7am metric*/
	FROM
		      SAM.EAMInpatient.ADTSource ADT
LEFT JOIN SAM.EAMInpatient.Departments
		ON Departments.DepartmentID = ADT.DepartmentID
		/*Need to report record on each eligible day for the encounter at 7am*/
		CROSS APPLY (
			SELECT 
				CalendarDate
				,CalendarDateAt7AM
			FROM 
				SAM.EAMInpatient.DateDimension
			WHERE 
				CalendarDateAt7AM >= ADT.EffectiveDTS AND CalendarDateAt7AM < ADT.NextEventEffectiveDTS
				) AS Dates
	WHERE
       (
	        (ADT.ServiceInclusionFLG = 1  AND ADT.DepartmentInclusionFLG = 1)
        OR
	        (ADT.ServiceInclusionFLG = 1 AND ADT.PatientClassCD ='101' AND ADT.DepartmentInclusionFLG = 0)
		    OR
	        (ADT.ServiceInclusionFLG = 0 AND ADT.DepartmentInclusionFLG = 1)
		    )
		AND ADT.Excludein7amCensusFLG = 0 /*excludes event types that would skew the 7am Census*/ 
  
