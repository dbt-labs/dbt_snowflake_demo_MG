/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: MetricImagingRead
Description: Logically this belongs to MetricEncounterUtilization but SQL Server prohibits aggregateion of aggregatation.
Even in the case where there isn't actual cross-row aggregation such as here. This aggregates columns within a row.

Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/
 
  SELECT 	
	EventImagingFact.ImagingKey,
  (SELECT MIN(v) FROM (VALUES (PreliminaryInstant), (FinalizingInstant)) AS entries(v))
	AS 'CalculatedReadDTS'
FROM SAM.EAMImaging.EventImagingFact
INNER JOIN SAM.EAMImaging.PopulationImaging
ON EventImagingFact.ImagingKey = PopulationImaging.ImagingKey