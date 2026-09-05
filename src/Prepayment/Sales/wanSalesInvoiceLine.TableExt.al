namespace Wanamics.WanaDoc.Prepayment;

using Microsoft.Sales.History;
tableextension 87313 "wan Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(87300; "wan Order Quantity"; Decimal)
        {
            Caption = 'Order Qty.';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'The quantity of the item ordered.';
        }
        field(87301; "wan Order Amount"; Decimal)
        {
            Caption = 'Order Amount';
            DataClassification = ToBeClassified;
            ToolTip = 'The amount of the item ordered.';
            BlankZero = true;
        }
        field(87309; "wan Prepayment %"; Decimal)
        {
            Caption = 'Prepayment %';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 2;
            BlankZero = true;
            Width = 5;
            ToolTip = 'The percentage of the prepayment.';
        }
        field(87310; "wan Prepmt. Line Amount"; Decimal)
        {
            Caption = 'Prepmt. Amount';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'The amount of the prepayment.';
        }
        field(87311; "wan Prepmt. Amt. Inv."; Decimal)
        {
            Caption = 'Prepmt. Amt. Inv.';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'The amount of the prepayment that has been invoiced.';
        }
        field(87312; "wan Prepmt. Amt. Incl. VAT"; Decimal)
        {
            Caption = 'Prepmt. Amt. Incl. VAT';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'The amount of the prepayment including VAT.';
        }
        field(87329; "wan Prepmt. Amount Inv. (LCY)"; Decimal)
        {
            Caption = 'Prepmt. Amount Inv. (LCY)';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'The amount of the prepayment that has been invoiced in local currency.';
        }
        field(87332; "wan Prepmt. VAT Amt. Inv.(LCY)"; Decimal)
        {
            Caption = 'Prepmt. VAT Amount Inv. (LCY)';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'The VAT amount of the prepayment that has been invoiced in local currency.';
        }
    }
}
