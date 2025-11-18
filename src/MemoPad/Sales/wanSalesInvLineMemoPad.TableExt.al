namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.History;
using Microsoft.Sales.Document;
tableextension 87338 "wan Sales Inv. Line MemoPad" extends "Sales Invoice Line"
{
    procedure wanMemoPad()
    var
        AttachedLine: Record "Sales Invoice Line";
        AttachedToLine: Record "Sales Invoice Line";
        MemoPadPage: Page "wan MemoPad";
        Memo: Text;
        CaptionLbl: Label '%1 %2';
        Document: Page "Sales Invoice";
    begin
        if Rec."Attached to Line No." = 0 then
            AttachedToLine := Rec
        else
            AttachedToLine.Get(Rec."Document No.", Rec."Attached to Line No.");
        MemoPadPage.SetCaption(StrSubstNo(CaptionLbl, Document.Caption, Rec."Document No."));

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
