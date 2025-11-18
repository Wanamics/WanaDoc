namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Sales.Document;
using System.Utilities;

codeunit 87310 "wan Sales Indent. Mgt."
{
    var
        IndentHelper: Codeunit "wan Indent Helper";

    procedure Shift(var pLine: Record "Sales Line"; pShift: Integer)
    var
        SubLine: Record "Sales Line";
        ShiftNotAllowedErr: Label 'shift not allowed';
    begin
        pLine.TestField("Attached to Line No.", 0);
        pLine.SetLoadFields("wan Indentation");
        pLine.Setrange("Attached to Line No.", 0);
        if pShift < 0 then
            pLine.SetAscending("Line No.", false);
        if pLine.FindSet then begin
            SubLine.SetLoadFields("wan Indentation");
            SubLine.SetRange("Document Type", pLine."Document Type");
            SubLine.SetRange("Document No.", pLine."Document No.");
            // if pShift < 0 then
            //     SubLine.SetAscending("Line No.", false);
            repeat
                if not ShiftAllowed(pLine, pShift) then
                    pLine.FieldError("wan Indentation", ShiftNotAllowedErr);
                if pLine.wanIsTitle() then begin
                    SubLine.SetFilter("Line No.", '>%1', pLine."Line No.");
                    if SubLine.FindSet() then
                        repeat
                            if SubLine."wan Indentation" <= pLine."wan Indentation" then
                                break;
                            SubLine."wan Indentation" += pShift;
                            SubLine.Modify();
                        until SubLine.Next() = 0;
                end;
                pLine."wan Indentation" += pShift;
                pLine.Modify();
                ShiftAttachedLines(pLine, pShift);
            until pLine.Next() = 0;
        end;
    end;

    local procedure ShiftAllowed(var pLine: Record "Sales Line"; pShift: Integer): Boolean
    var
        PrevLine: Record "Sales Line";
        NextLine: Record "Sales Line";
    begin
        if pShift > 0 then begin
            if not GetLine(pLine, '<', Prevline) then
                exit(false);
            if PrevLine.wanIsTitle() then
                exit(pLine."wan Indentation" >= PrevLine."wan Indentation")
            else
                exit(pLine."wan Indentation" < PrevLine."wan Indentation");
        end else begin
            if pLine."wan Indentation" <= 0 then
                exit(false);
            if not GetLine(pLine, '>', NextLine) then
                exit(true)
            else if pLine.wanIsTitle() then
                exit(NextLine."wan Indentation" <= pLine."wan Indentation")
            else
                exit(NextLine."wan Indentation" < pLine."wan Indentation");
        end;
    end;

    local procedure GetLine(pSourceLine: Record "Sales Line"; pWhere: Text; var pTargetLine: Record "Sales Line"): Boolean
    begin
        pTargetLine.SetLoadFields("wan Indentation");
        pTargetLine.SetRange("Document Type", pSourceLine."Document Type");
        pTargetLine.SetRange("Document No.", pSourceLine."Document No.");
        pTargetLine.SetRange("Attached to Line No.", 0);
        pTargetLine.SetFilter("Line No.", pWhere + '%1', pSourceLine."Line No.");
        if pWhere = '<' then
            exit(pTargetLine.FindLast())
        else
            exit(pTargetLine.FindFirst());
    end;

    local procedure ShiftAttachedLines(var pRec: Record "Sales Line"; pShift: Integer)
    var
        Line: Record "Sales Line";
    begin
        Line.SetLoadFields("wan Indentation");
        Line.SetRange("Document Type", pRec."Document Type");
        Line.SetRange("Document No.", pRec."Document No.");
        Line.SetRange("Attached to Line No.", pRec."Line No.");
        Line.ModifyAll("wan Indentation", pRec."wan Indentation");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsert(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        PrevLine: Record "Sales Line";
        Math: Codeunit Math;
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;
        if not GetLine(Rec, '<', PrevLine) then
            exit;
        if PrevLine.wanIsTotal() then
            Rec."wan Indentation" := Math.Max(PrevLine."wan Indentation" - 1, 0)
        else if PrevLine.wanIsTitle() then
            // if Rec.wanIsTitle() then
            //     Rec."wan Indentation" := PrevLine."wan Indentation"
            // else 
                Rec."wan Indentation" := PrevLine."wan Indentation" + 1
        else
            Rec."wan Indentation" := PrevLine."wan Indentation";
        Rec.Modify(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterDelete(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        Line: Record "Sales Line";
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;
        if not Rec.wanIsTitle() then
            exit;
        Line.SetLoadFields("wan Indentation");
        Line.SetRange("Document Type", Rec."Document Type");
        Line.SetRange("Document No.", Rec."Document No.");
        Line.SetFilter("Line No.", '>%1', Rec."Line No.");
        if Line.FindSet() then
            repeat
                if Line."wan Indentation" <= Rec."wan Indentation" then
                    break;
                Line."wan Indentation" -= 1;
                Line.Modify(false)
            until Line.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateNo, '', false, false)]
    local procedure OnBeforeValidateNo(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    var
        Hold: Code[20];
    begin
        if SalesLine."No." in [IndentHelper.TitleCode(), IndentHelper.TotalCode()] then begin
            Hold := SalesLine."No.";
            if SalesLine.Type <> SalesLine.Type::" " then begin
                SalesLine."No." := '';
                SalesLine.Validate(Type, SalesLine.Type::" ");
                SalesLine."No." := Hold;
            end;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeAttachedLineInsert, '', false, false)]
    local procedure OnBeforeAttachedLineInsert(var pAttachedLine: Record "Sales Line"; pLine: Record "Sales Line")
    begin
        pAttachedLine."wan Indentation" := pLine."wan Indentation";
    end;

    procedure InsertTotalLines(pRec: Record "Sales Header")
    var
        Line: Record "Sales Line";
    begin
        Line.SetLoadFields(Type, "No.", "wan Indentation");
        Line.SetRange("Document Type", pRec."Document Type");
        Line.SetRange("Document No.", pRec."No.");
        Line.SetRange(Type, Line.Type::" ");
        Line.SetRange("No.", IndentHelper.TitleCode());
        if Line.FindSet() then
            repeat
                InsertTotalLine(Line);
            until Line.Next() = 0;
    end;

    local procedure InsertTotalLine(pLine: Record "Sales Line")
    var
        Line: Record "Sales Line";
        xLine: Record "Sales Line";
        TotalLbl: Label 'Total : %1', Comment = '%1:Title description';
    begin
        Line.SetLoadFields(Type, "No.", "Attached to Line No.", "wan Indentation");
        Line.SetRange("Document Type", pLine."Document Type");
        Line.SetRange("Document No.", pLine."Document No.");
        Line.SetFilter("Line No.", '>%1', pLine."Line No.");
        Line.SetRange("wan Indentation", 0, pLine."wan Indentation" + 1);
        Line.SetRange("Attached to Line No.", 0);
        if Line.FindSet() then
            repeat
                if (Line."wan Indentation" <= pLine."wan Indentation") or Line.wanIsTotal() then
                    break;
                xLine := Line;
            until Line.Next() = 0;
        if (Line."wan Indentation" = pLine."wan Indentation" + 1) and Line.wanIsTotal() then
            exit;
        if GetLine(xLine, '>', Line) then
            Line."Line No." := (Line."Line No." + xLine."Line No.") div 2
        else
            Line."Line No." := xLine."Line No." + 10000;
        Line.Init();
        Line."No." := IndentHelper.TotalCode();
        Line."wan Indentation" := pLine."wan Indentation" + 1;
        Line.Description := CopyStr(StrSubstNo(TotalLbl, pLine.Description), 1, MaxStrLen(Line.Description));
        Line.Insert(false);
    end;
}
