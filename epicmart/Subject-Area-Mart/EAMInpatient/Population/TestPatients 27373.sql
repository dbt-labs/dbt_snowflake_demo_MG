/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: TestPatients
Description: This binding identifies test patients to be excluded from EAM Inpatient entities

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
SELECT 
	EpicPatient.PatientID
	,1 TestPatientFLG
FROM Epic.Patient.Patient EpicPatient
INNER JOIN Integration.MasterReference.Patient MasterPatient 
	ON EpicPatient.EDWPatientID = MasterPatient.EDWPatientID
	AND MasterPatient.TestFLG = 'TRUE'