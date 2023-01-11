/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: RuleGetFirstEDOrder
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

  SELECT EventOrders.EncounterKey
        ,EventOrders.ProcedureOrderEpicId 
    FROM SAM.EAMBehavioral.EventOrders
   WHERE EventOrders.RowNum = 1
 
   UNION

  SELECT EventPsychNotes.EncounterKey
        ,0
    FROM SAM.EAMBehavioral.EventPsychNotes