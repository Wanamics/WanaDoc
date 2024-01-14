page 87301 "wan Document Contents"
{
    ApplicationArea = All;
    Caption = 'Document Contents';
    PageType = List;
    SourceTable = "wan Document Content";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Report ID"; Rec."Report ID")
                {
                    ToolTip = 'Specifies the value of the Report ID field.';
                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Report Caption");
                    end;
                }
                field("Report Caption"; Rec."Report Caption")
                {
                    ToolTip = 'Specifies the value of the Report Caption field.';
                }
                field(Placement; Rec.Placement)
                {
                    ToolTip = 'Specifies the value of the Placement field.';
                }
                field("Language Code"; Rec."Language Code")
                {
                    ToolTip = 'Specifies the value of the Language Code field.';
                }
            }
            group(RichTextGroup)
            {
                ShowCaption = false;

                field(RichText; RichText)
                {
                    Caption = 'Content';
                    MultiLine = true;
                    // ExtendedDatatype = RichContent;

                    trigger OnValidate()
                    begin
                        SetContent();
                    end;
                }
            }
        }
    }
    var
        RichText: Text;

    trigger OnAfterGetRecord()
    begin
        GetContent();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(RichText);
    end;

    local procedure GetContent()
    var
        RichTextInS: InStream;
    begin
        Rec.CalcFields("Content");
        Rec."Content".CreateInStream(RichTextInS, TextEncoding::UTF8);
        RichTextInS.Read(RichText);
    end;

    local procedure SetContent()
    var
        RichTextOutS: OutStream;
    begin
        Rec."Content".CreateOutStream(RichTextOutS, TextEncoding::UTF8);
        RichTextOutS.Write(RichText);
        Rec.Modify(true);
    end;
}
