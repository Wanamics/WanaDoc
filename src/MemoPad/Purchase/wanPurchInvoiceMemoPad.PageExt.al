namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Purchases.Document;
pageextension 87322 "wan Purch. Invoice MemoPad" extends "Purch. Invoice Subform"
{
    layout
    {
        modify(Description)
        {
            Editable = not wanIsAttached;
        }
    }
    actions
    {
        addlast(processing)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                Caption = ' ', Locked = true;
                ToolTip = 'Use MemoPad to View/Edit attached lines';
                Ellipsis = true;
                Image = Text;

                trigger OnAction()
                var
                    Header: Record "Purchase Header";
                begin
                    Header := Rec.GetPurchHeader();
                    if Rec.wanMemoPad(CurrPage.Editable() and (Header.Status = Header.Status::Open)) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
    var
        wanIsAttached: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        wanIsAttached := Rec."Attached to Line No." <> 0;
    end;
}
