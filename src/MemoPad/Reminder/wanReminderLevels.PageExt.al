namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Reminder;
pageextension 87332 "wan Reminder Levels" extends "Reminder Levels"
{
    actions
    {
        addafter(EndingText)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                Caption = 'Texts';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Text;
                Tooltip = 'Open the MemoPad for this Reminder Level.';

                trigger OnAction()
                begin
                    page.RunModal(page::"wan Reminder Level", Rec);
                end;
            }
        }
    }
}