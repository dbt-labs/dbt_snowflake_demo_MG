/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: EventADTRecords
Description: 

Date      User            ADO#    Description
20221130  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

 SELECT
	 EDPatient.DepartmentID
  ,EDPatient.DepartmentDSC AS DepartmentNM
	,EDEvent.EventID
	,EDEvent.EventTypeCD
	,EDEvent.LineNBR
	,EDEvent.EventNM
	,EDEvent.EventDTS AS StaffedBedStartDTS
	,ISNULL(LEAD(EDEvent.EventDTS, 1) 
		 OVER(PARTITION BY EDPatient.DepartmentID
		 ORDER BY EDEvent.EventDTS ASC), CAST(GETDATE() AS DATE)) AS NextStaffedBedStartDTS
	,EDEvent.StaffedBedNBR
	,EDEvent.FullyStaffedFLG

FROM  Epic.Clinical.EDEvent
LEFT JOIN Epic.Clinical.EDPatient
	ON EDEvent.EventID = EDPatient.EventID
WHERE EDEvent.EventTypeCD ='24000'  
	AND EDPatient.DepartmentID NOT IN /*These 3 departments below are no longer in use but wwere included  in population for historic data. 
									                    With the staffed beds and occupancy piece being more current, is it needed to be included or not? Need consensus with engineeer and maybe domain on this*/
  ('10050010044', /*SLM WEST 2 SR PSYCH UH DNU */  
   '10050010043', /*SLM EAST 3 CH PSYCH UH DNU */  
   '10050020093',	/*SLM EAST 7 AD PSYCH DNU */
   '10040010053'  /*BWF 6 NORTH*/  --This unit doesn't house only BH patients so we can't tell which staffed beds are actually BH. We need more info from the domain on how to move forward with this. Should it be excluded? If it is included, how do we ascertain the correct numbers?*/
	)
  
  AND EXISTS
 (
  SELECT 'Behavioral Health Departments'
    FROM SAM.EAMBehavioral.DomainConfiguration
   WHERE DomainConfiguration.ConfigurationItemDSC = 'DepartmentEpicId'
     AND DomainConfiguration.ConfigurationValueTXT = EDPatient.DepartmentID
 )