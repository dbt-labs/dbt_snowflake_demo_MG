/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: EventADT
Description: Stands in for Epic.Encounter.ADT as a source to avoid contention while the SAM is running, preventing spikes in execution duration.

History:

Date		  User		 TFS#	  Description
20220728	Adam Proctor	  Initial script creation
*********************************************************************************************************************************************************/

SELECT
	ADT.PatientEncounterID
	,ADT.PatientID
	,ADT.EventID
	,ADT.EffectiveDTS
	,ADT.EventSEQ
	,ADT.ADTEventTypeCD
	,ADT.ADTEventTypeDSC
	,ADT.ADTEventSubtypeCD
	,ADT.ADTEventSubtypeDSC
	,ADT.DepartmentID
	,ADT.PatientClassDSC
  ,ADT.PatientClassCD 
	,ADT.PatientServiceCD
	,ADT.PatientServiceDSC
	,ADT.BedID
	,ADT.RoomID
  ,ADT.EDWLastModifiedDTS
  ,HospitalServiceGroupDim.HospitalServiceGroupName
FROM Epic.Encounter.ADT

INNER JOIN EpicMart.Curated.HospitalServiceGroupFact ON HospitalServiceGroupFact.HospitalServiceEpicId = ADT.PatientServiceCD
INNER JOIN EpicMart.Curated.HospitalServiceGroupDim ON HospitalServiceGroupDim.HospitalServiceGroupKey = HospitalServiceGroupFact.HospitalServiceGroupKey
	AND HospitalServiceGroupDim.HospitalServiceGroupTypeId = 14 
  WHERE EXISTS
  
(SELECT 1 AS 'Service Area 10 Encounter'
FROM SAM.EAMInpatient.ADTEncounters 
WHERE ADTEncounters.EncounterEpicCSN = ADT.PatientEncounterID
)