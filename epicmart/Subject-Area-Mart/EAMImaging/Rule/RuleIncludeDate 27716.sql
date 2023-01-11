/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: RuleIncludeDate
Description: There is a valid date range for the domain

Originally copied from Carmin and Margaret's date binding.
Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/

/* This entity was marked inactive, as no limit on date based volume was necessary for performance or in build requirements */
SELECT DateDim.DateKey
	,DateDim.DateValue
	,CASE 
		WHEN DateDim.DateKey > 0
			THEN DATEADD(DAY, 364, DateDim.DateValue)
		END AS NextYearDateValue
	,CASE 
		WHEN DateDim.DateKey > 0
			THEN DATEADD(DAY, - 364, DateDim.DateValue)
		END AS LastYearDateValue
	,DateDim.DayOfWeek
  ,DateDim.IndexDayOfWeek
	,DateDim.WeekNumber
	,DateDim.WeekYear
	,DateDim.Year
	,DateDim.FiscalYear
  ,MONTH(DateValue) AS CalendarMonth,
	YEAR(DateValue) AS CalendarYear,
	MONTH(DATEADD(MONTH, -1, DateValue)) AS PreviousMonthNBR,
	YEAR(DATEADD(MONTH, -1, DateValue)) AS YearOfPreviousMonthNBR
FROM EpicMart.Caboodle.DateDim
WHERE DateDim.DateValue >= 

(
SELECT MIN(DateValue) AS FirstDate  /* First date needed for full prior year reporting */
FROM EpicMart.Curated.DateDim
WHERE DateDim.FiscalYear IN (
		SELECT FiscalYear - 5
		FROM EpicMart.Curated.DateDim
		WHERE DateValue = CAST(GETDATE() AS DATE)
		)
		)
	AND DateDim.DateValue <= (
SELECT
	MAX(CAST(EDWLastModifiedDTS AS DATE)) FROM Epic.Orders.Imaging AS LastDate
		)
	AND DateDim.DateKey > 0