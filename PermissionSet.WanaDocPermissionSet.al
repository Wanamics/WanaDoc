permissionset 87010 "WanaDoc"
{
    Assignable = true;
    Caption = 'WanaDoc Permission Set';
    Permissions =
        table "wan Excel Buffer Extended" = X,
        codeunit "wan MemoPad Purchase" = X,
        codeunit "wan MemoPad Sales" = X,
        codeunit "wan MemoPad Management" = X,
        codeunit wanExcelBufferEvents = X,
        codeunit "wan Excel Purchase Lines" = X,
        codeunit "wan Excel Sales Lines" = X,
        page "wan MemoPad" = X,
        page "wan Reminder Level" = X;
}