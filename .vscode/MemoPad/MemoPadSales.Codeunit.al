codeunit 87427 "wan MemoPad Sales"
{
    procedure GetExtendedText(pHeader: Record "Sales Header"; pLine: Record "Sales Line") ReturnValue: text;
    var
        ETL: Record "Extended Text Line" temporary;
    begin
        GetExtendedTextLines(pHeader, pLine, ETL);
        if ETL.FindSet() then
            repeat
                ReturnValue += ETL.Text;
            until ETL.Next() = 0;
    end;

    procedure GetExtendedTextLines(pHeader: Record "Sales Header"; pLine: Record "Sales Line"; var pExtendedTextLine: Record "Extended Text Line" temporary)
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
                ETH.SetRange("Sales Quote", true);
            pHeader."Document Type"::Order:
                ETH.SetRange("Sales Order", true);
            pHeader."Document Type"::Invoice:
                ETH.SetRange("Sales Invoice", true);
            pHeader."Document Type"::"Credit Memo":
                ETH.SetRange("Sales Credit memo", true);
            pHeader."Document Type"::"Blanket Order":
                ETH.SetRange("Sales Blanket Order", true);
            pHeader."Document Type"::"Return Order":
                ETH.SetRange("Sales Return Order", true);
        end;
        TransferExtendedText.ReadExtTextLines(ETH, pHeader."Document Date", pHeader."Language Code");
        TransferExtendedText.GetTempExtTextLine(pExtendedTextLine);
    end;

    procedure GetAttachedLines(pLine: Record "Sales Line") ReturnValue: Text;
    var
        AttachedLine: Record "Sales Line";
    begin
        AttachedLine.SetRange("Document Type", pLine."Document Type");
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
