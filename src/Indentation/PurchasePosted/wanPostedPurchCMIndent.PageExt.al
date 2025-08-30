namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Purchases.History;

pageextension 87335 "wan Posted Purch. C.M. Indent" extends "Posted Purch. Cr. Memo Subform"
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
