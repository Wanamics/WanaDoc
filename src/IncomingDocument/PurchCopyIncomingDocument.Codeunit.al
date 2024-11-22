namespace Wanamics.WanaDoc.IncomingDocument;
using Microsoft.EServices.EDocument;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Document;
using Microsoft.Inventory.Posting;

codeunit 87306 "wan Purch. Copy Incoming Doc."
{
    TableNo = "Incoming Document";
    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", OnAfterCreatePurchHeaderFromIncomingDoc, '', false, false)]
    local procedure OnAfterCreatePurchHeaderFromIncomingDoc(sender: Record "Incoming Document"; var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader.Validate("Buy-from Vendor No.", sender."Vendor No.");
        if sender."Posting Date" = 0D then
            PurchHeader.Validate("Posting Date", sender."Document Date")
        else
            PurchHeader.Validate("Posting Date", sender."Posting Date");
        PurchHeader.Validate("Document Date", sender."Document Date");
        PurchHeader.Validate("Due Date", sender."Due Date");
        If PurchHeader."Document Type" = PurchHeader."Document Type"::Invoice then begin
            PurchHeader.Validate("Vendor Invoice No.", sender."Vendor Invoice No.")
        end else begin
            PurchHeader.Validate("Vendor Cr. Memo No.", sender."Vendor Invoice No.");
        end;
        PurchHeader.Validate("Posting Description", sender.Description);
        PurchHeader.Validate("Vendor Order No.", sender."Order No.");
        if PurchHeader."Currency Code" <> sender."Currency Code" then
            PurchHeader.Validate("Currency Code", sender."Currency Code");
        PurchHeader.Validate("Posting Description", sender.Description);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnBeforePostPurchaseDoc, '', false, false)]
    local procedure OnBeforePostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean; var HideProgressWindow: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var IsHandled: Boolean)
    var
        IncomingDocument: Record "Incoming Document";
        TotalsMismatchErr: Label 'The credit memo cannot be posted because the total is different from the total on the related incoming document.';
    begin
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice then // Already checked by PurchaseInvoice.VerifyTotal
            exit;
        if not PurchaseHeader.IsTotalValid() then
            Error(TotalsMismatchErr);
    end;
}
