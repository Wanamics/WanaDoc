codeunit 87302 "wan Document Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Custom Report Selection", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomReportSelection(var Rec: Record "Custom Report Selection")
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange(Usage, Rec.Usage);
        if ReportSelections.FindFirst() then
            Rec."Report ID" := ReportSelections."Report ID";
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Pro Forma Inv", 'OnAfterLineOnPreDataItem', '', false, false)]
    local procedure OnAfterLineOnPreDataItem(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SalesLine.SetRange(Type); // Reset SetRange(Type, Type::Item)
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Pro Forma Inv", 'OnBeforeGetItemForRec', '', false, false)]
    local procedure OnBeforeGetItemForRec(ItemNo: Code[20]; var IsHandled: Boolean)
    var
        Item: Record Item;
    begin
        // Unfortunately, SalesLine is not a parm
        if not Item.Get(ItemNo) then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Invoice", 'OnBeforeGetDocumentCaption', '', false, false)]
    local procedure OnBeforeGetDocumentCaption(SalesInvoiceHeader: Record "Sales Invoice Header"; var DocCaption: Text)
    var
        PrepaymentInvoice: Label 'Prepayment Invoice';
    begin
        if SalesInvoiceHeader."Prepayment Invoice" then
            DocCaption := PrepaymentInvoice;
    end;
}
