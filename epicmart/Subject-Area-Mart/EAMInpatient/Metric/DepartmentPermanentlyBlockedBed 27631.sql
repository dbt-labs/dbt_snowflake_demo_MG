/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: DepartmentPermanentlyBlockedBed
Description: This binding pulls in permanently blocked beds for each department from an IDEA application.

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220615	bs234	  170595  New binding to source data needed from IDEA to be used in Occupational Occupancy metric for Inpatient
*********************************************************************************************************************************************************/

SELECT
    DepartmentEpicID
,   DepartmentNM
,   EffectiveStartDTS
,   EffectiveEndDTS
,   PermanentlyBlockedBedCNT
FROM
	IDEAApplication.EAMInpatient.DepartmentPermanentlyBlockedBed