#if FALSE
namespace Wanamics.WanaDoc.IncomingDocument;

using Microsoft.Purchases.Document;

pageextension 87306 "wan Purch. Invoice Subf." extends "Purch. Invoice Subform"
{
    actions
    {
        addlast("F&unctions")
        {
            action(wanCopyBlanketOrderLines)
            {
                ApplicationArea = All;
                Caption = 'Copy Blanket Order Lines';
                Ellipsis = true;
                Image = BlanketOrder;
                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"wan Purch. Copy Blk.Ord. Lines", Rec);
                end;
            }
        }
    }
}
#endif
