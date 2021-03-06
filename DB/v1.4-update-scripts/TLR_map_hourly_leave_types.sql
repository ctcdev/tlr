/* May or may not be of use - Assumes HSL and SSL HP leave types are in ODS */
/* Add entry types for new leave types */
INSERT INTO [TLR].[dbo].[EntryType] ( EntryTypeID, HPLeaveTypeID, Title, Active, OrderNumber )
	VALUES ( 'SL', 'SSL', 'Student Hourly Sick Leave', 1, 5 )
	, ( 'HL', 'HSL', 'Hourly Sick Leave', 1, 4 )

/* Add entry type mappings to employee types */
INSERT INTO [TLR].[dbo].[EmployeeEntryType] ( EmployeeTypeID, EntryTypeID ) 
	VALUES ( 'S', 'SL' )
	, ( 'H', 'HL' )