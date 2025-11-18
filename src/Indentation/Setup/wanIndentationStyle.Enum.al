namespace Wanamics.WanaDoc.Indentation;

enum 87301 "wan Indentation Style"
{
    Extensible = true;
    Caption = 'Indentation Style';

    value(0; None)
    {
        Caption = 'None', Locked = true;
    }
    value(1; Standard)
    {
        Caption = 'Standard', Locked = true;
    }
    value(2; StandardAccent) // blue
    {
        Caption = 'StandardAccent', Locked = true;
    }
    value(3; Strong) // bold
    {
        Caption = 'Strong', Locked = true;
    }
    value(4; StrongAccent) // blue + bold
    {
        Caption = 'StrongAccent', Locked = true;
    }
    value(5; Attention) // red + italic
    {
        Caption = 'Attention', Locked = true;
    }
    value(6; AttentionAccent) // blue + italic
    {
        Caption = 'AttentionAccent', Locked = true;
    }
    value(7; Favorable) // green + bold
    {
        Caption = 'Favorable', Locked = true;
    }
    value(8; Unfavorable) // red + italic + bold
    {
        Caption = 'Unfavorable', Locked = true;
    }
    value(9; Ambiguous) // yellow
    {
        Caption = 'Ambiguous', Locked = true;
    }
    value(10; Subordinate) // yellow + italic
    {
        Caption = 'Subordinate', Locked = true;
    }
}
