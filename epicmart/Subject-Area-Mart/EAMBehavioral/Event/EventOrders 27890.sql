/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: EventOrders
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT ProcedureOrderFact.ProcedureOrderEpicId
      ,ProcedureOrderFact.ProcedureDurableKey
      ,ProcedureOrderFact.DepartmentKey
      ,ProcedureOrderFact.EncounterKey
      ,ProcedureOrderFact.OrderedInstant
      ,ProcedureOrderFact.OrderedDateKey
      ,ProcedureOrderFact.PatientDurableKey
      ,ProcedureDim.Code AS ProcCode
      ,CAST(ProcedureDim.Name AS VARCHAR(255)) AS CodeName
      ,ProcedureOrderFact.EDWLastModifiedDTS
      ,ROW_NUMBER() OVER(PARTITION BY ProcedureOrderFact.EncounterKey ORDER BY ProcedureOrderFact.ProcedureOrderEpicId) AS RowNum

 FROM EpicMart.Caboodle.ProcedureOrderFact
 
 INNER JOIN EpicMart.Caboodle.EDVisitFact
   ON EDVisitFact.EncounterKey = ProcedureOrderFact.EncounterKey
  AND ProcedureOrderFact.OrderedInstant >= EDVisitFact.ArrivalInstant
	AND ProcedureOrderFact.OrderedInstant <= EDVisitFact.DepartureInstant 

INNER JOIN EpicMart.Caboodle.ProcedureDim
   ON ProcedureDim.ProcedureKey = ProcedureOrderFact.ProcedureKey 
    
WHERE EXISTS
   (SELECT 'Behavioral Order'
      FROM SAM.EAMBehavioral.DomainConfiguration
     WHERE DomainConfiguration.ConfigurationItemDSC = 'BehavioralProcedureED'
       AND DomainConfiguration.ConfigurationValueTXT = ProcedureDim.Code
   )
   
