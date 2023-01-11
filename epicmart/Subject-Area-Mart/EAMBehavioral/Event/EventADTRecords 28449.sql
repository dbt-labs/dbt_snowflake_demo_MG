/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: EventADTRecords
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/


SELECT 
	 ADT.PatientEncounterID
  ,ADT.PatientID
	,ADT.EventID
	,ADT.EffectiveDTS
  ,LEAD(EventID, 1) OVER(PARTITION BY PatientEncounterID ORDER BY EventSEQ ASC )      AS NextEventID
	,LEAD(EffectiveDTS, 1) OVER(PARTITION BY PatientEncounterID ORDER BY EventSEQ ASC ) AS NextEventEffectiveDTS
	,ADT.EventSEQ
	,ADT.ADTEventTypeCD
  ,CASE 
    WHEN ADTEventTypeCD IN ('4','10')	/*Transfer Out [4], Leave of Absence Census [10] */
		THEN 1 
    ELSE 0 
	 END                                                                                AS Excludein7amCensusFLG
	,ADT.ADTEventTypeDSC
	,ADT.ADTEventSubtypeCD
	,ADT.ADTEventSubtypeDSC
	,ADT.DepartmentID
	,ADT.PatientClassCD
	,ADT.PatientClassDSC
	,ADT.PatientServiceCD
	,ADT.PatientServiceDSC
	,ADT.BedID
	,ADT.RoomID
  ,ADT.EDWLastModifiedDTS
FROM
	Epic.Encounter.ADT	/*Pull all the information we need from ADT for all following steps*/

WHERE 
	ADT.ADTEventSubtypeCD <> 2		/*Exclude Canceled events */
	AND ((ADT.DepartmentID = '10040010053' AND Epic.Encounter.ADT.PatientServiceCD = '154') OR ADT.DepartmentID <>'10040010053')
  AND ADT.PatientEncounterID IS NOT NULL

AND EXISTS
 (
  SELECT 'Behavioral Health Departments'
    FROM SAM.EAMBehavioral.DomainConfiguration
   WHERE DomainConfiguration.ConfigurationItemDSC = 'DepartmentEpicId'
     AND DomainConfiguration.ConfigurationValueTXT = ADT.DepartmentID
 )


	