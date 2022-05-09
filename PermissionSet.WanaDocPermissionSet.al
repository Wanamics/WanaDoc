permissionset 87010 "WanaDoc"
{
    Assignable = true;
    Caption = 'WanaDoc Permission Set';
    Permissions =
        codeunit "wan MemoPad Purchase" = X,
        codeunit "wan MemoPad Sales" = X,
        codeunit "wan MemoPad Management" = X,
        page "wan MemoPad" = X,
        page "wan Reminder Level" = X;
}