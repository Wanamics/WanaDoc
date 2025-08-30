namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Document;
pageextension 87346 "wan Sales Order MemoPad" extends "Sales Order Subform"
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
