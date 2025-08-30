namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Purchases.Document;

tableextension 87315 "wan Purch. Line Indent." extends "Purchase Line"
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
        AttachedToLine: Record "Purchase Line";
    begin
        if "Attached to Line No." = 0 then
            exit(wanIndentHelper.Style(Type, "No."))
        else
            if AttachedToLine.Get("Document Type", "Document No.", "Attached to Line No.") then
                exit(AttachedToLine.wanStyle());
    end;

    procedure wanIsEnabled(pEditable: Boolean): boolean
    var
        Header: Record "Purchase Header";
    begin
        Header := GetPurchHeader();
        exit(pEditable and (Header.Status = Header.Status::Open));
    end;
}
