namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Purchases.Archive;

pageextension 87338 "wan Purch. Order Arch. Indent" extends "Purchase Order Archive Subform"
{
    layout
    {
        modify(Control1)
        {
            IndentationControls = Description;
            IndentationColumn = wanIndentation;
        }
        modify(Description)
        {
            StyleExpr = wanStyle;
        }
    }
    var
        wanIndentation: Integer;
        wanStyle: Text;

    trigger OnAfterGetRecord()
    begin
        wanStyle := Rec.wanStyle();
        wanIndentation := Rec.wanIndentation();
    end;
}
