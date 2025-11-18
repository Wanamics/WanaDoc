permissionset 87300 "WanaDoc_REPORT"
{
    Access = Internal;
    Assignable = true;
    Caption = 'WanaDoc Report', Locked = true;
    Permissions =
        table "wan Document Content" = X,
        tabledata "wan Document Content" = RIMD,
        codeunit "wan Document Events" = X,
        codeunit "wan Document Helper" = X,
        codeunit "wan Purch. Prepayment Events" = X,
        codeunit "wan Sales Prepayment Events" = X,
        codeunit "WanaDoc Purchase Events" = X,
        codeunit "WanaDoc Sales Events" = X,
        page "wan Document Contents" = X,
        page "wan Reminder Level" = X,
        report "wan Purchase - Blanket Order" = X,
        report "wan Purchase - Quote" = X,
        report "wan Sales - Blanket Order" = X;
}