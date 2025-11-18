namespace Wanamics.WanaProj.BlkOrderLines;

using Microsoft.Purchases.Document;
pageextension 87399 "wan Purch. Order BlkOrder" extends "Purchase Order"
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
