pageextension 87301 "wan Purchase Order" extends "Purchase Order"
{
    layout
    {
        addafter("Quote No.")
        {
            field(YourReference; Rec."Your Reference")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
        }
    }
}
