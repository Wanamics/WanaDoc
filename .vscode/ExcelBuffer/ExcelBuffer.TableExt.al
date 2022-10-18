tableextension 87370 "wan Excel Buffer" extends "Excel Buffer"
{
    var
        gExcelBufferExtended: Record "wan Excel Buffer Extended";

    procedure SetExtendedText(var pText: Text);
    var
        lMaxStrLen: Integer;
    begin
        if StrLen(pText) > MaxStrLen("Cell Value as Text") then begin
            gExcelBufferExtended."Row No." := "Row No.";
            gExcelBufferExtended."Column No." := "Column No.";
            while StrLen(pText) <> 0 do begin
                lMaxStrLen := MaxStrLen(gExcelBufferExtended."Extended Text");
                gExcelBufferExtended."Extended Text" := CopyStr(pText, 1, lMaxStrLen);
                if StrLen(pText) > lMaxStrLen then
                    pText := CopyStr(pText, lMaxStrLen + 1)
                else
                    pText := '';
                gExcelBufferExtended."Extended Line No." += 10000;
                gExcelBufferExtended.Insert();
            end;
        end;
    end;

    Procedure GetExtendedText() ReturnValue: Text;
    begin
        gExcelBufferExtended.SetRange("Row No.", "Row No.");
        gExcelBufferExtended.SetRange("Column No.", "Column No.");
        if gExcelBufferExtended.FindSet() then
            repeat
                ReturnValue += gExcelBufferExtended."Extended Text";
            until gExcelBufferExtended.Next() = 0;
    end;
}