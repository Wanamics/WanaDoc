namespace Wanamics.WanaDoc.Prepayment;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Finance.ReceivablesPayables;
using Wanamics.WanaDoc.MemoPad;
using Microsoft.Foundation.ExtendedText;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Posting;
codeunit 87300 "wan Sales Prepayment Events"
{
    Permissions = tabledata "Sales invoice Line" = im;

    var
        StatusCheckSuspended: Boolean;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertHeader(var Rec: Record "Sales Header")
    begin
        Rec."Compress Prepayment" := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeTestStatusOpen', '', false, false)]
    local procedure OnBeforeTestStatusOpen(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; xSalesLine: Record "Sales Line"; CallingFieldNo: Integer; var StatusCheckSuspended: Boolean)
    begin
        if CallingFieldNo in [SalesLine.FieldNo("Prepayment %"), SalesLine.FieldNo("Prepayment Amount")] then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnAfterCreateLinesOnBeforeGLPosting', '', false, false)]
    local procedure OnAfterCreateLinesOnBeforeGLPosting(var SalesHeader: Record "Sales Header"; SalesInvHeader: Record "Sales Invoice Header"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempPrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer" temporary; DocumentType: Option; var LastLineNo: Integer)
    var
        FromLine: Record "Sales Line";
        ToLine: Record "Sales Invoice Line";
    begin
        if SalesHeader."Compress Prepayment" or (SalesInvHeader."No." = '') then
            exit;
        FromLine.SetRange("Document Type", SalesHeader."Document Type");
        FromLine.SetRange("Document No.", SalesHeader."No.");
        if FromLine.FindSet() then
            repeat
                if ToLine.Get(SalesInvHeader."No.", FromLine."Line No.") then begin
                    SetPrepaymentFields(FromLine, ToLine);
                    ToLine.Modify(false)
                end else begin
                    ToLine.TransferFields(FromLine);
                    ToLine."Document No." := SalesInvHeader."No.";
                    ToLine."Line No." := FromLine."Line No.";
                    if FromLine.Type <> FromLine.Type::" " then begin
                        ToLine.Type := ToLine.Type::"G/L Account";
                        ToLine."No." := '';
                        ToLine.Quantity := 1;
                        ToLine."Unit Price" := 0;
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

    local procedure SetPrepaymentFields(pLine: Record "Sales Line"; var pInvoiceLine: Record "Sales Invoice Line")
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnAfterSalesInvHeaderInsert', '', false, false)]
    local procedure OnAfterSalesInvHeaderInsert(var SalesInvoiceHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean)
    begin
        SalesInvoiceHeader."wan Compress Prepayment" := SalesHeader."Compress Prepayment";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeSalesLineByChangedFieldNo', '', false, false)]
    local procedure OnBeforeSalesLineByChangedFieldNo(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ChangedFieldNo: Integer; var IsHandled: Boolean; xSalesHeader: Record "Sales Header")
    begin
        if ChangedFieldNo = SalesHeader.FieldNo("Prepayment %") then
            SalesLine.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeUpdatePrepmtSetupFields', '', false, false)]

    local procedure OnBeforeUpdatePrepmtSetupFields(var SalesLine: Record "Sales Line"; var IsHandled: Boolean; CurrentFieldNo: Integer)
    /*
    var
        VATPostingSetup: Record "VAT Posting Setup";
    */
    begin
        // Handle SalesLine.UpdatePrepmtSetupFields() to inherit VAT % from Line (not from VATPostingSetup)
        if (SalesLine."Prepayment %" <> 0) and (SalesLine.Type <> SalesLine.Type::" ") then begin
            SalesLine.TestField("Document Type", SalesLine."Document Type"::Order);
            SalesLine.TestField("No.");
            if CurrentFieldNo = SalesLine.FieldNo("Prepayment %") then
                if SalesLine."System-Created Entry" and not SalesLine.IsServiceChargeLine() then
                    exit;
            /* TODO or not TODO ?
            Autre solution ?
            * utiliser un GCM TVA distinct selon que les acomptes sont ou non soumis à TVA
              et si pas de GCP TVA sur le compte acompte défini en PostingSetup appliquer à l'acompte la TVA de la ligne
            
            VATPostingSetup.SetLoadFields("Unrealized VAT Type");
            if VATPostingSetup.Get(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group") and
                (VATPostingSetup."Unrealized VAT Type" = VATPostingSetup."Unrealized VAT Type"::" ") then
                exit;
            */
            if SalesLine."System-Created Entry" and not SalesLine.IsServiceChargeLine() then
                SalesLine."Prepayment %" := 0;
            SalesLine."Prepayment VAT %" := SalesLine."VAT %";
            SalesLine."Prepmt. VAT Calc. Type" := SalesLine."VAT Calculation Type";
            SalesLine."Prepayment VAT Identifier" := SalesLine."VAT Identifier";
            if SalesLine."Prepmt. VAT Calc. Type" in
               [SalesLine."Prepmt. VAT Calc. Type"::"Reverse Charge VAT", SalesLine."Prepmt. VAT Calc. Type"::"Sales Tax"]
            then
                SalesLine."Prepayment VAT %" := 0;
            SalesLine."Prepayment Tax Group Code" := SalesLine."Tax Group Code";
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnAfterSalesInvLineInsert', '', false, false)]
    local procedure OnAfterSalesInvLineInsert(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; PrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer"; CommitIsSuppressed: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        MemoPad: Codeunit "wan MemoPad Sales";
        TempExtendedTextLine: Record "Extended Text Line" temporary;
        Item: Record Item;
        ExtendedLine: Record "Sales invoice Line";
    begin
        if SalesInvHeader."wan Compress Prepayment" then
            exit;
        SalesHeader.Get(SalesLine."Document Type"::Order, SalesInvHeader."Prepayment Order No.");
        SalesLine.Get(SalesLine."Document Type"::Order, SalesInvHeader."Prepayment Order No.", PrepmtInvLineBuffer."Line No.");
        ExtendedLine."Document No." := SalesInvLine."Document No.";
        ExtendedLine."Line No." := SalesInvLine."Line No.";
        ExtendedLine."Attached to Line No." := SalesInvLine."Line No.";
        MemoPad.GetExtendedTextLines(SalesHeader, SalesLine, TempExtendedTextLine);
        if TempExtendedTextLine.FindSet() then
            repeat
                ExtendedLine."Line No." += 1;
                ExtendedLine.Description := TempExtendedTextLine.Text;
                ExtendedLine.Insert();
            until TempExtendedTextLine.Next() = 0;
        SalesInvLine."Line No." := ExtendedLine."Line No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnCreatePrepaymentLinesOnBeforeInsertedPrepmtVATBaseToDeduct', '', false, false)]
    local procedure OnCreatePrepaymentLinesOnBeforeInsertedPrepmtVATBaseToDeduct(var TempPrepmtSalesLine: Record "Sales Line" temporary; var SalesHeader: Record "Sales Header"; var TempSalesLine: Record "Sales Line" temporary)
    begin
        if SalesHeader."Compress Prepayment" then
            exit;
        TempPrepmtSalesLine.Validate("VAT Prod. Posting Group", TempSalesLine."VAT Prod. Posting Group");
    end;
}
