/* 
SAM Name: EAMInpatient
Binding Name: EAMInpatientTimePlaceholder

This binding will run in its own batch at a scheduled time. 
It will be a dependency for the full EAMInpatient batch, in addition to EpicMartEnd

*/

select getdate() AS LastModifiedInstant