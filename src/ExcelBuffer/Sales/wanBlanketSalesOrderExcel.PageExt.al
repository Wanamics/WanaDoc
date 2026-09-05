namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Document;
using Wanamics.WanaDoc.Excel;
pageextension 87389 "wan Blanket Sales Order Excel" extends "Blanket Sales Order Subform"
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
                Tooltip = 'Export the Blanket Sales Order to Excel.';
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
                Tooltip = 'Import data from an Excel file.';
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