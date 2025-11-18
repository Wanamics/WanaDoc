namespace Wanamics.WanaDoc.Prepayment;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Finance.ReceivablesPayables;
using Wanamics.WanaDoc.MemoPad;
using Microsoft.Foundation.ExtendedText;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Posting;
codeunit 87307 "wan Purch. Prepayment Events"
{
    Permissions = tabledata "Purch. Inv. Line" = im;

    var
        StatusCheckSuspended: Boolean;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeInsertEvent, '', false, false)]
    local procedure OnBeforeInsertHeader(var Rec: Record "Purchase Header")
    begin
        Rec."Compress Prepayment" := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeTestStatusOpen, '', false, false)]
    local procedure OnBeforeTestStatusOpen(var PurchaseLine: Record "Purchase Line"; var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean; xPurchaseLine: Record "Purchase Line"; CallingFieldNo: Integer /*; var StatusCheckSuspended: Boolean*/)
    begin
        if CallingFieldNo in [PurchaseLine.FieldNo("Prepayment %"), PurchaseLine.FieldNo("Prepayment Amount")] then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Prepayments", OnAfterCreateLinesOnBeforeGLPosting, '', false, false)]
    local procedure OnAfterCreateLinesOnBeforeGLPosting(var PurchaseHeader: Record "Purchase Header"; PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; var TempPrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer" temporary; DocumentType: Option; var LastLineNo: Integer)
    var
        FromLine: Record "Purchase Line";
        ToLine: Record "Purch. Inv. Line";
    begin
        if PurchaseHeader."Compress Prepayment" or (PurchInvHeader."No." = '') then
            exit;
        FromLine.SetRange("Document Type", PurchaseHeader."Document Type");
        FromLine.SetRange("Document No.", PurchaseHeader."No.");
        if FromLine.FindSet() then
            repeat
                if ToLine.Get(PurchInvHeader."No.", FromLine."Line No.") then begin
                    SetPrepaymentFields(FromLine, ToLine);
                    ToLine.Modify(false)
                end else begin
                    ToLine.TransferFields(FromLine);
                    ToLine."Document No." := PurchInvHeader."No.";
                    ToLine."Line No." := FromLine."Line No.";
                    if FromLine.Type <> FromLine.Type::" " then begin
                        ToLine.Type := ToLine.Type::"G/L Account";
                        ToLine."No." := '';
                        ToLine.Quantity := 1;
                        ToLine."Direct Unit Cost" := 0;
                        ToLine."Line Amount" := 0;
                        ToLine."VAT %" := 0;
                        ToLine.Amount := 0;
                        ToLine."VAT Difference" := 0;
                        ToLine."Amount Including VAT" := 0;
                        ToLine."VAT Calculation Type" := ToLine."VAT Calculation Type"::"Normal VAT";
                        ToLine."VAT Base Amount" := 0;
                        ToLine."VAT Identifier" := '';
                        SetPrepaymentFields(FromLine, ToLine);
                    end;
                    ToLine.Insert(false);
                end;
            until FromLine.Next() = 0;
    end;

    local procedure SetPrepaymentFields(pLine: Record "Purchase Line"; var pInvoiceLine: Record "Purch. Inv. Line")
    begin
        pInvoiceLine."Unit of Measure" := pLine."Unit of Measure";
        pInvoiceLine."wan Order Quantity" := pLine.Quantity;
        pInvoiceLine."wan Order Amount" := pLine."Line Amount";
        pInvoiceLine."wan Prepayment %" := pLine."Prepayment %";
        pInvoiceLine."wan Prepmt. Line Amount" := pLine."Prepmt. Line Amount";
        pInvoiceLine."wan Prepmt. Amt. Inv." := pLine."Prepmt. Amt. Inv.";
        pInvoiceLine."wan Prepmt. Amt. Incl. VAT" := pLine."Prepmt. Amt. Incl. VAT";
        pInvoiceLine."wan Prepmt. Amount Inv. (LCY)" := pLine."Prepmt. Amount Inv. (LCY)";
        pInvoiceLine."wan Prepmt. VAT Amt. Inv.(LCY)" := pLine."Prepmt. VAT Amount Inv. (LCY)";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Prepayments", OnAfterPurchInvHeaderInsert, '', false, false)]
    local procedure OnAfterPurchInvHeaderInsert(var PurchInvHeader: Record "Purch. Inv. Header"; PurchHeader: Record "Purchase Header"; CommitIsSupressed: Boolean)
    begin
        PurchInvHeader."wan Compress Prepayment" := PurchHeader."Compress Prepayment";
    end;

    // OnBeforeSalesLineByChangedFieldNo to not have a Purchase equivalent
    // [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeSalesLineByChangedFieldNo, '', false, false)]
    // local procedure OnBeforePurchaseLineByChangedFieldNo(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; ChangedFieldNo: Integer; var IsHandled: Boolean; xPurchaseHeader: Record "Purchase Header")
    // begin
    //     if ChangedFieldNo = PurchaseHeader.FieldNo("Prepayment %") then
    //         PurchaseLine.SuspendStatusCheck(true);
    // end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeUpdatePrepmtSetupFields, '', false, false)]

    local procedure OnBeforeUpdatePrepmtSetupFields(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean /*; CurrentFieldNo: Integer*/)
    /*
    var
        VATPostingSetup: Record "VAT Posting Setup";
    */
    begin
        // Handle PurchaseLine.UpdatePrepmtSetupFields() to inherit VAT % from Line (not from VATPostingSetup)
        if (PurchaseLine."Prepayment %" <> 0) and (PurchaseLine.Type <> PurchaseLine.Type::" ") then begin
            PurchaseLine.TestField("Document Type", PurchaseLine."Document Type"::Order);
            PurchaseLine.TestField("No.");
            /*
            if CurrentFieldNo = PurchaseLine.FieldNo("Prepayment %") then
                if PurchaseLine."System-Created Entry" and not PurchaseLine.IsServiceChargeLine() then
                    exit;
            */
            /* TODO or not TODO ?
            Autre solution ?
            * utiliser un GCM TVA distinct selon que les acomptes sont ou non soumis à TVA
              et si pas de GCP TVA sur le compte acompte défini en PostingSetup appliquer à l'acompte la TVA de la ligne
            
            VATPostingSetup.SetLoadFields("Unrealized VAT Type");
            if VATPostingSetup.Get(PurchaseLine."VAT Bus. Posting Group", PurchaseLine."VAT Prod. Posting Group") and
                (VATPostingSetup."Unrealized VAT Type" = VATPostingSetup."Unrealized VAT Type"::" ") then
                exit;
            */
            if PurchaseLine."System-Created Entry" /*and not PurchaseLine.IsServiceChargeLine()*/ then
                PurchaseLine."Prepayment %" := 0;
            PurchaseLine."Prepayment VAT %" := PurchaseLine."VAT %";
            PurchaseLine."Prepmt. VAT Calc. Type" := PurchaseLine."VAT Calculation Type";
            PurchaseLine."Prepayment VAT Identifier" := PurchaseLine."VAT Identifier";
            if PurchaseLine."Prepmt. VAT Calc. Type" in
               [PurchaseLine."Prepmt. VAT Calc. Type"::"Reverse Charge VAT", PurchaseLine."Prepmt. VAT Calc. Type"::"Sales Tax"]
            then
                PurchaseLine."Prepayment VAT %" := 0;
            PurchaseLine."Prepayment Tax Group Code" := PurchaseLine."Tax Group Code";
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Prepayments", OnAfterPurchInvLineInsert, '', false, false)]
    local procedure OnAfterPurchaseInvLineInsert(var PurchInvLine: Record "Purch. Inv. Line"; PurchInvHeader: Record "Purch. Inv. Header"; PrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        MemoPad: Codeunit "wan MemoPad Purchase";
        TempExtendedTextLine: Record "Extended Text Line" temporary;
        Item: Record Item;
        ExtendedLine: Record "Purch. Inv. Line";
    begin
        if PurchInvHeader."wan Compress Prepayment" then
            exit;
        PurchaseHeader.Get(PurchaseLine."Document Type"::Order, PurchInvHeader."Prepayment Order No.");
        PurchaseLine.Get(PurchaseLine."Document Type"::Order, PurchInvHeader."Prepayment Order No.", PrepmtInvLineBuffer."Line No.");
        ExtendedLine."Document No." := PurchInvLine."Document No.";
        ExtendedLine."Line No." := PurchInvLine."Line No.";
        ExtendedLine."Attached to Line No." := PurchInvLine."Line No.";
        MemoPad.GetExtendedTextLines(PurchaseHeader, PurchaseLine, TempExtendedTextLine);
        if TempExtendedTextLine.FindSet() then
            repeat
                ExtendedLine."Line No." += 1;
                ExtendedLine.Description := TempExtendedTextLine.Text;
                ExtendedLine.Insert();
            until TempExtendedTextLine.Next() = 0;
        PurchInvLine."Line No." := ExtendedLine."Line No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnCreatePrepaymentLinesOnBeforeInsertedPrepmtVATBaseToDeduct, '', false, false)]
    local procedure OnCreatePrepaymentLinesOnBeforeInsertedPrepmtVATBaseToDeduct(var TempPrepmtPurchLine: Record "Purchase Line" temporary; var PurchaseHeader: Record "Purchase Header"; var TempPurchaseLine: Record "Purchase Line" temporary)
    begin
        if PurchaseHeader."Compress Prepayment" then
            exit;
        TempPrepmtPurchLine.Validate("VAT Prod. Posting Group", TempPurchaseLine."VAT Prod. Posting Group");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Prepayments", OnBeforePurchInvLineInsert, '', false, false)]
    local procedure OnBeforePurchInvLineInsert(var PurchInvLine: Record "Purch. Inv. Line"; PurchInvHeader: Record "Purch. Inv. Header"; PrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer"; CommitIsSupressed: Boolean)
    begin
        if PurchInvHeader."wan Compress Prepayment" then
            exit;
        PurchInvLine."Line No." := PrepmtInvLineBuffer."Line No.";
    end;
}
