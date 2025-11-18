namespace Wanamics.WanaDoc.Excel;
Table 87316 "wan Excel Buffer Extended"
{
    Caption = 'Excel Buffer Extended';
    TableType = Temporary;

    fields
    {
        field(1; "Row No."; Integer)
        {
            Caption = 'Row No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Column No."; Integer)
        {
            Caption = 'Column No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Extended Line No."; Integer)
        {
            Caption = 'Extended Line No.';
            DataClassification = ToBeClassified;
        }
        field(4; "Extended Text"; Text[250])
        {
            Caption = 'Cell Value as Text';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Row No.", "Column No.", "Extended Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    local procedure CutPosition(pText: Text; pMaxStrLen: Integer) ReturnValue: Integer
    var
        lPos: Integer;
    begin
        ReturnValue := pMaxStrLen;
        lPos := StrPos(pText, ' ');
        if lPos <> 0 then
            while (ReturnValue > 1) and (CopyStr(pText, ReturnValue, 1) <> ' ') do
                ReturnValue -= 1;
    end;

    procedure NextLine(var pExtendedText: Text; pMaxStrLen: Integer) ReturnValue: Text
    var
        lLength: Integer;
        lLineBreak: Text[1];
        lLineCutPos: Integer;
        lLineBreakPos: Integer;
        LF: Char;
    begin
        LF := 10;
        lLineBreak := Format(LF);
        lLineBreakPos := StrPos(pExtendedText, lLineBreak);
        if lLineBreakPos > 0 then
            if lLineBreakPos > pMaxStrLen then begin
                lLineCutPos := CutPosition(CopyStr(pExtendedText, 1, lLineBreakPos - 1), pMaxStrLen);
                ReturnValue := CopyStr(pExtendedText, 1, lLineCutPos);
                pExtendedText := CopyStr(pExtendedText, lLineCutPos + 1);
            end else begin
                ReturnValue := CopyStr(pExtendedText, 1, lLineBreakPos - 1);
                pExtendedText := CopyStr(pExtendedText, lLineBreakPos + 1);
            end
        else
            if StrLen(pExtendedText) > pMaxStrLen then begin
                lLineCutPos := CutPosition(pExtendedText, pMaxStrLen);
                ReturnValue := CopyStr(pExtendedText, 1, lLineCutPos);
                pExtendedText := CopyStr(pExtendedText, lLineCutPos + 1);
            end else begin
                ReturnValue := pExtendedText;
                pExtendedText := '';
            end;
    end;
}

