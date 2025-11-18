namespace Wanamics.WanaDoc.Document;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.VAT.Clause;
using Microsoft.Finance.VAT.Setup;
using Wanamics.WanaDoc.MemoPad;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Item;
reportextension 87322 "wan Standard Purchase - Order" extends "Standard Purchase - Order"
{
    dataset
    {
        add("Purchase Header")
        {
            column(wanCompanyAddress; CompanyAddress) { }
            column(wanCompanyContactInfo; CompanyContactInfo) { }
            column(wanCompanyLegalInfo; CompanyLegalInfo) { }
            column(wanBuyFromAddress_Lbl; DocumentHelper.iIf(BuyFromAddress <> '', BuyFromAddress_Lbl, '')) { }
            column(wanBuyFromAddress; BuyFromAddress) { }
            column(wanShipToAddress_Lbl; DocumentHelper.iIf(ShipToAddress <> '', ShipToAddress_Lbl, '')) { }
            column(wanShipToAddress; ShipToAddress) { }
            column(wanPayToAddress_Lbl; DocumentHelper.iIf(PayToAddress <> '', PayToAddress_Lbl, '')) { }
            column(wanPayToAddress; PayToAddress) { }
            column(wanRequestedReceiptDate; DocumentHelper.FormatDate("Requested Receipt Date")) { }
            column(wanOurAccountNo; Vendor."Our Account No.") { }
            column(wanVATClause; wanVATClause.Description) { }
            column(wanMailGreetingText; wanMailGreeting_Lbl) { }
            column(wanMailBodyText; wanMailBody_Lbl) { }
            column(wanMailClosingText; wanMailClosing_Lbl) { }
            // column(wanReqDelivDate; DocumentHelper.FormatDate("Purchase Header"."Requested Delivery Date")) { }
            // column(wanReqDelivDate_Lbl; FieldCaption("Requested Delivery Date")) { }
            // column(wanPromDelivDate; DocumentHelper.FormatDate("Purchase Header"."Promised Delivery Date")) { }
            // column(wanPromDelivDate_Lbl; FieldCaption("Promised Delivery Date")) { }
            column(wanVersion; DocumentHelper.GetVersion("No. of Archived Versions")) { }
        }
        modify("Purchase Header")
        {
            CalcFields = "No. of Archived Versions";
            trigger OnAfterAfterGetRecord()
            var
                VATPostingSetup: Record "VAT Posting Setup";
                wanPurchaseLine: Record "Purchase Line";
                wanAddressesHelper: Codeunit "wan Purch. Addresses Helper";
            begin
                wanAddressesHelper.SetHeaderAddresses("Purchase Header", BuyFromAddress, ShipToAddress, PayToAddress);
                if "Purchase Header"."Document Type" <> "Purchase Header"."Document Type"::Quote then
                    Vendor.Get("Buy-from Vendor No.");
                if VATPostingSetup.Get("VAT Bus. Posting Group", '') and (VATPostingSetup."VAT Clause Code" <> '') then
                    wanVATClause.Get(VATPostingSetup."VAT Clause Code")
                else
                    Clear(wanVATClause);
                wanPosition := 0;

                wanPurchaseLine.SetRange("Document Type", "Document Type");
                wanPurchaseLine.SetRange("Document No.", "No.");
                wanPurchaseLine.SetFilter("Line Discount %", '<>0');
                wanHasLineDiscount := not wanPurchaseLine.IsEmpty();
            end;
        }
        modify("Purchase Line")
        {
            trigger OnBeforePreDataItem()
            begin
                SetRange("Attached To Line No.", 0);
            end;

            trigger OnAfterAfterGetRecord()
            begin
                if Type <> Type::" " then
                    wanPosition += 1;
                wanMemo := GetMemo("Purchase Header", "Purchase Line");
            end;
        }
        add("Purchase Line")
        {
            column(wanPosition; DocumentHelper.iif(Type <> Type::" ", format(wanPosition), '')) { }
            column(wanMemoPad; wanMemo) { }
            column(wanQuantity_UOM; wanQuantityUOM("Purchase Line")) { }
            column(wanVATPercent; DocumentHelper.iIf(Type = Type::" ", '', format("Purchase Line"."VAT %"))) { }
            column(wanVATPercent_lbl; "Purchase Line".fieldcaption("VAT %")) { }
            column(wanLineDiscPercent; DocumentHelper.BlankZero("Purchase Line"."Line Discount %")) { }
            column(wanLineDiscPercentTitle; DocumentHelper.iIf(wanHasLineDiscount, format("Purchase Line".FieldCaption("Line Discount %")), '')) { }
        }
        add(LetterText)
        {
            column(wanBeginningContent; FetchContent(enum::"wan Document Content Placement"::Beginning)) { }
            column(wanEndingContent; FetchContent(enum::"wan Document Content Placement"::Ending)) { }
        }
    }
    rendering
    {
        layout(WanaDoc)
        {
            Type = Word;
            LayoutFile = './ReportLayouts/wanPurchaseOrder.docx';
            Caption = 'WanaDoc Purchase Order (Word)';
            Summary = 'The WanaDoc Purchase Order (Word) provides a detailed layout.';
        }
    }
    protected var
        MemoPad: Codeunit "wan MemoPad Purchase";
        FormatAddress: Codeunit "Format Address";
        BuyFromAddress_Lbl: Label 'Buy-from';
        BuyFromAddress: Text;
        ShipToAddress_Lbl: Label 'Ship-to';
        ShipToAddress: Text;
        PayToAddress_Lbl: Label 'Pay-to';
        PayToAddress: Text;
        CompanyAddress: Text;
        CompanyContactInfo: Text;
        CompanyLegalInfo: Text;
        DocumentHelper: Codeunit "wan Document Helper";
        Vendor: Record Vendor;
        wanVATClause: Record "VAT Clause";
        wanMailGreeting_Lbl: Label 'Dear vendor';
        wanMailBody_Lbl: Label 'Please find enclosed an order, to which we kindly ask you to acknowledge receipt as soon as possible.';
        wanMailClosing_Lbl: Label 'Sincerely';
        wanMemo: Text;
        wanPosition: Integer;
        // wanOptionLbl: Label '-';
        wanHasLineDiscount: Boolean;

    trigger OnPreReport()
    begin
        DocumentHelper.GetCompanyInfo(CompanyAddress, CompanyContactInfo, CompanyLegalInfo);
    end;

    local procedure GetMemo(pHeader: Record "Purchase Header"; pLine: Record "Purchase Line") ReturnValue: Text;
    var
        AttachedLines: Text;
        Item: Record Item;
    begin
        ReturnValue := pLine.Description;
        OnBeforeGetMemo(pHeader, pLine, ReturnValue);
        if pLine.Type = pLine.Type::Item then begin
            ReturnValue += DocumentHelper.ItemReferences(pLine."No.", pLine."Item Reference No.");
            ReturnValue += DocumentHelper.Tariff(pLine."No.", pHeader."Ship-to Country/Region Code");
        end;
        AttachedLines := MemoPad.GetAttachedLines(pLine);
        if AttachedLines = '' then
            AttachedLines := MemoPad.GetExtendedText(pHeader, pLine);
        if AttachedLines <> '' then
            ReturnValue += MemoPad.LineFeed() + AttachedLines;
        OnAfterGetMemo(pHeader, pLine, ReturnValue);
    end;

    local procedure wanQuantityUOM(pLine: Record "Purchase Line"): Text
    begin
        if pLine.Quantity = 0 then
            exit(pLine."Unit of Measure")
        else
            exit(DocumentHelper.iif(pLine.Type = pLine.Type::" ", '', Format(pLine.Quantity) + MemoPad.LineFeed + pLine."Unit of Measure"));
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetMemo(pHeader: Record "Purchase Header"; pLine: Record "Purchase Line"; var ReturnValue: Text)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterGetMemo(pHeader: Record "Purchase Header"; pLine: Record "Purchase Line"; var ReturnValue: Text)
    begin
    end;

    local procedure FetchContent(pPlaceHolder: Enum "wan Document Content Placement") ReturnValue: Text
    begin
        ReturnValue := DocumentHelper.Content(CurrReport.ObjectId(false), pPlaceHolder, "Purchase Header"."Language Code");
        OnAfterFetchContent("Purchase Header", pPlaceHolder, ReturnValue);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterFetchContent(pHeader: Record "Purchase Header"; pPlaceHolder: Enum "wan Document Content Placement"; var ReturnValue: Text)
    begin
    end;
}