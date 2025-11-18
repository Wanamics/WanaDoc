namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Document;
using Wanamics.WanaDoc.Excel;
pageextension 87387 "wan Sales Quote Excel" extends "Sales Quote Subform"
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
