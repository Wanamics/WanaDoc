namespace Wanamics.WanaDoc.Document;

using Wanamics.WanaDoc.MemoPad;
using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using Microsoft.Finance.VAT.Clause;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Item;
using System.Utilities;
using Microsoft.CRM.Team;
using Microsoft.Foundation.Shipping;
using Microsoft.Foundation.PaymentTerms;
reportextension 87302 "wan Standard Sales ProFormaInv" extends "Standard Sales - Pro Forma Inv"
{
    dataset
    {
        add(Header)
        {
            column(wanCompanyAddress; wanCompanyAddress) { }
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
            column(wanShipmentMethodDescription_Lbl; DocumentHelper.iIf(ShipmentMethod.Description = '', '', ShipmentMethod.TableCaption())) { }
            column(wanRegistrationNo_Lbl; DocumentHelper.iIf("VAT Registration No." = '', '', FieldCaption("VAT Registration No."))) { }
            //[+ from SalesOrderConf to inherit from the same layout
            column(Page_Lbl; Page_Lbl) { }
            column(SalesPersonText_Lbl; SalepersonPurchaser.TableCaption()) { }
            column(ShipmentMethodDescription_Lbl; DocumentHelper.iIf("Shipment Method Code" = '', '', ShipmentMethod.TableCaption())) { }
            column(PaymentTermsDescription_Lbl; PaymentTerms.TableCaption()) { }
            column(PaymentTermsDescription; PaymentTerms.Description) { }
            column(QuoteNo_Lbl; DocumentHelper.iIf("Quote No." = '', '', FieldCaption("Quote No."))) { }
            column(YourReference_Lbl; FieldCaption("Your Reference")) { }
            column(VATRegistrationNo_Lbl; FieldCaption("VAT Registration No.")) { }
            column(QuoteNo; "Quote No.") { }
            column(VATRegistrationNo; "VAT Registration No.") { }
            column(CompanyLegalStatement; '') { }
            column(Invoice_Lbl; Invoice_Lbl) { }

            // column(ShipToAddress_Lbl; ShiptoAddrLbl) { }
            // column(ShipToAddress1; ShipToAddr[1]) { }
            // column(ShipToAddress2; ShipToAddr[2]) { }
            // column(ShipToAddress3; ShipToAddr[3]) { }
            // column(ShipToAddress4; ShipToAddr[4]) { }
            // column(ShipToAddress5; ShipToAddr[5]) { }
            // column(ShipToAddress6; ShipToAddr[6]) { }
            // column(ShipToAddress7; ShipToAddr[7]) { }
            // column(ShipToAddress8; ShipToAddr[8]) { }
            //]
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
                //[+ from SalesOrderConf to inherit from the same layout
                if not SalepersonPurchaser.Get("Salesperson Code") then
                    SalepersonPurchaser.Init();
                if ShipmentMethod.Get("Shipment Method Code") then
                    ShipmentMethod.TranslateDescription(ShipmentMethod, "Language Code")
                else
                    ShipmentMethod.Init();
                if PaymentTerms.Get("Payment Terms Code") then
                    PaymentTerms.TranslateDescription(PaymentTerms, "Language Code")
                else
                    PaymentTerms.Init();
                FormatAddr.SalesHeaderShipTo(ShipToAddr, CustomerAddress, Header);
                //]
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
            //[+ from SalesOrderConf to inherit from the same layout
            column(Description_Line_Lbl; FieldCaption(Description)) { }
            column(Quantity_Line_Lbl; FieldCaption(Quantity)) { }
            column(UnitOfMeasure; "Unit of Measure") { }
            column(UnitOfMeasure_Lbl; FieldCaption("Unit of Measure")) { }
            column(UnitPrice_Lbl; FieldCaption("Unit Price")) { }
            column(LineAmount_Line_Lbl; FieldCaption("Line Amount")) { }
            column(LineAmount_Line; DocumentHelper.iIf(Type = Type::" ", '', Format("Line Amount"))) { }
            column(VATPct_Line_Lbl; FieldCaption("VAT %")) { }
            column(UnitPrice; "Unit Price") { }
            column(VATPct_Line; DocumentHelper.BlankZero("VAT %")) { }
            //]
        }

        add(Totals)
        {
            column(wanTotalNetWeight; DocumentHelper.iIf(wanTotalNetWeight <> 0, StrSubstNo(wanTotalNetWeightLbl, wanTempItem.FieldCaption("Net Weight"), wanTotalNetWeight), '')) { }
        }
        addbefore(Totals)
        {
            dataitem(LetterText; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                // column(wanBeginningContent; DocumentHelper.Content(CurrReport.ObjectId(false), enum::"wan Document Content Placement"::Beginning, Header."Language Code")) { }
                // column(wanEndingContent; DocumentHelper.Content(CurrReport.ObjectId(false), enum::"wan Document Content Placement"::Ending, Header."Language Code")) { }
                column(wanBeginningContent; FetchContent(enum::"wan Document Content Placement"::Beginning)) { }
                column(wanEndingContent; FetchContent(enum::"wan Document Content Placement"::Ending)) { }
            }
        }
    }
    rendering
    {
        layout(WanaDocProFormaInv)
        {
            Type = Word;
            LayoutFile = './ReportLayouts/wanSalesProFormaInvoice.docx';
            Caption = 'WanaDoc Pro Forma Invoice (Word)';
            Summary = 'The WanaDoc Pro Forma Invoice (Word) provides a detailed layout.';
        }
    }
    var
        MemoPad: Codeunit "wan MemoPad Sales";
        FormatAddr: Codeunit "Format Address";
        SellToAddress_Lbl: Label 'Sell-to';
        SellToAddress: Text;
        ShipToAddress_Lbl: Label 'Ship-to';
        ShipToAddress: Text;
        BillToAddress_Lbl: Label 'Bill-to';
        BillToAddress: Text;
        wanCompanyAddress: Text; // CompanyAddress defined in "Standard Sales - Pro Forma Inv" as : array[8] of Text[100];
        CompanyContactInfo: Text;
        CompanyLegalInfo: Text;
        DocumentHelper: Codeunit "wan Document Helper";
        AddressesHelper: Codeunit "wan Sales Addresses Helper";
        Customer: Record Customer;
        wanVATClause: Record "VAT Clause";
        wanMailGreeting_Lbl: Label 'Dear customer';
        wanMailBody_Lbl: Label 'Thank you for your business. Our order confirmation is attached to this message.';
        wanMailClosing_Lbl: Label 'Sincerely';
        wanMemo: Text;
        //[+ from SalesOrderConf to inherit from the same layout
        Invoice_Lbl: Label 'Proforma invoice';
        Page_Lbl: Label 'Page';
        ShiptoAddrLbl: Label 'Ship-to Address';
        SalepersonPurchaser: Record "Salesperson/Purchaser";
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        ShipToAddr: array[8] of Text[100];
    //]

    var
        wanTempItem: Record Item temporary;
        wanTotalNetWeight: Decimal;
        wanTotalNetWeightLbl: Label 'Total %1: %2', Comment = '%1:FieldCaption("Net Weight"), %2: TotalNetWeight';
        wanPosition: Integer;
        wanOptionLbl: Label '-';
        wanHasLineDiscount: Boolean;

    trigger OnPreReport()
    begin
        DocumentHelper.GetCompanyInfo(wanCompanyAddress, CompanyContactInfo, CompanyLegalInfo);
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

    //[
    local procedure wanShipToCountryName(): Text
    var
        CountryRegion: Record "Country/Region";
    begin
        if Header."Ship-to Country/Region Code" = '' then
            CountryRegion.Code := CompanyInformation."Country/Region Code"
        else
            CountryRegion.Code := Header."Ship-to Country/Region Code";
        if CountryRegion.Get(CountryRegion.Code) then
            exit(CountryRegion.Name);
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
