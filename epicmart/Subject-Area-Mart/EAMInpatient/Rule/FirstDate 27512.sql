/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: FirstDate
Description: This binding calculates the first date to use wherever a date range is needed

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220518	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
SELECT MIN(DateValue) AS FirstDate
	,MIN(DATEADD(YEAR, 1, DateValue)) AS FirstReportedDate
FROM EpicMart.Curated.DateDim
WHERE DateDim.FiscalYear IN (
		SELECT FiscalYear - 4
		FROM EpicMart.Curated.DateDim
		WHERE DateValue = cast(getdate() AS DATE)
		)