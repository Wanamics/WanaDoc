namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Sales.Document;

pageextension 87310 "wan Sales Quote Indent" extends "Sales Quote Subform"
{
    layout
    {
        modify(Control1)
        {
            IndentationControls = Description;
            IndentationColumn = wanIndentation;
        }
        // addfirst(Control1)
        // {
        //     field(LineNo; Rec."Line No.")
        //     {
        //         ApplicationArea = All;
        //     }
        //     field(Indentation; Rec."wan Indentation")
        //     {
        //         ApplicationArea = All;
        //     }
        // }
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
                    wanIndentMgt: Codeunit "wan Sales Indent. Mgt.";
                    Selection: Record "Sales Line";
                begin
                    CurrPage.SetSelectionFilter(Selection);
                    wanIndentMgt.Shift(Selection, -1);
                end;
            }
            action(wanShiftRight)
            {
                ApplicationArea = All;
                Caption = ' ', Locked = true;
                ToolTip = 'Shift Lines Right';
                Image = NextRecord;
                Enabled = wanEnabled;
                trigger OnAction()
                var
                    wanIndentMgt: Codeunit "wan Sales Indent. Mgt.";
                    Selection: Record "Sales Line";
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
                    wanIndentMgt: Codeunit "wan Sales Indent. Mgt.";
                    ConfirmLbl: Label 'Do you want to insert missing total line for each title line?';
                begin
                    if Confirm(ConfirmLbl, false) then
                        wanIndentMgt.InsertTotalLines(TotalSalesHeader);
                end;
            }
        }
    }
    var
        wanEnabled: Boolean;
        wanIndentation: Integer;
        wanStyle: Text;

    trigger OnAfterGetRecord()
    begin
        wanEnabled := Rec.wanIsEnabled(CurrPage.Editable);
        wanStyle := Rec.wanStyle();
        wanIndentation := Rec."wan Indentation";
    end;
}
