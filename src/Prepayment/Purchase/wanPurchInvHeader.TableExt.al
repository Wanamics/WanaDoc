namespace Wanamics.WanaDoc.Prepayment;

using Microsoft.Purchases.History;
tableextension 87317 "wan Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(87332; "wan Compress Prepayment"; Boolean)
        {
            Caption = 'Compress Prepayment';
        }
    }
}
