USE [TLR]
GO
/****** Object:  StoredProcedure [dbo].[usp_SELECT_TimesheetTotals_LEAVE]    Script Date: 1/10/18 3:21:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[usp_SELECT_TimesheetTotals_LEAVE]
(
	@TimesheetID int
)
AS



--declare @TimesheetID int
--set @TimesheetID = 168804

declare @BeginDate datetime
select @BeginDate = BeginDate from vw_Timesheet where TimesheetID=@TimesheetID

declare @Today datetime
set @Today = getdate()

if DATEPART(YEAR, @Today) = Datepart(YEAR, @BeginDate) and DATEPART(month, @Today) = Datepart(month, @BeginDate)
--This means we are looking at the timesheet during the same month and can show the balances

select 
t.EntryTypeID
,'(' + t.EntryTypeID + ') ' + t.Title as LeaveType
,b.Balance as PrevBalance
,ts.TimesheetTotal
,m.MonthTotal
,b.Balance - m.MonthTotal as EndBalance
,t.OrderNumber
,CASE
	WHEN b.Balance-m.MonthTotal < 0 then 1
	ELSE 0
END as NegativeBalance
from vw_LeaveBalance b
left outer join (
	select 
	e.HPLeaveTypeID
	,Sum(e.Duration) as MonthTotal
	from vw_TimesheetEntry e
	where e.SID=(select SID from vw_Timesheet where TimesheetID=@TimesheetID)
	and DATEPART(YEAR, @BeginDate) = Datepart(YEAR, e.EntryDate)
	and DATEPART(month, @BeginDate) = Datepart(month, e.EntryDate)
	and e.TimesheetStatusID <> 5
	group by e.HPLeaveTypeID, e.Title, e.OrderNumber
	) m on b.LeaveTypeID = m.HPLeaveTypeID
left outer join (
	select 
	e.HPLeaveTypeID
	,Sum(e.Duration) as TimesheetTotal
	from vw_TimesheetEntry e
	where e.TimesheetID=@TimesheetID
	group by e.HPLeaveTypeID, e.Title, e.OrderNumber
	) ts on b.LeaveTypeID = ts.HPLeaveTypeID	
join vw_EntryType t on b.LeaveTypeID = t.HPLeaveTypeID
where b.SID=(select SID from vw_Timesheet where TimesheetID=@TimesheetID)
and (b.LeaveTypeID in('VAC','CSL','P/H','PRL','NSL','TSR','HSL','SSL') or
	(b.LeaveTypeID not in('VAC','CSL','P/H','PRL','NSL','TSR','HSL','SSL') and b.Balance > 0))



union all

select 
t.EntryTypeID
,'(' + t.EntryTypeID + ') ' + t.Title as LeaveType
,0 as Balance
,ts.TimesheetTotal
,m.MonthTotal
,0 as EndBalance
,t.OrderNumber
,0
from vw_EntryType t
join (
	select 
	e.EntryTypeID
	,Sum(e.Duration) as MonthTotal
	from vw_TimesheetEntry e
	where e.SID=(select SID from vw_Timesheet where TimesheetID=@TimesheetID)
	and DATEPART(YEAR, @BeginDate) = Datepart(YEAR, e.EntryDate)
	and DATEPART(month, @BeginDate) = Datepart(month, e.EntryDate)
	and e.TimesheetStatusID <> 5
	group by e.EntryTypeID, e.Title, e.OrderNumber
	) m on t.EntryTypeID= m.EntryTypeID
join (
	select 
	e.EntryTypeID
	,Sum(e.Duration) as TimesheetTotal
	from vw_TimesheetEntry e
	where e.TimesheetID=@TimesheetID
	group by e.EntryTypeID, e.Title, e.OrderNumber
	) ts on t.EntryTypeID = ts.EntryTypeID	
where 
isNULL(t.HPLeaveTypeID, '') not in('VAC','CSL','P/H','CMP','PRL','NSL','TSR','HSL','SSL')
order by t.OrderNumber




else
begin

declare @BalanceView table(
	EntryTypeID varchar(3)
	,LeaveType varchar(50)
	,PrevBalance decimal(8,2)
	,TimesheetTotal decimal (7,2)
	,MonthTotal decimal (8,2)
	,EndBalance decimal (8,2)
	,OrderNumber int
	)

insert @BalanceView
select 
t.EntryTypeID
,'(' + t.EntryTypeID + ') ' + t.Title as LeaveType
,h.EndBalance as PrevBalance
,ts.TimesheetTotal
,m.MonthTotal
,h.EndBalance - m.MonthTotal as EndBalance
,t.OrderNumber
from vw_LeaveHistory h
left outer join (
	select 
	e.HPLeaveTypeID
	,Sum(e.Duration) as MonthTotal
	from vw_TimesheetEntry e
	where e.SID=(select SID from vw_Timesheet where TimesheetID=@TimesheetID)
	and DATEPART(YEAR, @BeginDate) = Datepart(YEAR, e.EntryDate)
	and DATEPART(month, @BeginDate) = Datepart(month, e.EntryDate)
	and e.TimesheetStatusID <> 5
	group by e.HPLeaveTypeID, e.Title, e.OrderNumber
	) m on h.LeaveTypeID = m.HPLeaveTypeID
left outer join (
	select 
	e.HPLeaveTypeID
	,Sum(e.Duration) as TimesheetTotal
	from vw_TimesheetEntry e
	where e.TimesheetID=@TimesheetID
	group by e.HPLeaveTypeID, e.Title, e.OrderNumber
	) ts on h.LeaveTypeID = ts.HPLeaveTypeID	
join vw_EntryType t on h.LeaveTypeID = t.HPLeaveTypeID
where h.SID=(select SID from vw_Timesheet where TimesheetID=@TimesheetID)
--and h.LeaveTypeID in('VAC','CSL','P/H','CMP','PRL','NSL')
and h.LeaveTypeID in('VAC','CSL','NSL','HSL','SSL')
	 --or (h.LeaveTypeID not in('VAC','CSL','NSL') and h.EndBalance > 0))
and DatePart(year, dateadd(month, -1, @BeginDate)) = YearTaken
and DatePart(month, dateadd(month, -1, @BeginDate)) = MonthTaken


insert @BalanceView
select 
distinct t.EntryTypeID 
,'(' + t.EntryTypeID + ') ' + t.Title as LeaveType
,(select top 1 EndBalance
	from vw_LeaveHistory
	where SID=(select SID from vw_Timesheet where TimesheetID=@TimesheetID)
	and CAST(Cast(MonthTaken as varchar(2))+'/1/'+Cast(YearTaken as varchar(4)) as datetime) < Cast(Cast(DatePart(month, @BeginDate) as varchar(2)) + '/1/' + Cast(DATEPART(year, @BeginDate) as varchar(4)) as datetime)
	and LeaveTypeID = h.LeaveTypeID
	order by YearTaken DESC, MonthTaken DESC
	) as PrevBalance
,ts.TimesheetTotal
,m.MonthTotal
,(select top 1 EndBalance - m.MonthTotal
	from vw_LeaveHistory
	where SID=(select SID from vw_Timesheet where TimesheetID=@TimesheetID)
	and CAST(Cast(MonthTaken as varchar(2))+'/1/'+Cast(YearTaken as varchar(4)) as datetime) < Cast(Cast(DatePart(month, @BeginDate) as varchar(2)) + '/1/' + Cast(DATEPART(year, @BeginDate) as varchar(4)) as datetime)
	and LeaveTypeID = h.LeaveTypeID
	order by YearTaken DESC, MonthTaken DESC
	) as EndBalance
,t.OrderNumber	
from vw_LeaveHistory h 
left outer join (
	select 
	e.HPLeaveTypeID
	,Sum(e.Duration) as MonthTotal
	from vw_TimesheetEntry e
	where e.SID=(select SID from vw_Timesheet where TimesheetID=@TimesheetID)
	and DATEPART(YEAR, @BeginDate) = Datepart(YEAR, e.EntryDate)
	and DATEPART(month, @BeginDate) = Datepart(month, e.EntryDate)
	and e.TimesheetStatusID <> 5
	group by e.HPLeaveTypeID, e.Title, e.OrderNumber
	) m on h.LeaveTypeID = m.HPLeaveTypeID
left outer join (
	select 
	e.HPLeaveTypeID
	,Sum(e.Duration) as TimesheetTotal
	from vw_TimesheetEntry e
	where e.TimesheetID=@TimesheetID
	group by e.HPLeaveTypeID, e.Title, e.OrderNumber
	) ts on h.LeaveTypeID = ts.HPLeaveTypeID	
join vw_EntryType t on h.LeaveTypeID = t.HPLeaveTypeID
where h.SID=(select SID from vw_Timesheet where TimesheetID=@TimesheetID)
and t.EntryTypeID not in(select EntryTypeID from @BalanceView)


insert @BalanceView
select 
t.EntryTypeID
,'(' + t.EntryTypeID + ') ' + t.Title as LeaveType
,null as Balance
,ts.TimesheetTotal
,m.MonthTotal
,null as EndBalance
,t.OrderNumber
from vw_EntryType t
join (
	select 
	e.EntryTypeID
	,Sum(e.Duration) as MonthTotal
	from vw_TimesheetEntry e
	where e.SID=(select SID from vw_Timesheet where TimesheetID=@TimesheetID)
	and DATEPART(YEAR, @BeginDate) = Datepart(YEAR, e.EntryDate)
	and DATEPART(month, @BeginDate) = Datepart(month, e.EntryDate)
	and e.TimesheetStatusID <> 5
	group by e.EntryTypeID, e.Title, e.OrderNumber
	) m on t.EntryTypeID= m.EntryTypeID
join (
	select 
	e.EntryTypeID
	,Sum(e.Duration) as TimesheetTotal
	from vw_TimesheetEntry e
	where e.TimesheetID=@TimesheetID
	group by e.EntryTypeID, e.Title, e.OrderNumber
	) ts on t.EntryTypeID = ts.EntryTypeID	
where 
isNULL(t.HPLeaveTypeID, '') not in('VAC','CSL','NSL','HSL','SSL')--,'P/H','CMP','PRL','NSL')
and t.EntryTypeID not in(select EntryTypeID from @BalanceView)




select 
*
,CASE
	WHEN PrevBalance-MonthTotal  < 0 and EntryTypeID in ('V','S','N','C','P','X','T','HL','SL') then 1
	ELSE 0
END as NegativeBalance
from @BalanceView 
order by OrderNumber



end

/*
select 
'(' + e.EntryTypeID + ') ' + e.Title as LeaveType
,Sum(e.Duration) as TimesheetTotal
,b.MonthTotal
,b.PrevBalance
,b.EndBalance
,e.OrderNumber
from vw_TimesheetEntry e
left outer join (
			select 
			e.EntryTypeID
			,Sum(e.Duration) as MonthTotal
			,'' as PrevBalance
			,b.EndBalance
			from vw_TimesheetEntry e
			left outer join vw_LeaveHistory b on e.HPLeaveTypeID= b.LeaveTypeID and b.SID=e.SID and DATEPART(month, @BeginDate) = b.MonthTaken and DATEPART(year, @BeginDate) = b.YearTaken
			where e.SID=(select SID from vw_Timesheet where TimesheetID=@TimesheetID)
			and DATEPART(YEAR, @BeginDate) = Datepart(YEAR, e.EntryDate)
			and DATEPART(month, @BeginDate) = Datepart(month, e.EntryDate)
			--and e.TimesheetStatusID <> 5
			group by e.EntryTypeID, e.Title, b.EndBalance, e.OrderNumber
			) b on e.EntryTypeID = b.EntryTypeID
where TimesheetID=@TimesheetID
group by e.EntryTypeID, e.Title, e.OrderNumber, b.MonthTotal, b.PrevBalance, b.EndBalance
order by e.OrderNumber

--select * from vw_LeaveHistory where SID='950240733' and YearTaken = 2009 and MonthTaken = 3
*/

