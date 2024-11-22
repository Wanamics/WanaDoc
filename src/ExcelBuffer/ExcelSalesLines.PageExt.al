// Warning Multi-Objects
namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Document;
using Microsoft.Foundation.ExtendedText;
using Wanamics.WanaDoc.Excel;
pageextension 87385 "wan Sales Order Excel" extends "Sales Order Subform"
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
pageextension 87388 "wan Sales Cr.Memo Excel" extends "Sales Cr. Memo Subform"
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