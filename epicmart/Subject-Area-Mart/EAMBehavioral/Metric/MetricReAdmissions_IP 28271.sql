/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: MetricReAdmissions_IP
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
SELECT PopulationReAdmissions_IP.InpatientEncounterKey
      ,PopulationReAdmissions_IP.InpatientPatientDurableKey
      ,PopulationReAdmissions_IP.ADMISSION_DATE
      ,PopulationReAdmissions_IP.DISCHARGE_DATE
      ,PopulationReAdmissions_IP.NextPsychArrivalDate /* PreviousPsychDischargeDate */
      ,PopulationReAdmissions_IP.LengthOfStayInDays
      ,DATEDIFF(DAY, PopulationReAdmissions_IP.DISCHARGE_DATE, PopulationReAdmissions_IP.NextPsychArrivalDate)  AS NoOfDaysSinceLastDischarge
      
      ,CASE WHEN PopulationReAdmissions_IP.NextPsychArrivalDate IS NULL
        		THEN 0
        		WHEN DATEDIFF(DAY, PopulationReAdmissions_IP.DISCHARGE_DATE, PopulationReAdmissions_IP.NextPsychArrivalDate) > 30
        		THEN 0
        		WHEN DATEDIFF(DAY, PopulationReAdmissions_IP.DISCHARGE_DATE, PopulationReAdmissions_IP.NextPsychArrivalDate) < =30
        		THEN 1
        		ELSE NULL
        	END AS '30DayIPReadmitFLG'
      ,CASE WHEN DATEDIFF(DAY, Discharge_Date,  GETDATE()) >= 30
  		THEN 1
  		ELSE 0
  	END                       AS 'IP30DayReAdmitReportingFLG'
  FROM SAM.EAMBehavioral.PopulationReAdmissions_IP