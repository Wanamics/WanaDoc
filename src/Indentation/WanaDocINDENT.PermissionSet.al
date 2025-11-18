permissionset 87301 "WanaDoc_INDENT"
{
    Access = Internal;
    Assignable = true;
    Caption = 'WanaDoc Indent', Locked = true;
    Permissions =
        tabledata "wan Indentation Setup" = R,
        table "wan Indentation Setup" = X,
        page "wan Indentation Setup" = X,
        codeunit "wan Indent Helper" = X,
        codeunit "wan Purch. Indent. Mgt." = X,
        codeunit "wan Sales Indent. Mgt." = X;
}