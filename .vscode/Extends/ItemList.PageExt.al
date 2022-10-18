pageextension 87031 "wan_ Item List" extends "Item List"
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
                trigger OnAction()
                var
                    ExcelExtendedTexts: codeunit "wan Excel Extended Texts";
                    ExtendedTextHeader: record "Extended Text Header";
                begin
                    ExcelExtendedTexts.Export(ExtendedTextHeader);
                end;
            }
            action(wanImportExtendedTexts)
            {
                Caption = 'Import Extended text';
                ApplicationArea = All;
                Image = Import;
                trigger OnAction()
                var
                    ExcelExtendedTexts: codeunit "wan Excel Extended Texts";
                    ExtendedTextHeader: record "Extended Text Header";
                begin
                    ExcelExtendedTexts.Import(ExtendedTextHeader);
                end;
            }
        }
    }
}