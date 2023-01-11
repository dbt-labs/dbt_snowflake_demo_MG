/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: BEHAVIORAL_PSYCHBOARDERS_DTL_TBL
Description: Union the Inpatient Psych Boarders and the ED Psych Boarders, encounter key and arrival date form the key

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

/* IP Psych Boarders */
SELECT
       PopulationPsychBoarders.DateKey										                  AS ARRIVAL_DATE_KEY
      ,PopulationPsychBoarders.DATE											                    AS ARRIVAL_DTS
      ,PopulationPsychBoarders.DepartmentKey								                AS ED_DEPARTMENT_KEY
      ,PopulationPsychBoarders.PatientDurableKey							              AS PATIENT_DURABLE_KEY
      ,PopulationPsychBoarders.patientkey									                  AS PATIENT_KEY
      ,CASE
         WHEN ((CONVERT(int, CONVERT(char(8), PopulationPsychBoarders.DATE, 112)) - CONVERT(char(8), PopulationPsychBoarders.BirthDate, 112)) / 10000) BETWEEN 0 AND 17
         THEN CAST('Child'								                AS varchar(5000)) 
         
         WHEN ((CONVERT(int, CONVERT(char(8), PopulationPsychBoarders.DATE, 112)) - CONVERT(char(8), PopulationPsychBoarders.BirthDate, 112)) / 10000) BETWEEN 18 AND 64
         THEN CAST('Adult'								                AS varchar(5000)) 
         
         WHEN ((CONVERT(int, CONVERT(char(8), PopulationPsychBoarders.DATE, 112)) - CONVERT(char(8), PopulationPsychBoarders.BirthDate, 112)) / 10000) >= 65
         THEN CAST('Geriatric'							              AS varchar(5000))          
        END																	                                AS AGE_IN_YEARS_DSC
      ,CAST(PopulationPsychBoarders.EncounterEpicCsn	    AS varchar(50))		AS ENCOUNTER_EPIC_CSN_ID 
      ,PopulationPsychBoarders.EncounterKey									                AS ENCOUNTER_KEY
      ,CAST(NULL																	        AS varchar(5000)) AS DISCHARGE_DISPOSITION_DSC
      ,PopulationPsychBoarders.EndInstant									                  AS DISCHARGE_DTS 

	    ,CAST(DepartmentDim.DepartmentEpicId				        AS varchar(50))		AS DEPARTMENT_EPIC_ID 
	    ,CAST(Department.DepartmentID						            AS varchar(50))		AS DEPARTMENT_ID  
      ,CAST(DepartmentDim.DepartmentName				          AS varchar(300))	AS DEPARTMENT_NM 
      ,CAST(Department.RevenueLocationID				          AS varchar(50))		AS REVENUE_LOCATION_ID  
      ,CAST(RevenueLocation.RevenueLocationNM			        AS varchar(300))	AS REVENUE_LOCATION_NM  
      ,CAST(ParentLocation.LocationID					            AS varchar(50))		AS HOSPITAL_PARENT_LOCATION_ID  
      ,CAST(ParentLocation.RevenueLocationNM			        AS varchar(300))	AS HOSPITAL_PARENT_LOCATION_NM  

      ,CAST(PopulationPsychBoarders.ProcedureOrderEpicId  AS varchar(50))	  AS PROCEDURE_ORDER_EPIC_ID  
      ,PopulationPsychBoarders.ProcedureDurableKey							            AS PROCEDURE_DURABLE_KEY
      ,PopulationPsychBoarders.OrderedInstant								                AS ORDER_INSTANT_DTS  
      ,PopulationPsychBoarders.OrderedDateKey								                AS ORDER_DATE_KEY
      ,CAST(PopulationPsychBoarders.ProcCode			        AS varchar(50))		AS PROCEDURE_CD  
      ,CAST(PopulationPsychBoarders.CodeName			        AS varchar(300))	AS PROCEDURE_NM  

	    ,NULL																	                                AS BENEFIT_PLAN_NM
      ,NULL																	                                AS COVERAGE_KEY
      ,NULL																	                                AS BENEFIT_PLAN_EPIC_ID
      ,NULL																	                                AS MGBACO_MEMBERSHIP_FLG
          
      ,CAST(MetricPCP_Psych.PCP_Type					            AS varchar(50))		AS PCP_TYPE_CD 
      ,MetricPCP_Psych.PCPInternalFLG										                    AS PCP_INTERNAL_FLG
      ,MetricPCP_Psych.PCPExternalFLG										                    AS PCP_EXTERNAL_FLG
      
      ,NULL																	                                AS HOURS_BETWEEN_NBR
      
      ,CAST(PopulationPsychBoarders.IsDeleted			        AS char(1))			  AS IS_DELETED_FLG 
      ,PopulationPsychBoarders.EDWLastModifiedDTS							              AS EDW_LAST_MODIFIED_DTS
      ,CAST('IP'																	        AS varchar(50))   AS PSYCH_BOARDER_TYPE_CD 

