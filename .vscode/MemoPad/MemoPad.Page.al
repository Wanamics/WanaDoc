page 87420 "wan MemoPad"
{
    Caption = 'MemoPad';
    DataCaptionExpression = gCaption;
    Editable = true;
    LinksAllowed = false;
    PageType = StandardDialog;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            grid(MemoPad)
            {
                field(Memo; Memo)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }

    var
        Memo: Text;
        gCaption: Text;

    procedure SetCaption(Value: Text)
    begin
        gCaption := Value;
    end;

    procedure SetText(Value: Text)
    begin
        Memo := Value;
    end;

    procedure GetText(): Text
    begin
        exit(Memo);
    end;
}