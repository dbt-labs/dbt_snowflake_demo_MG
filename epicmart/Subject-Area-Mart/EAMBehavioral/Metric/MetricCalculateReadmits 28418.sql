/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: MetricCalculateReadmits
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
	SELECT MetricLastDischargeDate.EncounterKey
      ,MetricLastDischargeDate.PatientDurableKey
      ,MetricLastDischargeDate.EDArrivalDate  AS EDArrivalDate
      ,MetricLastDischargeDate.EDischargeDate AS EDischargeDate
      ,MetricLastDischargeDate.InpatientAdmitDate  AS InpatientAdmitDate
      ,MetricLastDischargeDate.InpatientDischargeDate  AS InpatientDischargeDate
      ,MetricLastDischargeDate.FirstArrivalForCurrentEncounter
      ,MetricLastDischargeDate.LastDischargeForCurrentEncounter
      ,LEAD(MetricLastDischargeDate.FirstArrivalforCurrentEncounter) 
         OVER(PARTITION BY MetricLastDischargeDate.PatientDurableKey 
         ORDER BY MetricLastDischargeDate.FirstArrivalforCurrentEncounter
                 ,MetricLastDischargeDate.LastDischargeForCurrentEncounter ASC) AS 'FirstArrivalFromNextEncounter'

FROM SAM.EAMBehavioral.MetricLastDischargeDate