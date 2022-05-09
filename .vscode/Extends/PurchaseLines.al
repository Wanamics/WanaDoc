// Warning Multi-Objects
tableextension 87039 "wan Purchase Line" extends "Purchase Line"
{
    procedure wanMemoPad(pEditable: boolean) ReturnValue: Boolean
    var
        AttachedLine: Record "Purchase Line";
        AttachedToLine: Record "Purchase Line";
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
                    AttachedLine.Insert();
                until MemoPadBuffer.Next = 0;
            end;
        end;
    end;
}
pageextension 87054 "wan Purchase Order Subform" extends "Purchase Order Subform"
{
    actions
    {
        addlast(processing)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'MemoPad', FRA = 'MemoPad';
                Ellipsis = true;
                Image = Text;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec.wanMemoPad(true) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}
pageextension 87055 "wan Purch. Invoice Subform" extends "Purch. Invoice Subform"
{
    actions
    {
        addlast(processing)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'MemoPad', FRA = 'MemoPad';
                Ellipsis = true;
                Image = Text;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec.wanMemoPad(true) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}
pageextension 87097 "wan Purch. Quote Subform" extends "Purchase Quote Subform"
{
    actions
    {
        addlast(processing)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'MemoPad', FRA = 'MemoPad';
                Ellipsis = true;
                Image = Text;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec.wanMemoPad(true) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}
pageextension 87098 "wan Purch. Cr. Memo Subform" extends "Purch. Cr. Memo Subform"
{
    actions
    {
        addlast(processing)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'MemoPad', FRA = 'MemoPad';
                Ellipsis = true;
                Image = Text;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec.wanMemoPad(true) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}
pageextension 87510 "wan Blank. Purch. Order Sub." extends "Blanket Purchase Order Subform"
{
    actions
    {
        addlast(processing)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'MemoPad', FRA = 'MemoPad';
                Ellipsis = true;
                Image = Text;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec.wanMemoPad(true) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}