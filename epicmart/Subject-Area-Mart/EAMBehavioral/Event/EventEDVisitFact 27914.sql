/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: EventEDVisitFact
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT *
  FROM (
        SELECT
             EDVisitFact.ArrivalDateKey
        	  ,CAST(SUBSTRING(CONVERT(varchar, DateDim.DateValue), 1, 10) + ' ' +
        	   SUBSTRING(CONVERT(varchar, TimeOfDayDim.TimeValue), 1, 8) AS datetime) AS ArrivalDateTime
            ,EDVisitFact.ArrivalInstant
            ,EDVisitFact.EdDepartmentKey
            ,DepartmentDim.DepartmentEpicId
            ,EDVisitFact.PatientDurableKey
            ,PatientDim.PatientKey
            ,PatientDim.BirthDate
            ,EncounterFact.PatientClassCategoryKey
            ,EDVisitFact.EncounterEpicCsn
            ,EDVisitFact.EncounterKey
            ,EDVisitFact.CoverageKey
            ,CAST(EDVisitFact.EDDisposition AS varchar(255)) AS DischargeDisposition
            ,EDVisitFact.DepartureInstant AS EDDischarge 
            ,EDVisitFact.IsDeleted
            ,ROW_NUMBER() OVER ( PARTITION BY PatientDim.DurableKey, EDVisitFact.EncounterKey ORDER BY PatientDim.StartDate DESC) AS LatestRecordRank
            ,EDVisitFact.EDWLastModifiedDTS
            
        FROM EpicMart.Caboodle.EDVisitFact

        LEFT JOIN EpicMart.Caboodle.PatientDim
          ON PatientDim.DurableKey = EDVisitFact.PatientDurableKey
         AND PatientDim.IsCurrent = 'True'

        LEFT JOIN EpicMart.Caboodle.DateDim  
          ON DateDim.DateKey = EDVisitFact.ArrivalDateKey
          
        LEFT JOIN EpicMart.Caboodle.DepartmentDim
          ON DepartmentDim.DepartmentKey = EDVisitFact.EdDepartmentKey

        LEFT JOIN EpicMart.Caboodle.TimeOfDayDim
          ON TimeOfDayDim.TimeOfDayKey = EDVisitFact.ArrivalTimeOfDayKey
          
        LEFT JOIN EpicMart.Caboodle.EncounterFact 
          ON EncounterFact.EncounterKey = EDVisitFact.EncounterKey
          
        WHERE (EXISTS 
          (SELECT 'Behavioral Order Encounter'
             FROM SAM.EAMBehavioral.EventOrders
            WHERE EventOrders.EncounterKey = EDVisitFact.EncounterKey)
            
           OR EXISTS
             (SELECT 'Psych Note Encounter'
               FROM SAM.EAMBehavioral.EventPsychNotes
              WHERE EventPsychNotes.EncounterEpicCSN = EDVisitFact.EncounterEpicCsn))
        ) Ranked   
WHERE Ranked.LatestRecordRank = 1 
  