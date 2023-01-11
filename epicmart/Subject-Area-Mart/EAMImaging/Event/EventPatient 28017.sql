/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: EventPatient
Description: Get the patient's MRN.

From Carmin's script for EAMAmbulatory
Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
20221011  Adam Proctor            Hotfix for duplicates on RANK
*********************************************************************************************************************************************************/

SELECT 
* 
FROM(
SELECT
      PatientDim.PatientKey,
      PatientDim.DurableKey as PatientDurableKey,
      PatientDim.PatientEpicID,
      [Identity].PatientIdentityID AS PMRN,
      PatientDim.IsCurrent
      /*Epic's issues with patients having multiple DurableKeys with IsCurrent = 'True' causes issues with duplicate patient records.
      	Until those issues are fully resolved, alternate solution to use rank (LatestRecordRank) will be used in place of "IsCurrent" */,
      PatientDim.StartDate,
      PatientDim.EndDate,
      RANK() OVER (
        PARTITION BY PatientDim.DurableKey
        ORDER BY
          PatientDim.StartDate DESC,
          PatientDim.PatientEpicID DESC,
          PatientDim.PatientKey DESC
      ) AS LatestRecordRank,
      PatientDim.EDWLastModifiedDTS
    FROM
      EpicMart.Caboodle.PatientDim
      LEFT OUTER JOIN Epic.Patient.Patient EpicPatient ON PatientDim.PatientEpicID = EpicPatient.PatientID
      LEFT OUTER JOIN Epic.Patient.[Identity] ON PatientDim.PatientEpicID = [Identity].PatientID
      AND [Identity].IdentityTypeID = '0'
      /*PMRN*/
    WHERE
      PatientDim.IsCurrent = 'True'
    ) Ranked
WHERE LatestRecordRank = 1

