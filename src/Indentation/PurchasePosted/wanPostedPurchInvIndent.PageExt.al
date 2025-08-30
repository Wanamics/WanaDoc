namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Purchases.History;

pageextension 87336 "wan Posted Purch. Inv. Indent" extends "Posted Purch. Invoice Subform"
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
