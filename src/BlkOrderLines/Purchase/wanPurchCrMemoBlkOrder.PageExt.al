namespace Wanamics.WanaProj.BlkOrderLines;
using Microsoft.Purchases.Document;
pageextension 87390 "wan Purch. Cr. Memo BlkOrder" extends "Purch. Cr. Memo Subform"
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
                Tooltip = 'Insert lines from a blanket order into the current document.';
                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"wan Purch. BlkOrder Copy Lines", Rec);
                end;
            }
        }
    }
}
