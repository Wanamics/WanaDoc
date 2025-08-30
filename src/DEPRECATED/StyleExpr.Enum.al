#if FALSE
namespace Wanamics.WanaDoc.Indentation;

enum 87301 StyleExpr
{
    Extensible = true;
    
    value(0; None)
    {
        Caption = 'None';
    }
    value(1; Standard)
    {
        Caption = 'Standard';
    }
    value(2; StandardAccent) // Blue
    {
        Caption = 'Standard Accent';
    }
    value(3; Strong)
    {
        Caption = 'Strong';
    } 
    value(4; StrongAccent) // Blue + Bold
    {
        Caption = 'Strong Accent';
    }
    value(5; Attention) // Red + Italic
    {
        Caption = 'Attention';
    }
    value(6; AttentionAccent) // Blue + Italic
    {
        Caption = 'Attention Accent';
    }
    value(7; Favorable)// Green + Bold
    {
        Caption = 'Favorable';
    }
    value(8; Unfavorable)// Red + Italic + Bold
    {
        Caption = 'Unfavorable';
    }
    value(9; Ambiguous)// Yellow
    {
        Caption = 'Ambiguous';
    }
    value(10; Subordinate)// Yellow + Italic
    {
        Caption = 'Subordinate';
    }   
}
#endif
