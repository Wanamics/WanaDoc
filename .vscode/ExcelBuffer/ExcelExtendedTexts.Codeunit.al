codeunit 87279 "wan Excel Extended Texts"
{
    trigger OnRun()
    begin
    end;

    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColumnNo: Integer;
        SheetName: Label 'Data';
        ExcelBufferExtended: Record "wan Excel Buffer Extended" temporary;
        DescriptionMemo: Text;

    procedure Import(pRec: Record "Extended Text Header")
    var
        ImportFromExcelTitle: Label 'Import Excel File';
        ExcelFileCaption: Label 'Excel Files (*.xlsx)';
        ExcelFileExtensionTok: Label '.xlsx', Locked = true;
        IStream: InStream;
        FileName: Text;
    begin
        if UploadIntoStream('', '', '', FileName, IStream) then begin
            ExcelBuffer.LOCKTABLE;
            ExcelBuffer.OpenBookStream(IStream, SheetName);
            ExcelBuffer.ReadSheet();
            AnalyzeData(pRec);
            ExcelBuffer.DeleteAll();
            ExcelBufferExtended.DeleteAll();
        end;
    end;

    local procedure AnalyzeData(pRec: Record "Extended Text Header")
    begin
        ImportTitles(pRec);
        ImportLines(pRec);
    end;

    local procedure ImportTitles(var pRec: record "Extended text Header")
    begin
        ExcelBuffer.Get(1, 1);
        Evaluate(pRec."Table Name", ExcelBuffer."Cell Value as Text");
        //pRec."Table Name" := pRec."Table Name"::Item;
        if ExcelBuffer.Get(1, 2) then
            pRec.Validate("Language Code", ExcelBuffer."Cell Value as Text");
    end;

    local procedure ImportLines(var pRec: record "Extended text Header")
    var
        lRowNo: Integer;
        lNext: Integer;
        lExists: Boolean;
        lCount: Integer;
        lProgress: Integer;
        lDialog: Dialog;
        ltAnalyzing: Label 'Analyzing Data...\\';

    begin
        InitLine(pRec);
        lDialog.Open(ltAnalyzing + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
        lDialog.Update(1, 0);
        ExcelBuffer.SetFilter("Row No.", '>1');
        lCount := ExcelBuffer.Count;
        if ExcelBuffer.FindSet then
            repeat
                lRowNo := ExcelBuffer."Row No.";
                repeat
                    lProgress += 1;
                    ImportCell(pRec, ExcelBuffer."Column No.", ExcelBuffer."Cell Value as Text");
                    lNext := ExcelBuffer.Next;
                until (lNext = 0) or (ExcelBuffer."Row No." <> lRowNo);
                InsertLine(pRec);
                lDialog.Update(1, Round(lProgress / lCount * 10000, 1));
            until lNext = 0;
    end;

    local procedure InitLine(var pRec: Record "Extended Text Header")
    begin
        pRec.Init;
    end;

    local procedure InsertLine(var pRec: Record "Extended Text Header")
    begin
        pRec.Description := ExcelBufferExtended.NextLine(DescriptionMemo, MaxStrLen(pRec.Description));
        pRec.Insert(true);
        AfterInsert(pRec);
        InsertExtendedTextLines(pRec, DescriptionMemo);
        InitLine(pRec);
    end;

    local procedure InsertExtendedTextLines(var pRec: Record "Extended text Header"; var pText: Text)
    var
        ExtendedTextLine: Record "Extended Text Line";
    begin
        if pText = '' then
            exit;
        ExtendedTextLine.Init;
        ExtendedTextLine."Table Name" := pRec."Table Name";
        ExtendedTextLine."No." := pRec."No.";
        ExtendedTextLine."Language Code" := pRec."Language Code";
        repeat
            ExtendedTextLine."Line No." += 10000;
            ExtendedTextLine.Text := ExcelBufferExtended.NextLine(pText, MaxStrLen(ExtendedTextLine.Text));
            ExtendedTextLine.Insert;
        until StrLen(pText) = 0;
    end;

    local procedure ImportCell(var pRec: Record "Extended Text Header"; pColumnNo: Integer; pCell: Text)
    begin
        CASE pColumnNo OF
            1:
                pRec.VALIDATE("No.", pCell);
            2:
                begin
                    DescriptionMemo := pCell;
                    //ExcelBufferExtended.AppendExtendedText(DescriptionMemo, ExcelBuffer);
                    //ExcelBufferExtended.Split(ExcelBuffer, pCell);
                end;
        END;
    end;

    local procedure AfterInsert(var pRec: Record "Extended Text Header")
    var
    //ExtendedTextLine: record "Extended Text Line";
    begin
        /*
        ExtendedTextLine."Table Name" := pRec."Table Name";
        ExtendedTextLine."No." := pRec."No.";
        ExtendedTextLine."Text No." := pRec."Text No.";
        ExtendedTextLine."Language Code" := pRec."Language Code";
        if ExcelBufferExtended.FINDSET then
            repeat
                ExtendedTextLine.Text := ExcelBufferExtended."Extended Text";
                ExtendedTextLine.Insert;
            until ExcelBufferExtended.Next = 0;
        */
    end;

    procedure Export(var pRec: Record "Extended Text Header")
    var
        lblConfirm: Label 'Do-you want to create an Excel book for %1 %2(s)?', Comment = '%1: Count, %2: TableCaption';
        ProgressDialog: Codeunit "Excel Buffer Dialog Management";
        lRec: Record "Extended Text Header";
    begin
        lRec.SETRANGE("Table Name", pRec."Table Name");
        lRec.SETRANGE("Language Code", pRec."Language Code");
        lRec.SETFilter("No.", pRec.GetFilter("No."));
        if not confirm(lblConfirm, true, lRec.Count(), lRec.TableCaption()) then
            exit;

        ProgressDialog.Open('');
        RowNo := 1;
        ColumnNo := 1;
        ExportTitles(pRec);
        if lRec.FindSet then
            repeat
                ProgressDialog.SetProgress(RowNo);
                RowNo += 1;
                ColumnNo := 1;
                ExportLine(lRec);
            until lRec.Next = 0;
        ProgressDialog.Close;

        ExcelBuffer.CreateNewBook(SheetName);
        ExcelBuffer.WriteSheet(format(pRec."Table Name") + ' ' + pRec."Language Code", COMPANYNAME, USERID);
        ExcelBuffer.CloseBook;
        ExcelBuffer.SetFriendlyFilename(SafeFileName(pRec));
        ExcelBuffer.OpenExcel;
    end;

    local procedure SafeFileName(pRec: Record "Extended Text Header"): Text
    var
        FileManagement: Codeunit "File Management";
    begin
        EXIT(FileManagement.GetSafeFileName(format(pRec."Table Name") + ' ' + pRec."Language Code"));
    end;

    local procedure EnterCell(pRowNo: Integer; var pColumnNo: Integer; pCellValue: Text; pBold: Boolean; pUnderLine: Boolean; pNumberFormat: Text; pCellType: Option)
    begin
        ExcelBuffer.Init;
        ExcelBuffer.Validate("Row No.", pRowNo);
        ExcelBuffer.Validate("Column No.", pColumnNo);
        ExcelBuffer."Cell Value as Text" := pCellValue;
        ExcelBuffer.Formula := '';
        ExcelBuffer.Bold := pBold;
        ExcelBuffer.Underline := pUnderLine;
        ExcelBuffer.NumberFormat := pNumberFormat;
        ExcelBuffer."Cell Type" := pCellType;
        ExcelBuffer.Insert;
        pColumnNo += 1;
    end;

    local procedure FullDescription(pRec: Record "Extended Text Header") ReturnValue: Text
    var
        ExtendedTextLine: Record "Extended Text Line";
    //Chr10: Char;
    //Chr13: Char;
    begin
        //Chr10 := 10;
        //Chr13 := 13;
        ReturnValue := pRec.Description;
        ExtendedTextLine.SetRange("Table Name", pRec."Table Name");
        ExtendedTextLine.SetRange("No.", pRec."No.");
        ExtendedTextLine.SetRange("Language Code", ExtendedTextLine."Language Code");
        if ExtendedTextLine.FindSet then
            repeat
                /*
                if Separator = 1 then
                    ReturnValue := ReturnValue + Format(Chr13) + Format(Chr10) + Description
                else
                */
                ReturnValue := ReturnValue + ExtendedTextLine.Text;
            until ExtendedTextLine.Next = 0;
    end;

    local procedure ExportTitles(var pRec: record "Extended text Header")
    begin
        EnterCell(RowNo, ColumnNo, format(pRec."Table Name"), TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(RowNo, ColumnNo, prec."Language Code", TRUE, FALSE, '', ExcelBuffer."Cell Type"::Text);
    end;

    local procedure ExportLine(pRec: Record "Extended Text Header")
    begin
        EnterCell(RowNo, ColumnNo, pRec."No.", FALSE, FALSE, '', ExcelBuffer."Cell Type"::Text);
        EnterCell(RowNo, ColumnNo, FullDescription(pRec), false, false, '', ExcelBuffer."cell type"::Text);
    end;

}