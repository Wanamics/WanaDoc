namespace Wanamics.WanaDoc.Document;

using Microsoft.Sales.History;
using Microsoft.Sales.Customer;
using Microsoft.Finance.VAT.Clause;
using Microsoft.Finance.VAT.Setup;
using System.Text;
using Microsoft.Foundation.Address;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Foundation.ExtendedText;
using Wanamics.WanaDoc.MemoPad;
reportextension 87307 "wan Standard Sales - Cr. Memo" extends "Standard Sales - Credit Memo"
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
            column(wanExternalDocumentNo_Lbl; DocumentHelper.iif("External Document No." = '', '', Fieldcaption("External Document No."))) { }
            column(wanVATClause; wanVATClause.Description) { }
            column(wanLatePaymentClause; wanLatePaymentClause) { }
            column(wanPaymentMethodText; DocumentHelper.PaymentMethodText("Language Code", "Payment Method Code", "Company Bank Account Code", "Bill-to Customer No.", '')) { }
            column(wanColumn1_Lbl; wanColumn_Lbl[1]) { }
            column(wanColumn2_Lbl; wanColumn_Lbl[2]) { }
            column(wanColumn3_Lbl; wanColumn_Lbl[3]) { }
            column(wanYourReference_Lbl; DocumentHelper.iif("Your Reference" = '', '', FieldCaption("Your Reference"))) { }
            // column(wanOrderNo_Lbl; DocumentHelper.iIf("Order No." = '', '', FieldCaption("Order No."))) { }
        }
        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            var
                VATPostingSetup: Record "VAT Posting Setup";
                wanLine: Record "Sales Invoice Line";
            begin
                AddressesHelper.SetCrMemoAddresses(Header, SellToAddress, ShipToAddress, BillToAddress);
                Customer.Get("Sell-to Customer No.");
                if "Prepayment Credit Memo" then begin
                    wanColumn_Lbl[1] := Line.FieldCaption("wan Order Amount"); //+ MemoPad.LineFeed() + Line.FieldCaption("wan Order Quantity");
                    wanColumn_Lbl[2] := Line.FieldCaption("wan Prepmt. Line Amount"); //+ MemoPad.LineFeed + Line.FieldCaption("wan Prepayment %");
                    wanColumn_Lbl[3] := Line.FieldCaption("wan Prepmt. Amt. Inv.");
                    Clear(wanTotal);
                end else begin
                    wanColumn_Lbl[1] := Line.FieldCaption(Quantity) + MemoPad.LineFeed() + Line.FieldCaption("Unit of Measure");
                    wanColumn_Lbl[2] := Line.FieldCaption("Unit Price");
                    wanLine.SetRange("Document No.", "No.");
                    wanLine.SetFilter("Line Discount %", '<>0');
                    wanHasLineDiscount := not wanLine.IsEmpty();
                    wanColumn_Lbl[3] := DocumentHelper.iIf(wanHasLineDiscount, Line.FieldCaption("Line Discount %"), '');
                end;
                if VATPostingSetup.Get("VAT Bus. Posting Group", '') and (VATPostingSetup."VAT Clause Code" <> '') then
                    wanVATClause.Get(VATPostingSetup."VAT Clause Code")
                else
                    Clear(wanVATClause);
                wanPosition := 0;
                if Header."Gen. Bus. Posting Group" <> wanGenBusPostingGroup.Code then
                    if wanGenBusPostingGroup.Get(Header."Gen. Bus. Posting Group") then
                        wanLatePaymentClause := GetExtendedText(Header."Posting Date", Header."Language Code", wanGenBusPostingGroup."wan Late Payment Text Code")
                    else
                        Clear(wanLatePaymentClause);
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
                case true of
                    Type = Type::" ":
                        begin
                            wanColumn[1] := '';
                            wanColumn[2] := '';
                            wanColumn[3] := '';
                        end;
                    Header."Prepayment Credit memo" /*and not Header."wan Compress Prepayment"*/:
                        begin
                            wanColumn[1] := DocumentHelper.BlankZero("wan order Amount", wanAutoFormat::AmountFormat, Header."Currency Code") + MemoPad.LineFeed + Format("wan Order Quantity") + ' ' + "Unit of Measure";
                            wanColumn[2] := DocumentHelper.BlankZero("wan Prepmt. Line Amount", wanAutoFormat::AmountFormat, Header."Currency Code") + MemoPad.LineFeed + DocumentHelper.BlankZeroPercent("wan Prepayment %");
                            wanColumn[3] := DocumentHelper.BlankZero("wan Prepmt. Amt. Inv.", wanAutoFormat::AmountFormat, Header."Currency Code");
                            wanTotal[1] += "wan order Amount";
                            wanTotal[2] += "wan Prepmt. Line Amount";
                            wanTotal[3] += "wan Prepmt. Amt. Inv.";
                        end;
                    else
                        wanColumn[1] := DocumentHelper.BlankZero("Quantity") + MemoPad.LineFeed + "Unit of Measure";
                        wanColumn[2] := DocumentHelper.BlankZero("Unit price", wanAutoFormat::UnitAmountFormat, Header."Currency Code");
                        wanColumn[3] := DocumentHelper.BlankZero("Line Discount %");
                end;
            end;
        }
        add(Line)
        {
            column(wanPosition; DocumentHelper.iif(Type <> Type::" ", format(wanPosition), '')) { }
            column(wanMemoPad; wanMemo) { }
            column(wanQuantity_UOM; DocumentHelper.iif(Line.Type = Line.Type::" ", '', Format(Line.Quantity) + MemoPad.LineFeed + Line."Unit of Measure")) { }
            column(wanColumn1; wanColumn[1]) { }
            column(wanColumn2; wanColumn[2]) { }
            column(wanColumn3; wanColumn[3]) { }
            column(wanLineDiscPercent; DocumentHelper.BlankZero("Line Discount %")) { }
            column(wanLineDiscPercent_Lbl; DocumentHelper.iIf(wanHasLineDiscount, format(FieldCaption("Line Discount %")), '')) { }
        }
        add(ReportTotalsLine)
        {
            column(wanTotal1; DocumentHelper.BlankZero(wanTotal[1], wanAutoFormat::AmountFormat, Header."Currency Code")) { }
            column(wanTotal2; DocumentHelper.BlankZero(wanTotal[2], wanAutoFormat::AmountFormat, Header."Currency Code")) { }
            column(wanTotal3; DocumentHelper.BlankZero(wanTotal[3], wanAutoFormat::AmountFormat, Header."Currency Code")) { }
        }
        modify(ReportTotalsLine)
        {
            trigger OnAfterAfterGetRecord()
            begin
                if ReportTotalsLine."Line No." > 1 then
                    clear(wanTotal);
            end;
        }
        add(LetterText)
        {
            column(wanBeginningContent; FetchContent(enum::"wan Document Content Placement"::Beginning)) { }
            column(wanEndingContent; FetchContent(enum::"wan Document Content Placement"::Ending)) { }
        }
    }
    rendering
    {
        layout(WanaDocSalesInvoice)
        {
            Type = Word;
            LayoutFile = './ReportLayouts/wanSalesCrMemo.docx';
            Caption = 'WanaDoc Sales Cr. Memo (Word)';
            Summary = 'The WanaDoc Sales Cr. Memo (Word) provides a detailed layout.';
        }
    }
    protected var
        MemoPad: Codeunit "wan MemoPad Sales Cr. Memo";
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
        wanMailGreeting_Lbl: Label 'Dear customer',;
        wanMailBody_Lbl: Label 'Thank you for your business. Your invoice is attached to this message.';
        wanMailClosing_Lbl: Label 'Sincerely';
        wanMemo: Text;
        wanPosition: Integer;
        wanColumn_Lbl: array[3] of Text;
        wanColumn: array[3] of Text;
        wanTotal: array[3] of Decimal;
        wanAutoFormat: Enum "Auto Format";
        wanGenBusPostingGroup: Record "Gen. Business Posting Group";
        wanLatePaymentClause: Text;
        wanHasLineDiscount: Boolean;

    trigger OnPreReport()
    begin
        DocumentHelper.GetCompanyInfo(CompanyAddress, CompanyContactInfo, CompanyLegalInfo);
    end;

    local procedure GetMemo(pHeader: Record "Sales Cr.Memo Header"; pLine: Record "Sales Cr.Memo Line") ReturnValue: Text;
    var
        AttachedLines: Text;
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ReturnValue := pLine.Description;
        OnBeforeGetMemo(pHeader, pLine, ReturnValue);
        if pLine.Type = pLine.Type::Item then begin
            ReturnValue += DocumentHelper.ItemReferences(pLine."No.", pLine."Item Reference No.");
            ReturnValue += DocumentHelper.Tariff(pLine."No.", pHeader."Ship-to Country/Region Code");
            DocumentHelper.TrackingLines(ItemLedgerEntry."Document Type"::"Sales Return Receipt".AsInteger(), pLine."Return Receipt No.", pLine."Return Receipt Line No.");
        end;
        AttachedLines := MemoPad.GetAttachedLines(pLine);
        if AttachedLines = '' then
            AttachedLines := MemoPad.GetExtendedText(pHeader, pLine);
        if AttachedLines <> '' then
            ReturnValue += MemoPad.LineFeed() + AttachedLines;
        OnAfterGetMemo(pHeader, pLine, ReturnValue);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetMemo(pHeader: Record "Sales Cr.Memo Header"; pLine: Record "Sales Cr.Memo Line"; var ReturnValue: Text)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterGetMemo(pHeader: Record "Sales Cr.Memo Header"; pLine: Record "Sales Cr.Memo Line"; var ReturnValue: Text)
    begin
    end;

    local procedure GetExtendedText(pDate: date; pLanguageCode: Code[10]; pNo: Code[20]) ReturnValue: text;
    var
        ETH: Record "Extended Text Header";
        ETL: Record "Extended Text Line" temporary;
        TransferExtendedText: Codeunit "Transfer Extended Text";
    begin
        ETH.SetRange("Table Name", ETH."Table Name"::"Standard Text");
        ETH.SetRange("No.", pNo);
        TransferExtendedText.ReadExtTextLines(ETH, pDate, pLanguageCode);
        TransferExtendedText.GetTempExtTextLine(ETL);
        if ETL.FindSet() then begin
            repeat
                ReturnValue += ETL.Text;
            Until ETL.Next() = 0;
        end;
    end;


    local procedure FetchContent(pPlaceHolder: Enum "wan Document Content Placement") ReturnValue: Text
    begin
        ReturnValue := DocumentHelper.Content(CurrReport.ObjectId(false), pPlaceHolder, Header."Language Code");
        OnAfterFetchContent(Header, pPlaceHolder, ReturnValue);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterFetchContent(pHeader: Record "Sales Cr.Memo Header"; pPlaceHolder: Enum "wan Document Content Placement"; var ReturnValue: Text)
    begin
    end;
}