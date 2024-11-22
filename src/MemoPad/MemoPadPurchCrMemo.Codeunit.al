namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Purchases.History;
using Microsoft.Foundation.ExtendedText;
codeunit 87324 "wan MemoPad Purch. Cr. Memo"
{
    procedure GetExtendedText(pHeader: Record "Purch. Cr. Memo Hdr."; pLine: Record "Purch. Cr. Memo Line") ReturnValue: text;
    var
        ETH: Record "Extended Text Header";
        ETL: Record "Extended Text Line" temporary;
        TransferExtendedText: Codeunit "Transfer Extended Text";
    begin
        case pLine.Type of
            pLine.Type::Item:
                ETH.SetRange("Table Name", ETH."Table Name"::Item);
            pLine.Type::Resource:
                ETH.SetRange("Table Name", ETH."Table Name"::Resource);
            pLine.Type::"G/L Account":
                ETH.SetRange("Table Name", ETH."Table Name"::"G/L Account");
            else
                exit;
        end;
        ETH.SetRange("No.", pLine."No.");
        ETH.SetRange("Purchase Credit Memo", true);
        TransferExtendedText.ReadExtTextLines(ETH, pHeader."Document Date", pHeader."Language Code");
        TransferExtendedText.GetTempExtTextLine(ETL);
        if ETL.FindSet() then begin
            repeat
                ReturnValue += ETL.Text;
            Until ETL.Next() = 0;
        end;
    end;

    procedure GetAttachedLines(pLine: Record "Purch. Cr. Memo Line") ReturnValue: Text;
    var
        AttachedLine: Record "Purch. Cr. Memo Line";
    begin
        AttachedLine.SetRange("Document No.", pLine."Document No.");
        AttachedLine.SetRange("Attached to Line No.", pLine."Line No.");
        if AttachedLine.FindSet() then
            repeat
                ReturnValue += AttachedLine.Description;
            until AttachedLine.Next() = 0;
    end;

    procedure LineFeed() ReturnValue: Text[2];
    begin
        ReturnValue[1] := 13;
        ReturnValue[2] := 10;
    end;
}