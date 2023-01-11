/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: EDVisitFactStage
Description: This binding joins ED visit details to events

History:

Date		  User		 TFS#	  Description
20220609	cx127	  169482  New binding to source all columns needed from EDVisitFact for metrics overlapping domains
20221130  KG312   !12451  Bring in EDDepartureDate
*********************************************************************************************************************************************************/
	SELECT 
    MedSurgAdmissionEncounter.PatientEncounterID
    ,ArrivedtoED
    ,CAST(EDVisitFact.ArrivalInstant AS date) AS EDArrivalDate
    ,IsBoarder
    ,BoarderDurationInMinutes
    ,CASE 
		  WHEN EdVisitFact.DepartureInstant IS NOT NULL
		    THEN CAST(EDVisitFact.DepartureInstant AS date) 
		  ELSE CAST(DATEADD(minute,BoarderDurationInMinutes,EDVisitFact.ArrivalInstant)AS date)
	   END AS EDDepartureDate
	FROM SAM.EAMInpatient.ADTSource MedSurgAdmissionEncounter
    INNER JOIN EpicMart.Curated.EDVisitFact
      ON MedSurgAdmissionEncounter.PatientEncounterID = EDVisitFact.EncounterEpicCsn
	WHERE 
    MedSurgAdmissionEncounter.IsFirstQualifyingAdmitEvent = 1
    AND EDVisitFact.IsDepartmentEmergency = 1 /*Limit to the EAM ED Domain population*/