codeunit 87370 "wan ExcelBuffer Events"
{
    [EventSubscriber(ObjectType::Table, database::"Excel Buffer", 'OnWriteCellValueOnBeforeSetCellValue', '', false, false)]
    local procedure OnWriteCellValueOnBeforeSetCellValue(var ExcelBuffer: Record "Excel Buffer"; var CellTextValue: Text)
    begin
        ExcelBuffer.SetExtendedText(CellTextValue);
    end;
}
