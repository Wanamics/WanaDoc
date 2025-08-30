namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Sales.History;

pageextension 87327 "wan Posted Sales CM Indent" extends "Posted Sales Cr. Memo Subform"
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
        wanIndentation := Rec."wan Indentation";
    end;
}
