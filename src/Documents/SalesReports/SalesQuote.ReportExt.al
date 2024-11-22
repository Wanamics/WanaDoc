namespace Wanamics.WanaDoc.Document;

using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using Microsoft.Finance.VAT.Clause;
using Microsoft.Finance.VAT.Setup;
using Wanamics.WanaDoc.MemoPad;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Item;
reportextension 87304 "Standard Sales - Quote" extends "Standard Sales - Quote"
{
    WordLayout = './ReportLayouts/wanSalesQuote.docx';
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
            column(wanVATClause; wanVATClause.Description) { }
            column(wanMailGreetingText; wanMailGreeting_Lbl) { }
            column(wanMailBodyText; wanMailBody_Lbl) { }
            column(wanMailClosingText; wanMailClosing_Lbl) { }
            column(wanReqDelivDate; DocumentHelper.FormatDate(Header."Requested Delivery Date")) { }
            column(wanReqDelivDate_Lbl; Header.FieldCaption("Requested Delivery Date")) { }
            column(wanPromDelivDate; DocumentHelper.FormatDate(Header."Promised Delivery Date")) { }
            column(wanPromDelivDate_Lbl; Header.FieldCaption("Promised Delivery Date")) { }
            column(wanVersion; DocumentHelper.GetVersion("No. of Archived Versions")) { }
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
        add(LetterText)
        {
            column(wanBeginningContent; DocumentHelper.Content(CurrReport.ObjectId(false), enum::"wan Document Content Placement"::Beginning, Header."Language Code")) { }
            column(wanEndingContent; DocumentHelper.Content(CurrReport.ObjectId(false), enum::"wan Document Content Placement"::Ending, Header."Language Code")) { }
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
        CompanyAddress: Text;
        CompanyContactInfo: Text;
        CompanyLegalInfo: Text;
        DocumentHelper: Codeunit "wan Document Helper";
        Customer: Record Customer;
        wanVATClause: Record "VAT Clause";
        wanMailGreeting_Lbl: Label 'Dear customer',;
        wanMailBody_Lbl: Label 'Thank you for your business. Your quote is attached to this message.';
        wanMailClosing_Lbl: Label 'Sincerely';

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