namespace Wanamics.WanaDoc.Excel;

using Microsoft.Purchases.Document;
pageextension 87376 "wan Purch. Invoice Excel" extends "Purch. Invoice Subform"
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
