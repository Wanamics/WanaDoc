#if FALSE
namespace Wanamics.WanaDoc.Document;

codeunit 87309 "wan Document Content"
{
    procedure GetContent(pReportId: Text; pPlaceHolder: Enum "wan Document Content Placement"; pLanguageCode: Code[10]) ReturnValue: Text
    var
        ReportID: Integer;
        DocumentContent: Record "wan Document Content";
        ContentInStream: InStream;
    begin
        Evaluate(ReportID, pReportId.Substring(8));
        DocumentContent.SetRange("Report ID", ReportID);
        DocumentContent.SetRange("Placement", pPlaceHolder);
        DocumentContent.SetFilter("Language Code", '%1|%2', pLanguageCode, '');
        if DocumentContent.FindLast() then begin
            DocumentContent.CalcFields("Content");
            DocumentContent."Content".CreateInStream(ContentInStream, TextEncoding::UTF8);
            ContentInStream.Read(ReturnValue);
        end;
        OnAfterGetContent(ReportID, pPlaceHolder, pLanguageCode, ReturnValue);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterGetContent(pReportId: Integer; pPlaceHolder: Enum "wan Document Content Placement"; pLanguageCode: Code[10]; var ReturnValue: Text)
    begin
    end;
}
#endif
