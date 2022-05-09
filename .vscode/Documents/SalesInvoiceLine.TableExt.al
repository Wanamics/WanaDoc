tableextension 87113 "Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(87015; "wan Order Quantity"; Decimal)
        {
            CaptionML = ENU = 'Order Qty.', FRA = 'Qté. commande';
            DataClassification = ToBeClassified;
        }
        field(87029; "wan Order Amount"; Decimal)
        {
            CaptionML = ENU = 'Order Amount', FRA = 'Mnt. commande';
            DataClassification = ToBeClassified;
        }
        field(87109; "wan Prepayment %"; Decimal)
        {
            CaptionML = ENU = 'Prepayment %', FRA = '% acompte';
            DataClassification = ToBeClassified;
        }
        field(87110; "wan Prepmt. Line Amount"; Decimal)
        {
            CaptionML = ENU = 'Prepmt. Amount', FRA = 'Mnt. acompte';
            DataClassification = ToBeClassified;
        }
        field(87111; "wan Prepmt. Amt. Inv."; Decimal)
        {
            CaptionML = ENU = 'Prepmt. Amt. Inv.', FRA = 'Mnt. acompte fact.';
            DataClassification = ToBeClassified;
        }
        field(87112; "wan Prepmt. Amt. Incl. VAT"; Decimal)
        {
            CaptionML = ENU = 'Prepmt. Amt. Incl. VAT', FRA = 'Mnt. acompte TTC';
            DataClassification = ToBeClassified;
        }
        field(87129; "wan Prepmt. Amount Inv. (LCY)"; Decimal)
        {
            CaptionML = ENU = 'Prepmt. Amount Inv. (LCY)', FRA = 'Montant acompte antérieur (DS)';
            DataClassification = ToBeClassified;
        }
        field(87132; "wan Prepmt. VAT Amt. Inv.(LCY)"; Decimal)
        {
            CaptionML = ENU = 'Prepmt. VAT Amount Inv. (LCY)', FRA = 'Montant acompte antérieur TTC (DS)';
            DataClassification = ToBeClassified;
        }
    }
}
