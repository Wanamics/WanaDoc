permissionset 87303 "WanaDoc_EXCEL"
{
    Access = Internal;
    Assignable = true;
    Caption = 'WanaDoc Excel', Locked = true;
    Permissions =
        codeunit "wan Excel Extended Texts" = X,
        codeunit "wan Excel Purchase Lines" = X,
        codeunit "wan Excel Sales Lines" = X,
        codeunit "wan ExcelBuffer Events" = X,
        table "wan Excel Buffer Extended" = X,
        tabledata "wan Excel Buffer Extended" = RIMD;
}