namespace Wanamics.WanaDoc.Document;

using Wanamics.WanaDoc.MemoPad;
using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using Microsoft.Finance.VAT.Clause;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Item;
reportextension 87305 "wan Standard Sales Order Conf." extends "Standard Sales - Order Conf."
{
    dataset
    {
        add(Header)
        {
            column(wanCompanyAddress; CompanyAddress) { }
            column(wanCompanyContactInfo; CompanyContactInfo) { }
            column(wanCompanyLegalInfo; CompanyLegalInfo) { }
            column(wanSellToAddress_Lbl; DocumentHelper.iIf(SellToAddress <> '', SellToAddress_Lbl, '')) { }
            column(wanSellToAddress; SellToAddress) { }
            column(wanShipToAddress_Lbl; DocumentHelper.iIf(ShipToAddress <> '', ShipToAddress_Lbl, '')) { }
            column(wanShipToAddress; ShipToAddress) { }
            column(wanBillToAddress_Lbl; DocumentHelper.iIf(BillToAddress <> '', BillToAddress_Lbl, '')) { }
            column(wanBillToAddress; BillToAddress) { }
            column(wanOurAccountNo_Lbl; DocumentHelper.iif(Customer."Our Account No." = '', '', Customer.Fieldcaption("Our Account No."))) { }
            column(wanOurAccountNo; Customer."Our Account No.") { }
            column(wanVATClause; wanVATClause.Description) { }
            column(wanMailGreetingText; wanMailGreeting_Lbl) { }
            column(wanMailBodyText; wanMailBody_Lbl) { }
            column(wanMailClosingText; wanMailClosing_Lbl) { }
            column(wanReqDelivDate; DocumentHelper.FormatDate("Requested Delivery Date")) { }
            column(wanReqDelivDate_Lbl; DocumentHelper.iIf("Requested Delivery Date" = 0D, '', FieldCaption("Requested Delivery Date"))) { }
            column(wanPromDelivDate; DocumentHelper.FormatDate("Promised Delivery Date")) { }
            column(wanPromDelivDate_Lbl; DocumentHelper.iIf("Promised Delivery Date" = 0D, '', FieldCaption("Promised Delivery Date"))) { }
            column(wanVersion; DocumentHelper.GetVersion("No. of Archived Versions")) { }
            column(wanQuoteNo_Lbl; DocumentHelper.iIf("Quote No." = '', '', FieldCaption("Quote No."))) { }
            column(wanShipmentMethodDescription_Lbl; DocumentHelper.iIf(ShipmentMethod.Description = '', '', ShptMethodDescLbl)) { }
            column(wanRegistrationNo_Lbl; DocumentHelper.iIf("VAT Registration No." = '', '', FieldCaption("VAT Registration No."))) { }
        }
        modify(Header)
        {
            CalcFields = "No. of Archived Versions";
            trigger OnAfterAfterGetRecord()
            var
                VATPostingSetup: Record "VAT Posting Setup";
                wanLine: Record "Sales Line";
            begin
                AddressesHelper.SetHeaderAddresses(Header, SellToAddress, ShipToAddress, BillToAddress);
                if "Document Type" <> "Document Type"::Quote then
                    Customer.Get("Sell-to Customer No.");
                if VATPostingSetup.Get("VAT Bus. Posting Group", '') and (VATPostingSetup."VAT Clause Code" <> '') then
                    wanVATClause.Get(VATPostingSetup."VAT Clause Code")
                else
                    Clear(wanVATClause);
                wanTotalNetWeight := 0;
                wanPosition := 0;
                wanLine.SetRange("Document Type", "Document Type");
                wanLine.SetRange("Document No.", "No.");
                wanLine.SetFilter("Line Discount %", '<>0');
                wanHasLineDiscount := not wanLine.IsEmpty();
                CheckPromisedDeliveryAndShipmentDates(Header);
            end;
        }
        modify(Line)
        {
            trigger OnBeforePreDataItem()
            begin
                SetRange("Attached To Line No.", 0);
            end;

            trigger OnAfterAfterGetRecord()
            begin
                wanTotalNetWeight += "Net Weight" * Quantity;
                if Type <> Type::" " then
                    wanPosition += 1;
                wanMemo := GetMemo(Header, Line);
            end;
        }
        add(Line)
        {
            column(wanPosition; DocumentHelper.iif(Type <> Type::" ", format(wanPosition), '')) { }
            column(wanMemoPad; wanMemo) { }
            column(wanQuantity_UOM; wanQuantityUOM(Line)) { }
            column(wanLineDiscPercent; DocumentHelper.BlankZero("Line Discount %")) { }
            column(wanLineDiscPercent_Lbl; DocumentHelper.iIf(wanHasLineDiscount, format(FieldCaption("Line Discount %")), '')) { }
        }
        add(Totals)
        {
            column(wanTotalNetWeight; DocumentHelper.iIf(wanTotalNetWeight <> 0, StrSubstNo(wanTotalNetWeightLbl, wanTempItem.FieldCaption("Net Weight"), wanTotalNetWeight), '')) { }
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
            LayoutFile = './ReportLayouts/wanSalesOrderConf.docx';
            Caption = 'WanaDoc Sales Order Confirmation (Word)';
            Summary = 'The WanaDoc Sales Order Confirmation (Word) provides a detailed layout.';
        }
    }
    protected var
        MemoPad: Codeunit "wan MemoPad Sales";
        FormatAddress: Codeunit "Format Address";
        SellToAddress_Lbl: Label 'Sell-to';
        SellToAddress: Text;
        ShipToAddress_Lbl: Label 'Ship-to';
        ShipToAddress: Text;
        BillToAddress_Lbl: Label 'Bill-to';
        BillToAddress: Text;
        CompanyAddress: Text;
        CompanyContactInfo: Text;
        CompanyLegalInfo: Text;
        DocumentHelper: Codeunit "wan Document Helper";
        AddressesHelper: Codeunit "wan Sales Addresses Helper";
        Customer: Record Customer;
        wanVATClause: Record "VAT Clause";
        wanMailGreeting_Lbl: Label 'Dear customer';
        wanMailBody_Lbl: Label 'Thank you for your business. Your quote is attached to this message.';
        wanMailClosing_Lbl: Label 'Sincerely';
        wanMemo: Text;

    var
        wanTempItem: Record Item temporary;
        wanTotalNetWeight: Decimal;
        wanTotalNetWeightLbl: Label 'Total %1: %2', Comment = '%1:FieldCaption("Net Weight"), %2: TotalNetWeight';
        wanPosition: Integer;
        wanOptionLbl: Label '-';
        wanHasLineDiscount: Boolean;

    trigger OnPreReport()
    begin
        DocumentHelper.GetCompanyInfo(CompanyAddress, CompanyContactInfo, CompanyLegalInfo);
    end;

    local procedure GetMemo(pHeader: Record "Sales Header"; pLine: Record "Sales Line") ReturnValue: Text;
    var
        AttachedLines: Text;
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

    local procedure wanQuantityUOM(pLine: Record "Sales Line"): Text
    begin
        if pLine.Type = pLine.Type::" " then
            exit('');
        if pLine.Quantity = 0 then
            exit(pLine."Unit of Measure")
        else
            exit(DocumentHelper.iif(pLine.Type = pLine.Type::" ", '', Format(pLine.Quantity) + MemoPad.LineFeed() + pLine."Unit of Measure"));
    end;

    local procedure CheckPromisedDeliveryAndShipmentDates(pHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        CantBeGTLineErr: Label 'can''t be greater than the earliest one on outstanding sales lines';
    begin
        // pHeader.TestField("Shipment Date");
        // pHeader.TestField("Promised Delivery Date");
        if (pHeader."Shipment Date" = 0D) and (pHeader."Promised Delivery Date" = 0D) then
            exit;
        SalesLine.SetRange("Document Type", pHeader."Document Type");
        SalesLine.SetRange("Document No.", pHeader."No.");
        SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
        SalesLine.SetFilter("Outstanding Quantity", '>0');
        SalesLine.SetLoadFields("Promised Delivery Date", "Shipment Date");
        if SalesLine.FindSet() then
            repeat
                // if pHeader."Promised Delivery Date" <> 0D then
                if SalesLine."Promised Delivery Date" < pHeader."Promised Delivery Date" then
                    pHeader.FieldError("Promised Delivery Date", CantBeGTLineErr);
                // if pHeader."Shipment Date" <> 0D then
                if SalesLine."Shipment Date" < pHeader."Shipment Date" then
                    pHeader.FieldError("Shipment Date", CantBeGTLineErr);
            until SalesLine.Next() = 0;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetMemo(pHeader: Record "Sales Header"; pLine: Record "Sales Line"; var ReturnValue: Text)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterGetMemo(pHeader: Record "Sales Header"; pLine: Record "Sales Line"; var ReturnValue: Text)
    begin
    end;

    local procedure FetchContent(pPlaceHolder: Enum "wan Document Content Placement") ReturnValue: Text
    begin
        ReturnValue := DocumentHelper.Content(CurrReport.ObjectId(false), pPlaceHolder, Header."Language Code");
        OnAfterFetchContent(Header, pPlaceHolder, ReturnValue);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterFetchContent(pHeader: Record "Sales Header"; pPlaceHolder: Enum "wan Document Content Placement"; var ReturnValue: Text)
    begin
    end;
}
