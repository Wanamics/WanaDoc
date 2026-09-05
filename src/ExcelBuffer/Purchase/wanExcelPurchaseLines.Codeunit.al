namespace Wanamics.WanaDoc.Excel;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Document;
using System.IO;
Codeunit 87389 "wan Excel Purchase Lines"
{
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        TempExcelBufferExtended: Record "wan Excel Buffer Extended" temporary;
        RowNo: Integer;
        ColumnNo: Integer;
        SheetNameLbl: Label 'Data';
        DescriptionMemo: Text;

    procedure Import(var pRec: Record "Purchase Line")
    var
        // ImportFromExcelTitleLbl: Label 'Import Excel File';
        // ExcelFileCaptionLbl: Label 'Excel Files (*.xlsx)';
        // ExcelFileExtensionTok: Label '.xlsx', Locked = true;
        InStream: InStream;
        FileName: Text;
    begin
        if UploadIntoStream('', '', '', FileName, InStream) then begin
            TempExcelBuffer.LockTable();
            TempExcelBuffer.OpenBookStream(InStream, SheetNameLbl);
            TempExcelBuffer.ReadSheet();
            AnalyzeData(pRec);
            TempExcelBuffer.DeleteAll();
            TempExcelBufferExtended.DeleteAll();
        end;
    end;

    local procedure AnalyzeData(pRec: Record "Purchase Line")
    var
        lRec: Record "Purchase Line";
        lRowNo: Integer;
        lNext: Integer;
        // lExists: Boolean;
        lCount: Integer;
        lProgress: Integer;
        lDialog: Dialog;
        ltAnalyzingLbl: Label 'Analyzing Data...\\';
    begin
        lRec.SetRange("Document Type", pRec."Document Type");
        lRec.SetRange("Document No.", pRec."Document No.");
        if lRec.FindLast() then;
        lDialog.Open(ltAnalyzingLbl + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
        lDialog.Update(1, 0);
        TempExcelBuffer.SetFilter("Row No.", '>1');
        lCount := TempExcelBuffer.Count;
        if TempExcelBuffer.FindSet() then
            repeat
                InitLine(lRec, pRec);
                lRowNo := TempExcelBuffer."Row No.";
                repeat
                    lProgress += 1;
                    GetCell(lRec, TempExcelBuffer."Column No.", TempExcelBuffer."Cell Value as Text");
                    lNext := TempExcelBuffer.Next();
                until (lNext = 0) or (TempExcelBuffer."Row No." <> lRowNo);
                InsertLine(lRec);
                lDialog.Update(1, Round(lProgress / lCount * 10000, 1));
            until lNext = 0;
    end;

    local procedure InitLine(var pRec: Record "Purchase Line"; pToRec: Record "Purchase Line")
    begin
        pRec.Init();
        pRec."Document Type" := pToRec."Document Type";
        pRec."Document No." := pToRec."Document No.";
        pRec."Line No." += 10000;
        prec."Buy-from Vendor No." := pToRec."Buy-from Vendor No.";
        DescriptionMemo := '';
    end;

    local procedure InsertLine(var pRec: Record "Purchase Line")
    begin
        if DescriptionMemo <> '' then
            pRec.Description := TempExcelBufferExtended.NextLine(DescriptionMemo, MaxStrLen(pRec.Description));
        pRec.Insert(true);
        AfterInsert(pRec);
        InsertExtendedText(pRec);
    end;

    local procedure ToDecimal() ReturnValue: Decimal
    begin
        Evaluate(ReturnValue, TempExcelBuffer."Cell Value as Text");
    end;

    // local procedure ToDate(pCell: Text) ReturnValue: Date
    // begin
    //     Evaluate(ReturnValue, TempExcelBuffer."Cell Value as Text");
    // end;

    local procedure InsertExtendedText(var pLine: Record "Purchase Line")
    var
        lAttachedToLine: Record "Purchase Line";
    begin
        if DescriptionMemo = '' then
            exit;

        lAttachedToLine := pLine;
        repeat
            pLine.Init();
            pLine."Line No." += 10000;
            pLine."Attached to Line No." := lAttachedToLine."Line No.";
            pLine.Description := TempExcelBufferExtended.NextLine(DescriptionMemo, MaxStrLen(pLine.Description));
            pLine.Insert();
        until StrLen(DescriptionMemo) = 0;
    end;

    procedure Export(var pRec: Record "Purchase Line")
    var
        lRec: Record "Purchase Line";
        ProgressDialog: Codeunit "Excel Buffer Dialog Management";
        ConfirmLbl: Label 'Do-you want to create an Excel book for %1 %2(s)?', Comment = '%1: Count, %2: TableCaption';
    begin
        lRec.SetRange("Document Type", pRec."Document Type");
        lRec.SetRange("Document No.", pRec."Document No.");
        lRec.SetRange("Attached to Line No.", 0);
        if not Confirm(ConfirmLbl, true, lRec.Count(), lRec.TableCaption()) then
            exit;

        ProgressDialog.Open('');
        RowNo := 1;
        ColumnNo := 1;
        ExportTitles(pRec);
        if lRec.FindSet() then
            repeat
                ProgressDialog.SetProgress(RowNo);
                RowNo += 1;
                ColumnNo := 1;
                ExportLine(lRec);
            until lRec.Next() = 0;
        ProgressDialog.Close();

        TempExcelBuffer.CreateNewBook(SheetNameLbl);
        TempExcelBuffer.WriteSheet(Format(pRec."Document Type"), CompanyName, UserId);
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.SetFriendlyFilename(SafeFileName(pRec));
        TempExcelBuffer.OpenExcel();
    end;

    local procedure SafeFileName(pRec: Record "Purchase Line"): Text
    var
        lHeader: Record "Purchase Header";
        FileManagement: Codeunit "File Management";
    begin
        lHeader.Get(pRec."Document Type", pRec."Document No.");
        exit(FileManagement.GetSafeFileName(Format(lHeader."Document Type") + ' ' + lHeader."No." + ' - ' + lHeader."Buy-from Vendor Name" /* + ' - ' + Description*/));
    end;

    local procedure SetCell(pRowNo: Integer; var pColumnNo: Integer; pCellValue: Text; pBold: Boolean; pUnderLine: Boolean; pNumberFormat: Text; pCellType: Option)
    begin
        TempExcelBuffer.Init();
        TempExcelBuffer.Validate("Row No.", pRowNo);
        TempExcelBuffer.Validate("Column No.", pColumnNo);
        if StrLen(pCellValue) > MaxStrLen(TempExcelBuffer."Cell Value as text") then
            TempExcelBuffer.SetExtendedText(pCellValue)
        else
            TempExcelBuffer."Cell Value as Text" := pCellValue;
        TempExcelBuffer.Formula := '';
        TempExcelBuffer.Bold := pBold;
        TempExcelBuffer.Underline := pUnderLine;
        TempExcelBuffer.NumberFormat := pNumberFormat;
        TempExcelBuffer."Cell Type" := pCellType;
        TempExcelBuffer.Insert();
        pColumnNo += 1;
    end;

    local procedure FullDescription(pLine: Record "Purchase Line") ReturnValue: Text
    var
        lLineAttached: Record "Purchase Line";
    begin
        ReturnValue := pLine.Description;
        lLineAttached.SetRange("Document Type", pLine."Document Type");
        lLineAttached.SetRange("Document No.", pLine."Document No.");
        lLineAttached.SetRange("Attached to Line No.", pLine."Line No.");
        if lLineAttached.FindSet() then
            repeat
                ReturnValue := ReturnValue + lLineAttached.Description;
            until lLineAttached.Next() = 0;
    end;

    local procedure ExportTitles(pRec: Record "Purchase Line")
    var
        // i: Integer;
        GLSetup: Record "General Ledger Setup";
    begin
        SetCell(RowNo, ColumnNo, pRec.FieldCaption(Type), true, false, '', TempExcelBuffer."Cell Type"::Text); // 1
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("No."), true, false, '', TempExcelBuffer."Cell Type"::Text); // 2
        SetCell(RowNo, ColumnNo, pRec.FieldCaption(Description), true, false, '', TempExcelBuffer."Cell Type"::Text); // 3
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("Unit of Measure Code"), true, false, '', TempExcelBuffer."Cell Type"::Text); // 4
        SetCell(RowNo, ColumnNo, pRec.FieldCaption(Quantity), true, false, '', TempExcelBuffer."Cell Type"::Text); // 5
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("Direct Unit Cost"), true, false, '', TempExcelBuffer."Cell Type"::Text); // 6
        SetCell(RowNo, ColumnNo, pRec.FieldCaption(Amount), true, false, '', TempExcelBuffer."Cell Type"::Text); // 7
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("VAT Prod. Posting Group"), true, false, '', TempExcelBuffer."Cell Type"::Text); // 8
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("Job No."), true, false, '', TempExcelBuffer."Cell Type"::Text); // 9
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("Job Task No."), true, false, '', TempExcelBuffer."Cell Type"::Text); // 10
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("Shortcut Dimension 1 Code"), true, false, '', TempExcelBuffer."Cell Type"::Text); // 11
        SetCell(RowNo, ColumnNo, pRec.FieldCaption("Shortcut Dimension 2 Code"), true, false, '', TempExcelBuffer."Cell Type"::Text); // 12
        GLSetup.Get();
        SetCell(RowNo, ColumnNo, GLSetup."Shortcut Dimension 3 Code", true, false, '', TempExcelBuffer."Cell Type"::Text); // 13
        SetCell(RowNo, ColumnNo, GLSetup."Shortcut Dimension 4 Code", true, false, '', TempExcelBuffer."Cell Type"::Text); // 14
        SetCell(RowNo, ColumnNo, GLSetup."Shortcut Dimension 5 Code", true, false, '', TempExcelBuffer."Cell Type"::Text); // 15
        SetCell(RowNo, ColumnNo, GLSetup."Shortcut Dimension 6 Code", true, false, '', TempExcelBuffer."Cell Type"::Text); // 16
        SetCell(RowNo, ColumnNo, GLSetup."Shortcut Dimension 7 Code", true, false, '', TempExcelBuffer."Cell Type"::Text); // 17
        SetCell(RowNo, ColumnNo, GLSetup."Shortcut Dimension 8 Code", true, false, '', TempExcelBuffer."Cell Type"::Text); // 18

        OnAfterExportTitles(pRec, ColumnNo);
    end;

    local procedure ExportLine(pRec: Record "Purchase Line")
    var
        ShortcutDimCode: array[8] of Code[20];
        i: Integer;
    begin
        SetCell(RowNo, ColumnNo, Format(pRec.Type, 0, 1), false, false, '', TempExcelBuffer."Cell Type"::Text); // 1
        SetCell(RowNo, ColumnNo, pRec."No.", false, false, '', TempExcelBuffer."Cell Type"::Text); // 2
        SetCell(RowNo, ColumnNo, FullDescription(pRec), false, false, '', TempExcelBuffer."Cell Type"::Text); // 3
        if pRec.Type <> pRec.Type::" " then begin
            SetCell(RowNo, ColumnNo, pRec."Unit of Measure Code", false, false, '', TempExcelBuffer."Cell Type"::Text); // 4
            SetCell(RowNo, ColumnNo, Format(pRec.Quantity), false, false, '', TempExcelBuffer."Cell Type"::Number); // 5
            SetCell(RowNo, ColumnNo, Format(pRec."Direct Unit Cost"), false, false, '', TempExcelBuffer."Cell Type"::Number); // 6
            SetCell(RowNo, ColumnNo, Format(pRec.Amount), false, false, '', TempExcelBuffer."Cell Type"::Number); // 7
            SetCell(RowNo, ColumnNo, pRec."VAT Prod. Posting Group", false, false, '', TempExcelBuffer."Cell Type"::Text); // 8
            SetCell(RowNo, ColumnNo, pRec."Job No.", false, false, '', TempExcelBuffer."Cell Type"::Text); // 9
            SetCell(RowNo, ColumnNo, pRec."Job Task No.", false, false, '', TempExcelBuffer."Cell Type"::Text); // 10
            SetCell(RowNo, ColumnNo, pRec."Shortcut Dimension 1 Code", false, false, '', TempExcelBuffer."Cell Type"::Text); // 11
            SetCell(RowNo, ColumnNo, pRec."Shortcut Dimension 2 Code", false, false, '', TempExcelBuffer."Cell Type"::Text); // 12
            pRec.ShowShortcutDimCode(ShortcutDimCode);
            for i := 3 to 8 do
                SetCell(RowNo, ColumnNo, ShortcutDimCode[i], false, false, '', TempExcelBuffer."Cell Type"::Text); // 13..18
        end;

        OnAfterExportLine(pRec, ColumnNo);
    end;

    local procedure GetCell(var pRec: Record "Purchase Line"; pColumnNo: Integer; pText: Text)
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
                if StrLen(pText) <= MaxStrLen(pRec.Description) then
                    pRec.Description := pText
                else
                    if not TempExcelBuffer."Cell Value as Blob".HasValue then
                        DescriptionMemo := pText
                    else begin
                        TempExcelBuffer.Calcfields("Cell Value as Blob");
                        TempExcelBuffer."Cell Value as Blob".CreateInStream(InStream, TextEncoding::Windows);
                        InStream.Read(DescriptionMemo);
                    end;
            4:
                pRec.Validate("Unit of Measure Code", pText);
            5:
                pRec.Validate(Quantity, ToDecimal());
            6:
                pRec.Validate("Direct Unit Cost", ToDecimal());
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
                OnAfterGetCell(pColumnNo, pRec);
        end;
    end;

    local procedure AfterInsert(var pRec: Record "Purchase Line")
    begin
        pRec.Validate("Shortcut Dimension 1 Code");
        pRec.Validate("Shortcut Dimension 2 Code");
        OnAfterInsert(pRec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExportTitles(pRec: Record "Purchase Line"; pColumn: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExportLine(pRec: Record "Purchase Line"; pColumn: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetCell(pColumn: Integer; var pRec: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsert(var pRec: Record "Purchase Line")
    begin
    end;
}

