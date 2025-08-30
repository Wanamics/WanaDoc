namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Purchases.Document;

report 87306 "WanaDoc Attach Purch. Lines"
{
    Caption = 'WanaDoc Attach Purchase Lines', Locked = true;
    UsageCategory = None;
    ApplicationArea = All;
    ProcessingOnly = true;
    dataset
    {
        dataitem(Line; "Purchase Line")
        {
            DataItemTableView = sorting("Document Type", "Document No.", "Line No.") where("Attached to Line No." = const(0));
            RequestFilterFields = "Document Type", "Document No.";

            trigger OnPreDataItem()
            begin
                if not Confirm('Do you want to set "%1" for %2 "%3"?', false, FieldCaption("Attached to Line No."), Count, TableCaption) then
                    CurrReport.Break();
                StartDateTime := CurrentDateTime();
            end;

            trigger OnAfterGetRecord()
            begin
                if ("Document Type" <> xLine."Document Type") or ("Document No." <> xLine."Document No.") or
                    ("No." <> '') or (Type <> Type::" ") then
                    xLine := Line
                else if Type = Type::" " then begin
                    "Attached to Line No." := xLine."Line No.";
                    Modify();
                end;
            end;

            trigger OnPostDataItem()
            begin
                Message('Processed in %1 seconds', CurrentDateTime() - StartDateTime);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
    }

    var
        xLine: Record "Purchase Line";
        StartDateTime: DateTime;
}
