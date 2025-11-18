namespace Wanamics.WanaDoc.Prepayment;

using Microsoft.Sales.History;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Comment;
using Microsoft.Purchases.Document;

pageextension 87306 "wan Posted Purch. Inv. Prepmt." extends "Posted Purch. Invoice Subform"
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
    var
        Header: Record "Purch. Inv. Header";
    begin
        Header.Get(Rec."Document No.");
        wanPrepaymentVisible := not Header."wan Compress Prepayment";
    end;

    var
        wanPrepaymentVisible: Boolean;
}
