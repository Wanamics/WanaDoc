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
                Caption = ' ', Locked = true;
                ToolTip = 'Use MemoPad to View/Edit attached lines';
                Ellipsis = true;
                Image = Text;

                trigger OnAction()
                var
                    Header: Record "Sales Header";
                begin
                    Header := Rec.GetSalesHeader();
                    if Rec.wanMemoPad(CurrPage.Editable() and (Header.Status = Header.Status::Open)) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}
