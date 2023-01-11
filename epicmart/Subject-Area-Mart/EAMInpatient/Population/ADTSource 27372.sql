/*********************************************************************************************************************************************************
SAM Name: EAMInpatient
Binding Name: ADTSource
Description: This binding collects all non canceled ADT events

History:

Date		  User		 TFS#	    Description
20220502	ms2			164957    Initial script creation
20220513	cdunn9	167029	  Update to exclude Medicine and Surgical serivces and rename columns to include "Qualifying"
									ObservationPatientClassFLG to QualifyingObservationPatientClassFLG
									PostProcedureRecoveryPatientClassFLG to QualifyingPostProcedureRecoveryPatientClassFLG
									IsInpatientCensusEvent to IsQualifyingInpatientCensusEvent
									IsFirstInpatientCensusEvent to IsFirstQualifyingInpatientCensusEvent
									IsFirstPatientClassEvent to IsFirstQualifyingPatientClassEvent
20220728  Adam Proctor        Replace reference to Clarity ADT and instead use EventADT to avoid source contention during ETL.
20221118  KG312	ADO PR !12451	Add flags for Service & Dept Inc to be used in DailyOccupancyat7am INNER to Departments for exclusions
*********************************************************************************************************************************************************/
SELECT
	 ADT.PatientEncounterID
	,ADT.PatientID
	,ADT.EventID
	,ADT.EffectiveDTS
	,CASE 
		WHEN ADT.EventSeq = min(CASE 
					WHEN ADT.PatientClassCD IN (
							'101'		/*Inpatient  [101]*/
							,'104'		/*Observation [104]*/
							,'124'		/*Post Procedure Recovery [124]*/
							)
						AND ServiceInclusionFLG = 1
						THEN ADT.EventSeq
					END) OVER (
				PARTITION BY ADT.PatientEncounterID ORDER BY ADT.EventSEQ ASC
				)
			THEN 1
		ELSE 0
		END AS IsFirstQualifyingAdmitEvent
	,CASE 
		WHEN ADT.EventSeq = MIN(CASE
					WHEN ServiceInclusionFLG = 1
					THEN ADT.EventSeq
				END) OVER (
				PARTITION BY ADT.PatientEncounterID,ADT.PatientClassCD ORDER BY ADT.EventSEQ ASC
				)
			THEN 1
		ELSE 0
		END AS IsFirstQualifyingPatientClassEvent
	,CASE 
		WHEN ADT.EventSeq = MIN(CASE 
					WHEN ADT.ADTEventTypeCD = '6'	/*Census [6]*/
						AND ADT.PatientClassCD IN (
							'101'		/*Inpatient  [101]*/
							)
						AND ServiceInclusionFLG = 1
						THEN ADT.EventSeq
					END) OVER (
		PARTITION BY ADT.PatientEncounterID ORDER BY ADT.EventSEQ ASC
		) THEN 1 ELSE 0 END  AS IsFirstQualifyingInpatientCensusEvent
	,CASE 
		WHEN ADT.ADTEventTypeCD = '6'	/*Census [6]*/
					AND ADT.PatientClassCD = '101'	/*Inpatient  [101]*/
					AND ServiceInclusionFLG = 1
					THEN 1
		ELSE 0
		END AS IsQualifyingInpatientCensusEvent
	, LEAD(ADT.EffectiveDTS, 1) OVER (
					PARTITION BY ADT.PatientEncounterID ORDER BY  
							ADT.EventSEQ ASC)
		 AS NextEventEffectiveDTS
	,ADT.EventSEQ
	,ADT.ADTEventTypeCD
	,ADT.ADTEventTypeDSC
	,ADT.ADTEventSubtypeCD
	,ADT.ADTEventSubtypeDSC
	,ADT.DepartmentID
	,ADT.PatientClassCD
	,ADT.PatientClassDSC
	,CASE 
		WHEN ADT.PatientClassCD = '104' /*Observation [104]*/
			AND ServiceInclusionFLG = 1
			THEN 1
		ELSE 0
		END AS QualifyingObservationPatientClassFLG
	,CASE 
		WHEN ADT.PatientClassCD = '124' /*Post Procedure Recovery [124]*/
			AND ServiceInclusionFLG = 1
			THEN 1
		ELSE 0
		END AS QualifyingPostProcedureRecoveryPatientClassFLG
	,CASE WHEN ADT.ADTEventTypeCD IN ('4','10')	/*Transfer Out [4], Leave of Absence Census [10] */
			THEN 1 ELSE 0 
			END AS Excludein7amCensusFLG
	,ADT.PatientServiceCD
	,ADT.PatientServiceDSC
	,HospitalServiceGroupDim.HospitalServiceGroupName AS EAMServiceGrouping
	,ADT.BedID
	,ADT.RoomID
	,RuleHospitalServiceInclusion.ServiceInclusionFLG
	,CASE WHEN Departments.DepartmentIsMedSurgFLG = 1 
	         THEN 1
		  WHEN Departments.DepartmentIsICUFLG = 1
		     THEN 1
		ELSE 0
	 END AS 'DepartmentInclusionFLG'

      FROM SAM.EAMInpatient.EventADT ADT 
INNER JOIN SAM.EAMInpatient.ADTEncounters            ON ADTEncounters.EncounterEpicCSN = ADT.PatientEncounterID
 LEFT JOIN SAM.EAMInpatient.TestPatients             ON TestPatients.PatientID = ADT.PatientID
INNER JOIN SAM.EAMInpatient.Departments              ON Departments.DepartmentID = ADT.DepartmentID 
INNER JOIN EpicMart.Curated.HospitalServiceGroupFact ON HospitalServiceGroupFact.HospitalServiceEpicId = ADT.PatientServiceCD
INNER JOIN EpicMart.Curated.HospitalServiceGroupDim  ON HospitalServiceGroupDim.HospitalServiceGroupKey = HospitalServiceGroupFact.HospitalServiceGroupKey
	                                                AND HospitalServiceGroupDim.HospitalServiceGroupTypeId = 14 /* EAM MedSurg grouping */
INNER JOIN SAM.EAMInpatient.RuleHospitalServiceInclusion ON RuleHospitalServiceInclusion.HospitalServiceGroupKey = HospitalServiceGroupDim.HospitalServiceGroupKey

 WHERE ADT.ADTEventSubtypeCD <> 2 /*Exclude Canceled events */
   AND TestPatients.PatientID IS NULL /*Test Patient exclusion*/