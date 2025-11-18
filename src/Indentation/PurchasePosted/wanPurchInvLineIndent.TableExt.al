namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Purchases.History;

tableextension 87320 "wan Purch. Inv. Line Indent" extends "Purch. Inv. Line"
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
        AttachedToLine: Record "Purch. Inv. Line";
    begin
        if "Attached to Line No." = 0 then
            exit("wan Indentation")
        else
            if AttachedToLine.Get("Document No.", "Attached to Line No.") then
                exit(AttachedToLine."wan Indentation");
    end;

    procedure wanStyle(): Text
    var
        wanIndentHelper: Codeunit "wan Indent Helper";
        AttachedToLine: Record "Purch. Inv. Line";
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
