namespace Wanamics.WanaDoc.Prepayment;

using Microsoft.Purchases.History;
tableextension 87318 "wan Purch. Inv. Line" extends "Purch. Inv. Line"
{
    fields
    {
        field(87300; "wan Order Quantity"; Decimal)
        {
            Caption = 'Order Qty.';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'Specifies the order quantity of the item on the purchase order line.';
        }
        field(87301; "wan Order Amount"; Decimal)
        {
            Caption = 'Order Amount';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'Specifies the order amount of the item on the purchase order line.';
        }
        field(87309; "wan Prepayment %"; Decimal)
        {
            Caption = 'Prepayment %';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 2;
            BlankZero = true;
            Width = 5;
            ToolTip = 'Specifies the prepayment percentage of the item on the purchase order line.';
        }
        field(87310; "wan Prepmt. Line Amount"; Decimal)
        {
            Caption = 'Prepmt. Amount';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'Specifies the prepayment amount of the item on the purchase order line.';
        }
        field(87311; "wan Prepmt. Amt. Inv."; Decimal)
        {
            Caption = 'Prepmt. Amt. Inv.';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'Specifies the prepayment amount that has been invoiced for the item on the purchase order line.';
        }
        field(87312; "wan Prepmt. Amt. Incl. VAT"; Decimal)
        {
            Caption = 'Prepmt. Amt. Incl. VAT';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'Specifies the prepayment amount including VAT for the item on the purchase order line.';
        }
        field(87329; "wan Prepmt. Amount Inv. (LCY)"; Decimal)
        {
            Caption = 'Prepmt. Amount Inv. (LCY)';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'Specifies the prepayment amount that has been invoiced in local currency for the item on the purchase order line.';
        }
        field(87332; "wan Prepmt. VAT Amt. Inv.(LCY)"; Decimal)
        {
            Caption = 'Prepmt. VAT Amount Inv. (LCY)';
            DataClassification = ToBeClassified;
            BlankZero = true;
            ToolTip = 'Specifies the prepayment VAT amount that has been invoiced in local currency for the item on the purchase order line.';
        }
    }
}
