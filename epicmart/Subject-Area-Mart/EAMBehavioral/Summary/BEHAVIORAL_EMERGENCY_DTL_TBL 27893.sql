/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: BEHAVIORAL_EMERGENCY_DTL_TBL
Description: Emergency department visit grain details for metrics at that grain, encounter key.

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT 
       EventEDVisitFact.ArrivalDateKey									              AS ARRIVAL_DATE_KEY
      ,EventEDVisitFact.ArrivalDateTime									              AS ARRIVAL_DTS
      ,EventEDVisitFact.EdDepartmentKey									              AS ED_DEPARTMENT_KEY
      ,EventEDVisitFact.PatientDurableKey								              AS PATIENT_DURABLE_KEY
      ,EventEDVisitFact.PatientKey										                AS PATIENT_KEY
      ,CASE
         WHEN ((CONVERT(int, CONVERT(char(8), EventEDVisitFact.ArrivalDateTime, 112)) - CONVERT(char(8), EventEDVisitFact.BirthDate, 112)) / 10000) BETWEEN 0 AND 17
         THEN CAST('Child'							        AS varchar(5000)) 
         
         WHEN ((CONVERT(int, CONVERT(char(8), EventEDVisitFact.ArrivalDateTime, 112)) - CONVERT(char(8), EventEDVisitFact.BirthDate, 112)) / 10000) BETWEEN 18 AND 64
         THEN CAST('Adult'							        AS varchar(5000)) 
         
         WHEN ((CONVERT(int, CONVERT(char(8), EventEDVisitFact.ArrivalDateTime, 112)) - CONVERT(char(8), EventEDVisitFact.BirthDate, 112)) / 10000) >= 65
         THEN CAST('Geriatric'						      AS varchar(5000))            
        END																                                    AS AGE_IN_YEARS_DSC
      ,CAST(EventEDVisitFact.EncounterEpicCsn		AS varchar(50))		            AS ENCOUNTER_EPIC_CSN_ID 
      ,EventEDVisitFact.EncounterKey									                        AS ENCOUNTER_KEY
      ,CAST(EventEDVisitFact.DischargeDisposition	AS varchar(5000))	          AS DISCHARGE_DISPOSITION_DSC
      ,EventEDVisitFact.EDDischarge										                        AS ED_DISCHARGE_DTS
                                                                              
	    ,CAST(DepartmentDim.DepartmentEpicId			AS varchar(50))		            AS DEPARTMENT_EPIC_ID 
	    ,CAST(Department.DepartmentID					    AS varchar(50))		            AS DEPARTMENT_ID 
      ,CAST(DepartmentDim.DepartmentName			  AS varchar(300))	            AS DEPARTMENT_NM 
      ,CAST(Department.RevenueLocationID			  AS varchar(50))		            AS REVENUE_LOCATION_ID 
      ,CAST(RevenueLocation.RevenueLocationNM		AS varchar(300))	            AS REVENUE_LOCATION_NM 
      ,CAST(ParentLocation.LocationID				    AS varchar(50))		            AS HOSPITAL_PARENT_LOCATION_ID 
      ,CAST(ParentLocation.RevenueLocationNM		AS varchar(300))	            AS HOSPITAL_PARENT_LOCATION_NM 
                                                                      
      ,CAST(ISNULL(PopulationEDVisit.ProcedureOrderEpicId, 0)	AS varchar(50)) AS PROCEDURE_ORDER_EPIC_ID 
      ,ISNULL(PopulationEDVisit.ProcedureDurableKey, 0)					              AS PROCEDURE_DURABLE_KEY
      ,PopulationEDVisit.ORDER_INSTANT									                      AS ORDER_INSTANT_DTS 
      ,PopulationEDVisit.ORDER_DATE_KEY									                      AS ORDER_DATE_KEY
      ,CAST(ISNULL(PopulationEDVisit.ProcCode, 'NA') AS varchar(50))	        AS PROCEDURE_CD  
      ,CAST(ISNULL(PopulationEDVisit.CodeName, 'NA') AS varchar(300))	        AS PROCEDURE_NM 
                                                                              
      ,CAST(MetricCoverage_ED.BenefitPlanName		     AS varchar(300))	        AS BENEFIT_PLAN_NM 
      ,MetricCoverage_ED.CoverageKey									                        AS COVERAGE_KEY
      ,CAST(MetricCoverage_ED.BenefitPlanEpicId		   AS varchar(50))		      AS BENEFIT_PLAN_EPIC_ID
      ,MetricCoverage_ED.MGBACOMembershipFlg							                    AS MGBACO_MEMBERSHIP_FLG
      
      ,CAST(MetricPCP_ED.PCP_Type					           AS varchar(50))		      AS PCP_TYPE_CD 
      ,MetricPCP_ED.PCPInternalFLG										                        AS PCP_INTERNAL_FLG
      ,MetricPCP_ED.PCPExternalFLG										                        AS PCP_EXTERNAL_FLG
                                                                              
      ,MetricReAdmissions_ED.ED30DayReAdmitFLG							                  AS READMIT_FLG
      ,MetricReAdmissions_ED.ED30DayReAdmitReportingFLG					              AS ED_REPORTING_FLG 
                                                                              
	    ,PopulationEDVisit.psychnote										                        AS PSYCH_NOTE_FLG 
                                                                              
      ,CAST(EventEDVisitFact.IsDeleted				        AS char(1))			        AS IS_DELETED_FLG 
      ,EventEDVisitFact.EDWLastModifiedDTS								                    AS EDW_LAST_MODIFIED_DTS

