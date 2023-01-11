/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: EventPsychBoarders
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT * FROM
(
  SELECT ProcedureOrderFact.ProcedureOrderEpicId
        ,ProcedureOrderFact.ProcedureDurableKey
        ,ProcedureOrderFact.DepartmentKey
	      ,EventDepartments.DepartmentName
	      ,EventDepartments.DepartmentSpecialty
        ,Procedure2.PatientLocationID AS 'PsychBoarderDepartmentID'
	      ,Procedure2.PatientLocationDSC AS 'PsychBoarderDepartmentNM'
        ,ProcedureOrderFact.EncounterKey
        ,EncounterFact.PatientKey
        ,EncounterFact.EncounterEpicCsn
        ,EncounterFact.DateKey
        ,EncounterFact.Date
        ,EncounterFact.EndDateKey
        ,EncounterFact.EndInstant
        ,EncounterFact.DischargeDisposition
        ,EncounterFact.PrimaryCoverageKey
        ,PatientDim.BirthDate
        ,ProcedureOrderFact.OrderedInstant
        ,ProcedureOrderFact.OrderedDateKey
        ,ProcedureOrderFact.PatientDurableKey
        ,ProcedureDim.Code AS ProcCode
        ,CAST(ProcedureDim.Name AS VARCHAR(255)) AS CodeName
        ,ProcedureOrderFact.EDWLastModifiedDTS
        ,EncounterFact.IsDeleted
        ,ROW_NUMBER() OVER ( PARTITION BY PatientDim.DurableKey ORDER BY PatientDim.StartDate DESC) AS LatestRecordRank
        ,ROW_NUMBER() OVER(PARTITION BY ProcedureOrderFact.EncounterKey ORDER BY ProcedureOrderFact.OrderedInstant ASC) AS RowNum

 FROM EpicMart.Caboodle.ProcedureOrderFact
 
 LEFT JOIN Epic.Orders.Procedure2
	ON Procedure2.OrderProcedureID = ProcedureOrderFact.ProcedureOrderEpicId
 
 LEFT JOIN EpicMart.Caboodle.EncounterFact
   ON ProcedureOrderFact.EncounterKey = EncounterFact.EncounterKey
   
 LEFT JOIN EpicMart.Caboodle.PatientDim
  ON PatientDim.DurableKey = ProcedureOrderFact.PatientDurableKey
 AND PatientDim.IsCurrent = 'True'
 
 INNER JOIN EpicMart.Caboodle.ProcedureDim
   ON ProcedureDim.ProcedureKey = ProcedureOrderFact.ProcedureKey 

LEFT JOIN SAM.EAMBehavioral.EventDepartments
  ON EventDepartments.DepartmentKey = ProcedureOrderFact.DepartmentKey
    
WHERE NOT EXISTS
  (
  SELECT 'Behavioral Health Departments'
    FROM SAM.EAMBehavioral.DomainConfiguration
   WHERE DomainConfiguration.ConfigurationItemDSC = 'DepartmentEpicId'
     AND DomainConfiguration.ConfigurationValueTXT = EventDepartments.DepartmentEpicId
 )
 
  AND NOT EXISTS
  (
  SELECT 'Behavioral Health Department Specialty'
    FROM SAM.EAMBehavioral.DomainConfiguration
   WHERE DomainConfiguration.ConfigurationItemDSC = 'DepartmentSpecialty'
     AND DomainConfiguration.ConfigurationValueTXT = EventDepartments.DepartmentSpecialty
 )
 
AND NOT EXISTS
  (
  SELECT 'Behavioral Health Patient Location'
    FROM SAM.EAMBehavioral.DomainConfiguration
   WHERE DomainConfiguration.ConfigurationItemDSC = 'PatientLocationID'
     AND DomainConfiguration.ConfigurationValueTXT = Procedure2.PatientLocationID
 )

AND EXISTS 
  (SELECT 'Include Behavioral Pysch Boarder Orders'
     FROM SAM.EAMBehavioral.DomainConfiguration
    WHERE DomainConfiguration.ConfigurationValueTXT = ProcedureDim.Code
      AND DomainConfiguration.ConfigurationItemDSC = 'BehavioralProcedureIP')
) Filtered
WHERE Filtered.LatestRecordRank = 1
  AND Filtered.RowNum = 1

  
