namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Sales.Archive;

pageextension 87333 "wan Sales Quote Arch. Indent" extends "Sales Quote Archive Subform"
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
