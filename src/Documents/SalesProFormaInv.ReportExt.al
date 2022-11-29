reportextension 87302 "Standard Sales - Pro Forma Inv" extends "Standard Sales - Pro Forma Inv"
{
    WordLayout = './wanSalesProFormaInvoice.docx';
    dataset
    {
        add(Header)
        {
            column(wanCompanyAddress; wanCompanyAddress) { }
            column(wanCompanyContactInfo; CompanyContactInfo) { }
            column(wanCompanyLegalInfo; CompanyLegalInfo) { }
            column(wanSellToAddress_Lbl; SellToAddress_Lbl) { }
            column(wanSellToAddress; SellToAddress) { }
            column(wanShipToAddress_Lbl; ShipToAddress_Lbl) { }
            column(wanShipToAddress; ShipToAddress) { }
            column(wanBillToAddress_Lbl; BillToAddress_Lbl) { }
            column(wanBillToAddress; BillToAddress) { }
            column(wanOurAccountNo_Lbl; DocumentHelper.iif(Customer."Our Account No." = '', '', Customer.Fieldcaption("Our Account No."))) { }
            column(wanOurAccountNo; Customer."Our Account No.") { }
            column(wanMailGreetingLbl; wanMailGreeting_Lbl) { }
            column(wanMailBodyLbl; wanMailBody_Lbl) { }
            column(wanMailClosingLbl; wanMailClosing_Lbl) { }
            column(wanReqDelivDate; DocumentHelper.FormatDate(Header."Requested Delivery Date")) { }
            column(wanReqDelivDate_Lbl; Header.FieldCaption("Requested Delivery Date")) { }
            column(wanPromDelivDate; DocumentHelper.FormatDate(Header."Promised Delivery Date")) { }
            column(wanPromDelivDate_Lbl; Header.FieldCaption("Promised Delivery Date")) { }
            column(wanVersion; "No. of Archived Versions" + 1) { }
            column(wanVATClause; wanVATClause.Description) { }
            //+ from SalesOrderConf to inherit from the same layout
            column(Page_Lbl; Page_Lbl) { }
            column(SalesPersonText_Lbl; SalepersonPurchaser.TableCaption()) { }
            column(ShipmentMethodDescription_Lbl; ShipmentMethod.TableCaption()) { }
            column(PaymentTermsDescription_Lbl; PaymentTerms.TableCaption()) { }
            column(PaymentTermsDescription; PaymentTerms.Description) { }
            column(QuoteNo_Lbl; FieldCaption("Quote No.")) { }
            column(YourReference_Lbl; FieldCaption("Your Reference")) { }
            column(VATRegistrationNo_Lbl; FieldCaption("VAT Registration No.")) { }
            column(QuoteNo; "Quote No.") { }
            column(VATRegistrationNo; "VAT Registration No.") { }
            column(CompanyLegalStatement; '') { }
            column(Invoice_Lbl; Invoice_Lbl) { }
        }
        modify(Header)
        {
            CalcFields = "No. of Archived Versions";
            trigger OnAfterAfterGetRecord()
            var
                VATPostingSetup: Record "VAT Posting Setup";
            begin
                DocumentHelper.SetSalesHeaderAddresses(Header, SellToAddress, ShipToAddress, BillToAddress);
                Customer.Get("Sell-to Customer No.");
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
                CalcFields("Work Description");
                ShowWorkDescription := "Work Description".HasValue;
                //[
                if VATPostingSetup.Get("VAT Bus. Posting Group", '') and (VATPostingSetup."VAT Clause Code" <> '') then
                    wanVATClause.Get(VATPostingSetup."VAT Clause Code")
                else
                    Clear(wanVATClause);
                //]
            end;
        }
        modify(Line)
        {
            trigger OnBeforePreDataItem()
            begin
                SetRange("Attached To Line No.", 0);
            end;
        }
        add(Line)
        {
            column(wanMemoPad; GetMemo(Header, Line)) { }
            column(wanQuantity_UOM; DocumentHelper.iif(Line.Type = Line.Type::" ", '', Format(Line.Quantity) + MemoPad.LineFeed + Line."Unit of Measure")) { }
            //+ from SalesOrderConf to inherit from the same layout
            column(Description_Line_Lbl; FieldCaption(Description)) { }
            column(Quantity_Line_Lbl; FieldCaption(Quantity)) { }
            column(UnitPrice_Lbl; FieldCaption("Unit Price")) { }
            column(LineAmount_Line_Lbl; FieldCaption("Line Amount")) { }
            column(VATPct_Line_Lbl; FieldCaption("VAT %")) { }
            column(UnitPrice; "Unit Price") { }
            column(LineDiscountPercentText_Line; FieldCaption("Line Discount %")) { }
            column(LineAmount_Line; DocumentHelper.iIf(Type = Type::" ", '', Format("Line Amount"))) { }
            column(VATPct_Line; DocumentHelper.BlankZero("VAT %")) { }
        }
        addlast(Header)
        {
            //+ Copy from StandardSalesOrderConf report
            dataitem(WorkDescriptionLines; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 .. 99999));
                column(WorkDescriptionLineNumber; Number)
                {
                }
                column(WorkDescriptionLine; WorkDescriptionLine)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if WorkDescriptionInstream.EOS then
                        CurrReport.Break();
                    WorkDescriptionInstream.ReadText(WorkDescriptionLine);
                end;

                trigger OnPostDataItem()
                begin
                    Clear(WorkDescriptionInstream)
                end;

                trigger OnPreDataItem()
                begin
                    if not ShowWorkDescription then
                        CurrReport.Break();
                    Header."Work Description".CreateInStream(WorkDescriptionInstream, TextEncoding::UTF8);
                end;
            }
        }
    }
    var
        MemoPad: Codeunit "wan MemoPad Sales";
        FormatAddress: Codeunit "Format Address";
        SellToAddress_Lbl: Label 'Sell-to';
        SellToAddress: Text;
        ShipToAddress_Lbl: Label 'Ship-to';
        ShipToAddress: Text;
        BillToAddress_Lbl: Label 'Bill-to';
        BillToAddress: Text;
        wanCompanyAddress: Text;
        CompanyContactInfo: Text;
        CompanyLegalInfo: Text;
        DocumentHelper: Codeunit "wan Document Helper";
        Customer: Record Customer;
        wanMailGreeting_Lbl: Label 'Dear customer';
        wanMailBody_Lbl: Label 'Thank you for your business. Our order confirmation is attached to this message.';
        wanMailClosing_Lbl: Label 'Sincerely';

        wanVATClause: Record "VAT Clause";
        Invoice_Lbl: Label 'Proforma invoice';
        Page_Lbl: Label 'Page';
        SalepersonPurchaser: Record "Salesperson/Purchaser";
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        WorkDescriptionInstream: InStream;
        WorkDescriptionLine: Text;
        ShowWorkDescription: Boolean;

    trigger OnPreReport()
    begin
        DocumentHelper.GetCompanyInfo(wanCompanyAddress, CompanyContactInfo, CompanyLegalInfo);
    end;

    local procedure GetMemo(pHeader: Record "Sales Header"; pLine: Record "Sales Line") ReturnValue: Text;
    var
        AttachedLines: Text;
        Item: Record Item;
    begin
        ReturnValue := pLine.Description;
        OnBeforeGetMemo(pHeader, pLine, ReturnValue);
        if pLine.Type = pLine.Type::Item then begin
            ReturnValue += DocumentHelper.ItemReferences(pLine."No.", pLine."Item Reference No.");
            if pLine.Type = pLine.Type::Item then
                ReturnValue += DocumentHelper.Tariff(pLine."No.", pHeader."Ship-to Country/Region Code");
        end;
        AttachedLines := MemoPad.GetAttachedLines(pLine);
        if AttachedLines = '' then
            AttachedLines := MemoPad.GetExtendedText(pHeader, pLine);
        if AttachedLines <> '' then
            ReturnValue += MemoPad.LineFeed() + AttachedLines;
        OnAfterGetMemo(pHeader, pLine, ReturnValue);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetMemo(pHeader: Record "Sales Header"; pLine: Record "Sales Line"; var ReturnValue: Text)
    begin
    end;

    local procedure OnAfterGetMemo(pHeader: Record "Sales Header"; pLine: Record "Sales Line"; var ReturnValue: Text)
    begin
    end;
}

