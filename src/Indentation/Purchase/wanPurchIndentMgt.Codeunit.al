namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;

codeunit 87315 "wan Purch. Indent. Mgt."
{
    var
        IndentHelper: Codeunit "wan Indent Helper";

    procedure Shift(var pLine: Record "Purchase Line"; pShift: Integer)
    var
        SubLine: Record "Purchase Line";
        ShiftNotAllowedErr: Label 'shift not allowed';
    begin
        pLine.SetLoadFields("wan Indentation");
        pLine.Setrange("Attached to Line No.", 0);
        if pShift < 0 then
            pLine.SetAscending("Line No.", false);
        if pLine.FindSet then begin
            SubLine.SetLoadFields("wan Indentation");
            SubLine.SetRange("Document Type", pLine."Document Type");
            SubLine.SetRange("Document No.", pLine."Document No.");
            // if pShift < 0 then
            //     Line.SetAscending("Line No.", false);
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

    local procedure ShiftAllowed(var pLine: Record "Purchase Line"; pShift: Integer): Boolean
    var
        PrevLine: Record "Purchase Line";
    begin
        if pShift > 0 then begin
            if not GetLine(pLine, '<', Prevline) then
                exit(false);
            if PrevLine.wanIsTitle() then
                exit(pLine."wan Indentation" >= PrevLine."wan Indentation")
            else
                exit(pLine."wan Indentation" > PrevLine."wan Indentation");
        end else
            if pLine."wan Indentation" <= 0 then
                exit(false);
        exit(true);
    end;

    local procedure GetLine(pSourceLine: Record "Purchase Line"; pWhere: Text; var pTargetLine: Record "Purchase Line"): Boolean
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

    local procedure ShiftAttachedLines(var pRec: Record "Purchase Line"; pShift: Integer)
    var
        Line: Record "Purchase Line";
    begin
        Line.SetLoadFields("wan Indentation");
        Line.SetRange("Document Type", pRec."Document Type");
        Line.SetRange("Document No.", pRec."Document No.");
        Line.SetRange("Attached to Line No.", pRec."Line No.");
        Line.ModifyAll("wan Indentation", pRec."wan Indentation");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsert(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    var
        PrevLine: Record "Purchase Line";
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;
        if not GetLine(Rec, '<', PrevLine) then
            exit;
        if PrevLine.wanIsTotal() then
            Rec."wan Indentation" := PrevLine."wan Indentation" - 1
        else if not PrevLine.wanIsTitle() then
            Rec."wan Indentation" := PrevLine."wan Indentation"
        else
            if Rec.wanIsTitle() then
                Rec."wan Indentation" := PrevLine."wan Indentation"
            else
                Rec."wan Indentation" := PrevLine."wan Indentation" + 1;
        Rec.Modify(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterDelete(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    var
        Line: Record "Purchase Line";
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

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateNo, '', false, false)]
    local procedure OnBeforeValidateNo(var PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
        if PurchaseLine."No." in [IndentHelper.TitleCode(), IndentHelper.TotalCode()] then begin
            if PurchaseLine.Type <> PurchaseLine.Type::" " then begin
                PurchaseLine."No." := '';
                PurchaseLine.Validate(Type, PurchaseLine.Type::" ");
                PurchaseLine."No." := IndentHelper.TitleCode();
            end;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeAttachedLineInsert, '', false, false)]
    local procedure OnBeforeAttachedLineInsert(var pAttachedLine: Record "Purchase Line"; pLine: Record "Purchase Line")
    begin
        pAttachedLine."wan Indentation" := pLine."wan Indentation";
    end;

    procedure InsertTotalLines(pRec: Record "Purchase Header")
    var
        Line: Record "Purchase Line";
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

    local procedure InsertTotalLine(pLine: Record "Purchase Line")
    var
        Line: Record "Purchase Line";
        xLine: Record "Purchase Line";
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
                if (Line."wan Indentation" <= pLine."wan Indentation") or IndentHelper.IsTotal(Line.Type, Line."No.") then
                    break;
                xLine := Line;
            until Line.Next() = 0;
        if (Line."wan Indentation" = pLine."wan Indentation" + 1) and IndentHelper.IsTotal(Line.Type, Line."No.") then
            exit;
        if GetLine(xLine, '>', Line) then
            Line."Line No." := (Line."Line No." + xLine."Line No.") div 2
        else
            Line."Line No." := xLine."Line No." + 10000;
        Line.Init();
        Line."No." := IndentHelper.TotalCode();
        Line."wan Indentation" := pLine."wan Indentation" + 1;
        Line.Description := CopyStr(StrSubstNo(TotalLbl, pLine.Description), 1, maxstrlen(Line.Description));
        Line.Insert(false);
    end;
}
