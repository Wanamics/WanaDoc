namespace Wanamics.WanaDoc.Indentation;
using Microsoft.Sales.Document;

codeunit 87305 "wan Indent Helper"
{
    procedure TitleCode(): Code[20]
    begin
        exit('§');
    end;

    procedure TotalCode(): Code[20]
    begin
        exit('=');
    end;

    procedure IsTitle(pType: enum "Sales Line Type"; pCode: Code[20]): Boolean
    begin
        exit((pType = pType::" ") and (pCode = TitleCode()));
    end;

    procedure IsTotal(pType: enum "Sales Line Type"; pCode: Code[20]): Boolean
    begin
        exit((pType = pType::" ") and (pCode = TotalCode()));
    end;

    procedure Style(pType: enum "Sales Line Type"; pCode: Code[20]): Text
    begin
        if IsTitle(pType, pCode) then
            exit('StrongAccent');
        if IsTotal(pType, pCode) then
            exit('StandardAccent');
        exit('None');
        // 0: None
        // 1: Standard
        // 2: StandardAccent // Blue
        // 3: Strong
        // 4: StrongAccent // Blue + Bold
        // 5: Attention // Red + Italic
        // 6: AttentionAccent // Blue + Italic
        // 7: Favorable // Green + Bold
        // 8: Unfavorable// Red + Italic + Bold
        // 9: Ambiguous // Yellow
        // 10:Subordinate// Yellow + Italic
    end;
}
