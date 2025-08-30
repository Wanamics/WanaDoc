namespace Wanamics.WanaDoc.Document;

using Microsoft.Sales.Reminder;
using Microsoft.Foundation.Address;
reportextension 87317 "WanaDoc Reminder - Test" extends "Reminder - Test"
{
    WordLayout = './ReportLayouts/wanReminderTest.docx';
    dataset
    {
        add("Reminder Header")
        {

            column(wanCompanyAddress; CompanyAddress) { }
            column(wanCompanyContactInfo; CompanyContactInfo) { }
            column(wanCompanyLegalInfo; CompanyLegalInfo) { }
            column(wanToAddress; ToAddress) { }
        }
        modify("Reminder Header")
        {
            trigger OnAfterAfterGetRecord()
            var
                Addr: array[8] of Text;
            begin
                FormatAddress.Reminder(Addr, "Reminder Header");
                ToAddress := DocumentHelper.FullAddress(Addr);
            end;
        }
    }
    var
        FormatAddress: Codeunit "Format Address";
        ToAddress: Text;
        CompanyAddress: Text;
        CompanyContactInfo: Text;
        CompanyLegalInfo: Text;
        DocumentHelper: Codeunit "wan Document Helper";

    trigger OnPreReport()
    begin
        DocumentHelper.GetCompanyInfo(CompanyAddress, CompanyContactInfo, CompanyLegalInfo);
    end;
}