namespace Wanamics.WanaProj.BlkOrderLines;

using Microsoft.Sales.Document;
pageextension 87391 "wan Sales Order BlkOrder" extends "Sales Order"
{
    layout
    {
        addbefore("Status")
        {
            field("Blanket Order No."; Rec."wan Blanket Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Blanket Order No. field.';
            }
        }
    }
}
