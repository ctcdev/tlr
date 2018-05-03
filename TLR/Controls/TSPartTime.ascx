<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="TSPartTime.ascx.vb" Inherits="TLR.TS_PartTime" %>
<%@ Register Src="Feedback.ascx" TagName="Feedback" TagPrefix="ucl" %>
<%@ Register Src="TSActionLog.ascx" TagName="TSActionLog" TagPrefix="ucl" %>

<ucl:Feedback ID="uclFeedback" runat="server" />
    <script language="javascript" type="text/javascript">
        function ToggleMealVisibility()
        {
            if (document.getElementById('<%=ddlStartHour.ClientID %>') != null && 
                    document.getElementById('<%=chkbxEnterType.ClientID %>').checked == false) {
                var objStartHour = document.getElementById('<%=ddlStartHour.ClientID %>')
                var StartHour = objStartHour.options[objStartHour.selectedIndex].value;
                var objStartMinute = document.getElementById('<%=ddlStartMinute.ClientID %>')
                var StartMinute = objStartMinute.options[objStartMinute.selectedIndex].value;
                var objStartAMPM = document.getElementById('<%=ddlStartAMPM.ClientID %>')
                var StartAMPM = objStartAMPM.options[objStartAMPM.selectedIndex].value
                if ((StartAMPM == "AM") && (StartHour == 12)) {StartHour = 0;}
                var StartMinutes = (StartHour * 60) + (StartMinute*1);
                if ((StartAMPM == "PM") && (StartHour != 12)) {StartMinutes += 720;}
                
                var objEndHour = document.getElementById('<%=ddlEndHour.ClientID %>')
                var EndHour = objEndHour.options[objEndHour.selectedIndex].value;
                var objEndMinute = document.getElementById('<%=ddlEndMinute.ClientID %>')
                var EndMinute = objEndMinute.options[objEndMinute.selectedIndex].value;
                var objEndAMPM = document.getElementById('<%=ddlEndAMPM.ClientID %>')
                var EndAMPM = objEndAMPM.options[objEndAMPM.selectedIndex].value;
                if ((EndAMPM == "AM") && (EndHour == 12)) {EndHour = 24;}            
                var EndMinutes = (EndHour * 60) + (EndMinute*1);
                if ((EndAMPM == "PM") && (EndHour != 12)) {EndMinutes += 720;}

                if (EndMinutes - StartMinutes >= 300)
                {
                    document.getElementById('liMealBreak').className = '';
                }
                else {
                    document.getElementById('liMealBreak').className = 'meal_time_invisible';
                    var objMealMinutes = document.getElementById('<%=ddlMealTime.ClientID %>')
                    objMealMinutes.options.value = "0";
                }
            }
        }
        $(document).ready(function () {
            // Change dropdown hidden status based on checkbox
            $('#<%=chkbxEnterType.ClientID%>').change(function () {
                if (this.checked) {
                    // checkbox is checked
                    $('#<%=ddlEntryType.ClientID%>').removeClass('hide');
                    $('#liMealBreak').removeClass().addClass('meal_time_invisible');
                } else {
                    $('#<%=ddlEntryType.ClientID%>').addClass('hide');
                    ToggleMealVisibility();
                }
            });
        });
    </script>

<h1>Timesheet for <asp:Label ID="lblTSPeriod" runat="server" /> <br /> &nbsp;&nbsp;  <asp:label ID="lblDelegationInfo" runat="server" /></h1>

<!-- Timesheet header / job details -->
<!--*********************************************************************************************-->
<asp:Panel ID="pnlTSDetails" CssClass="box ts_details_time" runat="server">
    <h2><asp:Literal ID="litTSDetails" runat="server" Text="TS Details" /></h2>
    <ol>
    <li>
        <span class="field_name">Status:</span>
        <asp:Label ID="lblStatus" CssClass="field_value_status" runat="server" />
    </li>    
    <li>
        <span class="field_name">Name (SID):</span>
        <asp:Label CssClass="field_value" ID="lblName" runat="server" />
    </li>
    <li>
        <span class="field_name">Supervisor(s):</span>
        <asp:Label ID="lblSupervisor" CssClass="field_value" runat="server" />
    </li>
    <li>
        <span class="field_name">Job Title:</span>
        <asp:Label ID="lblJobTitle" CssClass="field_value" runat="server" />
    </li>  
    <li>
        <span class="field_name">Pay Rate:</span>
        <asp:Label ID="lblPayRate" CssClass="field_value" runat="server" />
    </li>
    <li>
        <span class="field_name">Budget(s):</span>
        <asp:Label ID="lblBudget" CssClass="field_value" runat="server" />
    </li>
    <li>
        <span class="field_name">Due Date:</span>
        <asp:Label ID="lblDueDate" CssClass="field_value" runat="server" />
    </li>      
    <li id="liUpdateTimesheet" runat="server" visible="false">
        <span class="field_name">&nbsp;</span>
        <a href="UpdateTimesheet.aspx?TimesheetID=<%=request.querystring("TimesheetID") %>">Update Timesheet Information</a>
    </li>    
    </ol>
