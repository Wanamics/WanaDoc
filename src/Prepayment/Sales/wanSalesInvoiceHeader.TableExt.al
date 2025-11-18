namespace Wanamics.WanaDoc.Prepayment;

using Microsoft.Sales.History;
tableextension 87312 "wan Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(87332; "wan Compress Prepayment"; Boolean)
        {
            Caption = 'Compress Prepayment';
        }
    }
}
