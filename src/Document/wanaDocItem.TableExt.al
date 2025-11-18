namespace WanaDoc.WanaDoc;

using Microsoft.Inventory.Item;

tableextension 87301 "WanaDoc Item" extends Item
{
    fields
    {
        modify("Net Weight")
        {
            Caption = 'Net Weight (kg)';
        }
        modify("Gross Weight")
        {
            Caption = 'Gross Weight (kg)';
        }
    }
}
