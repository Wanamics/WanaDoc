namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Document;
pageextension 87308 "wan Sales Blanket Order MemoP." extends "Blanket Sales Order Subform"
{
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
                    Header: Record "Sales Header";
                begin
                    Header := Rec.GetSalesHeader();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}