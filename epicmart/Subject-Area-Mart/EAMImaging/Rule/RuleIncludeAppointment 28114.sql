/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: RuleIncludeAppointment
Description: There are two sources of encounter population, images and appointment requests.

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/

SELECT PatientEncounterID
FROM SAM.EAMImaging.EventRequestedEncounter

WHERE ProcedureNM NOT LIKE '%3D%'
AND ProcedureNM NOT LIKE '%OUTSIDE%'
	
GROUP BY PatientEncounterID
/* 
There is not a maintained grouper list of 3D and OUTSIDE encounters to cover both appointments and images 

Compare to the same concern in another exclusion of imaging
*/