namespace Wanamics.WanaDoc.Prepayment;

using Microsoft.Sales.History;

pageextension 87303 "wan Posted Sales Inv. Prepmt." extends "Posted Sales Invoice Subform"
{
    layout
    {
        addbefore("Line Amount")
        {
            field("wan Order Amount"; Rec."wan Order Amount")
            {
                ApplicationArea = All;
                Visible = wanPrepaymentVisible;
                BlankZero = true;
            }
            field("wan Prepayment %"; Rec."wan Prepayment %")
            {
                ApplicationArea = All;
                Visible = wanPrepaymentVisible;
                BlankZero = true;
                Width = 5;
            }
            field(wanPremptLineAmount; Rec."wan Prepmt. Line Amount")
            {
                ApplicationArea = All;
                Visible = wanPrepaymentVisible;
                BlankZero = true;
                Width = 5;
            }
            field("wan Prepmt. Amt. Inv."; Rec."wan Prepmt. Amt. Inv.")
            {
                ApplicationArea = All;
                Visible = wanPrepaymentVisible;
                BlankZero = true;
            }
            field(wanPremptToPost; Rec."wan Prepmt. Line Amount" - Rec."wan Prepmt. Amt. Inv.")
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
        wanPrepaymentVisible := not Rec.GetInvoiceHeader()."wan Compress Prepayment";
    end;

    var
        wanPrepaymentVisible: Boolean;
}