</asp:Panel>
<!--*********************************************************************************************-->


<div class="box">

<!-- Add/Edit Entry -->
<!--*********************************************************************************************-->
<asp:Panel ID="pnlEntryDetails" CssClass="box add_entry_time" runat="server" Visible="false">
    <h2><asp:Literal ID="litHeader" runat="server" Text="Add Entry" /></h2>
    <fieldset title="Add/Edit time entry">
    <legend title="Add/Edit time entry">Add/Edit time entry</legend>
    <ol>
    <li>
        <label for="<%=ddlDate.ClientID%>">Date:</label>
        <span><asp:DropDownList CssClass="field" width="150" ID="ddlDate" runat="server" /></span>
    </li>
    <li>
        <label for="fsStartTime">Start Time:</label>
        <span>
        <fieldset title="Start time" id="fsStartTime">
            <label for="<%=ddlStartHour.ClientID%>" class="invisible_label">Start hour:</label>
            <asp:DropDownList CssClass="field" ID="ddlStartHour" runat="server" OnChange="ToggleMealVisibility()" />
            <label for="<%=ddlStartMinute.ClientID%>" class="invisible_label">Start minute:</label>
            <asp:DropDownList CssClass="field" ID="ddlStartMinute" runat="server" OnChange="ToggleMealVisibility()" />
            <label for="<%=ddlStartAMPM.ClientID%>" class="invisible_label">AM/PM</label>
            <asp:DropDownList CssClass="field" ID="ddlStartAMPM" runat="server" OnChange="ToggleMealVisibility()">
                <asp:ListItem Text="AM" Value="AM" />
                <asp:ListItem Text="PM" Value="PM" />
            </asp:DropDownList>
        </fieldset>
        </span>

    </li>
    <li>
        <label for="fsEndTime">End Time:</label>
        <span>
            <fieldset title="Start time" id="fsEndTime">
            <label for="<%=ddlEndHour.ClientID%>" class="invisible_label">End hour:</label>
            <asp:DropDownList CssClass="field" ID="ddlEndHour" runat="server" OnChange="ToggleMealVisibility()" />
            <label for="<%=ddlEndMinute.ClientID%>" class="invisible_label">End minute:</label>
            <asp:DropDownList CssClass="field" ID="ddlEndMinute" runat="server" OnChange="ToggleMealVisibility()" />
            <label for="<%=ddlEndAMPM.ClientID%>" class="invisible_label">AM/PM</label>
            <asp:DropDownList CssClass="field" ID="ddlEndAMPM" runat="server" OnChange="ToggleMealVisibility()">
                <asp:ListItem Text="AM" Value="AM" />
                <asp:ListItem Text="PM" Value="PM" />
            </asp:DropDownList>
            </fieldset>  
        </span>
    &nbsp;&nbsp;&nbsp;</li>
    <li id="liMealBreak" class="meal_time_invisible">
        <label for="<%=ddlMealTime.ClientID%>">Meal Time:</label>
        <span>
            <p class="meal_time_disclaimer">
                The Dept. of Labor & Industries rules state: Employees shall be allowed a meal period (break) of at least 30 minutes, no less than two hours, nor more than five hours from the beginning of the shift. Did you take a meal break?
            </p>
            <asp:DropDownList CssClass="field" ID="ddlMealTime" runat="server" />
        </span>
    </li>
    <li id="liEntryType" runat="server">
        <label><asp:Checkbox id="chkbxEnterType" value="true" runat="server" /> Add as leave</label>
        <!--<label for="<%=ddlEntryType.ClientID%>">Entry Type:</label>-->
        <%
            If chkbxEnterType.Checked Then
                ddlEntryType.CssClass = "field"
            Else
                ddlEntryType.CssClass = "field hide"
            End If
        %>
        <span><asp:DropDownList ID="ddlEntryType" runat="server" DataTextField="LeaveType" DataValueField="EntryTypeID" /></span>
    </li>
    <li>
        <span class="update">
            <asp:Button ID="btnAddEntry" title="Add Entry" CssClass="button" Text="Add Entry" runat="server" />
            <asp:Button ID="btnUpdateEntry" Title="Update Entry" CssClass="button" Text="Update" Visible="false" runat="server" />
            <asp:Button ID="btnDeleteEntry" Title="Delete Entry" CssClass="button" Text="Delete" Visible="false" runat="server" />
            <asp:Button ID="btnCancelUpdate" Title="Cancel" CssClass="button" Text="Cancel" Visible="false" runat="server" />
        </span>
    </li>
    </ol>
    </fieldset>
