namespace Wanamics.WanaProj.BlkOrderLines;

using Microsoft.Sales.Document;
using Microsoft.Utilities;
page 87390 "wan Sales BlkOrder Lookup"
{
    Caption = 'Sales Blanket Orders';
    DataCaptionFields = "Document Type";
    ApplicationArea = All;
    Editable = false;
    PageType = List;
    SourceTable = "Sales Header";

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                }
                field("External Document No."; Rec."External Document No.")
                {
                }
                field("Your Reference"; Rec."Your Reference")
                {
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    Visible = false;
                }
                field("Bill-to Name"; Rec."Bill-to Name")
                {
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    Visible = false;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    Visible = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    Visible = false;
                }
                field("Document Date"; Rec."Document Date")
                {
                }
                field("Due Date"; Rec."Due Date")
                {
                }
                field(Status; Rec.Status)
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(ShowDocument)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Document';
                    Image = EditLines;
                    ShortCutKey = 'Return';

                    trigger OnAction()
                    var
                        PageManagement: Codeunit "Page Management";
                    begin
                        PageManagement.PageRun(Rec);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ShowDocument_Promoted; ShowDocument)
                {
                }
            }
        }
    }
}