FROM SAM.EAMBehavioral.PopulationPsychBoarders

INNER JOIN SAM.EAMBehavioral.IncrementalHelper_PSYCHBOARDERS_DETAIL
 ON PopulationPsychBoarders.EncounterKey = IncrementalHelper_PSYCHBOARDERS_DETAIL.EncounterKey

LEFT JOIN EpicMart.Caboodle.DepartmentDim 
  ON PopulationPsychBoarders.DepartmentKey = DepartmentDim.DepartmentKey

INNER JOIN Epic.Reference.Department
  ON DepartmentDim.DepartmentEpicId = CAST(Department.DepartmentID AS VARCHAR(255))

LEFT OUTER JOIN Epic.Reference.[Location] RevenueLocation
  ON Department.RevenueLocationID = RevenueLocation.LocationID

LEFT OUTER JOIN Epic.Reference.[Location] ParentLocation
  ON RevenueLocation.ADTParentID = ParentLocation.LocationID
  
LEFT JOIN SAM.EAMBehavioral.MetricPCP_Psych
  ON MetricPCP_Psych.EncounterKey = PopulationPsychBoarders.EncounterKey

  
  
UNION ALL
/* ED Psych Boarders */
SELECT 
       CONVERT(varchar, MetricPsychBoarderTransfers.CalendarDate, 112)          AS ARRIVAL_DATE_KEY
      ,MetricPsychBoarderTransfers.CalendarDateAt7AM					                  AS ARRIVAL_DTS
      ,MetricPsychBoarderTransfers.DepartmentKey						                    AS ED_DEPARTMENT_KEY
      ,MetricPsychBoarderTransfers.PatientDurableKey					                  AS PATIENT_DURABLE_KEY
      ,MetricPsychBoarderTransfers.patientkey							                      AS PATIENT_KEY
      ,CASE
         WHEN ((CONVERT(int, CONVERT(char(8), MetricPsychBoarderTransfers.CalendarDateAt7AM, 112)) - CONVERT(char(8), MetricPsychBoarderTransfers.BirthDate, 112)) / 10000) BETWEEN 0 AND 17
         THEN CAST('Child'								                  AS varchar(5000)) 
         
         WHEN ((CONVERT(int, CONVERT(char(8), MetricPsychBoarderTransfers.CalendarDateAt7AM, 112)) - CONVERT(char(8), MetricPsychBoarderTransfers.BirthDate, 112)) / 10000) BETWEEN 18 AND 64
         THEN CAST('Adult'								                  AS varchar(5000))
         
         WHEN ((CONVERT(int, CONVERT(char(8), MetricPsychBoarderTransfers.CalendarDateAt7AM, 112)) - CONVERT(char(8), MetricPsychBoarderTransfers.BirthDate, 112)) / 10000) >= 65
         THEN CAST('Geriatric'							                AS varchar(5000))         
        END																                                      AS AGE_IN_YEARS_DSC
      ,CAST(MetricPsychBoarderTransfers.PatientEncounterID  AS varchar(50))	    AS ENCOUNTER_EPIC_CSN_ID 
      ,MetricPsychBoarderTransfers.EncounterKey							                    AS ENCOUNTER_KEY
      ,CAST(NULL																            AS varchar(5000))   AS DISCHARGE_DISPOSITION_DSC
      ,NULL																                                      AS DISCHARGE_DTS 
                                                                                
	    ,CAST(DepartmentDim.DepartmentEpicId									AS varchar(50))     AS DEPARTMENT_EPIC_ID
	    ,CAST(Department.DepartmentID											    AS varchar(50))     AS DEPARTMENT_ID
      ,CAST(DepartmentDim.DepartmentName                    AS varchar(300))	  AS DEPARTMENT_NM
      ,CAST(Department.RevenueLocationID										AS varchar(50))     AS REVENUE_LOCATION_ID
      ,CAST(RevenueLocation.RevenueLocationNM								AS varchar(300))    AS REVENUE_LOCATION_NM
      ,CAST(ParentLocation.LocationID										    AS varchar(50))     AS HOSPITAL_PARENT_LOCATION_ID
      ,CAST(ParentLocation.RevenueLocationNM								AS varchar(300))    AS HOSPITAL_PARENT_LOCATION_NM	

      ,CAST(MetricPsychBoarderTransfers.ProcedureOrderEpicId	AS varchar(50))	  AS PROCEDURE_ORDER_EPIC_ID
      ,MetricPsychBoarderTransfers.ProcedureDurableKey					                AS PROCEDURE_DURABLE_KEY
      ,MetricPsychBoarderTransfers.OrderedInstant						                    AS ORDER_INSTANT_DTS 
      ,MetricPsychBoarderTransfers.OrderedDateKey						                    AS ORDER_DATE_KEY
      ,CAST(MetricPsychBoarderTransfers.ProcCode							AS varchar(50))	  AS PROCEDURE_CD
      ,CAST(MetricPsychBoarderTransfers.CodeName							AS varchar(300))	AS PROCEDURE_NM

	    ,CAST(MetricCoverage_EDBoarders.BenefitPlanName					AS varchar(300))	AS BENEFIT_PLAN_NM
      ,MetricCoverage_EDBoarders.CoverageKey							                      AS COVERAGE_KEY
      ,CAST(MetricCoverage_EDBoarders.BenefitPlanEpicId				AS varchar(50))		AS BENEFIT_PLAN_EPIC_ID
      ,MetricCoverage_EDBoarders.MGBACOMembershipFlg					                  AS MGBACO_MEMBERSHIP_FLG
          
      ,CAST(MetricPCP_EDBoarders.PCP_Type									    AS varchar(50))   AS PCP_TYPE_CD 
      ,MetricPCP_EDBoarders.PCPInternalFLG								                      AS PCP_INTERNAL_FLG
      ,MetricPCP_EDBoarders.PCPExternalFLG								                      AS PCP_EXTERNAL_FLG
                                                                                
      ,MetricPsychBoarderTransfers.HoursBetween							                    AS HOURS_BETWEEN_NBR
      
      /* NCS greater than 2 hours / all patients with ADT34 */
      
      ,NULL																                                      AS IS_DELETED_FLG
      ,MetricPsychBoarderTransfers.EDWLastModifiedDTS					                  AS EDW_LAST_MODIFIED_DTS
      ,CAST('ED'																              AS varchar(50))   AS PSYCH_BOARDER_TYPE_CD 

