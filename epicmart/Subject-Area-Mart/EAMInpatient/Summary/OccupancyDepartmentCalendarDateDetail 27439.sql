/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: OccupancyDepartmentCalendarDateDetail
Description: This binding matches numerator and denominator data for occupancy metrics
History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220502	ms2			164957  Initial script creation
20220615	bs234		170595  Adjusted occupational bed count to remove permanently blocked beds
*********************************************************************************************************************************************************/
    SELECT
		OccupancyDepartmentCalendarDate.CalendarDate
		,DateDim.FiscalYear	AS CalendarFiscalYear
		,OccupancyDepartmentCalendarDate.DepartmentID	
		,OccupancyDepartmentCalendarDate.DepartmentNM	
		,OccupancyDepartmentCalendarDate.RevenueLocationID
		,OccupancyDepartmentCalendarDate.RevenueLocationNM
		,OccupancyDepartmentCalendarDate.HospitalParentLocationID
		,OccupancyDepartmentCalendarDate.HospitalParentLocationNM
		,OccupancyDepartmentCalendarDate.NewMedSurgICUFlg
		,DepartmentDay7amCensus.OccupiedAt7amCNT	/*Numerator*/
		,LicensedBedDepartmentDate.LicensedBedCNT	/*Denominator for LicensedBedOccupancy*/
		,BedBlocksDepartmentDate.BlockedBedAt7amCNT	
		,DepartmentPermanentlyBlockedBed.PermanentlyBlockedBedCNT
		/*Denominator for Occupational (Licensed - Blocked) Bed Occupancy - likely a better way to handle this calculation at an earlier stage*/
		,(ISNULL(LicensedBedDepartmentDate.LicensedBedCNT,0) - ISNULL(BedBlocksDepartmentDate.BlockedBedAt7amCNT,0)) as OccupationalBedCNT	
    ,(ISNULL(LicensedBedDepartmentDate.LicensedBedCNT,0) - ISNULL(BedBlocksDepartmentDate.BlockedBedAt7amCNT,0) - ISNULL(DepartmentPermanentlyBlockedBed.PermanentlyBlockedBedCNT,0)) as OperationalBedCNT	
	FROM 
		SAM.EAMInpatient.OccupancyDepartmentCalendarDate AS OccupancyDepartmentCalendarDate
		LEFT OUTER JOIN SAM.EAMInpatient.BedBlocksDepartmentDate				
			ON OccupancyDepartmentCalendarDate.DepartmentID = BedBlocksDepartmentDate.DepartmentID 
			AND OccupancyDepartmentCalendarDate.CalendarDate = BedBlocksDepartmentDate.CalendarDate
		LEFT OUTER JOIN SAM.EAMInpatient.LicensedBedDepartmentDate		
			ON OccupancyDepartmentCalendarDate.DepartmentID = LicensedBedDepartmentDate.DepartmentID 
			AND OccupancyDepartmentCalendarDate.CalendarDate = LicensedBedDepartmentDate.CalendarDate
		LEFT OUTER JOIN SAM.EAMInpatient.DepartmentDay7amCensus			
			ON OccupancyDepartmentCalendarDate.DepartmentID = DepartmentDay7amCensus.DepartmentID 
			AND OccupancyDepartmentCalendarDate.CalendarDate = DepartmentDay7amCensus.CalendarDate
		LEFT OUTER JOIN EpicMart.Curated.DateDim			
			ON DateDim.DateValue = OccupancyDepartmentCalendarDate.CalendarDate
    LEFT JOIN SAM.EAMInpatient.DepartmentPermanentlyBlockedBed
      ON DepartmentPermanentlyBlockedBed.DepartmentEpicID = OccupancyDepartmentCalendarDate.DepartmentID
      AND OccupancyDepartmentCalendarDate.CalendarDate BETWEEN DepartmentPermanentlyBlockedBed.EffectiveStartDTS AND DepartmentPermanentlyBlockedBed.EffectiveEndDTS
	WHERE 
		OccupancyDepartmentCalendarDate.CalendarDate>= (SELECT FirstDate FROM SAM.EAMInpatient.FirstDate)
     /*This is not an EAM restriction - only included for the discovery query*/
