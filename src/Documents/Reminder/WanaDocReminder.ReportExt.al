namespace Wanamics.WanaDoc.Document;

using Microsoft.Sales.Reminder;
using Microsoft.Foundation.Address;
using System.Security.AccessControl;
using System.Text;
reportextension 87316 "WanaDoc Reminder" extends Reminder
{
    dataset
    {
        add("Issued Reminder Header")
        {
            column(wanCompanyAddress; CompanyAddress) { }
            column(wanCompanyContactInfo; CompanyContactInfo) { }
            column(wanCompanyLegalInfo; CompanyLegalInfo) { }
            column(wanToAddress; ToAddress) { }
        }
        modify("Issued Reminder Header")
        {
            trigger OnAfterAfterGetRecord()
            var
                Addr: array[8] of Text;
            begin
                FormatAddress.IssuedReminder(Addr, "Issued Reminder Header");
                ToAddress := DocumentHelper.FullAddress(Addr);
            end;
        }
        add("Issued Reminder Line")
        {
            column(wanOriginalAmtBWZ; DocumentHelper.BlankZero("Original Amount", "Auto Format"::AmountFormat, "Issued Reminder Header"."Currency Code")) { }
            column(wanRemainingAmtBWZ; DocumentHelper.BlankZero("Remaining Amount", "Auto Format"::AmountFormat, "Issued Reminder Header"."Currency Code")) { }
        }
        add(LetterText)
        {
            column(wanCreatedByName; wanCreatedByName("Issued Reminder Header".SystemCreatedBy)) { }
            column(wanUserName; wanUserName()) { }
        }
    }
    rendering
    {
        layout("WanaDocReminder")
        {
            Type = Word;
            LayoutFile = './ReportLayouts/wanReminder.docx';
            Caption = 'WanaDoc Reminder (Word)';
            Summary = 'The WanaDoc Reminder (Word) provides a detailed layout.';
        }
        layout("WanaDocReminderEmail")
        {
            Type = Word;
            LayoutFile = './ReportLayouts/wanReminderEmail.docx';
            Caption = 'WanaDoc Reminder e-mail (Word)';
            Summary = 'The WanaDoc Reminder e-mail (Word) provides a detailed layout.';
        }
    }
    trigger OnPreReport()
    begin
        DocumentHelper.GetCompanyInfo(CompanyAddress, CompanyContactInfo, CompanyLegalInfo);
    end;

    var
        FormatAddress: Codeunit "Format Address";
        ToAddress: Text;
        CompanyAddress: Text;
        CompanyContactInfo: Text;
        CompanyLegalInfo: Text;
        DocumentHelper: Codeunit "wan Document Helper";

    local procedure wanCreatedByName(pUserID: Guid): Text
    var
        User: Record User;
    begin
        if User.GetBySystemId(pUserID) then
            exit(User."Full Name");
    end;

    local procedure wanUserName(): Text
    var
        User: Record User;
    begin
        if User.Get(UserSecurityId) then
            exit(User."Full Name");
    end;
}