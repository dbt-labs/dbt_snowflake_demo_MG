/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: ServiceArea10Patients
Description: This binding flags patients as being part of Service Area 10. 
              This allows filtering down to the correct encounter population for EAM

History:

Date		  User		 TFS#	  Description
------		------	------	---------------------------------------------------------------------------------------------------------------------------------
20220518	ms2			164957  Initial script creation
*********************************************************************************************************************************************************/
SELECT DISTINCT PatientDim.PatientEpicId
	,OrganizationSettingServiceArea.ServiceAreaID
FROM EPIC.Patient.AccessOrganizationGroup
INNER JOIN EPIC.Reference.BridgePatientAccessOrganization
	ON AccessOrganizationGroup.GROUPID = BridgePatientAccessOrganization.GROUPID
INNER JOIN EPIC.Reference.OrganizationSetting
	ON BridgePatientAccessOrganization.ORGANIZATIONID = OrganizationSetting.ORGANIZATIONID
INNER JOIN EPIC.Reference.OrganizationSettingServiceArea
	ON OrganizationSetting.SETTINGID = OrganizationSettingServiceArea.SETTINGID
		AND OrganizationSetting.LINENBR = OrganizationSettingServiceArea.GROUPLINENBR
INNER JOIN EpicMart.Curated.PatientDim
	ON PatientDim.patientepicid = AccessOrganizationGroup.patientid
WHERE OrganizationSetting.PatientAuthorizedServiceAreaFLG = 'Y'
	AND COALESCE(OrganizationSettingServiceArea.ServiceAreaID,0) = 10