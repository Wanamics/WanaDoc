namespace Wanamics.WanaProj.BlkOrderLines;

using Microsoft.Purchases.Document;
Codeunit 87396 "wan Purch. BlkOrder Copy Lines"
{
    TableNo = "Purchase Line";
    trigger OnRun()
    var
        BlanketOrderLine: Record "Purchase Line";
        Header: Record "Purchase Header";
        Lines: Page "Purchase Lines";
    begin
        Header.Get(Rec."Document Type", Rec."Document No.");
        Header.TestField("Currency Code", Rec."Currency Code");
        BlanketOrderLine.SetRange("Document Type", BlanketOrderLine."Document Type"::"Blanket Order");
        if Header."wan Blanket Order No." = '' then
            BlanketOrderLine.SetRange("Buy-from Vendor No.", Header."Buy-from Vendor No.")
        else
            BlanketOrderLine.SetRange("Document No.", Header."wan Blanket Order No.");
        BlanketOrderLine.SetRange("Completely Received", false);
        Lines.SetTableView(BlanketOrderLine);
        Lines.LookupMode(true);
        if Lines.RunModal() = Action::LookupOK then begin
            Lines.SetSelectionFilter(BlanketOrderLine);
            AddSelection(Rec, BlanketOrderLine, Header."wan Blanket Order No." = '');
        end;
    end;

    local procedure AddSelection(pBelowLine: Record "Purchase Line"; var pBlanketOrderLine: Record "Purchase Line"; pCopyDim: Boolean)
    var
        Line: Record "Purchase Line";
        NewLine: Record "Purchase Line";
        Step: Integer;
    begin
        pBlanketOrderLine.SetRange("Attached to Line No.", 0);
        pBlanketOrderLine.FindSet();
        InitNewLine(pBlanketOrderLine, pBelowLine, NewLine, Step);
        repeat
            NewLine."Line No." += Step;
            Line := NewLine;
            Line.Validate(Type, pBlanketOrderLine.Type);
            Line.Validate("No.", pBlanketOrderLine."No.");
            Line.Validate("Description", pBlanketOrderLine.Description);
            if pBlanketOrderLine."Unit of Measure Code" <> Line."Unit of Measure Code" then
                Line.Validate("Unit of Measure Code", pBlanketOrderLine."Unit of Measure Code");
            if (pBlanketOrderLine."Direct Unit Cost" <> 0) and (pBlanketOrderLine."Direct Unit Cost" <> Line."Direct Unit Cost") then
                Line.Validate("Direct Unit Cost", pBlanketOrderLine."Direct Unit Cost");
            if (pBlanketOrderLine."Line Discount %" <> 0) and (pBlanketOrderLine."Line Discount %" <> Line."Line Discount %") then
                Line.Validate("Line Discount %", pBlanketOrderLine."Line Discount %");
            if pCopyDim then
                Line.Validate("Dimension Set ID", pBlanketOrderLine."Dimension Set ID");
            Line.Validate("Blanket Order No.", pBlanketOrderLine."Document No.");
            Line.Validate("Blanket Order Line No.", pBlanketOrderLine."Line No.");
            Line.Insert(true);
            CopyAttachedLines(NewLine, pBlanketOrderLine, Step);
        until pBlanketOrderLine.Next = 0;
    end;

    local procedure InitNewLine(var pBlanketOrderLine: Record "Purchase Line"; pBelowLine: Record "Purchase Line"; var pNewLine: Record "Purchase Line"; var pStep: Integer)
    var
        UnableToInsertErr: label 'There is no more space to insert %1 line(s) between lines %2 and  %3';
    begin
        pNewLine.Copy(pBelowLine);
        pNewLine.SetRange("Document Type", pBelowLine."Document Type");
        pNewLine.SetRange("Document No.", pBelowLine."Document No.");
        if pBelowLine."Line No." = 0 then begin
            if pNewLine.FindLast then;
            pStep := 10000;
        end else begin
            if pNewLine.Next(-1) = 0 then
                pNewLine."Line No." := 0;
            pStep := (pBelowLine."Line No." - pNewLine."Line No.") div (CountLines(pBlanketOrderLine) + 1);
            if pStep = 0 then
                Error(UnableToInsertErr, CountLines(pBlanketOrderLine), pNewLine."Line No.", pBelowLine."Line No.");
        end;
        pNewLine.Init;
    end;

    local procedure CountLines(pLine: Record "Purchase Line") ReturnValue: Integer
    var
        AttachedLine: Record "Purchase Line";
    begin
        if pLine.FindSet() then
            repeat
                AttachedLine.SetRange("Document Type", pLine."Document Type");
                AttachedLine.SetRange("Document No.", pLine."Document No.");
                AttachedLine.SetRange("Attached to Line No.", pLine."Line No.");
                ReturnValue += AttachedLine.Count + 1;
            until pLine.Next = 0;
    end;

    local procedure CopyAttachedLines(var pNewLine: Record "Purchase Line"; pBlanketOrderLine: Record "Purchase Line"; pStep: Integer)
    var
        BlanketOrderLine: Record "Purchase Line";
        Line: Record "Purchase Line";
        AttachedToLineNo: Integer;
    begin
        AttachedToLineNo := Line."Line No.";
        BlanketOrderLine.SetRange("Document Type", pBlanketOrderLine."Document Type");
        BlanketOrderLine.SetRange("Document No.", pBlanketOrderLine."Document No.");
        BlanketOrderLine.SetRange("Attached to Line No.", pBlanketOrderLine."Line No.");
        if BlanketOrderLine.FindSet() then
            repeat
                pNewLine."Line No." += pStep;
                Line := pNewLine;
                Line."Attached to Line No." := AttachedToLineNo;
                Line.Validate("Description", BlanketOrderLine.Description);
                Line.Insert(true);
            until BlanketOrderLine.Next() = 0;
    end;
}
