namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Sales.History;

tableextension 87311 "wan Sales Invoice Line Indent" extends "Sales Invoice Line"
{
    fields
    {
        field(87350; "wan Indentation"; Integer)
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

    procedure wanIndentation(): Integer
    var
        AttachedToLine: Record "Sales Invoice Line";
    begin
        if "Attached to Line No." = 0 then
            exit(Rec."wan Indentation")
        else
            if AttachedToLine.Get("Document No.", "Attached to Line No.") then
                exit(AttachedToLine."wan Indentation");
    end;

    procedure wanStyle(): Text
    var
        wanIndentHelper: Codeunit "wan Indent Helper";
        AttachedToLine: Record "Sales Invoice Line";
    begin
        if "Attached to Line No." = 0 then
            exit(wanIndentHelper.Style(Type, "No."))
        else
            if AttachedToLine.Get("Document No.", "Attached to Line No.") then
                exit(AttachedToLine.wanStyle());
    end;
    // procedure wanIsEnabled(pEditable: Boolean): boolean
    // var
    //     Header: Record "Sales Header";
    // begin
    //     Header := GetSalesHeader();
    //     exit(pEditable and (Header.Status = Header.Status::Open));
    // end;
}
