namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Sales.History;

pageextension 87312 "wan Posted Sales Inv. Indent" extends "Posted Sales Invoice Subform"
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
