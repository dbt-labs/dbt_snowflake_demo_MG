/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: PopulationReAdmissions_IP
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT CalculateIPReAdmissions.InpatientRowNumber
      ,CalculateIPReAdmissions.InpatientEncounterKey
      ,CalculateIPReAdmissions.InpatientPatientDurableKey
      ,CalculateIPReAdmissions.ADMISSION_DATE
      ,CalculateIPReAdmissions.DISCHARGE_DATE
      ,CalculateIPReAdmissions.LengthOfStayInDays
      ,CASE 
        WHEN CalculateIPReAdmissions.InpatientRowNumber <> 0
    		THEN LEAD(CalculateIPReAdmissions.ADMISSION_DATE) 
              OVER(PARTITION BY CalculateIPReAdmissions.InpatientPatientDurableKey 
              ORDER BY CalculateIPReAdmissions.ADMISSION_DATE) 
    		ELSE NULL
    	 END AS NextPsychArrivalDate  /* Corresponds to working query PreviousPsychDischargeDate */

  FROM 
(
  SELECT CASE 
          WHEN PopulationInpatientVisit.DepartmentEpicId <> '10040010053' 
            OR (PopulationInpatientVisit.DepartmentEpicId = '10040010053' AND PopulationInpatientVisit.HospitalService = 'Addiction')
  		    THEN ROW_NUMBER() OVER(PARTITION BY PopulationInpatientVisit.PatientDurableKey ORDER BY CAST(PopulationInpatientVisit.ADMISSION_DATE AS DATE)) 
  		    ELSE 0
  	     END AS InpatientRowNumber
        ,PopulationInpatientVisit.EncounterKey       AS InpatientEncounterKey
      	,PopulationInpatientVisit.PatientDurableKey  AS InpatientPatientDurableKey
      	,PopulationInpatientVisit.ADMISSION_DATE
      	,PopulationInpatientVisit.DISCHARGE_DATE
        ,PopulationInpatientVisit.LengthOfStayInDays
        
    FROM SAM.EAMBehavioral.PopulationInpatientVisit
) CalculateIPReAdmissions

