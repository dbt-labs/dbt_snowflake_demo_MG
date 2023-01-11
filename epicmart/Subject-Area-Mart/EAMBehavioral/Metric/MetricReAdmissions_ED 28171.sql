/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: MetricReAdmissions_ED
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/


SELECT MetricCalculateReadmits.EncounterKey
      ,MetricCalculateReadmits.PatientDurableKey
      ,MetricCalculateReadmits.EDArrivalDate  AS EDArrivalDate
      ,MetricCalculateReadmits.EDischargeDate  AS EDischargeDate
      ,MetricCalculateReadmits.InpatientAdmitDate  AS InpatientAdmitDate
      ,MetricCalculateReadmits.InpatientDischargeDate  AS InpatientDischargeDate
      ,MetricCalculateReadmits.FirstArrivalForCurrentEncounter
      ,MetricCalculateReadmits.LastDischargeForCurrentEncounter
	,DATEDIFF(DAY, MetricCalculateReadmits.LastDischargeForCurrentEncounter, MetricCalculateReadmits.FirstArrivalFromNextEncounter) AS 'DaysBeforeNextEDorInpatientArrival'
	,CASE 
    WHEN DATEDIFF(DAY, MetricCalculateReadmits.LastDischargeForCurrentEncounter,  MetricCalculateReadmits.FirstArrivalFromNextEncounter) <= 30
		THEN 1
		WHEN MetricCalculateReadmits.LastDischargeForCurrentEncounter IS NULL
		THEN 0
		ELSE 0
	END                                                                   AS 'ED30DayReAdmitFLG'
	,CASE 
    WHEN MetricCalculateReadmits.EDArrivalDate IS NOT NULL
		THEN 1
		ELSE 0
	 END                                                                  AS 'ED30DayReAdmitEligibleFLG'
  ,CASE WHEN DATEDIFF(DAY, LastDischargeForCurrentEncounter,  GETDATE()) >= 30
		THEN 1
		ELSE 0
	  END                                                           AS 'ED30DayReAdmitReportingFLG'
  FROM SAM.EAMBehavioral.MetricCalculateReadmits