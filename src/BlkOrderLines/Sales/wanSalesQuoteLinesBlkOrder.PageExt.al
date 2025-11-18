namespace Wanamics.WanaProj.BlkOrderLines;

using Microsoft.Sales.Document;
pageextension 87394 "wan Sales Quote Lines BlkOrder" extends "Sales Quote Subform"
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
