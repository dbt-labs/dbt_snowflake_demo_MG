/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: BEHAVIORAL_INPATIENT_DTL_TBL
Description: Inpatient details for inpatient grain metrics, encounter key.

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
SELECT
       EventIPVisitFact.InpatientAdmissionDateKey							            AS ARRIVAL_DATE_KEY
      ,EventIPVisitFact.ADMISSION_DATE										                AS ARRIVAL_DTS
      ,EventIPVisitFact.DepartmentKey										                  AS ED_DEPARTMENT_KEY
      ,EventIPVisitFact.PatientDurableKey									                AS PATIENT_DURABLE_KEY
      ,EventIPVisitFact.PatientKey											                  AS PATIENT_KEY
      ,CASE
         WHEN ((CONVERT(int, CONVERT(char(8), EventIPVisitFact.ADMISSION_DATE, 112)) - CONVERT(char(8), EventIPVisitFact.BirthDate, 112)) / 10000) BETWEEN 0 AND 17
         THEN CAST('Child'								              AS varchar(5000)) 
         
         WHEN ((CONVERT(int, CONVERT(char(8), EventIPVisitFact.ADMISSION_DATE, 112)) - CONVERT(char(8), EventIPVisitFact.BirthDate, 112)) / 10000) BETWEEN 18 AND 64
         THEN CAST('Adult'								              AS varchar(5000)) 
         
         WHEN ((CONVERT(int, CONVERT(char(8), EventIPVisitFact.ADMISSION_DATE, 112)) - CONVERT(char(8), EventIPVisitFact.BirthDate, 112)) / 10000) >= 65
         THEN CAST('Geriatric'							            AS varchar(5000))         
        END																	                              AS AGE_IN_YEARS_DSC
      ,CAST(EventIPVisitFact.EncounterEpicCsn			      AS varchar(50))	  AS ENCOUNTER_EPIC_CSN_ID 
      ,EventIPVisitFact.EncounterKey								    		              AS ENCOUNTER_KEY
      ,CAST(EventIPVisitFact.DischargeDisposition		    AS varchar(5000))	AS DISCHARGE_DISPOSITION_DSC 
      ,EventIPVisitFact.DISCHARGE_DATE							    			            AS DISCHARGE_DTS 
                                                        
	    ,CAST(EventIPVisitFact.DepartmentEpicId			      AS varchar(50))		AS DEPARTMENT_EPIC_ID 
																                        
      ,CAST(EventIPVisitFact.DepartmentName				      AS varchar(300))	AS DEPARTMENT_NM  
      ,CAST(Department.RevenueLocationID				        AS varchar(50))		AS REVENUE_LOCATION_ID 
      ,CAST(RevenueLocation.RevenueLocationNM			      AS varchar(300))	AS REVENUE_LOCATION_NM 
      ,CAST(ParentLocation.LocationID					          AS varchar(50))		AS HOSPITAL_PARENT_LOCATION_ID  
      ,CAST(ParentLocation.RevenueLocationNM			      AS varchar(300))	AS HOSPITAL_PARENT_LOCATION_NM 

      ,CAST(ISNULL(EventOrders.ProcedureOrderEpicId, 0) AS varchar(50))		AS PROCEDURE_ORDER_EPIC_ID  
      ,ISNULL(EventOrders.ProcedureDurableKey, 0)							            AS PROCEDURE_DURABLE_KEY
      ,EventOrders.OrderedInstant											                    AS ORDER_INSTANT_DTS  
      ,EventOrders.OrderedDateKey											                    AS ORDER_DATE_KEY
      ,CAST(ISNULL(EventOrders.ProcCode, 'NA')			    AS varchar(50))		AS PROCEDURE_CD  
      ,CAST(ISNULL(EventOrders.CodeName, 'NA')			    AS varchar(300))	AS PROCEDURE_NM  
      
      ,CAST(MetricCoverage_IP.BenefitPlanName			      AS varchar(300))	AS BENEFIT_PLAN_NM  
      ,MetricCoverage_IP.CoverageKey										                  AS COVERAGE_KEY
      ,CAST(MetricCoverage_IP.BenefitPlanEpicId			    AS varchar(50)) 	AS BENEFIT_PLAN_EPIC_ID  
      ,MetricCoverage_IP.MGBACOMembershipFlg								              AS MGBACO_MEMBERSHIP_FLG
      
      ,CAST(MetricPCP_IP.PCP_Type						            AS varchar(50))		AS PCP_TYPE_CD 
      ,MetricPCP_IP.PCPInternalFLG											                  AS PCP_INTERNAL_FLG
      ,MetricPCP_IP.PCPExternalFLG											                  AS PCP_EXTERNAL_FLG
      
      ,MetricReAdmissions_IP.[30DayIPReadmitFLG]							            AS READMIT_FLG
      ,MetricReAdmissions_IP.IP30DayReAdmitReportingFLG						        AS IP_REPORTING_FLG
      
      ,CAST(EventIPVisitFact.IsDeleted					        AS char(1))			  AS IS_DELETED_FLG  
      ,EventIPVisitFact.EDWLastModifiedDTS									              AS EDW_LAST_MODIFIED_DTS

FROM SAM.EAMBehavioral.EventIPVisitFact

INNER JOIN SAM.EAMBehavioral.IncrementalHelper_INPATIENT_DETAIL
ON EventIPVisitFact.EncounterKey = IncrementalHelper_INPATIENT_DETAIL.EncounterKey

INNER JOIN Epic.Reference.Department
  ON CAST(Department.DepartmentID AS VARCHAR(255)) = EventIPVisitFact.DepartmentEpicId

LEFT OUTER JOIN Epic.Reference.[Location] RevenueLocation
  ON Department.RevenueLocationID = RevenueLocation.LocationID

LEFT OUTER JOIN Epic.Reference.[Location] ParentLocation
  ON RevenueLocation.ADTParentID = ParentLocation.LocationID
  
LEFT OUTER JOIN SAM.EAMBehavioral.EventOrders
  ON EventOrders.EncounterKey = EventIPVisitFact.EncounterKey
  
LEFT JOIN SAM.EAMBehavioral.MetricCoverage_IP
  ON MetricCoverage_IP.EncounterKey = EventIPVisitFact.EncounterKey
  
LEFT JOIN SAM.EAMBehavioral.MetricPCP_IP
  ON MetricPCP_IP.EncounterKey = EventIPVisitFact.EncounterKey
  
LEFT JOIN SAM.EAMBehavioral.MetricReAdmissions_IP
  ON MetricReAdmissions_IP.InpatientPatientDurableKey = EventIPVisitFact.PatientDurableKey
 AND MetricReAdmissions_IP.InpatientEncounterKey = EventIPVisitFact.EncounterKey
  
   WHERE EXISTS 
    (SELECT 'Behavioral InPatient Encounters'
  	   FROM SAM.EAMBehavioral.PopulationInpatientVisit
  	  WHERE PopulationInpatientVisit.EncounterKey = EventIPVisitFact.EncounterKey
        AND PopulationInpatientVisit.ProcedureOrderEpicId = ISNULL(EventOrders.ProcedureOrderEpicId, -1))