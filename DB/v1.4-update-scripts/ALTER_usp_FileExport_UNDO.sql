USE [TLR]
GO
/****** Object:  StoredProcedure [dbo].[usp_FileExport_UNDO]    Script Date: 1/5/18 10:47:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[usp_FileExport_UNDO]
(
	@FileName varchar(50)
)
AS

/*
Performs an UNDO of the file generation.
All things that got affected in the database when the file was generated
will be restored to their original state.
*/

--declare @FileName varchar(50)
--set @FileName='L200961114127'

IF Left(@FileName, 1) = 'L'
	begin
		delete TimesheetAction
		where 
		TimesheetID in (select distinct TimesheetID from ExportLeaveData where ExportFileName=@FileName)
		and ActionTypeID=8

		update Timesheet set
		TimesheetStatusID=4
		where TimesheetID in (select distinct TimesheetID from ExportLeaveData where ExportFileName=@FileName)

		delete ExportLeaveData where ExportFileName=@FileName
	end

if Left(@FileName, 1) = 'P' or Left(@FileName, 2) = 'HL'
	begin
		declare @LeaveFileName varchar(50), @TimeFileName varchar(50)

		--set file name vars depending on type of file
		if Left(@FileName, 1) = 'P'
			begin
				set @TimeFileName = @FileName
				set @LeaveFileName = 'HL' + substring(@FileName, 2, len(@FileName))
			end
		else if Left(@FileName, 2) = 'HL'
			begin 
				set @TimeFileName = 'P' + substring(@FileName, 3, len(@FileName))
				set @LeaveFileName = @FileName
			end

		--now delete actions and reset timesheet status
		delete TimesheetAction
		where 
		TimesheetID in (select distinct TimesheetID from ExportTimeData where ExportFileName=@TimeFileName
						union select distinct TimesheetID from ExportLeaveData where ExportFileName=@LeaveFileName)
		and ActionTypeID=8

		update Timesheet set
		TimesheetStatusID=4
		where TimesheetID in (select distinct TimesheetID from ExportTimeData where ExportFileName=@TimeFileName
						union select distinct TimesheetID from ExportLeaveData where ExportFileName=@LeaveFileName)

		delete ExportTimeData where ExportFileName=@TimeFileName
		delete ExportLeaveData where ExportFileName=@LeaveFileName
	end
/*
--Add undo action for HL file prefix
IF Left(@FileName, 1) = 'HL'
	delete TimesheetAction
	where 
	TimesheetID in (select distinct TimesheetID from ExportLeaveData where ExportFileName=@FileName)
	and ActionTypeID=8

	update Timesheet set
	TimesheetStatusID=4
	where TimesheetID in (select distinct TimesheetID from ExportLeaveData where ExportFileName=@FileName)

	delete ExportLeaveData where ExportFileName=@FileName
*/