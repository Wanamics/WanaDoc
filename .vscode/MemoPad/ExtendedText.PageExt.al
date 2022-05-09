pageextension 87420 "Extended Text" extends "Extended Text"
{
    layout
    {
        modify(Control25)
        {
            Visible = false;
        }
        AddAfter(Control25)
        {
            grid(MemoPad)
            {
                field(Memo; Memo)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;
                    trigger OnValidate()
                    begin
                        SetMemo(Memo);
                    end;
                }
            }
        }
    }
    var
        Memo: Text;
        MemoPadManagement: Codeunit "wan MemoPad Management";

    trigger OnAfterGetRecord()
    begin
        Memo := GetMemo();
    end;

    local procedure GetMemo() ReturnValue: Text;
    var
        ETL: Record "Extended Text Line";
    begin
        ETL.SetRange("Table Name", Rec."Table Name");
        ETL.SetRange("No.", Rec."No.");
        ETL.SetRange("Language Code", Rec."Language Code");
        ETL.SetRange("Text No.", Rec."Text No.");
        if ETL.FindSet() then
            repeat
                ReturnValue += ETL.Text;
            until ETL.Next() = 0;
    end;

    local procedure SetMemo(pMemo: Text)
    var
        ETL: Record "Extended Text Line";
        TempExtendedTextLine: Record "Extended Text Line" temporary;
    begin
        ETL.SetRange("Table Name", Rec."Table Name");
        ETL.SetRange("No.", Rec."No.");
        ETL.SetRange("Language Code", Rec."Language Code");
        ETL.SetRange("Text No.", Rec."Text No.");
        ETL.DeleteAll();
        MemoPadManagement.MemoToBuffer(pMemo, MaxStrLen(Rec.Description), TempExtendedTextLine);
        ETL."Table Name" := Rec."Table Name";
        ETL."No." := Rec."No.";
        ETL."Language Code" := Rec."Language Code";
        ETL."Text No." := Rec."Text No.";
        if TempExtendedTextLine.FindSet then begin
            repeat
                ETL.Init();
                ETL."Line No." += 10000;
                ETL.Text := TempExtendedTextLine.Text;
                ETL.Insert();
            until TempExtendedTextLine.Next = 0;
        end;
    end;
}
