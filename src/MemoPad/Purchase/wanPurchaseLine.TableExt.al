namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Foundation.ExtendedText;
using Microsoft.Purchases.Document;
tableextension 87329 "wan Purchase Line" extends "Purchase Line"
{
#if FALSE
    // Conflict with E-Doc Import (codeunit 6140) where "Type" set after insert
    trigger OnAfterInsert()
    var
        PrevLine: Record "Purchase Line";
    begin
        if Rec.IsTemporary then
            exit;
        if (Type = Type::" ") and ("No." = '') and ("Attached to Line No." = 0) then begin
            PrevLine.SetRange("Document Type", "Document Type");
            PrevLine.SetRange("Document No.", "Document No.");
            PrevLine.SetRange("Line No.", 0, "Line No." - 1);
            if PrevLine.FindLast() then begin
                if PrevLine."Attached to Line No." <> 0 then
                    "Attached to Line No." := PrevLine."Attached to Line No."
                else
                    "Attached to Line No." := PrevLine."Line No.";
                if (PrevLine.Type = Type::" ") and (PrevLine."No." = '') then
                    AppendLineFeed(PrevLine);
                if HasNextCommentLine() then
                    AppendLineFeed(Rec);
                Modify(false);
            end;
        end;
    end;

    local procedure AppendLineFeed(var pLine: Record "Purchase Line")
    var
        LineFeed: Text[1];
    begin
        LineFeed[1] := 10;
        if pLine.Description = '' then begin
            pLine.Description += LineFeed;
            pLine.Modify(false);
        end else
            if pLine.Description[StrLen(pLine.Description)] <> LineFeed then begin
                pLine.Description += LineFeed;
                pLine.Modify(false);
            end;
    end;

    local procedure HasNextCommentLine(): Boolean
    var
        NextLine: Record "Purchase Line";
    begin
        NextLine.SetRange("Document Type", "Document Type");
        NextLine.SetRange("Document No.", "Document No.");
        NextLine.SetRange("Attached to Line No.", "Attached to Line No.");
        NextLine.SetRange(Type, Type::" ");
        NextLine.SetRange("No.", '');
        NextLine.SetFilter("Line No.", '>%1', "Line No.");
        exit(not NextLine.IsEmpty());
    end;
#endif

    procedure wanMemoPad(pEditable: boolean) ReturnValue: Boolean
    var
        AttachedLine: Record "Purchase Line";
        AttachedToLine: Record "Purchase Line";
        TempMemoPadBuffer: Record "Extended Text Line" temporary;
        MemoPadManagement: Codeunit "wan MemoPad Management";
        MemoPadPage: Page "wan MemoPad";
        Memo: Text;
        OldText: Text;
        CaptionLbl: Label '%1 %2', Comment = '%1 = Document Type, %2 = Document No.';
    begin
        if Rec."Attached to Line No." = 0 then
            AttachedToLine := Rec
        else
            AttachedToLine.Get(Rec."Document Type", Rec."Document No.", Rec."Attached to Line No.");
        MemoPadPage.SetCaption(StrSubstNo(CaptionLbl, Rec."Document Type", Rec."Document No."));

        AttachedLine.SetRange("Document Type", Rec."Document Type");
        AttachedLine.SetRange("Document No.", Rec."Document No.");
        AttachedLine.SetRange("Attached to Line No.", AttachedToLine."Line No.");
        if AttachedLine.FindSet() then begin
            Memo += AttachedLine.Description;
            while AttachedLine.Next() <> 0 do
                Memo += AttachedLine.Description;
        end;

        MemoPadPage.SetText(Memo);
        MemoPadPage.LookupMode := true;
        MemoPadPage.Editable := pEditable;
        if (MemoPadPage.RunModal() = Action::LookupOK) and pEditable then begin
            OldText := Memo;
            Memo := MemoPadPage.GetText();
            if Memo = OldText then
                exit(false)
            else
                ReturnValue := true;
            AttachedLine.DeleteAll();
            MemoPadManagement.MemoToBuffer(Memo, MaxStrLen(Rec.Description), TempMemoPadBuffer);
            AttachedLine."Document Type" := Rec."Document Type";
            AttachedLine."Document No." := Rec."Document No.";
            AttachedLine."Line No." := AttachedToLine."Line No.";
            if TempMemoPadBuffer.FindSet() then begin
                repeat
                    AttachedLine.Init();
                    AttachedLine."Line No." += 10;
                    AttachedLine."Attached to Line No." := AttachedToLine."Line No.";
                    AttachedLine.Description := TempMemoPadBuffer.Text;
                    // AttachedLine."wan Indentation" := Rec."wan Indentation";
                    OnBeforeAttachedLineInsert(AttachedLine, Rec);
                    AttachedLine.Insert();
                until TempMemoPadBuffer.Next() = 0;
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAttachedLineInsert(var pAttachedLine: Record "Purchase Line"; pLine: Record "Purchase Line")
    begin
    end;
}
