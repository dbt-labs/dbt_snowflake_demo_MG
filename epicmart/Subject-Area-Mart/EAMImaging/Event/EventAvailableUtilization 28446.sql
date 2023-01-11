/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: EventAvailableUtilization
Description: 

Date      User            ADO#    Description
20221019  Adam Proctor    !12120  Initial creation
*********************************************************************************************************************************************************/

SELECT AvailableUtilization.SlotBeginDTS,
       AvailableUtilization.DepartmentID,
       AvailableUtilization.ProviderID,
       AvailableUtilization.AppointmentSEQ,
       AvailableUtilization.PatientEncounterID,
       AvailableUtilization.VisitTypeID,
       AvailableUtilization.DepartmentDSC,
       DATENAME(WEEKDAY, AvailableUtilization.SlotBeginDTS) AS DayOfWeekNM,
       DATEADD(MINUTE, AvailableUtilization.SlotLengthMinuteNBR, AvailableUtilization.SlotBeginDTS) AS SlotEndDTS,
       AvailableUtilization.SlotLengthMinuteNBR,
       AvailableUtilization.DayUnavailableFLG,
       AvailableUtilization.UnavailableReasonCD,
       AvailableUtilization.UnavailableReasonDSC,
       AvailableUtilization.TimeUnavailableFLG,
       AvailableUtilization.EDWLastModifiedDTS
FROM   Epic.Schedule.AvailableUtilization
       INNER JOIN
       SAM.EAMImaging.DomainResource
       ON DomainResource.ResourceID = AvailableUtilization.ProviderID;