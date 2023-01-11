/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: ADTEncounters
Description: This binding identifies all encounters that exist at least partially within the first and last date window. 
This allow picking up all events for these selected encounters.

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220518	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
SELECT DISTINCT AdtEventDim.EncounterEpicCSN
FROM EpicMart.Curated.AdtEventDim
INNER JOIN sam.EAMInpatient.ServiceArea10Patients
	ON ServiceArea10Patients.PatientEpicId = AdtEventDim.PatientEpicId
LEFT JOIN SAM.EAMInpatient.TestPatients
	ON TestPatients.PatientID = AdtEventDim.PatientEpicId
WHERE EventInstant >= (
		SELECT FirstDate
		FROM SAM.EAMInpatient.FirstDate
		)
	AND TestPatients.TestPatientFLG IS NULL