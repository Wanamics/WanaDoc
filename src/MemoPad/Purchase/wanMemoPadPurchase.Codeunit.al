namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Purchases.Document;
using Microsoft.Foundation.ExtendedText;
codeunit 87325 "wan MemoPad Purchase"
{
    procedure GetExtendedText(pHeader: Record "Purchase Header"; pLine: Record "Purchase Line") ReturnValue: text;
    var
        ETL: Record "Extended Text Line" temporary;
    begin
        GetExtendedTextLines(pHeader, pLine, ETL);
        if ETL.FindSet() then
            repeat
                ReturnValue += ETL.Text;
            until ETL.Next() = 0;
    end;

    procedure GetExtendedTextLines(pHeader: Record "Purchase Header"; pLine: Record "Purchase Line"; var pExtendedTextLine: Record "Extended Text Line" temporary)
    var
        ETH: Record "Extended Text Header";
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
        case pHeader."Document Type" of
            pHeader."Document Type"::Quote:
                ETH.SetRange("Purchase Quote", true);
            pHeader."Document Type"::Order:
                ETH.SetRange("Purchase Order", true);
            pHeader."Document Type"::Invoice:
                ETH.SetRange("Purchase Invoice", true);
            pHeader."Document Type"::"Credit Memo":
                ETH.SetRange("Purchase Credit memo", true);
            pHeader."Document Type"::"Blanket Order":
                ETH.SetRange("Purchase Blanket Order", true);
            pHeader."Document Type"::"Return Order":
                ETH.SetRange("Purchase Return Order", true);
        end;
        TransferExtendedText.ReadExtTextLines(ETH, pHeader."Document Date", pHeader."Language Code");
        TransferExtendedText.GetTempExtTextLine(pExtendedTextLine);
    end;

    procedure GetAttachedLines(pLine: Record "Purchase Line") ReturnValue: Text;
    var
        lLine: Record "Purchase Line";
    begin
        lLine.SetRange("Document Type", pLine."Document Type");
        lLine.SetRange("Document No.", pLine."Document No.");
        lLine.SetRange("Attached to Line No.", pLine."Line No.");
        if lLine.FindSet() then
            repeat
                ReturnValue += lLine.Description;
            until lLine.Next() = 0;
    end;

    procedure LineFeed() ReturnValue: Text;
    begin
        ReturnValue[1] := 10;
    end;
}
