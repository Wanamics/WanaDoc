namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Sales.Document;

tableextension 87310 "wan Sales Line Indent." extends "Sales Line"
{
    fields
    {
        field(87500; "wan Indentation"; Integer)
        {
            Caption = 'Indentation';
            DataClassification = SystemMetadata;
        }
    }

    procedure wanIsTitle(): Boolean
    var
        wanIndentHelper: Codeunit "wan Indent Helper";
    begin
        exit(wanIndentHelper.IsTitle(Type, "No."));
    end;

    procedure wanIsTotal(): Boolean
    var
        wanIndentHelper: Codeunit "wan Indent Helper";
    begin
        exit(wanIndentHelper.IsTotal(Type, "No."));
    end;

    procedure wanStyle(): Text
    var
        wanIndentHelper: Codeunit "wan Indent Helper";
        AttachedToLine: Record "Sales Line";
    begin
        if "Attached to Line No." = 0 then
            exit(wanIndentHelper.Style(Type, "No."))
        else
            if AttachedToLine.Get("Document Type", "Document No.", "Attached to Line No.") then
                exit(AttachedToLine.wanStyle());
    end;

    procedure wanIsEnabled(pEditable: Boolean): boolean
    var
        Header: Record "Sales Header";
    begin
        Header := GetSalesHeader();
        exit(pEditable and (Header.Status = Header.Status::Open));
    end;
}
