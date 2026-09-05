namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Foundation.ExtendedText;
using Microsoft.Sales.Reminder;

pageextension 87306 "Reminder Attach Ending Line" extends "Reminder Attach Ending Line"
{
    layout
    {
        modify(Lines)
        {
            Visible = false;
        }
        addafter(Lines)
        {
            field(MemoPad; MemoPad)
            {
                ApplicationArea = All;
                MultiLine = true;
                ShowCaption = false;
                trigger OnValidate()
                // var
                //     ReminderText: Record "Reminder Text";
                begin
                    SetMemo(MemoPad);
                end;
            }
        }
    }
    var
        MemoPadManagement: Codeunit "wan MemoPad Management";
        MemoPad: Text;

    trigger OnAfterGetRecord()
    var
        ReminderText: Record "Reminder Text";
    begin
        MemoPad := GetMemo(ReminderText.Position::Ending);
    end;

    local procedure GetMemo(pPosition: Enum "Reminder Text Position") ReturnValue: Text;
    var
        ReminderAttachmentTextLine: Record "Reminder Attachment Text Line";
    begin
        // ReminderAttachmentTextLine.SetRange("Reminder Terms Code", Rec."Reminder Terms Code");
        // ReminderAttachmentTextLine.SetRange("Reminder Level", Rec."No.");
        ReminderAttachmentTextLine.SetRange(Position, pPosition);
        ReminderAttachmentTextLine.SetRange(Id, Rec.Id);
        ReminderAttachmentTextLine.SetRange("Language Code", Rec."Language Code");
        ReminderAttachmentTextLine.SetRange(Position, Rec.Position);
        if ReminderAttachmentTextLine.FindSet() then
            repeat
                ReturnValue += ReminderAttachmentTextLine.Text;
            until ReminderAttachmentTextLine.Next() = 0;
    end;

    local procedure SetMemo(pMemo: Text)
    var
        ReminderAttachmentTextLine: Record "Reminder Attachment Text Line";
        TempExtendedTextLine: Record "Extended Text Line" temporary;
    begin
        // ReminderAttachmentTextLine.SetRange("Reminder Terms Code", Rec."Reminder Terms Code");
        // ReminderAttachmentTextLine.SetRange("Reminder Level", Rec."No.");
        // ReminderAttachmentTextLine.SetRange(Position, pPosition);
        ReminderAttachmentTextLine.SetRange(Id, Rec.Id);
        ReminderAttachmentTextLine.SetRange("Language Code", Rec."Language Code");
        ReminderAttachmentTextLine.SetRange(Position, Rec.Position);
        ReminderAttachmentTextLine.DeleteAll();
        MemoPadManagement.MemoToBuffer(pMemo, MaxStrLen(ReminderAttachmentTextLine.Text), TempExtendedTextLine);
        // ReminderAttachmentTextLine."Reminder Terms Code" := Rec."Reminder Terms Code";
        // ReminderAttachmentTextLine."Reminder Level" := Rec."No.";
        ReminderAttachmentTextLine.Id := Rec.Id;
        ReminderAttachmentTextLine."Language Code" := Rec."Language Code";
        ReminderAttachmentTextLine.Position := Rec.Position;
        if TempExtendedTextLine.FindSet() then begin
            repeat
                ReminderAttachmentTextLine.Init();
                ReminderAttachmentTextLine."Line No." += 10000;
                ReminderAttachmentTextLine.Text := TempExtendedTextLine.Text;
                ReminderAttachmentTextLine.Insert();
            until TempExtendedTextLine.Next() = 0;
        end;
    end;
}
