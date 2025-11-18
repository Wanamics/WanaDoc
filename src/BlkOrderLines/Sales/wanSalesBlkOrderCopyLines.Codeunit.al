namespace Wanamics.WanaProj.BlkOrderLines;
using Microsoft.Sales.Document;
Codeunit 87391 "wan Sales BlkOrder Copy Lines"
{
    TableNo = "Sales Line";
    trigger OnRun()
    var
        BlanketOrderLine: Record "Sales Line";
        Header: Record "Sales Header";
        Lines: Page "Sales Lines";
    begin
        Header.Get(Rec."Document Type", Rec."Document No.");
        Header.TestField("Currency Code", Rec."Currency Code");
        BlanketOrderLine.SetRange("Document Type", BlanketOrderLine."Document Type"::"Blanket Order");
        if Header."wan Blanket Order No." = '' then
            BlanketOrderLine.SetRange("Sell-to Customer No.", Header."Sell-to Customer No.")
        else
            BlanketOrderLine.SetRange("Document No.", Header."wan Blanket Order No.");
        BlanketOrderLine.SetRange("Completely Shipped", false);
        Lines.SetTableView(BlanketOrderLine);
        Lines.LookupMode(true);
        if Lines.RunModal() = Action::LookupOK then begin
            Lines.SetSelectionFilter(BlanketOrderLine);
            AddSelection(Rec, BlanketOrderLine, Header."wan Blanket Order No." = '');
        end;
    end;

    local procedure AddSelection(pBelowLine: Record "Sales Line"; var pBlanketOrderLine: Record "Sales Line"; pCopyDim: Boolean)
    var
        Line: Record "Sales Line";
        NewLine: Record "Sales Line";
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
            if (pBlanketOrderLine."Unit Price" <> 0) and (pBlanketOrderLine."Unit Price" <> Line."Unit Price") then
                Line.Validate("Unit Price", pBlanketOrderLine."Unit Price");
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

    local procedure InitNewLine(var pBlanketOrderLine: Record "Sales Line"; pBelowLine: Record "Sales Line"; var pNewLine: Record "Sales Line"; var pStep: Integer)
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

    local procedure CountLines(pLine: Record "Sales Line") ReturnValue: Integer
    var
        AttachedLine: Record "Sales Line";
    begin
        if pLine.FindSet() then
            repeat
                AttachedLine.SetRange("Document Type", pLine."Document Type");
                AttachedLine.SetRange("Document No.", pLine."Document No.");
                AttachedLine.SetRange("Attached to Line No.", pLine."Line No.");
                ReturnValue += AttachedLine.Count + 1;
            until pLine.Next = 0;
    end;

    local procedure CopyAttachedLines(var pNewLine: Record "Sales Line"; pBlanketOrderLine: Record "Sales Line"; pStep: Integer)
    var
        BlanketOrderLine: Record "Sales Line";
        Line: Record "Sales Line";
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
