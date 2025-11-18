namespace Wanamics.WanaDoc.Document;

using Microsoft.Sales.Document;

tableextension 87302 "WanaDoc Sales Line" extends "Sales Line"
{
    fields
    {
        modify("Net Weight")
        {
            Caption = 'Net Weight (kg/unit)';
        }
        modify("Gross Weight")
        {
            Caption = 'Gross Weight (kg/unit)';
        }
    }
}
