namespace Wanamics.WanaDoc.IncomingDocument;

using Microsoft.Purchases.Document;
Codeunit 87305 "wan Purch. Copy Blk.Ord. Lines"
{
    TableNo = "Purchase Line";
    trigger OnRun()
    var
        BlanketOrderLine: Record "Purchase Line";
        Header: Record "Purchase Header";
        Lines: Page "Purchase Lines";
    begin
        Header.Get(Rec."Document Type", Rec."Document No.");
        BlanketOrderLine.SetRange("Document Type", BlanketOrderLine."Document Type"::"Blanket Order");
        if Header."Quote No." <> '' then
            BlanketOrderLine.SetRange("Document No.", Header."Quote No.")
        else begin
            BlanketOrderLine.SetCurrentKey("Document Type", "Buy-from Vendor No.");
            BlanketOrderLine.SetRange("Buy-from Vendor No.", Header."Buy-from Vendor No.");
        end;
        // BlanketOrderLine.SetRange(Type, BlanketOrderLine.Type::Item);
        Lines.SetTableView(BlanketOrderLine);
        Lines.LookupMode(true);
        if Lines.RunModal() = Action::LookupOK then begin
            Lines.SetSelectionFilter(BlanketOrderLine);
            AddSelection(Header, Rec, BlanketOrderLine);
        end;
    end;

    local procedure AddSelection(pHeader: Record "Purchase Header"; pRec: Record "Purchase Line"; var pBlanketOrderLine: Record "Purchase Line")
    var
        Line: Record "Purchase Line";
        NewLine: Record "Purchase Line";
    begin
        InitNewLine(pRec, NewLine);
        pBlanketOrderLine.SetRange("Attached to Line No.", 0);
        if pBlanketOrderLine.FindSet then
            repeat
                pBlanketOrderLine.TestField("Currency Code", pHeader."Currency Code");
                NewLine."Line No." += 10000;
                Line := NewLine;
                Line.Validate(Type, pBlanketOrderLine.Type);
                Line.Validate("No.", pBlanketOrderLine."No.");
                Line.Validate("Description", pBlanketOrderLine.Description);
                if pBlanketOrderLine."Unit of Measure Code" <> Line."Unit of Measure Code" then
                    Line.Validate("Unit of Measure Code", pBlanketOrderLine."Unit of Measure Code");
                if (pBlanketOrderLine."Direct Unit Cost" <> 0) and (pBlanketOrderLine."Direct Unit Cost" <> Line."Direct Unit Cost") then begin
                    pBlanketOrderLine.TestField("Currency Code", pHeader."Currency Code");
                    Line.Validate("Direct Unit Cost", pBlanketOrderLine."Direct Unit Cost");
                end;
                if (pBlanketOrderLine."Line Discount %" <> 0) and (pBlanketOrderLine."Line Discount %" <> Line."Line Discount %") then
                    Line.Validate("Line Discount %", pBlanketOrderLine."Line Discount %");
                Line.Validate("Dimension Set ID", pBlanketOrderLine."Dimension Set ID");
                Line.Insert(true);
                CopyAttachedLines(NewLine, pBlanketOrderLine);
            until pBlanketOrderLine.Next = 0;
    end;

    local procedure InitNewLine(pLine: Record "Purchase Line"; var NewLine: Record "Purchase Line")
    begin
        NewLine.Copy(pLine);
        pLine.SetRange("Document Type", pLine."Document Type");
        pLine.SetRange("Document No.", pLine."Document No.");
        if pLine.FindLast then
            NewLine."Line No." := pLine."Line No."
        else
            NewLine."Line No." := 0;
        NewLine.Init;
    end;

    local procedure CopyAttachedLines(var pNewLine: Record "Purchase Line"; var pBlanketOrderLine: Record "Purchase Line")
    var
        BlanketOrderLine: Record "Purchase Line";
        Line: Record "Purchase Line";
        AttachedToLineNo: Integer;
    begin
        AttachedToLineNo := pNewLine."Line No.";
        BlanketOrderLine.SetRange("Document Type", pBlanketOrderLine."Document Type");
        BlanketOrderLine.SetRange("Document No.", pBlanketOrderLine."Document No.");
        BlanketOrderLine.SetRange("Attached to Line No.", pBlanketOrderLine."Line No.");
        if BlanketOrderLine.FindSet() then
            repeat
                pNewLine."Line No." += 10000;
                Line := pNewLine;
                Line."Attached to Line No." := AttachedToLineNo;
                Line.Validate("Description", pBlanketOrderLine.Description);
            until BlanketOrderLine.Next() = 0;
    end;
}
