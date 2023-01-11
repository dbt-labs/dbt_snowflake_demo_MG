/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: MetricCoverage_EDBoarders
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/
    SELECT EventEDPsychBoarders.EncounterKey
		,CoverageDim.BenefitPlanName
		,CoverageDim.CoverageKey
		,CoverageDim.BenefitPlanEpicId
		,CASE WHEN CoverageDim.BenefitPlanEpicId = '300116' /*300116 is the benefit plan ID in Epic for MASSHEALTH MASS GENERAL BRIGHAM ACO */
			THEN 1
			ELSE 0
			END AS MGBACOMembershipFlg
    ,CoverageDim. EDWLastModifiedDTS

   FROM SAM.EAMBehavioral.EventEDPsychBoarders

   LEFT JOIN EpicMart.Caboodle.CoverageDim 
	 ON CoverageDim.CoverageKey = EventEDPsychBoarders.PrimaryCoverageKey
   