reportextension 87304 "Standard Sales - Quote" extends "Standard Sales - Quote"
{
    dataset
    {

        add(Header)
        {
            column(wanCompanyAddress; CompanyAddress) { }
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
            column(wanMailGreetingText; wanMailGreeting_Lbl) { }
            column(wanMailBodyText; wanMailBody_Lbl) { }
            column(wanMailClosingText; wanMailClosing_Lbl) { }
            column(wanReqDelivDate; DocumentHelper.FormatDate(Header."Requested Delivery Date")) { }
            column(wanReqDelivDate_Lbl; Header.FieldCaption("Requested Delivery Date")) { }
            column(wanPromDelivDate; DocumentHelper.FormatDate(Header."Promised Delivery Date")) { }
            column(wanPromDelivDate_Lbl; Header.FieldCaption("Promised Delivery Date")) { }
            column(wanVersion; DocumentHelper.GetVersion("No. of Archived Versions")) { }
            column(wanVATClause; wanVATClause.Description) { }
        }
        modify(Header)
        {
            CalcFields = "No. of Archived Versions";
            trigger OnAfterAfterGetRecord()
            var
                VATPostingSetup: Record "VAT Posting Setup";
            begin
                DocumentHelper.SetSalesHeaderAddresses(Header, SellToAddress, ShipToAddress, BillToAddress);
                if Header."Document Type" <> Header."Document Type"::Quote then
                    Customer.Get("Sell-to Customer No.");
                if VATPostingSetup.Get("VAT Bus. Posting Group", '') and (VATPostingSetup."VAT Clause Code" <> '') then
                    wanVATClause.Get(VATPostingSetup."VAT Clause Code")
                else
                    Clear(wanVATClause);
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
        }
    }
    var
        MemoPad: Codeunit "wan MemoPad Sales";
        FormatAddress: Codeunit "Format Address";
        SellToAddress_Lbl: TextConst ENU = 'Sell-to', FRA = 'Donneur d''ordre';
        SellToAddress: Text;
        ShipToAddress_Lbl: TextConst ENU = 'Ship-to', FRA = 'Livraison';
        ShipToAddress: Text;
        BillToAddress_Lbl: TextConst ENU = 'Bill-to', FRA = 'Facturation';
        BillToAddress: Text;
        CompanyAddress: Text;
        CompanyContactInfo: Text;
        CompanyLegalInfo: Text;
        DocumentHelper: Codeunit "wan Document Helper";
        Customer: Record Customer;
        wanMailGreeting_Lbl: TextConst ENU = 'Dear customer', FRA = 'Cher client,';
        wanMailBody_Lbl: TextConst ENU = 'Thank you for your business. Your quote is attached to this message.', FRA = 'Ci-joint le devis suivant :';
        wanMailClosing_Lbl: TextConst ENU = 'Sincerely', FRA = 'Bonne réception.';
        wanVATClause: Record "VAT Clause";

    trigger OnPreReport()
    begin
        DocumentHelper.GetCompanyInfo(CompanyAddress, CompanyContactInfo, CompanyLegalInfo);
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