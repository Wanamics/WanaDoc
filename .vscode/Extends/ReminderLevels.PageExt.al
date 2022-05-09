pageextension 87432 "wan Reminder Levels" extends "Reminder Levels"
{
    actions
    {
        addafter(EndingText)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Texts', FRA = 'Textes';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Text;

                trigger OnAction()
                begin
                    page.RunModal(page::"wan Reminder Level", Rec);
                end;
            }
        }
    }
}