</asp:Panel>

<!-- Timesheet totals-->
<!--*********************************************************************************************-->
<asp:Panel CssClass="ts_totals" ID="pnlTimesheetTotals" runat="server">
<h2 class="hidden">Timesheet Totals</h2>   
  <asp:Repeater ID="rptTimesheetTotals" runat="server">
       <HeaderTemplate>
        <table class="tbl" title="Timesheet totals and leave balance">
            <tr>
                <th><abbr title="Leave type">Type</abbr></th>
                <th><abbr title="Available balance">Avail Bal</abbr></th>
                <th>Reported</th>
                <th><abbr title="Estimated ending balance">Est New Bal</abbr></th>
            </tr>
       </HeaderTemplate>
       <ItemTemplate>
            <tr>
                <td class="leave_type"><abbr title='<%#DataBinder.Eval(Container, "DataItem.LeaveType")%>'><%#DataBinder.Eval(Container, "DataItem.EntryTypeID")%></abbr></td>
                <td><%#DataBinder.Eval(Container, "DataItem.PrevBalance")%></td>
                <td><%#DataBinder.Eval(Container, "DataItem.TimesheetTotal")%></td>
                <td class='<%#IIf(DataBinder.Eval(Container, "DataItem.NegativeBalance") = 1, "negative_balance", "")%>'>
                <%#IIf(DataBinder.Eval(Container, "DataItem.NegativeBalance") = 1, "<abbr title='Timesheet entries result in negative leave balance'>" & DataBinder.Eval(Container, "DataItem.EndBalance") & "</abbr>", DataBinder.Eval(Container, "DataItem.EndBalance"))%>
                </td>
            </tr>
       </ItemTemplate>
       <FooterTemplate>
        </table>
       </FooterTemplate>
   </asp:Repeater> 
</asp:Panel>
<!--*********************************************************************************************-->

</div>

<div class="box hourly">

<asp:DropDownList CssClass="field" ID="ddlBudgetAllocationSplitTypePerEntry" runat="server" Visible="false">
    <asp:ListItem Text="Hours" Value="Hours" Selected="True" />
    <asp:ListItem Text="Percent" Value="Percent" />
