namespace Wanamics.WanaDoc.Prepayment;

using Microsoft.Purchases.History;
tableextension 87319 "wan Purch. Cr.Memo Line" extends "Purch. Cr. Memo Line"
{
    fields
    {
        field(87300; "wan Order Quantity"; Decimal)
        {
            Caption = 'Order Qty.';
            DataClassification = ToBeClassified;
            BlankZero = true;
        }
        field(87301; "wan Order Amount"; Decimal)
        {
            Caption = 'Order Amount';
            DataClassification = ToBeClassified;
            BlankZero = true;
        }
        field(87309; "wan Prepayment %"; Decimal)
        {
            Caption = 'Prepayment %';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 2;
            BlankZero = true;
            Width = 5;
        }
        field(87310; "wan Prepmt. Line Amount"; Decimal)
        {
            Caption = 'Prepmt. Amount';
            DataClassification = ToBeClassified;
            BlankZero = true;
        }
        field(87311; "wan Prepmt. Amt. Inv."; Decimal)
        {
            Caption = 'Prepmt. Amt. Inv.';
            DataClassification = ToBeClassified;
            BlankZero = true;
        }
        field(87312; "wan Prepmt. Amt. Incl. VAT"; Decimal)
        {
            Caption = 'Prepmt. Amt. Incl. VAT';
            DataClassification = ToBeClassified;
            BlankZero = true;
        }
        field(87329; "wan Prepmt. Amount Inv. (LCY)"; Decimal)
        {
            Caption = 'Prepmt. Amount Inv. (LCY)';
            DataClassification = ToBeClassified;
            BlankZero = true;
        }
        field(87332; "wan Prepmt. VAT Amt. Inv.(LCY)"; Decimal)
        {
            Caption = 'Prepmt. VAT Amount Inv. (LCY)';
            DataClassification = ToBeClassified;
            BlankZero = true;
        }
    }
}
