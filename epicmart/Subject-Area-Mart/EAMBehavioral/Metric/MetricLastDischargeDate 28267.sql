/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: MetricLastDischargeDate
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
SELECT 
	 CASE WHEN PopulationReAdmissions_ED.EncounterKey IS NULL 
        THEN PopulationReAdmissions_ED.InpatientEncounterKey
		    ELSE PopulationReAdmissions_ED.EncounterKey
	 END                                                                              AS 'EncounterKey'
	,CASE WHEN PopulationReAdmissions_ED.PatientDurableKey IS NULL 
        THEN PopulationReAdmissions_ED.InpatientPatientDurableKey
		    ELSE PopulationReAdmissions_ED.PatientDurableKey
	 END                                                                              AS 'PatientDurableKey'
	,PopulationReAdmissions_ED.ArrivalDateTime                           AS EDArrivalDate
	,PopulationReAdmissions_ED.EDDischarge                              AS EDischargeDate
	,PopulationReAdmissions_ED.Admission_Date                          AS InpatientAdmitDate
	,PopulationReAdmissions_ED.Discharge_Date                          AS InpatientDischargeDate
  ,CASE WHEN PopulationReAdmissions_ED.ArrivalDateTime IS NULL 
			  THEN PopulationReAdmissions_ED.Admission_Date
		    WHEN PopulationReAdmissions_ED.Admission_Date IS NULL
			  THEN PopulationReAdmissions_ED.ArrivalDateTime 
		    WHEN PopulationReAdmissions_ED.ArrivalDateTime IS NOT NULL AND PopulationReAdmissions_ED.Admission_Date IS NOT NULL
			  THEN PopulationReAdmissions_ED.ArrivalDateTime
		END                                                             AS 'FirstArrivalForCurrentEncounter'
	,CASE WHEN PopulationReAdmissions_ED.EDDischarge IS NULL 
			  THEN PopulationReAdmissions_ED.Discharge_Date
		    WHEN PopulationReAdmissions_ED.Discharge_Date IS NULL
			  THEN PopulationReAdmissions_ED.EDDischarge
		    WHEN PopulationReAdmissions_ED.EDDischarge IS NOT NULL AND PopulationReAdmissions_ED.Discharge_Date IS NOT NULL
			  THEN PopulationReAdmissions_ED.Discharge_Date
		END                                                           AS 'LastDischargeForCurrentEncounter'
  
  FROM SAM.EAMBehavioral.PopulationReAdmissions_ED 











