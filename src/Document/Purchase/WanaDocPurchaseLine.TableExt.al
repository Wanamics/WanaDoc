namespace Wanamics.WanaDoc.Document;

using Microsoft.Purchases.Document;

tableextension 87303 "WanaDoc Purchase Line" extends "Purchase Line"
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
