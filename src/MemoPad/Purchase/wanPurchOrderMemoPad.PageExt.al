namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Purchases.Document;
pageextension 87321 "wan Purch. Order MemoPad" extends "Purchase Order Subform"
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
                    Header: Record "Purchase Header";
                begin
                    Header := Rec.GetPurchHeader();
                    if Rec.wanMemoPad(CurrPage.Editable() and (Header.Status = Header.Status::Open)) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}
