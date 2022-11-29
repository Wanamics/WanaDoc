codeunit 87328 "wan MemoPad Sales Invoice"
{
    procedure GetExtendedText(pHeader: Record "Sales Invoice Header"; pLine: Record "Sales Invoice Line") ReturnValue: text;
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
        ETH.SetRange("Sales Invoice", true);
        TransferExtendedText.ReadExtTextLines(ETH, pHeader."Document Date", pHeader."Language Code");
        TransferExtendedText.GetTempExtTextLine(ETL);
        if ETL.FindSet() then begin
            repeat
                ReturnValue += ETL.Text;
            Until ETL.Next() = 0;
        end;
    end;

    procedure GetAttachedLines(pLine: Record "Sales Invoice Line") ReturnValue: Text;
    var
        AttachedLine: Record "Sales Invoice Line";
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