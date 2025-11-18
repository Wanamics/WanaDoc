namespace Wanamics.WanaDoc.Document;

using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
codeunit 87304 "WanaDoc Sales Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeInitPostingDescription, '', false, false)]
    local procedure OnBeforeInitPostingDescription(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        IsHandled := SetPostingDescription(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterValidateEvent, "Sell-to Customer No.", false, false)]
    local procedure OnAfterValidateSellToCustomerNo(var Rec: Record "Sales Header"; xRec: Record "Sales Header")
    begin
        SetPostingDescription(Rec);
    end;

    local procedure SetPostingDescription(var SalesHeader: Record "Sales Header"): Boolean
    var
        Customer: Record Customer;
        PrepmtPostingDescriptionLbl: Label 'Prepayment %1', Comment = '%1:Vendor Name';
    begin
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"]) then
            exit;
        if SalesHeader."Sell-to Customer No." = '' then
            exit;
        Customer.Get(SalesHeader."Sell-to Customer No.");
        SalesHeader."Posting Description" := Customer.Name;
        SalesHeader."Prepmt. Posting Description" := CopyStr(StrSubstNo(PrepmtPostingDescriptionLbl, Customer.Name), 1, MaxStrLen(SalesHeader."Prepmt. Posting Description"));
        exit(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterValidateEvent, "No.", false, false)]
    local procedure OnAfterValidateEvent(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if (CurrFieldNo = Rec.FieldNo("No.")) and
            // not (Rec.Type in [Rec.Type::Item, Rec.Type::Resource]) and
            (Rec.Type = Rec.Type::"G/L Account") and
            (Rec.Quantity = 0) then
            Rec.Validate(Quantity, 1);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnUpdateSalesLinesByFieldNoOnAfterSalesLineSetFilters, '', false, false)]
    local procedure OnUpdateSalesLinesByFieldNoOnAfterSalesLineSetFilters(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ChangedFieldNo: Integer)
    begin
        SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
        SalesLine.SetRange("Attached to Line No.", 0);
    end;
}
