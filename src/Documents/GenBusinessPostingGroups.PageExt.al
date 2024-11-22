namespace Wanamics.WanaDoc.Document;

using Microsoft.Finance.GeneralLedger.Setup;
pageextension 87300 "wan Gen. Bus. Posting Groups" extends "Gen. Business Posting Groups"
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
