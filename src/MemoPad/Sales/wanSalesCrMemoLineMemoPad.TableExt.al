namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.History;
using Microsoft.Sales.Document;
tableextension 87339 "wan Sales Cr.Memo Line MemoPad" extends "Sales Cr.Memo Line"
{
    procedure wanMemoPad()
    var
        AttachedLine: Record "Sales Cr.Memo Line";
        AttachedToLine: Record "Sales Cr.Memo Line";
        MemoPadPage: Page "wan MemoPad";
        Memo: Text;
        CaptionLbl: Label '%1 %2';
        Document: Page "Sales Credit Memo";
    begin
        if Rec."Attached to Line No." = 0 then
            AttachedToLine := Rec
        else
            AttachedToLine.Get(Rec."Document No.", Rec."Attached to Line No.");
        MemoPadPage.SetCaption(StrSubstNo(CaptionLbl, Document, Rec."Document No."));

        AttachedLine.SetRange("Document No.", Rec."Document No.");
        AttachedLine.SetRange("Attached to Line No.", AttachedToLine."Line No.");
        if AttachedLine.FindSet() then begin
            Memo += AttachedLine.Description;
            while AttachedLine.Next() <> 0 do
                Memo += AttachedLine.Description;
        end;

        MemoPadPage.SetText(Memo);
        MemoPadPage.LookupMode := false;
        MemoPadPage.Editable := false;
        MemoPadPage.RunModal();
    end;
}
