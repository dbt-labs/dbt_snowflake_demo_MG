/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: PopulationPsychBoarders
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT
	   EventPsychBoarders.ProcedureOrderEpicId
    ,EventPsychBoarders.ProcedureDurableKey
    ,EventPsychBoarders.DepartmentKey
	  ,EventPsychBoarders.DepartmentName
	  ,EventPsychBoarders.DepartmentSpecialty
    ,EventPsychBoarders.PatientKey
    ,EventPsychBoarders.Birthdate
    ,EventPsychBoarders.EncounterKey
    ,EventPsychBoarders.EncounterEpicCsn
    ,EventPsychBoarders.DateKey
    ,EventPsychBoarders.Date
    ,EventPsychBoarders.EndDateKey
    ,EventPsychBoarders.EndInstant
    ,EventPsychBoarders.DischargeDisposition
    ,EventPsychBoarders.OrderedInstant
    ,EventPsychBoarders.OrderedDateKey
    ,EventPsychBoarders.PatientDurableKey
    ,EventPsychBoarders.ProcCode
    ,EventPsychBoarders.CodeName
    ,EventPsychBoarders.PrimaryCoverageKey
    ,EventPsychBoarders.IsDeleted
    ,EventPsychBoarders.EDWLastModifiedDTS

	  FROM SAM.EAMBehavioral.EventPsychBoarders
  
 WHERE NOT EXISTS 
  	(SELECT 'Exclude Test Patient'
  	FROM SAM.EAMBehavioral.RuleExcludeTestPatient
  	WHERE EventPsychBoarders.PatientDurableKey = RuleExcludeTestPatient.DurableKey)
    
    
 