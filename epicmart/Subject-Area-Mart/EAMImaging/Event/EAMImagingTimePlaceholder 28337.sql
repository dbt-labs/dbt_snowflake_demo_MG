/*********************************************************************************************************************************************************
SAM Name: EAMImaging
Binding Name: EAMImagingTimePlaceholder
Description: 
ETL for this SAM was sequenced and needed a pre-requisite check on a weekly basis in addition to fresh sources.

A weekly scheduled batch was created with only this object, so execution satifies the pre-requisite.


Date      User            ADO#    Description
20220802  Adam Proctor    !10981  Initial creation
*********************************************************************************************************************************************************/

SELECT GETDATE() AS EDWLastModifiedDTS