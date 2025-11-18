permissionset 87302 "WanaDoc_MEMOPAD"
{
    Access = Internal;
    Assignable = true;
    Caption = 'WanaDoc MemoPad', Locked = true;
    Permissions =
        codeunit "wan MemoPad Management" = X,
        codeunit "wan MemoPad Purch. Cr. Memo" = X,
        codeunit "wan MemoPad Purchase" = X,
        codeunit "wan MemoPad Purchase Invoice" = X,
        codeunit "wan MemoPad Sales" = X,
        codeunit "wan MemoPad Sales Cr. Memo" = X,
        codeunit "wan MemoPad Sales Invoice" = X,
        codeunit "wan MemoPad Sales Shipment" = X,
        page "wan MemoPad" = X,
        report "WanaDoc MemoPad Attach Purch." = X,
        report "WanaDoc MemoPad Attach Sales" = X,
        report "WanaDoc MemoPad Set ExtText LF" = X,
        report "WanaDoc MemoPad Set Purch. LF" = X,
        report "WanaDoc MemoPad Set Sales LF" = X;
}