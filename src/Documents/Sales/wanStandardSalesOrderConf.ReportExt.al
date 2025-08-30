namespace Wanamics.WanaDoc.Document;

using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using Microsoft.Finance.VAT.Clause;
using Microsoft.Finance.VAT.Setup;
using Wanamics.WanaDoc.MemoPad;
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
            column(wanReqDelivDate_Lbl; FieldCaption("Requested Delivery Date")) { }
            column(wanPromDelivDate; DocumentHelper.FormatDate("Promised Delivery Date")) { }
            column(wanPromDelivDate_Lbl; FieldCaption("Promised Delivery Date")) { }
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
                if "Document Type" <> "Document Type"::Quote then
                    Customer.Get("Sell-to Customer No.");
                if VATPostingSetup.Get("VAT Bus. Posting Group", '') and (VATPostingSetup."VAT Clause Code" <> '') then
                    wanVATClause.Get(VATPostingSetup."VAT Clause Code")
                else
                    Clear(wanVATClause);
                wanPosition := 0;
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
            column(wanLineAmountOrOption; DocumentHelper.iif(Type = Type::" ", '', DocumentHelper.iIf(Quantity = 0, wanOptionLbl, format("Line Amount")))) { }
        }
        add(LetterText)
        {
            column(wanBeginningContent; DocumentHelper.Content(CurrReport.ObjectId(false), enum::"wan Document Content Placement"::Beginning, Header."Language Code")) { }
            column(wanEndingContent; DocumentHelper.Content(CurrReport.ObjectId(false), enum::"wan Document Content Placement"::Ending, Header."Language Code")) { }
        }
    }
    rendering
    {
        layout("StandardSalesQuote.rdlc")
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
        Customer: Record Customer;
        wanVATClause: Record "VAT Clause";
        wanMailGreeting_Lbl: Label 'Dear customer',;
        wanMailBody_Lbl: Label 'Thank you for your business. Your quote is attached to this message.';
        wanMailClosing_Lbl: Label 'Sincerely';
        wanMemo: Text;
        wanPosition: Integer;
        wanOptionLbl: Label '-';

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
        if pLine.Quantity = 0 then
            exit(pLine."Unit of Measure")
        else
            exit(DocumentHelper.iif(pLine.Type = pLine.Type::" ", '', Format(pLine.Quantity) + MemoPad.LineFeed() + pLine."Unit of Measure"));
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetMemo(pHeader: Record "Sales Header"; pLine: Record "Sales Line"; var ReturnValue: Text)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterGetMemo(pHeader: Record "Sales Header"; pLine: Record "Sales Line"; var ReturnValue: Text)
    begin
    end;
}