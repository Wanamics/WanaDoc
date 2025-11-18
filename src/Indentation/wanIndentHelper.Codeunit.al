namespace Wanamics.WanaDoc.Indentation;
using Microsoft.Sales.Document;

codeunit 87305 "wan Indent Helper"
{
    var
        Setup: Record "wan Indentation Setup";

    local procedure GetSetup()
    begin
        if Setup.Code <> '' then
            exit;
        Setup.Code := '_';
        if not Setup.ReadPermission then
            exit;
        if Setup.Get() then;
    end;

    procedure TitleCode(): Code[20]
    begin
        GetSetup();
        exit(Setup."Title Code");
    end;

    procedure TotalCode(): Code[20]
    begin
        GetSetup();
        exit(Setup."Total Code");
    end;

    procedure IsTitle(pType: enum "Sales Line Type"; pCode: Code[20]): Boolean
    begin
        if pType <> pType::" " then
            exit;
        GetSetup();
        exit(pCode = Setup."Title Code");
    end;

    procedure IsTotal(pType: enum "Sales Line Type"; pCode: Code[20]): Boolean
    begin
        if pType <> pType::" " then
            exit;
        GetSetup();
        exit(pCode = Setup."Total Code");
    end;

    procedure Style(pType: enum "Sales Line Type"; pCode: Code[20]): Text
    begin
        if pType <> pType::" " then
            exit;
        GetSetup();
        case pCode of
            Setup."Title Code":
                exit(format(Setup."Title Style"));
            Setup."Total Code":
                exit(format(Setup."Total Style"));
        end;
    end;

    procedure Indent(var pMemo: Text; pIndentation: Integer)
    var
        Lines: list of [Text];
        Margin: Text;
        i: Integer;
        NonBreakingSpace: Text;
        LineFeed: Text[1];
    begin
        LineFeed[1] := 10;
        if (pMemo = '') or (pIndentation <= 0) then
            exit;
        NonBreakingSpace[1] := 8239;
        GetSetup();
        for i := 1 to pIndentation * Setup."Indent Width" do
            Margin += NonBreakingSpace;
        Lines := pMemo.Split(LineFeed);
        pMemo := '';
        for i := 1 to Lines.Count() - 1 do
            pMemo += Margin + Lines.Get(i) + LineFeed;
        pMemo += Margin + Lines.Get(Lines.Count);
    end;
}
