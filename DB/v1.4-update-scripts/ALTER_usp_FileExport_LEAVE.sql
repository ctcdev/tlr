USE [TLR]
GO
/****** Object:  StoredProcedure [dbo].[usp_FileExport_LEAVE]    Script Date: 1/11/18 4:28:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[usp_FileExport_LEAVE]
(
	@SID char(9) -- person generating the file
	,@BeginDate datetime
	,@FileName varchar(50) output
)
AS

--/********** FOR DEBUGGING ************/
--declare	 @SID char(9)
--		,@BeginDate datetime
--		,@FileName varchar(50)
	
--set @SID= '950394601' -- '950381268'
--set @BeginDate = '12/16/09'
--/********** END DEBUGGING ************/

declare @DateStamp datetime
set @DateStamp = getdate()

set @FileName = 'L' + dbo.uf_FormatDate(@DateStamp, 'yyymdhhhnn') + Cast(DATEPART(second, @DateStamp) as varchar(3)) + '.run'

/*only include those leave timesheets where there are no other entries than
'VAC','CSL','P/H','PRL','CMP','WRK', 'SCH', 'TSR'
If there are any non-standard leave/positive time entries (i.e. LWO or LWC) then 
we need to add that timesheet to a list of timesheets to exlude from the leave 
export so that it is processed manually by Payroll.
*/
declare @Timesheets table (TimesheetID int)
insert @Timesheets
select Distinct TimesheetID 
from vw_TimesheetEntry
where Cast(BeginDate as datetime) = @BeginDate
and TimesheetStatusID=4
and TimesheetTypeID=2 --Leave
and HPLeaveTypeID not in ('VAC','CSL','P/H','PRL','CMP','WRK', 'SCH', 'TSR')

/*----- set the endDate (which is needed by usp_SELECT_Timesheet_Overtime) -----*/
declare @EndPeriodDate datetime
SELECT distinct @EndPeriodDate = EndDate FROM vw_TimeSheet WHERE BeginDate = @BeginDate

declare @OvertimeTimesheets table (
	TimesheetID int
	,[SID] char(9)
	,EmployeeName varchar(80)
	,DepartmentName varchar(50)
	,JobTitle varchar(16)
	,OvertimeAmount decimal(6,2)
)
insert into @OvertimeTimesheets
exec usp_SELECT_Timesheet_Overtime @EndPeriodDate

--/********** FOR DEBUGGING ************/
--select * from @OvertimeTimesheets
--/********** END DEBUGGING ************/

insert ExportLeaveData (TimesheetID,SID,BeginDate,EndDate,LeaveTaken,LeaveTypeID,CreatedBy,CreatedOn,ExportFileName)
select 
	ts.TimesheetID
	,ts.SID
	,dbo.uf_FormatDate(Cast(ts.BeginDate as datetime), 'yymmdd') as BeginDate
	,dbo.uf_FormatDate(Cast(ts.EndDate as datetime), 'yymmdd') as EndDate
	,Cast(Sum(e.Duration)*100 as int) as TimesheetTotal
	,e.HPLeaveTypeID
	,@SID as CreatedBy
	,@DateStamp as CreatedOn
	,@FileName as ExportFileName
from vw_TimesheetEntry e
join vw_Timesheet ts on e.TimesheetID = ts.TimesheetID
where e.TimesheetID not in (select TimesheetID from @Timesheets) 
and e.TimesheetID not in (select TimesheetID from @OvertimeTimesheets) -- human needs to verify timesheets w/ OT
and Cast(ts.BeginDate as datetime) = @BeginDate
and ts.TimesheetTypeID=2 --Leave
and ts.TimesheetStatusID = 4
and e.HPLeaveTypeID in ('VAC','CSL','P/H','PRL','CMP','WRK','SCH','TSR') -- leave types to include in export
group by ts.TimesheetID, e.HPLeaveTypeID, ts.BeginDate, ts.SID, ts.EndDate
order by SID

---------------------------------------------------------------------------------
-- Added by Nathan 11/23/09 to remove people from export w/ negative sick balance
-- 2017-12-15: Updated to include hourly leave type and group by leave 
--				type to allow multiple rows for an SID depending on leave type
---------------------------------------------------------------------------------
declare  @userSickTime TABLE (SID int ,sickTimeEntered dec(6,2))

insert into @userSickTime (SID, sickTimeEntered) 
select 
	e.SID
	,SUM(e.Duration) as sickTimeEntered
	from vw_TimesheetEntry e
	where DATEPART(YEAR, @BeginDate) = Datepart(YEAR, e.EntryDate)
	and DATEPART(month, @BeginDate) = Datepart(month, e.EntryDate)
	and e.TimesheetStatusID <> 5
	and e.HPLeaveTypeID in ('CSL','HSL','SSL')	-- list sick leave types
	group by e.HPLeaveTypeID, e.SID	

declare @usersWithNegSickTime TABLE (SID int)	
insert into @usersWithNegSickTime
select ust.SID
	from @userSickTime ust
	left join vw_LeaveBalance lb on lb.SID = ust.SID 
	where lb.LeaveTypeID in ('CSL','HSL','SSL')	-- list sick leave types
	AND (lb.Balance - ust.sickTimeEntered) < 0


-- delete everyone with negative sick leave that may be in the ExportTimeData table 
delete from ExportLeaveData
WHERE SID in (select SID from @usersWithNegSickTime)
and ExportFileName=@FileName



--This will set the status of all timesheets exported to "Processed"
update Timesheet set
TimesheetStatusID = 5 
where TimesheetID in (select distinct TimesheetID from ExportLeaveData where ExportFileName=@FileName)

--Create an action for all processed timesheets
insert TimesheetAction (TimesheetID,ActionTypeID,ActionBy,ActionDate)
select 
distinct TimesheetID
,8 --Process by payroll
,@SID
,@DateStamp
from ExportLeaveData where ExportFileName=@FileName

-- Not sure why we're removing these after the fact, instead of just not including them in the original query - shawn.south 3/15/10
-- Nicole note 12/21/17: WRK and SCH need to be included before so that timesheets with only those entries still get marked as processed
delete dbo.ExportLeaveData
where ExportFileName=@FileName and LeaveTypeID in ('WRK', 'SCH')

select 
	SID+BeginDate+EndDate+Right('000000', 6-Len(LeaveTaken))+LeaveTaken+LeaveTypeID as FileLine
	,ExportFileName
from ExportLeaveData 
where ExportFileName=@FileName


