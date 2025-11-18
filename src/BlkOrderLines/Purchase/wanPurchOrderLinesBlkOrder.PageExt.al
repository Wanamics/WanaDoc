namespace Wanamics.WanaProj.BlkOrderLines;
using Microsoft.Purchases.Document;
pageextension 87398 "wan Purch. OrderLines BlkOrder" extends "Purchase Order Subform"
{
    actions
    {
        addfirst(processing)
        {
            action(wanInsertBlanketOrderLines)
            {
                ApplicationArea = All;
                Caption = 'Insert Blanket Order Lines';
                Ellipsis = true;
                Image = BlanketOrder;
                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"wan Purch. BlkOrder Copy Lines", Rec);
                end;
            }
        }
    }
}
