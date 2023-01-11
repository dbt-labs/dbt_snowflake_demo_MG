/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: RuleExcludeTestPatient
Description: This binding identifies test patients to be excluded from EAMBehavioral entities

History:

Date		  User		        ADO#	  Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT PatientDim.PatientKey
      ,PatientDim.DurableKey
	  ,EpicPatient.EDWPatientID
	  ,EpicPatient.PatientID
	    ,1 TestPatientFLG
FROM Epic.Patient.Patient EpicPatient

LEFT JOIN EpicMart.Caboodle.PatientDim
  ON PatientDim.PatientEpicId = EpicPatient.PatientId

INNER JOIN Integration.MasterReference.Patient MasterPatient 
	ON EpicPatient.EDWPatientID = MasterPatient.EDWPatientID
	AND MasterPatient.TestFLG = 'TRUE'