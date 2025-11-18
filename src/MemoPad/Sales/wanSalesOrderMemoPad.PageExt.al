namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Document;
pageextension 87346 "wan Sales Order MemoPad" extends "Sales Order Subform"
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
                Caption = 'MemoPad', Locked = true;
                ToolTip = 'Use MemoPad to View/Edit attached lines';
                Ellipsis = true;
                Image = Text;

                trigger OnAction()
                begin
                    if Rec.wanMemoPad(CurrPage.Editable() and (Rec.GetSalesHeader().Status = "Sales Document Status"::Open)) then
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
