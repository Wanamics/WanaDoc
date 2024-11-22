namespace Wanamics.WanaDoc.Excel;

using Microsoft.Sales.Document;
using System.IO;
using Microsoft.Finance.GeneralLedger.Setup;
Codeunit 87369 "wan Excel Sales Lines"
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

    procedure Import(var pRec: Record "Sales Line")
    var
        ImportFromExcelTitle: Label 'Import Excel File';
        ExcelFileCaption: Label 'Excel Files (*.xlsx)';
        ExcelFileExtensionTok: Label '.xlsx', Locked = true;
        InStream: InStream;
        FileName: Text;
    begin
        if UploadIntoStream('', '', '', FileName, InStream) then begin
            ExcelBuffer.LOCKTABLE;
            ExcelBuffer.OpenBookStream(InStream, SheetName);
            ExcelBuffer.ReadSheet();
            AnalyzeData(pRec);
            ExcelBuffer.DeleteAll();
            ExcelBufferExtended.DeleteAll();
        end;
    end;

    local procedure AnalyzeData(pRec: Record "Sales Line")
    var
        lRowNo: Integer;
        lNext: Integer;
        lExists: Boolean;
        lCount: Integer;
        lProgress: Integer;
        lDialog: Dialog;
        ltAnalyzing: Label 'Analyzing Data...\\';
        lRec: Record "Sales Line";
    begin
        lRec.SetRange("Document Type", pRec."Document Type");
        lRec.SetRange("Document No.", pRec."Document No.");
        if lRec.FindLast then;
        lDialog.Open(ltAnalyzing + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
        lDialog.Update(1, 0);
        ExcelBuffer.SetFilter("Row No.", '>1');
        lCount := ExcelBuffer.Count;
        if ExcelBuffer.FindSet then
            repeat
                InitLine(lRec, pRec);
                lRowNo := ExcelBuffer."Row No.";
                repeat
                    lProgress += 1;
                    GetCell(lRec, ExcelBuffer."Column No.", ExcelBuffer."Cell Value as Text");
                    lNext := ExcelBuffer.Next;
                until (lNext = 0) or (ExcelBuffer."Row No." <> lRowNo);
                InsertLine(lRec, pRec);
                lDialog.Update(1, Round(lProgress / lCount * 10000, 1));
            until lNext = 0;
    end;

    local procedure InitLine(var pRec: Record "Sales Line"; pToRec: Record "Sales Line")
    begin
        pRec.Init;
        pRec."Document Type" := pToRec."Document Type";
        pRec."Document No." := pToRec."Document No.";
        pRec."Line No." += 10000;
        pRec."Sell-to Customer No." := pToRec."Sell-to Customer No.";
        DescriptionMemo := '';
    end;

    local procedure InsertLine(var pRec: Record "Sales Line"; pToRec: Record "Sales Line")
    begin
        if DescriptionMemo <> '' then
            pRec.Description := ExcelBufferExtended.NextLine(DescriptionMemo, MaxStrLen(pRec.Description));
        pRec.Insert(true);
        AfterInsert(pRec);
        InsertExtendedText(pRec);
    end;

    local procedure ToDecimal() ReturnValue: Decimal
    begin
        Evaluate(ReturnValue, ExcelBuffer."Cell Value as Text");
    end;

    local procedure ToDate(pCell: Text) ReturnValue: Date
    begin
        Evaluate(ReturnValue, ExcelBuffer."Cell Value as Text");
    end;

    local procedure InsertExtendedText(var pLine: Record "Sales Line")
    var
        lAttachedToLine: Record "Sales Line";
    begin
        if DescriptionMemo = '' then
            exit;

        lAttachedToLine := pLine;
        repeat
            pLine.Init;
            pLine."Line No." += 10000;
            pLine."Attached to Line No." := lAttachedToLine."Line No.";
            pLine.Description := ExcelBufferExtended.NextLine(DescriptionMemo, MaxStrLen(pLine.Description));
            pLine.Insert;
        until StrLen(DescriptionMemo) = 0;
    end;

    procedure Export(var pRec: Record "Sales Line")
    var
        lblConfirm: Label 'Do-you want to create an Excel book for %1 %2(s)?', Comment = '%1: Count, %2: TableCaption';
        ProgressDialog: Codeunit "Excel Buffer Dialog Management";
        lRec: Record "Sales Line";
    begin
        lRec.SetRange("Document Type", pRec."Document Type");
        lRec.SetRange("Document No.", pRec."Document No.");
        lRec.SetRange("Attached to Line No.", 0);
        if not Confirm(lblConfirm, true, lRec.Count(), lRec.TableCaption()) then
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
        ExcelBuffer.WriteSheet(Format(pRec."Document Type"), CompanyName, UserId);
        ExcelBuffer.CloseBook;
        ExcelBuffer.SetFriendlyFilename(SafeFileName(pRec));
        ExcelBuffer.OpenExcel;
    end;

    local procedure SafeFileName(pRec: Record "Sales Line"): Text
    var
        FileManagement: Codeunit "File Management";
        lHeader: Record "Sales Header";
    begin
        lHeader.Get(pRec."Document Type", pRec."Document No.");
        exit(FileManagement.GetSafeFileName(Format(lHeader."Document Type") + ' ' + lHeader."No." + ' - ' + lHeader."Sell-to Customer Name" /*+ ' - ' + Description*/));
    end;

    local procedure SetCell(pRowNo: Integer; var pColumnNo: Integer; pCellValue: Text; pBold: Boolean; pUnderLine: Boolean; pNumberFormat: Text; pCellType: Option)
    begin
        ExcelBuffer.Init;
        ExcelBuffer.Validate("Row No.", pRowNo);
        ExcelBuffer.Validate("Column No.", pColumnNo);
        if StrLen(pCellValue) > MaxStrLen(ExcelBuffer."Cell Value as text") then
            ExcelBuffer.SetExtendedText(pCellValue)
        else
            ExcelBuffer."Cell Value as Text" := pCellValue;
        ExcelBuffer.Formula := '';
        ExcelBuffer.Bold := pBold;
        ExcelBuffer.Underline := pUnderLine;
        ExcelBuffer.NumberFormat := pNumberFormat;
        ExcelBuffer."Cell Type" := pCellType;
        ExcelBuffer.Insert;
        pColumnNo += 1;
    end;

    local procedure FullDescription(pLine: Record "Sales Line") ReturnValue: Text
    var
        lLineAttached: Record "Sales Line";
    begin
        ReturnValue := pLine.Description;
        lLineAttached.SetRange("Document Type", pLine."Document Type");
        lLineAttached.SetRange("Document No.", pLine."Document No.");
        lLineAttached.SetRange("Attached to Line No.", pLine."Line No.");
        if lLineAttached.FindSet then
            repeat
                ReturnValue := ReturnValue + lLineAttached.Description;
            until lLineAttached.Next = 0;
    end;

    local procedure ExportTitles(pRec: Record "Sales Line")
    var
        lRec: Record "Sales Line";
        i: Integer;
        GLSetup: Record "General Ledger Setup";
    begin
        SetCell(RowNo, ColumnNo, pRec.FieldCaption(Type), true, false, '', ExcelBuffer."Cell Type"::Text); // 1
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("No."), true, false, '', ExcelBuffer."Cell Type"::Text); // 2
        SetCell(RowNo, ColumnNo, pRec.FieldCaption(Description), true, false, '', ExcelBuffer."Cell Type"::Text); // 3
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("Unit of Measure Code"), true, false, '', ExcelBuffer."Cell Type"::Text); // 4
        SetCell(RowNo, ColumnNo, pRec.FieldCaption(Quantity), true, false, '', ExcelBuffer."Cell Type"::Text); // 5
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("Unit Price"), true, false, '', ExcelBuffer."Cell Type"::Text); // 6
        SetCell(RowNo, ColumnNo, pRec.FieldCaption(Amount), true, false, '', ExcelBuffer."Cell Type"::Text); // 7
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("VAT Prod. Posting Group"), true, false, '', ExcelBuffer."Cell Type"::Text); // 8
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("Job No."), true, false, '', ExcelBuffer."Cell Type"::Text); // 9
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("Job Task No."), true, false, '', ExcelBuffer."Cell Type"::Text); // 10
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("Shortcut Dimension 1 Code"), true, false, '', ExcelBuffer."Cell Type"::Text); // 11
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("Shortcut Dimension 2 Code"), true, false, '', ExcelBuffer."Cell Type"::Text); // 12
        GLSetup.Get;
        SetCell(RowNo, ColumnNo, GLSetup."Shortcut Dimension 3 Code", true, false, '', ExcelBuffer."Cell Type"::Text); // 13
        SetCell(RowNo, ColumnNo, GLSetup."Shortcut Dimension 4 Code", true, false, '', ExcelBuffer."Cell Type"::Text); // 14
        SetCell(RowNo, ColumnNo, GLSetup."Shortcut Dimension 5 Code", true, false, '', ExcelBuffer."Cell Type"::Text); // 15
        SetCell(RowNo, ColumnNo, GLSetup."Shortcut Dimension 6 Code", true, false, '', ExcelBuffer."Cell Type"::Text); // 16
        SetCell(RowNo, ColumnNo, GLSetup."Shortcut Dimension 7 Code", true, false, '', ExcelBuffer."Cell Type"::Text); // 17
        SetCell(RowNo, ColumnNo, GLSetup."Shortcut Dimension 8 Code", true, false, '', ExcelBuffer."Cell Type"::Text); // 18

        OnAfterExportTitles(pRec, ColumnNo);
    end;

    local procedure ExportLine(pRec: Record "Sales Line")
    var
        ShortcutDimCode: array[8] of Code[20];
        i: Integer;
    begin
        SetCell(RowNo, ColumnNo, Format(pRec.Type, 0, 1), false, false, '', ExcelBuffer."Cell Type"::Text); // 1
        SetCell(RowNo, ColumnNo, pRec."No.", false, false, '', ExcelBuffer."Cell Type"::Text); // 2
        SetCell(RowNo, ColumnNo, FullDescription(pRec), false, false, '', ExcelBuffer."Cell Type"::Text); // 3
        if pRec.Type <> pRec.Type::" " then begin
            SetCell(RowNo, ColumnNo, pRec."Unit of Measure Code", false, false, '', ExcelBuffer."Cell Type"::Text); // 4
            SetCell(RowNo, ColumnNo, Format(pRec.Quantity), false, false, '', ExcelBuffer."Cell Type"::Number); // 5
            SetCell(RowNo, ColumnNo, Format(pRec."Unit Price"), false, false, '', ExcelBuffer."Cell Type"::Number); // 6
            SetCell(RowNo, ColumnNo, Format(pRec.Amount), false, false, '', ExcelBuffer."Cell Type"::Number); // 7
            SetCell(RowNo, ColumnNo, pRec."VAT Prod. Posting Group", false, false, '', ExcelBuffer."Cell Type"::Text); // 8
            SetCell(RowNo, ColumnNo, pRec."Job No.", false, false, '', ExcelBuffer."Cell Type"::Text); // 9
            SetCell(RowNo, ColumnNo, pRec."Job Task No.", false, false, '', ExcelBuffer."Cell Type"::Text); // 10
            SetCell(RowNo, ColumnNo, pRec."Shortcut Dimension 1 Code", false, false, '', ExcelBuffer."Cell Type"::Text); // 11
            SetCell(RowNo, ColumnNo, pRec."Shortcut Dimension 2 Code", false, false, '', ExcelBuffer."Cell Type"::Text); // 12
            pRec.ShowShortcutDimCode(ShortcutDimCode);
            for i := 3 to 8 do
                SetCell(RowNo, ColumnNo, ShortcutDimCode[i], false, false, '', ExcelBuffer."Cell Type"::Text); // 13..18

        end;

        OnAfterExportLine(pRec, ColumnNo);
    end;

    local procedure GetCell(var pRec: Record "Sales Line"; pColumnNo: Integer; pText: Text)
    var
        lCode: Code[20];
        InStream: InStream;
    begin
        case pColumnNo of
            1:
                begin
                    Evaluate(pRec.Type, pText);
                    pRec.Validate(Type);
                end;
            2:
                pRec.Validate("No.", pText);
            3:
                begin
                    if StrLen(pText) <= MaxStrLen(pRec.Description) then
                        pRec.Description := pText
                    else
                        if not ExcelBuffer."Cell Value as Blob".HasValue then
                            DescriptionMemo := pText
                        else begin
                            ExcelBuffer.Calcfields("Cell Value as Blob");
                            ExcelBuffer."Cell Value as Blob".CreateInStream(InStream, TextEncoding::Windows);
                            InStream.Read(DescriptionMemo);
                        end;
                end;
            4:
                pRec.Validate("Unit of Measure Code", pText);
            5:
                pRec.Validate(Quantity, ToDecimal);
            6:
                pRec.Validate("Unit Price", ToDecimal);
            7:
                ;//Amount
            8:
                pRec.Validate("VAT Prod. Posting Group", pText);
            9:
                pRec.Validate("Job No.", pText);
            10:
                pRec.Validate("Job Task No.", pText);
            11:
                pRec.Validate("Shortcut Dimension 1 Code", pText);
            12:
                pRec.Validate("Shortcut Dimension 2 Code", pText);
            13 .. 18:
                begin
                    lCode := pText;
                    pRec.ValidateShortcutDimCode(pColumnNo - 10, lCode);
                end;
            else
                OnAfterImportCell(pColumnNo, pRec);
        end;
    end;

    local procedure AfterInsert(var pRec: Record "Sales Line")
    begin
        pRec.Validate("Shortcut Dimension 1 Code");
        pRec.Validate("Shortcut Dimension 2 Code");
        OnAfterInsert(pRec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExportTitles(pRec: Record "Sales Line"; pColumn: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExportLine(pRec: Record "Sales Line"; pColumn: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterImportCell(pColumn: Integer; var pRec: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsert(var pRec: Record "Sales Line")
    begin
    end;
}

