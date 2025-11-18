namespace WanamicsDoc.WanaDoc.Prepayment;

using Microsoft.Sales.Document;

pageextension 87302 "wan Sales Order Subf. Prepmt." extends "Sales Order Subform"
{
    layout
    {
        modify("Prepayment %")
        {
            Visible = wanPrepaymentVisible;
            BlankZero = true;
            Width = 5;
        }
        modify("Prepmt. Line Amount")
        {
            Visible = wanPrepaymentVisible;
            BlankZero = true;
        }
        modify("Prepmt. Amt. Inv.")
        {
            Visible = wanPrepaymentVisible;
            BlankZero = true;
        }
        addafter("Prepmt. Amt. Inv.")
        {
            field(wanPremptToPost; Rec."Prepmt. Line Amount" - Rec."Prepmt. Amt. Inv.")
            {
                Caption = 'Prepmt. Amount to Invoice';
                ApplicationArea = All;
                Visible = wanPrepaymentVisible;
                BlankZero = true;
            }
        }

    }
    trigger OnAfterGetRecord()
    begin
        wanPrepaymentVisible := not Rec.GetSalesHeader()."Compress Prepayment";
    end;

    var
        wanPrepaymentVisible: Boolean;
}
