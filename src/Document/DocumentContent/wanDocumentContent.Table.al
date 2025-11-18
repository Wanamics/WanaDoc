namespace Wanamics.WanaDoc.Document;

using System.Globalization;
using System.Reflection;
table 87301 "wan Document Content"
{
    Caption = 'Document Content';
    LookupPageId = "wan Document Contents";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            NotBlank = true;
            BlankZero = true;
        }
        field(2; Placement; Enum "wan Document Content Placement")
        {
            Caption = 'Placement';
            NotBlank = true;
            BlankZero = true;
        }
        field(3; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
        field(4; "Content"; Blob)
        {
            Caption = 'Content';
        }
        field(10; "Report Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = const(Report), "Object ID" = field("Report ID")));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(PK; "Report ID", Placement, "Language Code")
        {
            Clustered = true;
        }
    }
    procedure Fetch(pReportId: Text; pPlaceHolder: Enum "wan Document Content Placement"; pLanguageCode: Code[10]) ReturnValue: Text
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
        OnAfterFetch(ReportID, pPlaceHolder, pLanguageCode, ReturnValue);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterFetch(pReportId: Integer; pPlaceHolder: Enum "wan Document Content Placement"; pLanguageCode: Code[10]; var ReturnValue: Text)
    begin
    end;
}
