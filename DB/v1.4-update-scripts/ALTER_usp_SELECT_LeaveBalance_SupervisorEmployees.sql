USE [TLR]
GO
/****** Object:  StoredProcedure [dbo].[usp_SELECT_LeaveBalance_SupervisorEmployees]    Script Date: 12/21/17 7:01:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[usp_SELECT_LeaveBalance_SupervisorEmployees]
(
	@SID char(9)
)

AS	
select 
j.SID
,e.DisplayName
,isNULL(VAC.Balance, 0.00) as VAC
,isNULL((select top 1 AccrueRate from vw_LeaveHistory h where SID=j.SID and isNULL(AccrueRate, 0.00) <> 0.00 and LeaveTypeID=VAC.LeaveTypeID order by YearTaken DESC, MonthTaken desc), 0.00) as VACAccrueRate
,isNULL(CSL.Balance, 0.00) as CSL
,isNULL((select top 1 AccrueRate from vw_LeaveHistory h where SID=j.SID and isNULL(AccrueRate, 0.00) <> 0.00 and LeaveTypeID=CSL.LeaveTypeID order by YearTaken DESC, MonthTaken desc), 0.00) as CSLAccrueRate
,isNULL(CMP.Balance, 0.00) as CMP
,isNULL(PH.Balance, 0.00) as PH
,isNULL(PRL.Balance, 0.00) as PRL
,isNULL(NSL.Balance, 0.00) as NSL
,isNULL(HSL.Balance, 0.00) as HSL
--,isNULL((select top 1 AccrueRate from vw_LeaveHistory h where SID=j.SID and isNULL(AccrueRate, 0.00) <> 0.00 and LeaveTypeID=HSL.LeaveTypeID order by YearTaken DESC, MonthTaken desc), 0.00) as HSLAccrueRate
,isNULL(SSL.Balance, 0.00) as SSL
--,dbo.uf_FormatDate(e.EmploymentStartDate, 'mm/dd') as AnniversaryDate
,e.EmploymentStartDate as AnniversaryDate
,CASE
	WHEN e.LeaveExpirMonth between 1 and 12 then e.LeaveExpirMonth
	ELSE DATEPART(month, e.EmploymentStartDate)
END as LeaveExpirMonth

from vw_Job j
left outer join vw_Employee e on j.SID = e.SID
join vw_Supervisor s on j.SuperID = s.SuperID
left outer join vw_LeaveBalance VAC on j.SID = VAC.SID and VAC.LeaveTypeID='VAC'
left outer join vw_LeaveBalance CSL on j.SID = CSL.SID and CSL.LeaveTypeID='CSL'
left outer join vw_LeaveBalance CMP on j.SID = CMP.SID and CMP.LeaveTypeID='CMP'
left outer join vw_LeaveBalance PH on j.SID = PH.SID and PH.LeaveTypeID='P/H'
left outer join vw_LeaveBalance PRL on j.SID = PRL.SID and PRL.LeaveTypeID='PRL'
left outer join vw_LeaveBalance NSL on j.SID = NSL.SID and NSL.LeaveTypeID='NSL'
left outer join vw_LeaveBalance HSL on j.SID = HSL.SID and HSL.LeaveTypeID = 'HSL'
left outer join vw_LeaveBalance SSL on j.SID = SSL.SID and SSL.LeaveTypeID = 'SSL'
where (s.SID = @SID
and j.JobLeaveIndicator='Y') or (j.SID = @SID and j.JobLeaveIndicator = 'Y') 
or (s.SID = @SID and j.EmployeeTypeID in ('H','S'))	--H and S employee types may not have a leave indicator of Y
order by e.DisplayName

