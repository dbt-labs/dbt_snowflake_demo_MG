/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: MetricPCP_IP
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

    SELECT EventIPVisitFact.EncounterKey
		,CASE WHEN [Resource].ProviderReferralSourceTypeCD = '1' /*Internal provider*/
			    THEN 'Internal'
          WHEN [Resource].ProviderReferralSourceTypeCD = '2' /*External provider*/
			    THEN 'External'
          ELSE 'N/A'
	
			END AS PCP_Type
		,CASE WHEN [Resource].ProviderReferralSourceTypeCD = '1' /*Internal provider*/
			    THEN 1
			ELSE 0
			END AS PCPInternalFLG
		,CASE WHEN [Resource].ProviderReferralSourceTypeCD = '2' /*External provider*/
			THEN 1
			ELSE 0
			END AS PCPExternalFLG
    ,(SELECT MAX(v) FROM (VALUES 
		(PatientEncounter.EDWLastModifiedDTS), 
		(ProviderDim.EDWLastModifiedDTS) 
		) AS VALUE(v) ) AS EDWLastModifiedDTS

   FROM SAM.EAMBehavioral.EventIPVisitFact
   
   LEFT JOIN Epic.Encounter.PatientEncounter
     ON PatientEncounter.PatientEncounterID = EventIPVisitFact.EncounterEpicCsn
   
   LEFT JOIN EpicMart.Caboodle.ProviderDim 
	 ON ProviderDim.ProviderEpicId = PatientEncounter.PCPID 
	AND ProviderDim.IsCurrent = 'True'   /*SER 190 in Clarity */

   LEFT JOIN Epic.Reference.[Resource]
	 ON [Resource].ProviderID = ProviderDim.ProviderEpicId

   WHERE EXISTS 
    (SELECT 'Behavioral Patient Encounters'
  	FROM SAM.EAMBehavioral.PopulationInpatientVisit
  	WHERE PopulationInpatientVisit.EncounterKey = EventIPVisitFact.EncounterKey)