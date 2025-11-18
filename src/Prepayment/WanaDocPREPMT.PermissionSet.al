permissionset 87305 "WanaDoc_PREPMT"
{
    Access = Internal;
    Assignable = true;
    Caption = 'WanaDoc Prepayment', Locked = true;
    Permissions =
        codeunit "wan Purch. Prepayment Events" = X,
        codeunit "wan Sales Prepayment Events" = X;
}