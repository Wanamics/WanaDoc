namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
pageextension 87328 "wan Posted Sales Inv. MemoPad" extends "Posted Sales Invoice Subform"
{
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
                    Rec.wanMemoPad();
                end;
            }
        }
    }
}