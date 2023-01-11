/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: PopulationSlot
Description: Find the first utilization row that will properly represent the status of the slot.

The Available Utilization table is unique on four columns, but representative slots are unique on two.

See the partition and consider the row number function for more information.

Date      User            ADO#    Description
20221019  Adam Proctor    !12120  Initial creation
*********************************************************************************************************************************************************/
SELECT * 
FROM
  (
  SELECT 
  	AvailableUtilization.SlotBeginDTS,                                                                          
    AvailableUtilization.DepartmentID,                                                                          
    CAST(AvailableUtilization.ProviderID AS VARCHAR(300)) AS ProviderID,                                                      
    AvailableUtilization.AppointmentSEQ,                                                                        
   ROW_NUMBER() OVER 
    (
    PARTITION BY 
     AvailableUtilization.SlotBeginDTS, 
     AvailableUtilization.ProviderID 
    ORDER BY 
     CASE WHEN PatientEncounter.AppointmentStatusCD IN (6,2) THEN 1 ELSE 0 END DESC, 
     AvailableUtilization.AppointmentSEQ,
     SlotEndDTS
     ) SlotReferenceRowNBR
  FROM SAM.EAMImaging.EventAvailableUtilization AvailableUtilization
  LEFT JOIN Epic.Encounter.PatientEncounter
  	ON PatientEncounter.PatientEncounterID = AvailableUtilization.PatientEncounterID
  WHERE NOT EXISTS
  (SELECT 'Test Patient Exclusion'
  FROM SAM.EAMImaging.RuleExcludeTestPatient
  WHERE PatientEncounter.PatientID = RuleExcludeTestPatient.PatientEpicID)
  ) A
WHERE SlotReferenceRowNBR = 1