FROM SAM.EAMBehavioral.MetricPsychBoarderTransfers

INNER JOIN SAM.EAMBehavioral.IncrementalHelper_PSYCHBOARDERS_DETAIL
 ON MetricPsychBoarderTransfers.EncounterKey = IncrementalHelper_PSYCHBOARDERS_DETAIL.EncounterKey

LEFT JOIN EpicMart.Caboodle.DepartmentDim 
  ON MetricPsychBoarderTransfers.DepartmentKey = DepartmentDim.DepartmentKey

INNER JOIN Epic.Reference.Department
  ON DepartmentDim.DepartmentEpicId = CAST(Department.DepartmentID AS VARCHAR(255))

LEFT OUTER JOIN Epic.Reference.[Location] RevenueLocation
  ON Department.RevenueLocationID = RevenueLocation.LocationID

LEFT OUTER JOIN Epic.Reference.[Location] ParentLocation
  ON RevenueLocation.ADTParentID = ParentLocation.LocationID
  
LEFT JOIN SAM.EAMBehavioral.MetricPCP_EDBoarders
  ON MetricPCP_EDBoarders.EncounterKey = MetricPsychBoarderTransfers.encounterkey

LEFT JOIN SAM.EAMBehavioral.MetricCoverage_EDBoarders
  ON MetricCoverage_EDBoarders.EncounterKey = MetricPsychBoarderTransfers.encounterkey