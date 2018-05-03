# TLR - Time and Leave Reporting Application

## Overview

The Time and Leave Reporting application is used by multiple institutions for employees to report time and leave.

## Version 1.4 changes - I-1433

> Note that this may be the last time Bellevue College provides any updates as our code base has moved away from the original collaborative distribution. You should consider and plan how your institution will maintain and update TLR for itself going forward.

The changes in this version center around providing functionality for hourly employees to report leave and have that leave flow to the export files generated and uploaded by payroll staff. The main changes are to the part-time timesheet (the one provided to hourly employees), supervisor employee leave balance view, and the payroll time file export and the multiple database stored procedures that support them.

- Part-time timesheet - Update to allow an eligible hourly employee to add leave and show a small leave balance grid (similar to exempt and classified timesheet). Because hourly leave cannot be assigned to an FWS or FWO budget there is also now a warning for supervisors as such when they are applying hours to budgets during the timesheet approval process. Due to time constraints, there is currently no built-in stop for the case that they ignore the warning. You will need to have an audit process/report to find and fix this. Your payroll will likely want to check that any employees with FWS or FWO budget types have an alternate budget available for their supervisors to apply hourly leave hours to.
- The leave balance page is now linked for eligible hourly employees in the left sidebar
- Supervisors will now see eligible hourly employee balances listed on their Employees' Balances page.
- The TIME file export has been updated to generate both a time file _and_ a leave file and to show both in the files list.

Because we started this work when we had no specific direction from the state board, we had to make a number of assumptions about how hourly leave would operate and be accounted for in the HP. Noted below are some assumptions and whether this distribution accounts for said proven-false assumptions - in some cases, due to time constraints in distributing this, fixes for false assumptions ARE NOT included, and you will be responsible for these.
 
#### Assumptions

Please check back here, as assumptions will be added/updated here as more information is received from the state board.

- Eligible hourly students will be updated to have an HP LeaveAccrualCode of 'Y' similar to exempt and classified employees.
	- Proven? FALSE. However, you should not need to make any changes to account for this as this means there is no change how the type of timesheet is chosen for an employees. 
- Hourly leave will be included as time in calculating overtime. 
	- Proven? FALSE. Per the state board, hourly leave is not to be included in calculating overtime. The v1.4.2 release includes updates related to hourly overtime calculation.
- Hourly leave time will be counted as both time AND leave.
	- Proven? ISH. The HOURLY file export job will create both time and leave entries in the respective generated files during export (and this is correct). However, there is ongoing discussion as to how best to mark time hours for leave for tax accounting purposes. The best solution here is still to be determined.
- Hourly employee leave balances will flow similar to how an exempt or classified employees currently does, i.e. eligible hourly employees will have entries in ODS EmployeeLeave and EmployeeLeaveHistory tables.
	- Proven? TRUE. As of February 8, we're seeing the leave data from the HP flowing into the ODS EmployeeLeave and EmployeeLeaveHistory tables under the HSL leave type.

#### Using release

When using the .zip release rather than building your own, you should be able to use your current `Web.config` altering only to add the following two new settings to the `TLR.My.MySettings` section:

````
 <setting name="BudgetEarningType_LeaveNotAllowed" serializeAs="String">
    <value>FWS,FWO</value>
 </setting>
 <setting name="JobEmployeeType_AllowsHourlyLeave" serializeAs="String">
    <value>H,S</value>
 </setting>
````


## TLR vocabulary

- "Part-time timesheet" vs "full-time timesheet"
	- Code-wise in TLR there are two different timesheets. The part-time timesheet is provided to hourly employees. The full-time timesheet is provided to all others. Obviously this nomenclature does not necessarily match 1:1 with the employee type as hourly employees can work full-time hours and classified employees can be part-time. 
	- Data-wise the timesheet type for an employee is chosen based on the LeaveAccrualCode in ODS. If "Y" the employee receives the "full-time" timesheet. If "N" the employee receives the "part-time" timesheet.
- "Time" and "Leave" file exports
	- Payroll users see two file export options - time and leave. 
		- Time - Traditionally, the time export option was called that because it generated a file for hourly positive time reported only.  However, with the v1.4 changes to allow hourly leave, this option now generates two files - one for hourly time reported and one for hourly leave reported. The naming has been kept for consistency purposes.
		- Leave - This file export option generates a file for non-hourly ("full-time timesheet") leave reported. This remains the same in v1.4.

## Setting up the TLR project for development

This info is only pertinent if you wish to set up a local version of the project for development. Otherwise, check the releases section for a downloadable, compiled version of the most recent release.

#### Requirements ####

- .NET 3.5 framework
- Visual Studio 2012
	
Note: In the interest of keeping this version as similar framework-wise to the previous version to limit variables for folks, this version is still using .NET 3.5, though it can easily be upgraded to .NET 4.6 or 4.7. It is currently a Visual Studio 2012 project, though it works fine in, or can be easily upgraded to, VS 2015 or 2017.

#### Clone project

Clone or fork the project to a local repo. Ensure you are using the dev branch for development (or create a new one for your updates, depending on how extensive they are).

#### Update config files

Update the necessary .config files (`WebAppSettingXXX.config` and `WebConnStrXXX.config` and update `Web.config` to point to the correct configSource files for your environment. 

#### Build project

Now build the TLR project. This should theoretically successfully build error free. Once built, you should be able to run it (with or without debugging) from Visual Studio. You can also configure it to use a local IIS server instead.
