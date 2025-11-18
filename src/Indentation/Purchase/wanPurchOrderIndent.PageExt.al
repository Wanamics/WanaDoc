namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Purchases.Document;

pageextension 87316 "wan Purch. Order Indent" extends "Purchase Order Subform"
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
    actions
    {
        addlast(Processing)
        {
            action(wanShiftLeft)
            {
                ApplicationArea = All;
                Caption = ' ', Locked = true;
                ToolTip = 'Shift Lines Left';
                Image = PreviousRecord;
                Enabled = wanEnabled and (Rec."wan Indentation" > 0);
                trigger OnAction()
                var
                    Selection: Record "Purchase Line";
                begin
                    CurrPage.SetSelectionFilter(Selection);
                    wanIndentMgt.Shift(Selection, -1);
                end;
            }
            action(wanShiftRight)
            {
                ApplicationArea = All;
                Caption = ' ', Locked = true;
                ToolTip = 'Shift Lines Left';
                Image = NextRecord;
                Enabled = wanEnabled;
                trigger OnAction()
                var
                    Selection: Record "Purchase Line";
                begin
                    CurrPage.SetSelectionFilter(Selection);
                    wanIndentMgt.Shift(Selection, +1);
                end;
            }
        }
        addlast("F&unctions")
        {
            action(wanInsertTotalLines)
            {
                ApplicationArea = All;
                Caption = 'Insert Total Lines';
                Image = Totals;
                Enabled = wanEnabled;
                trigger OnAction()
                var
                    ConfirmLbl: Label 'Do you want to insert missing total line for each title line?';
                begin
                    if Confirm(ConfirmLbl, false) then
                        wanIndentMgt.InsertTotalLines(TotalPurchaseHeader);
                end;
            }
        }
    }
    var
        wanIndentMgt: Codeunit "wan Purch. Indent. Mgt.";
        wanEnabled: Boolean;
        wanIndentation: Integer;
        wanStyle: Text;

    trigger OnAfterGetRecord()
    begin
        wanEnabled := Rec.wanIsEnabled(CurrPage.Editable);
        wanStyle := Rec.wanStyle();
        wanIndentation := Rec.wanIndentation();
    end;
}
