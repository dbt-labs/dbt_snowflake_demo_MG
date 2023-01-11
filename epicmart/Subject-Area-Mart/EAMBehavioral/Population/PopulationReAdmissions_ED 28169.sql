/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: PopulationReAdmissions_ED
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT PopulationEDVisit.EncounterKey 
    	,PopulationEDVisit.PatientDurableKey
    	,PopulationEDVisit.ArrivalDateTime AS ArrivalDateTime
    	,PopulationEDVisit.EDDischarge AS EDDischarge
    	,PopulationInpatientVisit.EncounterKey       AS InpatientEncounterKey
    	,PopulationInpatientVisit.PatientDurableKey  AS InpatientPatientDurableKey
    	,PopulationInpatientVisit.ADMISSION_DATE  AS ADMISSION_DATE
    	,PopulationInpatientVisit.DISCHARGE_DATE AS DISCHARGE_DATE

 FROM SAM.EAMBehavioral.PopulationEDVisit             /* Corresponds to working query #EdPatients */
 FULL OUTER JOIN SAM.EAMBehavioral.PopulationInpatientVisit  /* Corresponds to working query #BHInpatientsONLY */
   ON PopulationEDVisit.EncounterKey = PopulationInpatientVisit.EncounterKey 
   
   
