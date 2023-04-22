permissionset 87310 "WanaDoc"
{
    Assignable = true;
    Caption = 'WanaDoc';
    Permissions = //table "wan Excel Buffer Extended" = X,
        codeunit "wan MemoPad Purchase" = X,
        codeunit "wan MemoPad Sales" = X,
        codeunit "wan MemoPad Management" = X,
        codeunit "wan ExcelBuffer Events" = X,
        codeunit "wan Excel Purchase Lines" = X,
        codeunit "wan Excel Sales Lines" = X,
        page "wan MemoPad" = X,
        page "wan Reminder Level" = X,
        tabledata "wan Excel Buffer Extended" = RIMD,
        report "wan Purchase - Blanket Order" = X,
        report "wan Purchase - Quote" = X,
        codeunit "wan Document Events" = X,
        codeunit "wan Document Helper" = X,
        codeunit "wan Excel Extended Texts" = X,
        codeunit "wan MemoPad Purch. Cr. Memo" = X,
        codeunit "wan MemoPad Purchase Invoice" = X,
        codeunit "wan MemoPad Sales Cr. Memo" = X,
        codeunit "wan MemoPad Sales Invoice" = X,
        codeunit "wan MemoPad Sales Shipment" = X,
        codeunit "wan Sales Prepayment Events" = X,
        table "wan Excel Buffer Extended" = X;
}