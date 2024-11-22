namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Foundation.ExtendedText;
codeunit 87320 "wan MemoPad Management"
{
    var
        MemoPad: Page "wan MemoPad";

    procedure MemoToBuffer(var pMemo: Text; pMaxLength: Integer; var pMemoPadBuffer: Record "Extended text Line" temporary)
    var
        LineFeed: Text[2];
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

}