</asp:DropDownList>
<asp:Repeater ID="rptWeeks" runat="server">
<ItemTemplate>
    <h3>Week of <%#Format(Container.DataItem("FirstDay"), "M")%> - <%#Format(Container.DataItem("LastDay"), "M")%></h3>
        <table class="tbl">
        <thead>
            <tr class="<%#IIf(Container.ItemIndex > 0, "next", "") %>">
                <th>Date</th>
                <th>Start Time</th>
                <th>End Time</th>
                <th>Meal Time</th>
                <th>Total Hours</th>
                <th><%#ViewState("ActionsColumnText")%></th>
            </tr>
        </thead>
    <asp:Repeater ID="rptDays" runat="server">
        <ItemTemplate>
                <tr>
                    <th scope="row" class="day_and_date<%#IIf(Not IsDBNull(Container.DataItem("EntryTypeID")), " leave", "")%><%#IIf(Container.DataItem("InPayPeriod")=0," inactive","") %><%#IIf(Container.DataItem("SpecialDay")=true," holiday","") %>">
                        <abbr class="day" title="<%#Format(Container.DataItem("OneDay"), "dddd")%>"><%#Format(Container.DataItem("OneDay"), "ddd")%></abbr>
                        <abbr class="date" title="<%#Format(Container.DataItem("OneDay"), "m")%>"><%#Format(Container.DataItem("OneDay"), "M/d")%></abbr>
                        <%#IIf(Container.DataItem("SpecialDay") = True, "<br />" + Container.DataItem("Description"), "")%>
                        <%#IIf(Not IsDBNull(Container.DataItem("EntryTypeID")), "<br />" + Container.DataItem("EntryType"), "")%>
                    </th>
                    <td class="start_time<%#IIf(Not IsDBNull(Container.DataItem("EntryTypeID")), " leave", "")%><%#IIf(Container.DataItem("InPayPeriod")=0," inactive","") %><%#IIf(Container.DataItem("SpecialDay")=true," holiday","") %>"><%#Container.DataItem("EntryStartTime")%>
                    </td>   
                    <td class="end_time<%#IIf(Not IsDBNull(Container.DataItem("EntryTypeID")), " leave", "")%><%#IIf(Container.DataItem("InPayPeriod")=0," inactive","") %><%#IIf(Container.DataItem("SpecialDay")=true," holiday","") %>"><%#Container.DataItem("EntryEndTime")%></td>
                    <td class="meal_time<%#IIf(Not IsDBNull(Container.DataItem("EntryTypeID")), " leave", "")%><%#IIf(Container.DataItem("InPayPeriod")=0," inactive","") %><%#IIf(Container.DataItem("SpecialDay")=true," holiday","") %>"><%#IIf(Container.DataItem("MealBreak") > 0, Container.DataItem("MealBreak") & " <aabr title='minutes'>mins</aabr>", "")%></td>
                    <td class="total_time<%#IIf(Not IsDBNull(Container.DataItem("EntryTypeID")), " leave", "")%><%#IIf(Container.DataItem("InPayPeriod")=0," inactive","") %><%#IIf(Container.DataItem("SpecialDay")=true," holiday","") %>">
                        <%#IIf(Container.DataItem("TotalMinutes") > 0, Math.Floor(Container.DataItem("TotalMinutes") / 60) & " <abbr title='hours'>hrs</abbr>", "")%> <%#IIf((Container.DataItem("TotalMinutes") Mod 60) > 0, Container.DataItem("TotalMinutes") Mod 60 & " <aabr title='minutes'>mins</aabr>", "")%>
                        <span runat="server" visible='<%#viewstate("dsBudgets") isnot nothing and Container.DataItem("TotalMinutes") > 0 and Container.DataItem("TotalMinutes") mod 60 <> 0%>'>(<%#Format(Container.DataItem("TotalMinutes") / 60, "#.##")%> <abbr title="hours">hrs</abbr>)</span>
                    </td>
                    <td class="<%#IIf(Not IsDBNull(Container.DataItem("EntryTypeID")), " leave", "")%><%#IIf(Container.DataItem("InPayPeriod")=0," inactive","") %><%#IIf(Container.DataItem("SpecialDay")=true," holiday","") %>">
                        <asp:Button ID="btnEdit" Text="Edit" CssClass="link" runat="server" Visible='<%#IIf(Container.DataItem("TotalMinutes") > 0 and ViewState("blnClickableGridMode") and TLR.clsGeneric.DeNull(Container.DataItem("SID")) = TLR.clsSession.userSID, true, false) %>' CommandArgument='<%#Container.DataItem("TimesheetEntryID")%>' OnClick="EditEntry" /> 
                        <span onclick="javascript:return confirm('Are you sure you want to delete this entry?')">
                            <asp:Button ID="btnDelete" Text="Delete" CssClass="link" runat="server" Visible='<%#IIf(Container.DataItem("TotalMinutes") > 0 and ViewState("blnClickableGridMode") and TLR.clsGeneric.DeNull(Container.DataItem("SID")) = TLR.clsSession.userSID, true, false) %>' CommandArgument='<%#Container.DataItem("TimesheetEntryID")%>' OnClick="DeleteEntry" />
                        </span>
                        
                        
                        <asp:Repeater ID="rptBudgetAllocationPerEntryDisplay" runat="server" DataSource='<%# iif(DataBinder.Eval(Container, "DataItem.Budgets") <> "", DataBinder.Eval(Container, "DataItem.Budgets").ToString.Split(";"), nothing) %>'>
                           <HeaderTemplate>
                            <table summary="Hours assigned to each budget" class="entry_budget_allocation">
                                <tr>
                                    <th>Budget #</th>
                                    <th>Hours</th>
                                </tr>
                           </HeaderTemplate>
                           <ItemTemplate>
                                <tr>
                                    <td><%#Left(Container.DataItem.ToString, InStr(Container.DataItem.ToString, "|") - 1)%></td>
                                    <td><%#Right(Container.DataItem.ToString, Container.DataItem.ToString.Length - InStr(Container.DataItem.ToString, "|"))%></td>
                                </tr>
                           </ItemTemplate>
                           <FooterTemplate>
                           </table>
                           </FooterTemplate>
                        </asp:Repeater> 
                        
                        <asp:Repeater ID="rptBudgetAllocationPerEntry" runat="server" DataSource='<%# ViewState("dsBudgets")%>' visible='<%# Container.DataItem("TotalMinutes") > 0%>'>
                           <HeaderTemplate>
                            <table summary="Assign hours to each budget" class="entry_budget_allocation">
                                <tr>
                                    <th>Budget #</th>
                                    <th>Hours</th>
                                </tr>
                           </HeaderTemplate>
                           <ItemTemplate>
                                <tr>
                                    <td>
                                      <asp:label ID="lblBudgetAllocationNumber" runat="server" CssClass="budgetNumber" Text='<%#DataBinder.Eval(Container, "DataItem.BudgetNumber")%>' AssociatedControlID="txtBudgetAllocationAmount" />
                                      
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtBudgetAllocationAmount" runat="server" MaxLength="6" width="60px" CssClass="budgetPercentEntry" />
                                        
                                      
                                                                              
                                        <asp:Label ID="lblTotalEntryMinutes" runat="server" Visible="false" Text='<%# DataBinder.Eval(Container, "Parent.Parent.DataItem.TotalMinutes")%>' />
                                        <asp:Label ID="lblEntryID" runat="server" Visible="false" Text='<%# DataBinder.Eval(Container, "Parent.Parent.DataItem.TimesheetEntryID")%>' />
                                        

                                    </td>
                                </tr>
                           </ItemTemplate>
                           <FooterTemplate>
                           </table>
                           </FooterTemplate>        
                        </asp:Repeater>
                        <asp:Label ID="lblTotalEntryMinutes" runat="server" Visible="false" Text='<%# DataBinder.Eval(Container, "DataItem.TotalMinutes")%>' />
                        <asp:Label ID="lblEntryDate" runat="server" Visible="false" Text='<%# DataBinder.Eval(Container, "DataItem.OneDay")%>' />
                    </td>
                </tr>
            </tbody>             
        </ItemTemplate>
    </asp:Repeater>
    <tfoot>
        <tr>
            <th class="total_hours" scope="row"><abbr title="Regular hours worked this week (up to 40 hours)">Regular Hrs:</abbr></td>
            <td class="total_hours"></td>
            <td class="total_hours"></td>
            <td class="total_hours"></td>
            <td class="total_hours value" headers="total_hours">
                <%#IIf((Container.DataItem("TotalMinutes") - Container.DataItem("TotalLeaveMinutes")) >= 2400, "40", Math.Floor((Container.DataItem("TotalMinutes") - Container.DataItem("TotalLeaveMinutes")) / 60))%> <abbr title="hours">hrs</abbr> <%#IIf((Container.DataItem("TotalMinutes") - Container.DataItem("TotalLeaveMinutes")) > 2400, "0", Math.Floor((Container.DataItem("TotalMinutes") - Container.DataItem("TotalLeaveMinutes")) Mod 60))%> <aabr title="minutes">mins</aabr>
            </td>
            <td class="total_hours"></td>
        </tr>
        <tr id="rowTotalLeaveHours" runat="server" visible="false">
            <th class="total_hours" scope="row"><abbr title="Leave hours reported this week">Leave Hrs:</abbr></th>
            <td class="total_hours"></td>
            <td class="total_hours"></td>
            <td class="total_hours"></td>
            <td class="total_hours value" headers="total_hours">
                <%#Math.Floor(Container.DataItem("TotalLeaveMinutes") / 60)%> <abbr title="hours">hrs</abbr> <%#Math.Floor(Container.DataItem("TotalLeaveMinutes") Mod 60)%> <aabr title="minutes">mins</aabr>
            </td>
            <td class="total_hours"></td>
        </tr>
        <tr>
            <th class="total_hours" scope="row"><abbr title="Total hours worked this week between all jobs">This week:</abbr></td>
            <td class="total_hours"></td>
            <td class="total_hours"></td>
            <td class="total_hours"></td>
            <td class="total_hours" headers="total_hours value">
                <%#Math.Floor(Container.DataItem("TotalWeekMinutes") / 60)%> <abbr title="hours">hrs</abbr> <%#Math.Floor(Container.DataItem("TotalWeekMinutes") Mod 60)%> <aabr title="minutes">mins</aabr>
            </td>
            <td class="total_hours"></td>
        </tr>            
        <tr>
            <th class="total_hours" scope="row"><abbr title="Total overtime hours">Overtime:</abbr></td>
            <td class="total_hours"></td>
            <td class="total_hours"></td>
            <td class="total_hours"></td>
            <td class="total_hours value" headers="overtime">
                <%#IIf((Container.DataItem("TotalWeekMinutes") - Container.DataItem("TotalLeaveMinutes")) > 2400, Math.Floor((Container.DataItem("TotalWeekMinutes") - Container.DataItem("TotalLeaveMinutes") - 2400) / 60), "0")%> <abbr title="hours">hrs</abbr>
                <%#IIf((Container.DataItem("TotalWeekMinutes") - Container.DataItem("TotalLeaveMinutes")) > 2400, Math.Floor((Container.DataItem("TotalWeekMinutes") - Container.DataItem("TotalLeaveMinutes") - 2400) Mod 60), "0")%> <aabr title="minutes">mins</aabr>
            </td>
            <td class="total_hours"></td>
        </tr>        
    </tfoot>                      
    </table>     
</ItemTemplate>   
<FooterTemplate>

</FooterTemplate>     
</asp:Repeater>
</div>
<div class="box, ts_time_grandtotal">
Grand Total: <asp:Label CssClass="totalhours" ID="lblGrandTotalHours" runat="server" /> 
    <asp:Label CssClass="totalhours" ID="lblLeaveTotalHours" runat="server" />
</div>
<!--Remarks-->
<!--*********************************************************************************************-->
<div class="remarks">
<h2 id="h2Remarks" runat="server">Remarks</h2>
<asp:Repeater ID="rptRemarks" runat="server">
<HeaderTemplate>
    <table>
    <tr>
        <th id="remarkText">Remark Text</th>
        <th>Author/Date</th>
        <th>Action</th>
    </tr>
</HeaderTemplate>
<FooterTemplate>
    </table>
</FooterTemplate>
<ItemTemplate>
    <tr>
        <td class="text"><%#TLR.clsGeneric.PrepareForDisplay(Container.DataItem("RemarkText"))%></td>
        <td class="author_date"><%#Container.DataItem("DisplayName")%><br /><%#Format(Container.DataItem("LastUpdatedDate"), "g")%></td>
        <td class="action">
            <asp:Button ID="btnEditRemark" Text="Edit" CssClass="link edit" runat="server" CommandArgument='<%#Container.DataItem("TimesheetRemarkID")%>' OnClick="EditRemark" Visible='<%#IIf(Container.DataItem("SID") = TLR.clsSession.UserSID and ViewState("blnEditableRemarkMode"), true, false) %>' />                    
            <span onclick="javascript:return confirm('Are you sure you want to delete this remark?')">
                <asp:Button ID="btnDeleteRemark" Text="Delete" CssClass="link" runat="server" CommandArgument='<%#Container.DataItem("TimesheetRemarkID")%>' OnClick="DeleteRemark" Visible='<%#IIf(Container.DataItem("SID") = TLR.clsSession.UserSID and ViewState("blnEditableRemarkMode"), true, false) %>' />
            </span>            
        </td>
    </tr>
</ItemTemplate>
</asp:Repeater>

<asp:Button ID="btnAddRemark" CssClass="button" Text="Add Remark" runat="server" Visible='false' />
    <asp:Panel ID="pnlEditRemark" class="remark_edit" runat="server" Visible="false">
    <label for="<%=ddlDate.ClientID%>">Remark Text:</label>
    &nbsp;<span><asp:TextBox ID="txtRemark" TextMode="MultiLine" class="remark_text" Width="400" Height="60" runat="server" /></span>
        <span class="update">
            <asp:Button ID="btnSaveRemark" CssClass="button" Text="Save Remark" runat="server" />
            <asp:Button ID="btnCancelRemarkUpdate" CssClass="button" Text="Cancel" runat="server"/>
     </span>
     </asp:Panel>
</div>
<!--*********************************************************************************************-->


<!-- Budget Allocation: -->
<!--*********************************************************************************************-->
<div class="budget_allocation">
<asp:Panel ID="pnlBudgetAllocation" runat="server" Visible="false">
    <h2>Budget Allocation (<asp:Label ID="lblBudgetAllocationTotalHours" runat="server" /> hours)</h2>
    <asp:Label ID="lblLeaveWarning" runat="server" Visible="false" CssClass="warning" />
    <fieldset id="fsSplitBudgets" runat="server" visible="false">
    <label for="<%=ddlBudgetAllocationSplitType.ClientID%>">Allocate budgets by:</label>    
    <asp:DropDownList CssClass="field" ID="ddlBudgetAllocationSplitType" runat="server">
        <asp:ListItem Text="Percent" Value="Percent" />
        <asp:ListItem Text="Hours" Value="Hours" />
    </asp:DropDownList>    
    
    </fieldset>

    <asp:Label ID="lblBudgetSplit" runat="server" Visible="false">Budget allocations:</asp:Label>

    <asp:Repeater ID="rptBudgetAllocationSelection" runat="server">
       <HeaderTemplate>
        <table class="tbl">
            <tr>
                <th>Budget #</th>
                <th>Earning Type</th>
                <th>Allocation</th>
            </tr>
       </HeaderTemplate>
       <ItemTemplate>
            <tr>
                <td><asp:label ID="lblBudgetAllocationNumber" runat="server" Text='<%#DataBinder.Eval(Container, "DataItem.BudgetNumber")%>' /></td>
                <td><%#DataBinder.Eval(Container, "DataItem.EarningType")%></td>
                <td><asp:TextBox CssClass="txtBudgetAllocationAmount" ID="txtBudgetAllocationAmount" Text='<%#DataBinder.Eval(Container, "DataItem.Hours") %>' CssClassWidth="60" runat="server" Enabled="false" /></td>
            </tr>
       </ItemTemplate>
       <FooterTemplate>
       </table>
       </FooterTemplate>        
    </asp:Repeater>
</asp:Panel>
</div>


<div class="ts_actions">
<!--Timesheet submission interface-->
<!--*********************************************************************************************-->
<asp:Panel ID="pnlSubmissionInterface" class="ts_action_panel" runat="server" Visible="false">

<span onclick="javascript:return confirm('Are you sure you want to submit this timesheet to your supervisor for approval?');">
<asp:Button ID="btnSubmitTimesheet" CssClass="button_important" Text="Submit Timesheet" runat="server" />
</span>
<span onclick="javascript:return confirm('Are you sure you want DELETE this timesheet?')">
<asp:Button ID="btnDeleteTimesheet" CssClass="button" Text="Delete Timesheet" runat="server" />
</span>
</asp:Panel>
<!--*********************************************************************************************-->

<!--Approval interface-->
<!--*********************************************************************************************-->
<asp:Panel ID="pnlApprovalInterface" class="ts_action_panel" runat="server" Visible="false">
<span runat="server" id="spanApprove"  onclick="javascript:return confirm('Are you sure you want to approve this timesheet?')">
<asp:Button ID="btnApproveTimesheet" CssClass="button_important" Text="Approve Timesheet" runat="server" />
</span>
<span onclick="javascript:return confirm('Are you sure you want REJECT this timesheet?')">
<asp:Button ID="btnRejectTimesheet" CssClass="button" Text="Reject" runat="server" />
</span>
<label for"<%=txtComment.ClientID%>">Comment:</label>
&nbsp;<asp:TextBox ID="txtComment" CssClass="comment" TextMode="MultiLine" runat="server" />
</asp:Panel>
<!--*********************************************************************************************-->
</div>

         
    <ucl:TSActionLog ID="uclTSActionLog" runat="server" Visible="true" />

