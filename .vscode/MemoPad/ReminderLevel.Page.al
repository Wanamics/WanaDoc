page 87421 "wan Reminder Level"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Reminder Level";

    layout
    {
        area(Content)
        {
            group(Beginning)
            {
                CaptionML = ENU = 'Beginning Text', FRA = 'Texte début';

                field(BeginningMemo; BeginningMemo)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;
                    trigger OnValidate()
                    var
                        ReminderText: Record "Reminder Text";
                    begin
                        SetMemo(ReminderText.Position::Beginning, BeginningMemo);
                    end;
                }
            }
            group(EndingText)
            {
                CaptionML = ENU = 'Ending Text', FRA = 'Texte fin';
                field(EndingMemo; EndingMemo)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;
                    trigger OnValidate()
                    var
                        ReminderText: Record "Reminder Text";
                    begin
                        SetMemo(ReminderText.Position::Ending, EndingMemo);
                    end;
                }
            }
        }
    }
    var
        BeginningMemo, EndingMemo : Text;
        MemoPadManagement: Codeunit "wan MemoPad Management";

    trigger OnAfterGetRecord()
    var
        ReminderText: Record "Reminder Text";
    begin
        BeginningMemo := GetMemo(ReminderText.Position::Beginning);
        EndingMemo := GetMemo(ReminderText.Position::Ending);
    end;

    local procedure GetMemo(pPosition: Integer) ReturnValue: Text;
    var
        ReminderText: Record "Reminder Text";
    begin
        ReminderText.SetRange("Reminder Terms Code", Rec."Reminder Terms Code");
        ReminderText.SetRange("Reminder Level", Rec."No.");
        ReminderText.SetRange(Position, pPosition);
        if ReminderText.FindSet() then
            repeat
                ReturnValue += ReminderText.Text;
            until ReminderText.Next() = 0;
    end;

    local procedure SetMemo(pPosition: Integer; pMemo: Text)
    var
        ReminderText: Record "Reminder Text";
        TempExtendedTextLine: Record "Extended Text Line" temporary;
    begin
        ReminderText.SetRange("Reminder Terms Code", Rec."Reminder Terms Code");
        ReminderText.SetRange("Reminder Level", Rec."No.");
        ReminderText.SetRange(Position, pPosition);
        ReminderText.DeleteAll();
        MemoPadManagement.MemoToBuffer(pMemo, MaxStrLen(ReminderText.Text), TempExtendedTextLine);
        ReminderText."Reminder Terms Code" := Rec."Reminder Terms Code";
        ReminderText."Reminder Level" := Rec."No.";
        ReminderText.Position := pPosition;
        if TempExtendedTextLine.FindSet then begin
            repeat
                ReminderText.Init();
                ReminderText."Line No." += 10000;
                ReminderText.Text := TempExtendedTextLine.Text;
                ReminderText.Insert();
            until TempExtendedTextLine.Next = 0;
        end;
    end;
}