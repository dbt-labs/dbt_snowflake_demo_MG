/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: EventEncounterFact
Description: Obtain keys for Imaging Domain encounters, whether from the encounter via imaging or the encounter via appointment request.

This is a population of sorts, where we wanted to gather all the keys for the domain
Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/

SELECT
EncounterFact.EncounterKey
   
FROM EpicMart.Caboodle.EncounterFact
WHERE 
EXISTS
(
SELECT 'Domain Machine Imaging Encounter'
FROM SAM.EAMImaging.EventImagingFact
WHERE EncounterFact.EncounterKey = EventImagingFact.PerformingEncounterKey
)

UNION

SELECT
EncounterFact.EncounterKey

FROM EpicMart.Caboodle.EncounterFact
WHERE 
EXISTS
(
SELECT 'Domain Machine Appointment Encounter'
FROM SAM.EAMImaging.EventRequestedEncounter
WHERE EncounterFact.EncounterEpicCsn = EventRequestedEncounter.PatientEncounterID

)

/* There is no direct way to connect encounter fact to domain machines */

/* TODO check that there aren't future encounters, even though they are filtered
out downstream 
*/