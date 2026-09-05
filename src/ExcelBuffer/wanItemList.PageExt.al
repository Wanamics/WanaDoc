namespace Wanamics.WanaDoc.Excel;

using Microsoft.Foundation.ExtendedText;
using Microsoft.Inventory.Item;
pageextension 87331 "wan_ Item List" extends "Item List"
{
    layout
    {
    }

    actions
    {
        addbefore("&Create Stockkeeping Unit")
        {
            action(wanExportExtendedTexts)
            {
                Caption = 'Export Extended text';
                ApplicationArea = All;
                Image = Export;
                ToolTip = 'Export Extended text to Excel';
                trigger OnAction()
                var
                    ExtendedTextHeader: Record "Extended Text Header";
                    ExcelExtendedTexts: Codeunit "wan Excel Extended Texts";
                begin
                    ExcelExtendedTexts.Export(ExtendedTextHeader);
                end;
            }
            action(wanImportExtendedTexts)
            {
                Caption = 'Import Extended text';
                ApplicationArea = All;
                Image = Import;
                ToolTip = 'Import Extended text from Excel';
                trigger OnAction()
                var
                    ExtendedTextHeader: Record "Extended Text Header";
                    ExcelExtendedTexts: Codeunit "wan Excel Extended Texts";
                begin
                    ExcelExtendedTexts.Import(ExtendedTextHeader);
                end;
            }
        }
    }
}