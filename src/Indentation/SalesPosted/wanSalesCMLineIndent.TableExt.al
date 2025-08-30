namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Sales.History;

tableextension 87314 "wan Sales C.M. Line Indent." extends "Sales Cr.Memo Line"
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
