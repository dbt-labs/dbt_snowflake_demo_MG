/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: RuleExcludeTestPatient
Description: Test patients are not valid in the population

Originally copied from Carmin and Margaret's test patient binding.
Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/

SELECT 
	PatientDim.PatientKey
  ,PatientDim.DurableKey as PatientDurableKey
	,PatientDim.PatientEpicID
	,1 TestPatientFLG
FROM 
	EpicMart.Caboodle.PatientDim
	INNER JOIN Epic.Patient.Patient EpicPatient
		ON PatientDim.PatientEpicID = EpicPatient.PatientID
	INNER JOIN Integration.MasterReference.Patient MasterPatient 
		ON EpicPatient.EDWPatientID = MasterPatient.EDWPatientID
		AND MasterPatient.TestFLG = 'TRUE'
    
