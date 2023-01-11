/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: EventPsychNotes
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT
	 EDVisitFact.EDVisitKey
	,EDVisitFact.EncounterKey
	,EDVisitFact.EncounterEpicCsn
	,1 as PsychFLG

FROM 
	EpicMart.Caboodle.EDVisitFact
	LEFT OUTER JOIN Epic.Clinical.Note
		on EDVisitFact.EncounterEpicCsn = Note.PatientEncounterID
	LEFT OUTER JOIN Epic.Clinical.NoteEncounterInformation
		on Note.NoteID = NoteEncounterInformation.NoteID

WHERE
	Note.InpatientNoteTypeCD = '2'							/*Consults [2] */
	AND NoteEncounterInformation.AuthorServiceCD = '122'	/*Psychiatry [122] */
	AND NoteEncounterInformation.NoteStatusCD = '2'			/*Signed [2]*/

	 AND NOT EXISTS
     (SELECT 'Behavioral Order Encounter'
     FROM SAM.EAMBehavioral.EventOrders
    WHERE EventOrders.EncounterKey = EDVisitFact.EncounterKey)

GROUP BY 
		EDVisitFact.EDVisitKey
	,EDVisitFact.EncounterKey
	,EDVisitFact.EncounterEpicCsn
     
     