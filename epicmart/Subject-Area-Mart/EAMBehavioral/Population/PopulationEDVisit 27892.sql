/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: PopulationEDVisit
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT EventEDVisitFact.EncounterKey
      ,ISNULL(EventOrders.ProcedureOrderEpicId, 0) AS ProcedureOrderEpicId
      ,ISNULL(EventOrders.ProcedureDurableKey, 0) AS ProcedureDurableKey
      ,EventOrders.OrderedInstant					        AS ORDER_INSTANT
      ,EventOrders.OrderedDateKey					        AS ORDER_DATE_KEY
      ,ISNULL(EventOrders.ProcCode, 'NA')        AS ProcCode
      ,ISNULL(EventOrders.CodeName, 'NA')         AS CodeName
      ,EventEDVisitFact.PatientDurableKey
      ,EventEDVisitFact.PatientKey
      ,EventEDVisitFact.ArrivalDateTime
      ,EventEDVisitFact.EDDischarge
	  ,CASE 
		WHEN EventPsychNotes.PsychFLG = 1 THEN 1
		ELSE 0
	   END AS PsychNote

  FROM SAM.EAMBehavioral.EventEDVisitFact
  LEFT JOIN SAM.EAMBehavioral.EventOrders
    ON EventOrders.EncounterKey = EventEDVisitFact.EncounterKey

  LEFT JOIN SAM.EAMBehavioral.EventPsychNotes
    ON EventPsychNotes.EncounterKey = EventEDVisitFact.EncounterKey
  
 WHERE EXISTS
    (SELECT 'Get First Behavioral ED Order'
	    FROM SAM.EAMBehavioral.RuleGetFirstEDOrder
	   WHERE EventEDVisitFact.EncounterKey = RuleGetFirstEDOrder.EncounterKey
       AND (EventOrders.ProcedureOrderEpicId = RuleGetFirstEDOrder.ProcedureOrderEpicId
        OR RuleGetFirstEDOrder.ProcedureOrderEpicId = 0))
            
  AND NOT EXISTS 
	(SELECT 'Exclude Test Patient'
	FROM SAM.EAMBehavioral.RuleExcludeTestPatient
	WHERE EventEDVisitFact.PatientDurableKey = RuleExcludeTestPatient.DurableKey)