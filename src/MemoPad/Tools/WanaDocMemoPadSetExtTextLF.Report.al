namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Foundation.ExtendedText;

report 87303 "WanaDoc MemoPad Set ExtText LF"
{
    Caption = 'WanaDoc MemoPad Set Extended Text LineFeed', Locked = true;
    UsageCategory = None;
    ApplicationArea = All;
    ProcessingOnly = true;
    dataset
    {

        dataitem(Line; "Extended Text Line")
        {
            DataItemTableView = sorting("Table Name", "No.", "Language Code", "Text No.", "Line No.");
            RequestFilterFields = "Table Name", "No.", "Language Code", "Text No.";

            trigger OnPreDataItem()
            begin
                if not Confirm('Do you want to append line feed to %1 "%2"?', false, Count, TableCaption) then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord()
            begin
                if ("Table Name" = xLine."Table Name") and ("No." = xLine."No.") and
                ("Language Code" = xLine."Language Code") and ("Text No." = xLine."Text No.") then
                    xLine.Modify(false);
                if Text = '' then
                    Text += LineFeed
                else
                    if Text[StrLen(Text)] <> LineFeed then
                        Text += LineFeed;
                xLine := Line;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
    }
    trigger OnInitReport()
    begin
        LineFeed[1] := 10;
    end;

    var
        LineFeed: Text[1];
        xLine: Record "Extended Text Line";
}
