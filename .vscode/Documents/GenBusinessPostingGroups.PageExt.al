pageextension 87000 "wan Gen. Bus. Posting Groups" extends "Gen. Business Posting Groups"
{
    layout
    {
        addlast(Control1)
        {
            field(LatePaymentClause; Rec."wan Late Payment Text Code")
            {
                ApplicationArea = All;
            }
        }
    }
}