FROM SAM.EAMBehavioral.EventEDVisitFact

INNER JOIN SAM.EAMBehavioral.IncrementalHelper_EMERGENCY_DETAIL
ON EventEDVisitFact.EncounterKey = IncrementalHelper_EMERGENCY_DETAIL.EncounterKey

LEFT JOIN EpicMart.Caboodle.DepartmentDim 
  ON EventEDVisitFact.EdDepartmentKey = DepartmentDim.DepartmentKey

INNER JOIN Epic.Reference.Department
  ON DepartmentDim.DepartmentEpicId = CAST(Department.DepartmentID AS VARCHAR(255))

LEFT OUTER JOIN Epic.Reference.[Location] RevenueLocation
  ON Department.RevenueLocationID = RevenueLocation.LocationID

LEFT OUTER JOIN Epic.Reference.[Location] ParentLocation
  ON RevenueLocation.ADTParentID = ParentLocation.LocationID
  
INNER JOIN SAM.EAMBehavioral.PopulationEDVisit
  ON PopulationEDVisit.EncounterKey = EventEDVisitFact.EncounterKey
  
LEFT JOIN SAM.EAMBehavioral.MetricCoverage_ED
  ON MetricCoverage_ED.EncounterKey = EventEDVisitFact.EncounterKey
  
LEFT JOIN SAM.EAMBehavioral.MetricPCP_ED
  ON MetricPCP_ED.EncounterKey = EventEDVisitFact.EncounterKey
  
LEFT JOIN SAM.EAMBehavioral.MetricReAdmissions_ED
  ON MetricReAdmissions_ED.PatientDurableKey = EventEDVisitFact.PatientDurableKey
 AND MetricReAdmissions_ED.EncounterKey = EventEDVisitFact.EncounterKey
  
   WHERE EXISTS 
    (SELECT 'Behavioral ED Patient Encounters'
  	   FROM SAM.EAMBehavioral.PopulationEDVisit
  	  WHERE PopulationEDVisit.EncounterKey = EventEDVisitFact.EncounterKey
        AND (PopulationEDVisit.ProcedureOrderEpicId = PopulationEDVisit.ProcedureOrderEpicId
         OR ISNULL(PopulationEDVisit.ProcedureOrderEpicId, 0) = 0))

