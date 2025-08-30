namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Foundation.ExtendedText;
codeunit 87320 "wan MemoPad Management"
{
    var
        MemoPad: Page "wan MemoPad";

    procedure MemoToBuffer(var pMemo: Text; pMaxLength: Integer; var pMemoPadBuffer: Record "Extended text Line" temporary)
    var
        LineFeed: Text[1];
        Index: Integer;
    begin
        if pMemo = '' then
            exit;
        LineFeed[1] := 10;
        Index := pMemo.IndexOf(LineFeed);
        while Index > 0 do begin
            ProcessLine(pMemo.Substring(1, Index), pMaxLength, pMemoPadBuffer);
            pMemo := pMemo.Substring(Index + 1);
            Index := pMemo.IndexOf(LineFeed);
        end;
        ProcessLine(pMemo, pMaxLength, pMemoPadBuffer);
    end;

    local procedure ProcessLine(pTextLine: Text; pMaxLength: Integer; var pMemoPadBuffer: Record "Extended text Line" temporary)
    var
        Length: Integer;
    begin
        while StrLen(pTextLine) > pMaxLength do begin
            if pTextLine[pMaxLength + 1] = ' ' then
                Length := pMaxLength
            else begin
                Length := pMaxLength;
                while (pTextLine[Length] <> ' ') and (Length > 1) do
                    Length -= 1;
                if Length = 1 then
                    Length := pMaxLength;
            end;
            AddToBuffer(pTextLine.Substring(1, Length), pMemoPadBuffer);
            pTextLine := pTextLine.Substring(Length + 1);
        end;
        AddToBuffer(pTextLine, pMemoPadBuffer);
    end;

    local procedure AddToBuffer(pText: Text; var pMemoPadBuffer: Record "Extended text Line" temporary)
    begin
        pMemoPadBuffer.Init();
        pMemoPadBuffer."Line No." += 1;
        pMemoPadBuffer.Text := pText;
        pMemoPadBuffer.Insert();
    end;

    procedure GetMemo(pTableName: Enum "Extended Text Table Name"; pNo: Code[20]) ReturnValue: Text;
    var
        ETL: Record "Extended Text Line";
    begin
        ETL.SetRange("Table Name", pTableName);
        ETL.SetRange("No.", pNo);
        ETL.SetRange("Language Code", '');
        ETL.SetRange("Text No.", 0);
        if ETL.FindSet() then
            repeat
                ReturnValue += ETL.Text;
            until ETL.Next() = 0;
    end;

    procedure SetMemo(pTableName: Enum "Extended Text Table Name"; pNo: Code[20]; pMemo: Text)
    var
        ETH: Record "Extended Text Header";
        ETL: Record "Extended Text Line";
        TempExtendedTextLine: Record "Extended Text Line" temporary;
    begin
        ETL.SetRange("Table Name", ETL."Table Name"::Item);
        ETL.SetRange("No.", pNo);
        ETL.SetRange("Language Code", '');
        ETL.SetRange("Text No.", 0);
        ETL.DeleteAll();
        if not ETH.Get(ETH."Table Name"::Item, pNo, '', 0) then begin
            ETH.Init();
            ETH."Table Name" := ETH."Table Name"::Item;
            ETH."No." := pNo;
            ETH."Language Code" := '';
            ETH."Text No." := 0;
            ETH.Description := '';
            ETH.Insert();
        end;
        MemoToBuffer(pMemo, MaxStrLen(ETL.Text), TempExtendedTextLine);
        ETL."Table Name" := ETL."Table Name"::Item;
        ETL."No." := pNo;
        ETL."Language Code" := '';
        ETL."Text No." := 0;
        if TempExtendedTextLine.FindSet then begin
            repeat
                ETL.Init();
                ETL."Line No." += 10000;
                ETL.Text := TempExtendedTextLine.Text;
                ETL.Insert();
            until TempExtendedTextLine.Next = 0;
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
        for i := 1 to pIndentation * 3 do
            Margin += NonBreakingSpace;
        Lines := pMemo.Split(LineFeed);
        pMemo := '';
        for i := 1 to Lines.Count() - 1 do
            pMemo += Margin + Lines.Get(i) + LineFeed;
        pMemo += Margin + Lines.Get(Lines.Count);
    end;
}