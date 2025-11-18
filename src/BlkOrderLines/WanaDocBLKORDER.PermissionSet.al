permissionset 87304 "WanaDoc_BLKORDER"
{
    Access = Internal;
    Assignable = true;
    Caption = 'WanaDoc Blank Order', Locked = true;
    Permissions =
        codeunit "wan Purch. BlkOrder Events" = X,
        codeunit "wan Purch. BlkOrder Copy Lines" = X,
        codeunit "wan Sales BlkOrder Events" = X,
        codeunit "wan Sales BlkOrder Copy Lines" = X,
        page "wan Purch. BlkOrder Lookup" = X,
        page "wan Sales BlkOrder Lookup" = X;
}