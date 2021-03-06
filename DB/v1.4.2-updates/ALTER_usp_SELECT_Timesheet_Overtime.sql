USE [TLR]
GO
/****** Object:  StoredProcedure [dbo].[usp_SELECT_Timesheet_Overtime]    Script Date: 4/11/18 4:28:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================
-- Updated:
--	 v1.4.2 - Updated calculations for hourly weekly 
--		totals to exclude leave taken
--
-- Description:	Calculates overtime for all
-- employee types.
--
-- Parameters:
--	@EndPeriodDate		The last day of the pay period
--	@DeptFilterName		Name of the department to filter
--						the results by. For multiple
--						departments, separate with each
--						with a comma (,)
-- =====================================================
ALTER PROC [dbo].[usp_SELECT_Timesheet_Overtime]
(
	 @EndPeriodDate datetime
	,@DeptFilterName varchar(1024) = NULL
)
AS
declare @BeginPeriodDate datetime
declare @PayperiodHourLimit int

--/******* DEBUGGING VALUES ***************************/
--declare @EndPeriodDate datetime
--set @EndPeriodDate = CAST('12/31/2009' as datetime)
--declare @DeptFilterName varchar(50)
--set @DeptFilterName = null
--/****************************************************/

/*----- set the beginDate -----*/
SELECT distinct @BeginPeriodDate = BeginDate FROM TimeSheet
WHERE EndDate = cast(@EndPeriodDate as datetime)

/*------------- Calculate Overtime for weeks that end within the pay period range ----------------*/
declare @OvertimeTotals table
(
	[SID] char(9)
	,TimesheetType varchar(50)
	,Overtime decimal(6,2)
)	

