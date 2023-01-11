/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: MetricCoverage_IP
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
  SELECT EventIPVisitFact.EncounterKey
		,CoverageDim.BenefitPlanName
		,CoverageDim.CoverageKey
		,CoverageDim.BenefitPlanEpicId
		,CASE WHEN CoverageDim.BenefitPlanEpicId = '300116' /*300116 is the benefit plan ID in Epic for MASSHEALTH MASS GENERAL BRIGHAM ACO */
			THEN 1
			ELSE 0
			END AS MGBACOMembershipFlg
    ,CoverageDim. EDWLastModifiedDTS

   FROM SAM.EAMBehavioral.EventIPVisitFact

   LEFT JOIN EpicMart.Caboodle.CoverageDim 
	 ON CoverageDim.CoverageKey = EventIPVisitFact.PrimaryCoverageKey
   
   WHERE EXISTS 
    (SELECT 'Behavioral Inpatient Population Encounters'
  	FROM SAM.EAMBehavioral.PopulationInpatientVisit
  	WHERE PopulationInpatientVisit.EncounterKey = EventIPVisitFact.EncounterKey)