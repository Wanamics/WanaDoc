namespace Wanamics.WanaProj.BlkOrderLines;

using Microsoft.Sales.Document;
pageextension 87392 "wan Sales Order Lines BlkOrder" extends "Sales Order Subform"
{
    actions
    {
        addfirst(processing)
        {
            action(wanSelectBlanketOrderLines)
            {
                ApplicationArea = All;
                Caption = 'Select Blanket Order Lines';
                Ellipsis = true;
                Image = BlanketOrder;
                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"wan Sales BlkOrder Copy Lines", Rec);
                end;
            }
        }
    }
}
