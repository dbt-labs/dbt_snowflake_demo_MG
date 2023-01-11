/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: EAMBehavioralTimePlaceholder
Description: This binding will run in its own batch at a scheduled time.
             It will be a dependency for the full EAMAmbulatory batch, in addition to all other batch dependencies.

Following the same pattern started by Carmin and Margaret

History:
Date      User         ADO#    Description
20221109  Adam Proctor !11200  Initial script creation

*********************************************************************************************************************************************************/

SELECT 
  GETDATE() AS EDWLastModifiedDTS