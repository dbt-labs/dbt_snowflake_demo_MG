/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: EventEDPsychBoarders
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
SELECT * FROM 
(
SELECT 
     PatientDim.PatientKey
    ,PatientDim.DurableKey AS PatientDurableKey
    ,ProcedureOrderFact.ProcedureOrderEpicId
    ,ProcedureOrderFact.ProcedureDurableKey
    ,ProcedureOrderFact.OrderedInstant
    ,ProcedureOrderFact.EncounterKey
    ,EncounterFact.EncounterEpicCsn
    ,EncounterFact.PrimaryCoverageKey
    ,EncounterFact.DateKey
	  ,ProcedureOrderFact.Status
    ,ProcedureOrderFact.OrderedDateKey
	  ,OrderSum.SummaryTXT
    ,ProcedureOrderFact.DepartmentKey
	  ,Department.DepartmentNM
	  ,Department.DepartmentSpecialtyCD
    ,Department.DepartmentSpecialtyDSC
	  ,Location.RevenueLocationNM
    ,ProcedureDim.Code AS ProcCode
	  ,CAST(ProcedureDim.Name AS VARCHAR(255)) AS CodeName
    ,(SELECT MAX(v) FROM (VALUES 
     (ProcedureOrderFact.EDWLastModifiedDTS),
     (ProcedureDim.EDWLastModifiedDTS),
     (Procedure2.EDWLastModifiedDTS),
     (Department.EDWLastModifiedDTS),
     (Location.EDWLastModifiedDTS),
     (ProcedureOrderFact.EDWLastModifiedDTS),
     (OrderSum.EDWLastModifiedDTS),
     (EncounterFact.EDWLastModifiedDTS),
     (PatientDim.EDWLastModifiedDTS)
     ) AS VALUE(v) ) AS EDWLastModifiedDTS   
    ,PatientDim.BirthDate
    ,EDVisitFact.ArrivalInstant
	  ,EDVisitFact.DepartureInstant
    ,CASE 
      WHEN EDVisitFact.DepartureInstant IS NULL
		  THEN GETDATE()
		  ELSE EDVisitFact.DepartureInstant 
	   END AS EDDeparture
    ,RANK() OVER ( PARTITION BY PatientDim.DurableKey ORDER BY PatientDim.StartDate DESC) AS Row_Num
    ,ROW_NUMBER() OVER(PARTITION BY ProcedureOrderFact.EncounterKey ORDER BY ProcedureOrderFact.OrderedInstant ASC) AS Order_Num
FROM EpicMart.Caboodle.ProcedureOrderFact
INNER JOIN EpicMart.Caboodle.ProcedureDim
    ON ProcedureDim.ProcedureKey = ProcedureOrderFact.ProcedureKey
LEFT JOIN Epic.Orders.Procedure2
	ON ProcedureOrderFact.ProcedureOrderEpicId = Procedure2.OrderProcedureID
LEFT JOIN Epic.Reference.Department
	ON Procedure2.PatientLocationID = Department.DepartmentID
LEFT JOIN epic.Reference.Location
	ON Location.LocationID = Department.ADTParentID
LEFT JOIN Epic.Orders.OrderSummary OrderSum
	ON OrderSum.OrderID = ProcedureOrderFact.ProcedureOrderEpicID
  
LEFT JOIN EpicMart.Caboodle.EncounterFact
   ON ProcedureOrderFact.EncounterKey = EncounterFact.EncounterKey
   
LEFT JOIN EpicMart.Caboodle.EDVisitFact
  ON EDVisitFact.EncounterKey = ProcedureOrderFact.EncounterKey
  
LEFT JOIN EpicMart.Caboodle.PatientDim
  ON PatientDim.DurableKey = ProcedureOrderFact.PatientDurableKey
 AND PatientDim.IsCurrent = 'True'
 
WHERE EXISTS
(
   SELECT 'ED Psych Boarder Orders'
     FROM SAM.EAMBehavioral.DomainConfiguration
    WHERE DomainConfiguration.ConfigurationValueTXT = ProcedureDim.Code
      AND DomainConfiguration.ConfigurationItemDSC = 'EDPsychBoarderProcedure'
)

AND EXISTS

(
  SELECT 'ED Psych Boarder Department Specialty'
    FROM SAM.EAMBehavioral.DomainConfiguration
   WHERE DomainConfiguration.ConfigurationValueTXT = Department.DepartmentSpecialtyCD
     AND DomainConfiguration.ConfigurationItemDSC = 'EDPsychBoarderSpecialty'
 )
) Ranked
WHERE Ranked.Row_Num = 1
  AND Ranked.OrderedInstant >= Ranked.ArrivalInstant 
	AND Ranked.OrderedInstant <= Ranked.EDDeparture
  AND Ranked.Order_Num = 1