-- used by DATEPART calculations below (ref: http://www.devx.com/tips/Tip/22210)
SET DATEFIRST 7	-- Sunday
declare @OvertimeWeeks table
(
	[Week] int,
	BeginDate datetime,
	EndDate datetime
)

--/******* DEBUGGING *******************************/
--print @BeginPeriodDate
--print DATEPART(DW,  @BeginPeriodDate)
--/******* END DEBUGGING ***************************/

insert into @OvertimeWeeks
select 1
	,@BeginPeriodDate - (DATEPART(DW,  @BeginPeriodDate) - 1)
	,@BeginPeriodDate + (7 - DATEPART(DW,  @BeginPeriodDate))
union
select 2
	,@BeginPeriodDate - (DATEPART(DW,  @BeginPeriodDate) - 1) + 7	-- 2nd full week of pay period
	,@BeginPeriodDate + (7 - DATEPART(DW,  @BeginPeriodDate)) + 7

if (@EndPeriodDate >= @BeginPeriodDate + (7 - DATEPART(DW,  @BeginPeriodDate)) + 14)
begin
	insert into @OvertimeWeeks
	values (
		 3
		,@BeginPeriodDate - (DATEPART(DW,  @BeginPeriodDate) - 1) + 14	-- 3rd full week of pay period
		,@BeginPeriodDate + (7 - DATEPART(DW,  @BeginPeriodDate)) + 14
	)
end

; -- Mgmt. Studio complains if you try to run the query without this semi-colon.
with WeeklyTotals([Week], [SID], TimesheetType, [Hours]) as
(
	select
		tst.[Week]
		,tst.[SID]
		,ts.TypeName as TimesheetType
		,SUM(tst.[Minutes]) / 60 as "Hours"
	from (
		select
			 o.[Week]
			,te.[SID]
			,te.TimesheetID
			,te.EntryDate
			,te.EntryTypeID
		--	,te.EntryStartTime
		--	,te.EntryEndTime
			,case
				when 'Leave' = (select distinct TypeName from vw_Timesheet where TimesheetID = te.TimesheetID) then
				(
					case
						when te.EntryTypeID in ('C', 'D', 'J', 'K', 'P', 'S', 'V', 'W', 'X', 'E', 'O', 'H', 'L', 'Y') then
						(
							te.Duration * 60
						)
						when te.EntryTypeID in ('L', 'Y') then -- unpaid leave that reduces pay hours
						(
							0.00 - (te.Duration * 60)	-- convert to negative number
						)
						else
							0.00
					end
				)
				when 'Hourly' = (select distinct TypeName from vw_Timesheet where TimesheetID = te.TimesheetID) then
				(
					case
						when te.EntryTypeID in ('HL') then	-- exclude hourly leave from time totals
						(
							0.00
						)
						else
							cast((te.[Minutes] - te.MealBreak) as decimal)
					end
				)
			 end as [Minutes]
		--	,te.CreatedDate
		from vw_TimesheetEntry te
		inner join @OvertimeWeeks o on o.BeginDate <= te.EntryDate and o.EndDate >= te.EntryDate
	) tst
	inner join vw_Timesheet ts on ts.TimesheetID = tst.TimesheetID
	group by tst.[Week], tst.[SID], ts.TypeName
)
insert into @OvertimeTotals
select
	ot.[SID]
	,ot.TimesheetType
	,sum(ot.Overtime) as Overtime
from
(
	select
		wt.[Week]
		,wt.[SID]
		,wt.TimesheetType
		,wt.[Hours]
		,case
		 when wt.TimesheetType = 'Leave' then
			case
				-- Full-time total more than 40 hours?
				when wt.[Hours] > 40 then
					wt.[Hours] - 40
				else
					0
			end
		 else -- wt.TimesheetType = 'Hourly'
			case
				-- Does employee also have a full-time job?
				when exists (select * from WeeklyTotals where [SID] = wt.[SID] and TimesheetType = 'Leave') then
					case
						-- have they already worked a full 40 hrs in their full-time job?
						when ((
							select SUM([Hours]) from WeeklyTotals
							where [SID] = wt.[SID] and TimesheetType = 'Leave' and [Week] = wt.[Week]
						) >= 40) then
							-- all hourly hours charged as overtime
							wt.[Hours]
						else
							-- only hours that take them over 40 charged as overtime
							case
								when ((select SUM([Hours]) from WeeklyTotals where [SID] = wt.[SID] and [Week] = wt.[Week]) > 40) then
									((select SUM([Hours]) from WeeklyTotals where [SID] = wt.[SID] and [Week] = wt.[Week]) - 40)
								else
									0
							end
					end
				else -- Employee only has hourly job
					case
						when wt.[Hours] > 40 then
							wt.[Hours] - 40
						else
							0
					end
			end
		 end as Overtime
	from WeeklyTotals wt
	group by wt.[Week], wt.[SID], wt.TimesheetType, wt.[Hours]
) ot
where ot.Overtime > 0
group by ot.[SID], ot.TimesheetType

/*----------------- Construct final dataset for the report ----------------------*/
declare @DeptList table (DeptName varchar(50))

if (@DeptFilterName is null) or (@DeptFilterName = 'All')
	insert into @DeptList select distinct d.DepartmentName from vw_Department d	-- ALL
else
	insert into @DeptList select * from uf_SplitCharCSVArray(@DeptFilterName, ',') -- specified department(s)

select
	ts.TimesheetID
	,ts.[SID]
	,ts.DisplayName as Employee
--	,ts.JobDepartmentID
	,ts.JobDepartmentName as Department
	,ts.JobClassNameShort as Job
	,ot.Overtime
from vw_Timesheet ts
inner join @OvertimeTotals ot on ot.[SID] = ts.[SID] and ot.TimesheetType = ts.TypeName
where (ts.EndDate <= @EndPeriodDate and ts.BeginDate >= @BeginPeriodDate)
and ts.[SID] in (
	select [SID] from @OvertimeTotals
)
and ts.JobDepartmentName in (select DeptName from @DeptList)
order by ts.TimesheetID 
