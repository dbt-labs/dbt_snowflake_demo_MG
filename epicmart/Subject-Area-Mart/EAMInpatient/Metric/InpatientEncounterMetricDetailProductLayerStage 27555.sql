/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: InpatientEncounterMetricDetailProductLayerStage
Description: This binding produces the initial version of the MetricDetail entity with Snowflake standard names

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
20221130  KG312   !12451  Update to use EDDeparture instead of EDArrical for Reporting
*********************************************************************************************************************************************************/
SELECT
		 CAST(28 AS INT)				AS METRIC_ID
		,'Boarder Hours'	        AS METRIC_NM
		,InpatientEncounterDetail.PatientEncounterID as SOURCE_EPIC_ID
		,InpatientEncounterDetail.PatientID as PATIENT_ID
		/*	Dimensions for Required Level of Aggregation*/
		,InpatientEncounterDetail.EDDepartureDate as REPORTING_DT
		,InpatientEncounterDetail.EDDepartureFiscalYearNBR AS REPORTING_FISCAL_YEAR_NBR
		,InpatientEncounterDetail.DepartmentNM  DEPARTMENT_NM
		,InpatientEncounterDetail.RevenueLocationNM  REVENUE_LOCATION_NM
		,InpatientEncounterDetail.HospitalParentLocationNM AS HOSPITAL_PARENT_LOCATION_NM /**need to add hospital to this table*/
		,NULL AS OCCUPANCY_DEPARTMENT_GROUP_NM
		,NULL AS PATIENT_CLASS_DSC
		,NULL AS SERVICE_GROUP_DSC
		,NULL AS ADMISSION_SOURCE_GROUP_NM
		,CAST(NULL AS VARCHAR) as NewMedSurgICUFlg
		,CAST(NULL AS VARCHAR) as PatientClassDSC
		,CAST(NULL AS VARCHAR) AS ServiceGroupDSC
		,CAST(NULL AS VARCHAR) AS AdmissionSource
		,ROUND(CAST(InpatientEncounterDetail.BoarderDurationInMinutes AS DECIMAL(19,5))/60,4) 		AS NUMERATOR_NBR
		,CAST(InpatientEncounterDetail.IsBoarder AS DECIMAL(19,5))		              AS DENOMINATOR_NBR
		, CURRENT_TIMESTAMP AS EDW_LAST_MODIFIED_DTS
    , InpatientEncounterDetail.EDArrivalFiscalYearNBR AS ED_ARRIVAL_FISCAL_YEAR_NBR
    , InpatientEncounterDetail.EDArrivalDate AS ED_ARRIVAL_DT
    , InpatientEncounterDetail.EDDepartureFiscalYearNBR AS ED_DEPARTURE_FISCAL_YEAR_NBR
    , InpatientEncounterDetail.EDDepartureDate AS ED_DEPARTURE_DT
FROM
	SAM.EAMInpatient.InpatientEncounterDetail
  
WHERE InpatientEncounterDetail.EDDepartureDate IS NOT NULL
    AND InpatientEncounterDetail.IsBoarder=1
