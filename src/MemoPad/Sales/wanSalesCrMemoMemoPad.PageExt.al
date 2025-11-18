namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Document;
pageextension 87396 "wan Sales Cr.Memo MemoPad" extends "Sales Cr. Memo Subform"
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
                    if Rec.wanMemoPad(CurrPage.Editable() and (Rec.GetSalesHeader().Status = "Sales Document Status"::Open)) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}
