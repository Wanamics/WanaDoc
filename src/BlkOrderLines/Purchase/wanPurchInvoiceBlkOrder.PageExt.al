namespace Wanamics.WanaProj.BlkOrderLines;
using Microsoft.Purchases.Document;
pageextension 87397 "wan Purch. Invoice BlkOrder" extends "Purch. Invoice Subform"
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
