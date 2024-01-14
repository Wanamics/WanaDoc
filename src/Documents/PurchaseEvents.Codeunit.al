codeunit 87303 "WanaDoc Purchase Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeInitPostingDescription, '', false, false)]
    local procedure OnBeforeInitPostingDescription(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        IsHandled := SetPostingDescription(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnAfterValidateEvent, 'Buy-from Vendor No.', false, false)]
    local procedure OnAfterValidateBuyFromVendorNo(var Rec: Record "Purchase Header"; xRec: Record "Purchase Header")
    begin
        SetPostingDescription(Rec);
    end;

    local procedure SetPostingDescription(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        Vendor: Record Vendor;
        PrepmtPostingDescriptionLbl: Label 'Prepayment %1', Comment = '%1:Vendor Name';
    begin
        if not (PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Invoice, PurchaseHeader."Document Type"::"Credit Memo"]) then
            exit;
        if PurchaseHeader."Buy-from Vendor No." = '' then
            exit;
        Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
        PurchaseHeader."Posting Description" := Vendor.Name;
        PurchaseHeader."Prepmt. Posting Description" := CopyStr(StrSubstNo(PrepmtPostingDescriptionLbl, Vendor.Name), 1, MaxStrLen(PurchaseHeader."Prepmt. Posting Description"));
        exit(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterValidateEvent, 'No.', false, false)]
    local procedure OnAfterValidateEvent(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if (CurrFieldNo = Rec.FieldNo("No.")) and
            not (Rec.Type in [Rec.Type::Item, Rec.Type::Resource]) and
            (Rec.Quantity = 0) then
            Rec.Validate(Quantity, 1);
    end;
}
