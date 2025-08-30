namespace Wanamics.WanaDoc.Document;

using Microsoft.Sales.History;
tableextension 87313 "wan Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(87300; "wan Order Quantity"; Decimal)
        {
            Caption = 'Order Qty.';
            DataClassification = ToBeClassified;
        }
        field(87301; "wan Order Amount"; Decimal)
        {
            Caption = 'Order Amount';
            DataClassification = ToBeClassified;
        }
        field(87309; "wan Prepayment %"; Decimal)
        {
            Caption = 'Prepayment %';
            DataClassification = ToBeClassified;
        }
        field(87310; "wan Prepmt. Line Amount"; Decimal)
        {
            Caption = 'Prepmt. Amount';
            DataClassification = ToBeClassified;
        }
        field(87311; "wan Prepmt. Amt. Inv."; Decimal)
        {
            Caption = 'Prepmt. Amt. Inv.';
            DataClassification = ToBeClassified;
        }
        field(87312; "wan Prepmt. Amt. Incl. VAT"; Decimal)
        {
            Caption = 'Prepmt. Amt. Incl. VAT';
            DataClassification = ToBeClassified;
        }
        field(87329; "wan Prepmt. Amount Inv. (LCY)"; Decimal)
        {
            Caption = 'Prepmt. Amount Inv. (LCY)';
            DataClassification = ToBeClassified;
        }
        field(87332; "wan Prepmt. VAT Amt. Inv.(LCY)"; Decimal)
        {
            Caption = 'Prepmt. VAT Amount Inv. (LCY)';
            DataClassification = ToBeClassified;
        }
    }
}
