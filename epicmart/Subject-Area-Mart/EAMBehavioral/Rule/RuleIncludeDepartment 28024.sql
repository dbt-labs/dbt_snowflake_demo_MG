/*********************************************************************************************************************************************************
SAM Name: EAMBehavioral
Binding Name: RuleIncludeDepartment
Description: 

Date      User            ADO#    Description
20221027  Jamey Jameson   !11200  Initial creation
*********************************************************************************************************************************************************/

SELECT EventDepartments.DepartmentEpicId
	FROM SAM.EAMBehavioral.EventDepartments
 WHERE EXISTS
 (
  SELECT 'Behavioral Health Departments'
    FROM SAM.EAMBehavioral.DomainConfiguration
   WHERE DomainConfiguration.ConfigurationItemDSC = 'DepartmentEpicId'
     AND DomainConfiguration.ConfigurationValueTXT = EventDepartments.DepartmentEpicId
 )