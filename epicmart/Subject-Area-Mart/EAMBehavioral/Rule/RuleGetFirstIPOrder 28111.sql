/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: RuleGetFirstIPOrder
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT EventIPVisitFact.EncounterKey
      ,ISNULL(EventOrders.ProcedureOrderEpicId, -1) AS ProcedureOrderEpicId
  FROM SAM.EAMBehavioral.EventIPVisitFact

  LEFT JOIN SAM.EAMBehavioral.EventOrders
    ON EventOrders.EncounterKey = EventIPVisitFact.EncounterKey
  
  WHERE (EventOrders.RowNum = 1 OR ISNULL(EventOrders.ProcedureOrderEpicId, -1) = -1)