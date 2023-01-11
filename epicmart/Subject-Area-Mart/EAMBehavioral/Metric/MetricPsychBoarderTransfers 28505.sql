/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: MetricPsychBoarderTransfers
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
WITH EDBoardersAt7am AS
(
SELECT * FROM 
(
SELECT 
 TransferCenterRequestFact.RequestStartDateTime
,TransferCenterRequestFact.RequestResolutionDateTime
,TransferCenterRequestFact.TransferCenterRequestEpicId
,TransferCenterRequestFact.PatientDurableKey
,TransferCenterRequestFact.IntakeEncounterKey
,EventEDPsychBoarders.EncounterKey
,EventEDPsychBoarders.DepartmentKey
,EventEDPsychBoarders.DateKey
,EventEDPsychBoarders.PatientKey
,EventEDPsychBoarders.BirthDate
,TransferCenterRequestFact.TransferType
,CASE WHEN TransferCenterRequestFact.MinutesFromStartToResolution IS NOT NULL
	  THEN TransferCenterRequestFact.MinutesFromStartToResolution
	  WHEN TransferCenterRequestFact.MinutesFromStartToResolution IS NULL
	  THEN (DATEDIFF(MINUTE, TransferCenterRequestFact.RequestStartDateTime, GETDATE()))
  END																						AS MinutesFromStartToResolution
,CASE WHEN TransferCenterRequestFact.RequestResolutionDateTime IS NOT NULL
	  THEN (TransferCenterRequestFact.MinutesFromStartToResolution / 60) 
	  WHEN TransferCenterRequestFact.RequestResolutionDateTime IS NULL
      THEN (DATEDIFF(MINUTE, TransferCenterRequestFact.RequestStartDateTime, GETDATE())/60)
  END																						AS HoursBetween
,CASE WHEN TransferCenterRequestFact.RequestResolutionDateTime IS NOT NULL AND (TransferCenterRequestFact.MinutesFromStartToResolution / 60) >=2
	  THEN 1
	  WHEN TransferCenterRequestFact.RequestResolutionDateTime IS NULL AND (DATEDIFF(MINUTE, TransferCenterRequestFact.RequestStartDateTime, GETDATE())/60)>=2
	  THEN 1
	  ELSE 0
  END																						AS BoarderEligibleFlg
,TransferCenterRequestFact.MinutesFromStartToAccept
,TransferCenterRequestFact.RequestStatus
,TransferCenterRequestFact.AcceptedThenCanceled
,TransferCenterRequestFact.CancelReason
,EventEDPsychBoarders.EncounterEpicCsn
,EventEDPsychBoarders.ProcedureOrderEpicId
,EventEDPsychBoarders.ProcedureDurableKey
,EventEDPsychBoarders.OrderedInstant
,EventEDPsychBoarders.OrderedDateKey
,EventEDPsychBoarders.ProcCode
,EventEDPsychBoarders.CodeName
,EventEDPsychBoarders.ArrivalInstant
,EventEDPsychBoarders.DepartureInstant
,EventEDPsychBoarders.EDDeparture
,ROW_NUMBER() OVER(PARTITION BY EventEDPsychBoarders.EncounterKey ORDER BY TransferCenterRequestFact.RequestStartDateTime ASC) AS Row_Num
,(SELECT MAX(v) FROM (VALUES 
  (TransferCenterRequestFact.EDWLastModifiedDTS),
  (EventEDPsychBoarders.EDWLastModifiedDTS) 
  ) AS VALUE(v) ) AS EDWLastModifiedDTS
FROM EpicMart.Caboodle.TransferCenterRequestFact
LEFT JOIN SAM.EAMBehavioral.EventEDPsychBoarders 
  ON 	EventEDPsychBoarders.PatientDurableKey = TransferCenterRequestFact.PatientDurableKey
WHERE TransferCenterRequestFact.TransferType IN ('Inpatient','External','IP to IP','ED to IP','ESP Bed Seach')
and (TransferCenterRequestFact.RequestStartDateTime >= EventEDPsychBoarders.ArrivalInstant and TransferCenterRequestFact.RequestStartDateTime <= EventEDPsychBoarders.EDDeparture)
  
  AND EXISTS (SELECT 'Behavioral ED Boarder Order'
               FROM SAM.EAMBehavioral.EventEDPsychBoarders 
              WHERE EventEDPsychBoarders.PatientDurableKey = TransferCenterRequestFact.PatientDurableKey)
) Filtered
WHERE Filtered.Row_Num = 1
)

SELECT Dates.CalendarDate
	  ,Dates.CalendarDateAt7AM
    ,EDBoardersAt7am.DateKey
	  ,EDBoardersAt7am.EncounterEpicCsn				AS PatientEncounterID
	  ,EDBoardersAt7am.RequestStartDateTime
	  ,EDBoardersAt7am.RequestResolutionDateTime
	  ,EDBoardersAt7am.TransferCenterRequestEpicId
	  ,EDBoardersAt7am.PatientDurableKey
    ,EDBoardersAt7am.PatientKey
	  ,EDBoardersAt7am.IntakeEncounterKey
    ,EDBoardersAt7am.EncounterKey
    ,EDBoardersAt7am.DepartmentKey
	  ,EDBoardersAt7am.TransferType
	  ,EDBoardersAt7am.MinutesFromStartToResolution
	  ,EDBoardersAt7am.HoursBetween
	  ,EDBoardersAt7am.RequestStatus
	  ,EDBoardersAt7am.AcceptedThenCanceled
	  ,EDBoardersAt7am.CancelReason
    ,EDBoardersAt7am.BirthDate
    ,EDBoardersAt7am.ProcedureOrderEpicId
    ,EDBoardersAt7am.ProcedureDurableKey
    ,EDBoardersAt7am.OrderedInstant
    ,EDBoardersAt7am.OrderedDateKey
    ,EDBoardersAt7am.ProcCode
    ,EDBoardersAt7am.CodeName
    ,EDBoardersAt7am.EDWLastModifiedDTS
	  
  FROM EDBoardersAt7am
 CROSS APPLY (
			  SELECT CalendarDate
					,CalendarDateAt7AM
			    FROM SAM.EAMBehavioral.EventDateDimension
			   WHERE CalendarDateAt7AM >= EDBoardersAt7am.RequestStartDateTime AND CalendarDateAt7AM <= EDBoardersAt7am.EDDeparture
	) AS Dates
WHERE EDBoardersAt7am.BoarderEligibleFlg = 1
  AND (EDBoardersAt7am.RequestStartDateTime >= EDBoardersAt7am.ArrivalInstant and EDBoardersAt7am.RequestStartDateTime <= EDBoardersAt7am.EDDeparture)