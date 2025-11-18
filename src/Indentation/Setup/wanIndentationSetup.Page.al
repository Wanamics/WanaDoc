namespace Wanamics.WanaDoc.Indentation;

page 87302 "wan Indentation Setup"
{
    ApplicationArea = All;
    Caption = 'WanaDoc Indentation Setup';
    PageType = Card;
    SourceTable = "wan Indentation Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Title Code"; Rec."Title Code")
                {
                    ToolTip = 'Specifies the value of the Title Code field.', Comment = '%';
                }
                field("Total Code"; Rec."Total Code")
                {
                    ToolTip = 'Specifies the value of the Total Code field.', Comment = '%';
                }
                field("Title Style"; Rec."Title Style")
                {
                    ToolTip = 'Specifies the value of the Title Style field.', Comment = '%';
                }
                field("Total Style"; Rec."Total Style")
                {
                    ToolTip = 'Specifies the value of the Total Style field.', Comment = '%';
                }
                field("Indent Width"; Rec."Indent Width")
                {
                    ToolTip = 'Specifies the value of the Indent Width field.', Comment = '%';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if Rec.IsEmpty then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}
