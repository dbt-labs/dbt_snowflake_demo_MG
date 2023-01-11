/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: EventIPVisitFact
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
  SELECT * FROM 
  (  
  SELECT
	 HospitalAdmissionFact.InpatientAdmissionDateKey
  ,HospitalAdmissionFact.PatientKey
  ,HospitalAdmissionFact.PatientDurableKey
  ,PatientDim.BirthDate
	,HospitalAdmissionFact.EncounterEpicCsn
	,CAST(HospitalAdmissionFact.PatientClass AS varchar(255)) AS PatientClass
  ,HospitalAdmissionFact.DepartmentKey
	,CAST(EventDepartments.DepartmentName AS varchar(255)) AS DepartmentName
	,EventDepartments.DepartmentEpicId
  ,CAST(HospitalAdmissionFact.DischargeDisposition AS varchar(255)) AS DischargeDisposition
	,HospitalAdmissionFact.EncounterKey
  ,HospitalAdmissionFact.PrimaryCoverageKey
  ,CAST(SUBSTRING(CONVERT(varchar, AdmitDate.DateValue), 1, 10) + ' ' +
	   SUBSTRING(CONVERT(varchar, AdmitTime.TimeValue), 1, 8) AS datetime) AS ADMISSION_DATE
  ,CAST(SUBSTRING(CONVERT(varchar, DischDate.DateValue), 1, 10) + ' ' +
	   SUBSTRING(CONVERT(varchar, DischTime.TimeValue), 1, 8) AS datetime) AS DISCHARGE_DATE
	,CAST(HospitalAdmissionFact.HospitalService AS varchar(255)) AS HospitalService
  ,HospitalAdmissionFact.IsDeleted
  ,HospitalAdmissionFact.[Count]
  ,ROW_NUMBER() OVER ( PARTITION BY PatientDim.DurableKey, HospitalAdmissionFact.EncounterKey ORDER BY PatientDim.StartDate DESC) AS LatestRecordRank
  ,HospitalAdmissionFact.EDWLastModifiedDTS

FROM EpicMart.Caboodle.HospitalAdmissionFact

LEFT JOIN EpicMart.Caboodle.PatientDim
  ON PatientDim.DurableKey = HospitalAdmissionFact.PatientDurableKey
 AND PatientDim.IsCurrent = 'True'
 AND HospitalAdmissionFact.PatientDurableKey <> -1
 
LEFT JOIN SAM.EAMBehavioral.EventDepartments
  ON EventDepartments.DepartmentKey = HospitalAdmissionFact.DepartmentKey

INNER JOIN EpicMart.Caboodle.DateDim AdmitDate
   ON AdmitDate.DateKey = HospitalAdmissionFact.AdmissionDateKey
  
INNER JOIN EpicMart.Caboodle.TimeOfDayDim AdmitTime
  ON AdmitTime.TimeOfDayKey = HospitalAdmissionFact.AdmissionTimeOfDayKey

INNER JOIN EpicMart.Caboodle.DateDim DischDate 
   ON HospitalAdmissionFact.DischargeDateKey = DischDate.DateKey
  
INNER JOIN EpicMart.Caboodle.TimeOfDayDim DischTime
  ON DischTime.TimeOfDayKey = HospitalAdmissionFact.DischargeTimeOfDayKey
  
 WHERE EXISTS
 (
  SELECT 'Behavioral Health Departments'
    FROM SAM.EAMBehavioral.DomainConfiguration
   WHERE DomainConfiguration.ConfigurationItemDSC = 'DepartmentEpicId'
     AND DomainConfiguration.ConfigurationValueTXT = EventDepartments.DepartmentEpicId
 )
    
) Ranked
WHERE Ranked.LatestRecordRank = 1