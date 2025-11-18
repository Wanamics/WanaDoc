namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.History;
pageextension 87329 "wan Posted Sales C.M. MemoPad" extends "Posted Sales Cr. Memo Subform"
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