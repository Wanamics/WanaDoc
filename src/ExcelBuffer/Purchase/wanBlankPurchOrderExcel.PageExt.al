namespace Wanamics.WanaDoc.Excel;

using Microsoft.Purchases.Document;
pageextension 87379 "wan Blank. Purch. Order Excel" extends "Blanket Purchase Order Subform"
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
                ToolTip = 'Export Blanket Purchase Order to Excel';
                trigger OnAction()
                var
                    ExcelLines: Codeunit "wan Excel Purchase Lines";
                begin
                    ExcelLines.Export(Rec);
                end;
            }
            action(wanExcelImport)
            {
                ApplicationArea = All;
                Caption = 'Excel Import';
                Image = ImportExcel;
                ToolTip = 'Import Blanket Purchase Order from Excel';
                trigger OnAction()
                var
                    ExcelLines: Codeunit "wan Excel Purchase Lines";
                begin
                    ExcelLines.Import(Rec);
                end;
            }
        }
    }
}