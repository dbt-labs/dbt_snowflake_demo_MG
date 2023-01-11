/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: RuleHospitalServiceInclusion
Description: This rule will determine HospitalServiceGroup inclusion

History:

Date		  User		TFS#	         Description
20221117	KG312		ADO PR !12451  Initial script creation
*********************************************************************************************************************************************************/

SELECT HospitalServiceGroupKey
	   , HospitalServiceGroupName
     , CASE WHEN HospitalServiceGroupName in ('Medicine','Surgical')
              THEN 1 
		       ELSE 0 
	     END as ServiceInclusionFLG
 FROM EpicMart.Curated.HospitalServiceGroupDim