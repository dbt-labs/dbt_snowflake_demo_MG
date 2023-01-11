/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: PopulationInpatientVisit
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT EventIPVisitFact.EncounterKey
      ,EventIPVisitFact.PatientDurableKey
    	,EventIPVisitFact.ADMISSION_DATE
    	,EventIPVisitFact.DISCHARGE_DATE
      ,EventIPVisitFact.DepartmentEpicId
      ,EventIPVisitFact.HospitalService
      ,DATEDIFF(DAY, CAST(EventIPVisitFact.ADMISSION_DATE AS DATE), CAST(EventIPVisitFact.DISCHARGE_DATE AS DATE)) AS LengthOfStayInDays
      ,CASE 
        WHEN EventOrders.ProcedureOrderEpicId IS NOT NULL THEN EventOrders.ProcedureOrderEpicId
        ELSE -1
       END AS ProcedureOrderEpicId
  FROM SAM.EAMBehavioral.EventIPVisitFact
  LEFT JOIN SAM.EAMBehavioral.EventOrders
    ON EventOrders.EncounterKey = EventIPVisitFact.EncounterKey
  
 WHERE ((EventIPVisitFact.DepartmentEpicId = '10040010053' /* This department has a mix of Behavioral and non behavioral  */
        AND EventIPVisitFact.HospitalService = 'Addiction') 
	  OR  EventIPVisitFact.DepartmentEpicId <> '10040010053') /* This department has a mix of Behavioral and non behavioral  */
    
   AND EXISTS
     (SELECT 'Get First Behavioral IP Order'
	    FROM SAM.EAMBehavioral.RuleGetFirstIPOrder
	   WHERE EventIPVisitFact.EncounterKey = RuleGetFirstIPOrder.EncounterKey
       AND ISNULL(EventOrders.ProcedureOrderEpicId, -1) = RuleGetFirstIPOrder.ProcedureOrderEpicId)

   AND EXISTS
    (SELECT 'Include Departments'
	     FROM SAM.EAMBehavioral.RuleIncludeDepartment
	    WHERE EventIPVisitFact.DepartmentEpicId = RuleIncludeDepartment.DepartmentEpicId)
 
   AND NOT EXISTS 
  	(SELECT 'Exclude Test Patient'
  	   FROM SAM.EAMBehavioral.RuleExcludeTestPatient
  	  WHERE EventIPVisitFact.PatientDurableKey = RuleExcludeTestPatient.DurableKey)