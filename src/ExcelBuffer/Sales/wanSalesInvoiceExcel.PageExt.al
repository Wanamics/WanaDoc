namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Document;
using Wanamics.WanaDoc.Excel;
pageextension 87386 "wan Sales Invoice Excel" extends "Sales Invoice Subform"
{
    actions
    {
        addlast("F&unctions")
        {
            action(wanExcelExport)
            {
                ApplicationArea = All;
                Caption = 'Excel Export';
                Image = ExportToExcel;
                Tooltip = 'Export the sales invoice lines to an Excel file.';
                trigger OnAction()
                var
                    ExcelLines: Codeunit "wan Excel Sales Lines";
                begin
                    ExcelLines.Export(Rec);
                end;
            }
            action(wanExcelImport)
            {
                ApplicationArea = All;
                Caption = 'Excel Import';
                Image = ImportExcel;
                Tooltip = 'Import the sales invoice lines from an Excel file.';
                trigger OnAction()
                var
                    ExcelLines: Codeunit "wan Excel Sales Lines";
                begin
                    ExcelLines.Import(Rec);
                end;
            }
        }
    }
}
