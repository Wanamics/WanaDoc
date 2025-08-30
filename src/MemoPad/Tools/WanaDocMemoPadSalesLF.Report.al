namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Archive;

report 87301 "WanaDoc MemoPad Sales LF"
{
    Caption = 'WanaDoc MemoPad Set Sales LineFeed', Locked = true;
    UsageCategory = None;
    ApplicationArea = All;
    ProcessingOnly = true;
    Permissions =
        tabledata "Sales Shipment Line" = m,
        tabledata "Sales Invoice Line" = m,
        tabledata "Sales Cr.Memo Line" = m,
        tabledata "Sales Line Archive" = m,
        tabledata "Return Receipt Line" = m;
    dataset
    {
        // TableNo	N°	TableName	FieldName
        // 37	80	Sales Line	Attached to Line No.
        // 39	80	Purchase Line	Attached to Line No.
        // 111	80	Sales Shipment Line	Attached to Line No.
        // 113	80	Sales Invoice Line	Attached to Line No.
        // 115	80	Sales Cr.Memo Line	Attached to Line No.
        // 121	80	Purch. Rcpt. Line	Attached to Line No.
        // 123	80	Purch. Inv. Line	Attached to Line No.
        // 125	80	Purch. Cr. Memo Line	Attached to Line No.
        // 296	3	Reminder Line	Attached to Line No.
        // 298	3	Issued Reminder Line	Attached to Line No.
        // 303	3	Finance Charge Memo Line	Attached to Line No.
        // 305	3	Issued Fin. Charge Memo Line	Attached to Line No.
        // 1003	904	Job Planning Line	Attached to Line No.
        // 5108	80	Sales Line Archive	Attached to Line No.
        // 5110	80	Purchase Line Archive	Attached to Line No.
        // 5137	904	Job Planning Line Archive	Attached to Line No.
        // 5530	31	Inventory Event Buffer	Attached to Line No.
        // 5531	31	Inventory Page Data	Attached to Line No.
        // 5902	80	Service Line	Attached to Line No.
        // 5971	80	Filed Contract Line	Attached to Line No.
        // 5991	80	Service Shipment Line	Attached to Line No.
        // 5993	80	Service Invoice Line	Attached to Line No.
        // 5995	80	Service Cr.Memo Line	Attached to Line No.
        // 6012	80	Service Line Archive	Attached to Line No.
        // 6651	80	Return Shipment Line	Attached to Line No.
        // 6661	80	Return Receipt Line	Attached to Line No.

        dataitem(Line; "Sales Line")
        {
            DataItemTableView = where("Attached to Line No." = filter(<> 0));
            RequestFilterFields = "Document Type", "Document No.";

            trigger OnPreDataItem()
            begin
                // if not Confirm('Do you want to append line feed to %1 "%2"?', false, Count, TableCaption) then
                //     CurrReport.Break();
                Window.Update(1, Count);
                Window.Update(2, TableCaption);
            end;

            trigger OnAfterGetRecord()
            begin
                if ("Document Type" = xLine."Document Type") and ("Document No." = xLine."Document No.") and ("Attached to Line No." = xLine."Attached to Line No.") then
                    xLine.Modify(false);
                if Description = '' then
                    Description += LineFeed
                else
                    if Description[StrLen(Description)] <> LineFeed then
                        Description += LineFeed;
                xLine := Line;
            end;
        }
        dataitem("Shipment Line"; "Sales Shipment Line")
        {
            DataItemTableView = where("Attached to Line No." = filter(<> 0));
            RequestFilterFields = "Document No.";

            trigger OnPreDataItem()
            begin
                // if not Confirm('Do you want to append line feed to %1 "%2"?', false, Count, TableCaption) then
                //     CurrReport.Break();
                Window.Update(1, Count);
                Window.Update(2, TableCaption);
            end;

            trigger OnAfterGetRecord()
            begin
                if ("Document No." = xShipmentLine."Document No.") and ("Attached to Line No." = xShipmentLine."Attached to Line No.") then
                    xShipmentLine.Modify(false);
                if Description = '' then
                    Description += LineFeed
                else
                    if Description[StrLen(Description)] <> LineFeed then
                        Description += LineFeed;
                xShipmentLine := "Shipment Line";
            end;
        }
        dataitem("Invoice Line"; "Sales Invoice Line")
        {
            DataItemTableView = where("Attached to Line No." = filter(<> 0));
            RequestFilterFields = "Document No.";

            trigger OnPreDataItem()
            begin
                // if not Confirm('Do you want to append line feed to %1 "%2"?', false, Count, TableCaption) then
                //     CurrReport.Break();
                Window.Update(1, Count);
                Window.Update(2, TableCaption);
            end;

            trigger OnAfterGetRecord()
            begin
                if ("Document No." = xInvoiceLine."Document No.") and ("Attached to Line No." = xInvoiceLine."Attached to Line No.") then
                    xInvoiceLine.Modify(false);
                if Description = '' then
                    Description += LineFeed
                else
                    if Description[StrLen(Description)] <> LineFeed then
                        Description += LineFeed;
                xInvoiceLine := "Invoice Line";
            end;
        }
        dataitem("Cr.Memo Line"; "Sales Cr.Memo Line")
        {
            DataItemTableView = where("Attached to Line No." = filter(<> 0));
            RequestFilterFields = "Document No.";

            trigger OnPreDataItem()
            begin
                // if not Confirm('Do you want to append line feed to %1 "%2"?', false, Count, TableCaption) then
                //     CurrReport.Break();
                Window.Update(1, Count);
                Window.Update(2, TableCaption);
            end;

            trigger OnAfterGetRecord()
            begin
                if ("Document No." = xCrMemoLine."Document No.") and ("Attached to Line No." = xCrMemoLine."Attached to Line No.") then
                    xCrMemoLine.Modify(false);
                if Description = '' then
                    Description += LineFeed
                else
                    if Description[StrLen(Description)] <> LineFeed then
                        Description += LineFeed;
                xCrMemoLine := "Cr.Memo Line";
            end;
        }
        dataitem("Return Line"; "Return Receipt Line")
        {
            DataItemTableView = where("Attached to Line No." = filter(<> 0));
            RequestFilterFields = "Document No.";

            trigger OnPreDataItem()
            begin
                // if not Confirm('Do you want to append line feed to %1 "%2"?', false, Count, TableCaption) then
                //     CurrReport.Break();
                Window.Update(1, Count);
                Window.Update(2, TableCaption);
            end;

            trigger OnAfterGetRecord()
            begin
                if ("Document No." = xReturnLine."Document No.") and ("Attached to Line No." = xReturnLine."Attached to Line No.") then
                    xReturnLine.Modify(false);
                if Description = '' then
                    Description += LineFeed
                else
                    if Description[StrLen(Description)] <> LineFeed then
                        Description += LineFeed;
                xReturnLine := "Return Line";
            end;
        }
        dataitem(LineArchive; "Sales Line Archive")
        {
            DataItemTableView = where("Attached to Line No." = filter(<> 0));
            RequestFilterFields = "Document Type", "Document No.";

            trigger OnPreDataItem()
            begin
                // if not Confirm('Do you want to append line feed to %1 "%2"?', false, Count, TableCaption) then
                //     CurrReport.Break();
                Window.Update(1, Count);
                Window.Update(2, TableCaption);
            end;

            trigger OnAfterGetRecord()
            begin
                if ("Document Type" = xLineArchive."Document Type") and ("Document No." = xLineArchive."Document No.")
                and ("Doc. No. Occurrence" = xLineArchive."Doc. No. Occurrence") and ("Version No." = xLineArchive."Version No.")
                and ("Attached to Line No." = xLineArchive."Attached to Line No.") then
                    xLineArchive.Modify(false);
                if Description = '' then
                    Description += LineFeed
                else
                    if Description[StrLen(Description)] <> LineFeed then
                        Description += LineFeed;
                xLineArchive := LineArchive;
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

    trigger OnPreReport()
    begin
        if not Confirm('Do you want to append linefeed to all attached lines in the selected documents?', false) then
            CurrReport.Quit();
        Window.Open('Appending line feed to #1###### #2############################ ...');
        StartDateTime := CurrentDateTime;
    end;

    trigger OnPostReport()
    begin
        Window.Close();
        Message('Done in %1', CurrentDateTime - StartDateTime);
    end;

    var
        LineFeed: Text[1];
        Window: Dialog;
        StartDateTime: DateTime;
        xLine: Record "Sales Line";
        xShipmentLine: Record "Sales Shipment Line";
        xInvoiceLine: Record "Sales Invoice Line";
        xCrMemoLine: Record "Sales Cr.Memo Line";
        xReturnLine: Record "Return Receipt Line";
        xLineArchive: Record "Sales Line Archive";
}
