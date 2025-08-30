namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Document;
using Microsoft.Foundation.ExtendedText;
tableextension 87337 "wan Sales Line" extends "Sales Line"
{
    trigger OnAfterInsert()
    var
        PrevLine: Record "Sales Line";
    begin
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

    local procedure AppendLineFeed(var pLine: Record "Sales Line")
    var
        LineFeed: Text[1];
    begin
        LineFeed[1] := 10;
        if pLine.Description = '' then begin
            pLine.Description += LineFeed;
            pLine.Modify(false);
        end else if pLine.Description[StrLen(pLine.Description)] <> LineFeed then begin
            pLine.Description += LineFeed;
            pLine.Modify(false);
        end;
    end;

    local procedure HasNextCommentLine(): Boolean
    var
        NextLine: Record "Sales Line";
    begin
        NextLine.SetRange("Document Type", "Document Type");
        NextLine.SetRange("Document No.", "Document No.");
        NextLine.SetRange("Attached to Line No.", "Attached to Line No.");
        NextLine.SetRange(Type, Type::" ");
        NextLine.SetRange("No.", '');
        NextLine.SetFilter("Line No.", '>%1', "Line No.");
        exit(not NextLine.IsEmpty());
    end;

    procedure wanMemoPad(pEditable: boolean) ReturnValue: Boolean
    var
        AttachedLine: Record "Sales Line";
        AttachedToLine: Record "Sales Line";
        MemoPadPage: Page "wan MemoPad";
        MemoPadManagement: Codeunit "wan MemoPad Management";
        MemoPadBuffer: Record "Extended Text Line" temporary;
        Memo: Text;
        lOldText: Text;
        tCaption: Label '%1 %2';
    begin
        if Rec."Attached to Line No." = 0 then
            AttachedToLine := Rec
        else
            AttachedToLine.Get(Rec."Document Type", Rec."Document No.", Rec."Attached to Line No.");
        MemoPadPage.SetCaption(StrSubstNo(tCaption, Rec."Document Type", Rec."Document No."));

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
            lOldText := Memo;
            Memo := MemoPadPage.GetText();
            if Memo = lOldText then
                exit(false)
            else
                ReturnValue := true;
            AttachedLine.DeleteAll();
            MemoPadManagement.MemoToBuffer(Memo, MaxStrLen(Rec.Description), MemoPadBuffer);
            AttachedLine."Document Type" := Rec."Document Type";
            AttachedLine."Document No." := Rec."Document No.";
            AttachedLine."Line No." := AttachedToLine."Line No.";
            if MemoPadBuffer.FindSet then begin
                repeat
                    AttachedLine.Init();
                    AttachedLine."Line No." += 10;
                    AttachedLine."Attached to Line No." := AttachedToLine."Line No.";
                    AttachedLine.Description := MemoPadBuffer.Text;
                    OnBeforeAttachedLineInsert(AttachedLine, Rec);
                    AttachedLine.Insert();
                until MemoPadBuffer.Next = 0;
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAttachedLineInsert(var pAttachedLine: Record "Sales Line"; pLine: Record "Sales Line")
    begin
    end;
}
