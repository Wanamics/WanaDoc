reportextension 87306 "Standard Sales - Invoice" extends "Standard Sales - Invoice"
{
    WordLayout = './ReportLayouts/wanSalesInvoice.docx';
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
            column(wanExternalDocumentNo_Lbl; DocumentHelper.iif("External Document No." = '', '', Fieldcaption("External Document No."))) { }
            column(wanVATClause; wanVATClause.Description) { }
            column(wanLatePaymentClause; wanLatePaymentClause) { }
            column(wanPaymentMethodText; DocumentHelper.PaymentMethodText("Language Code", "Payment Method Code", "Company Bank Account Code", "Bill-to Customer No.", "Direct Debit Mandate ID")) { }

            column(wanColumn1_Lbl; wanColumn_Lbl[1]) { }
            column(wanColumn2_Lbl; wanColumn_Lbl[2]) { }
            column(wanColumn3_Lbl; wanColumn_Lbl[3]) { }
        }
        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            var
                VATPostingSetup: Record "VAT Posting Setup";
            begin
                DocumentHelper.SetSalesInvoiceAddresses(Header, SellToAddress, ShipToAddress, BillToAddress);
                Customer.Get("Sell-to Customer No.");
                if "Prepayment Invoice" then begin
                    wanColumn_Lbl[1] := Line.FieldCaption("wan Order Amount") + MemoPad.LineFeed() + Line.FieldCaption("wan Order Quantity");
                    wanColumn_Lbl[2] := Line.FieldCaption("wan Prepmt. Line Amount") + MemoPad.LineFeed + Line.FieldCaption("wan Prepayment %");
                    wanColumn_Lbl[3] := Line.FieldCaption("wan Prepmt. Amt. Inv.");
                    Clear(wanTotal);
                end else begin
                    wanColumn_Lbl[1] := Line.FieldCaption(Quantity) + MemoPad.LineFeed() + Line.FieldCaption("Unit of Measure");
                    wanColumn_Lbl[2] := Line.FieldCaption("Unit Price");
                    wanColumn_Lbl[3] := ''; //Line.FieldCaption("Line Discount %") ;
                end;
                if VATPostingSetup.Get("VAT Bus. Posting Group", '') and (VATPostingSetup."VAT Clause Code" <> '') then
                    wanVATClause.Get(VATPostingSetup."VAT Clause Code")
                else
                    Clear(wanVATClause);
                if Header."Gen. Bus. Posting Group" <> wanGenBusPostingGroup.Code then begin
                    Clear(wanLatePaymentClause);
                    if wanGenBusPostingGroup.Get(Header."Gen. Bus. Posting Group") then
                        wanLatePaymentClause := GetExtendedText(Header."Posting Date", Header."Language Code", wanGenBusPostingGroup."wan Late Payment Text Code");
                end;
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
                if Type = Type::" " then begin
                    wanColumn[1] := '';
                    wanColumn[2] := '';
                    wanColumn[3] := '';
                end else
                    if Header."Prepayment Invoice" and not Header."wan Compress Prepayment" then begin
                        wanColumn[1] := DocumentHelper.BlankZero("wan order Amount", wanAutoFormat::AmountFormat, Header."Currency Code") + MemoPad.LineFeed + Format("wan Order Quantity") + ' ' + "Unit of Measure";
                        wanColumn[2] := DocumentHelper.BlankZero("wan Prepmt. Line Amount", wanAutoFormat::AmountFormat, Header."Currency Code") + MemoPad.LineFeed + DocumentHelper.BlankZeroPercent("wan Prepayment %");
                        wanColumn[3] := DocumentHelper.BlankZero("wan Prepmt. Amt. Inv.", wanAutoFormat::AmountFormat, Header."Currency Code");
                        wanTotal[1] += "wan order Amount";
                        wanTotal[2] += "wan Prepmt. Line Amount";
                        wanTotal[3] += "wan Prepmt. Amt. Inv.";
                    end else begin
                        wanColumn[1] := DocumentHelper.BlankZero("Quantity") + MemoPad.LineFeed + "Unit of Measure";
                        wanColumn[2] := DocumentHelper.BlankZero("Unit price", wanAutoFormat::UnitAmountFormat, Header."Currency Code");
                        wanColumn[3] := DocumentHelper.BlankZero("Line Discount %");
                    end;
            end;
        }
        add(Line)
        {
            column(wanMemoPad; GetMemo(Header, Line)) { }
            column(wanQuantity_UOM; DocumentHelper.iif(Line.Type = Line.Type::" ", '', Format(Line.Quantity) + MemoPad.LineFeed + Line."Unit of Measure")) { }

            column(wanColumn1; wanColumn[1]) { }
            column(wanColumn2; wanColumn[2]) { }
            column(wanColumn3; wanColumn[3]) { }
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
    }
    var
        MemoPad: Codeunit "wan MemoPad Sales Invoice";
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
        //wanPaymentMethod : Record "Payment Method";
        //BankAccount : Record "Bank Account";

        wanColumn_Lbl: array[3] of Text;
        wanColumn: array[3] of Text;
        wanTotal: array[3] of Decimal;
        wanAutoFormat: Enum "Auto Format";
        wanGenBusPostingGroup: Record "Gen. Business Posting Group";
        wanVATClause: Record "VAT Clause";
        wanLatePaymentClause: Text;

    trigger OnPreReport()
    begin
        DocumentHelper.GetCompanyInfo(CompanyAddress, CompanyContactInfo, CompanyLegalInfo);
    end;

    local procedure GetMemo(pHeader: Record "Sales Invoice Header"; pLine: Record "Sales Invoice Line") ReturnValue: Text;
    var
        AttachedLines: Text;
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        OrderLine: Record "Sales Line";
    begin
        ReturnValue := pLine.Description;
        OnBeforeGetMemo(pHeader, pLine, ReturnValue);
        if pLine.Type = pLine.Type::Item then begin
            ReturnValue += DocumentHelper.ItemReferences(pLine."No.", pLine."Item Reference No.");
            ReturnValue += DocumentHelper.Tariff(pLine."No.", pHeader."Ship-to Country/Region Code");
            ReturnValue += ShipmentLines;
        end else
            if pHeader."Prepayment Invoice" and (pLine.Type = pLine.Type::"G/L Account") then begin
                if OrderLine.Get(OrderLine."Document Type"::Order, pHeader."Prepayment Order No.", pLine."Line No.") and
                   (OrderLine.Type = OrderLine.Type::Item) then begin
                    ReturnValue += DocumentHelper.ItemReferences(OrderLine."No.", pLine."Item Reference No.");
                    ReturnValue += DocumentHelper.Tariff(OrderLine."No.", pHeader."Ship-to Country/Region Code");
                end;
            end;
        AttachedLines := MemoPad.GetAttachedLines(pLine);
        if AttachedLines = '' then
            AttachedLines := MemoPad.GetExtendedText(pHeader, pLine);
        if AttachedLines <> '' then
            ReturnValue += MemoPad.LineFeed() + AttachedLines;
        OnAfterGetMemo(pHeader, pLine, ReturnValue);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetMemo(pHeader: Record "Sales Invoice Header"; pLine: Record "Sales Invoice Line"; var ReturnValue: Text)
    begin
    end;

    local procedure OnAfterGetMemo(pHeader: Record "Sales Invoice Header"; pLine: Record "Sales Invoice Line"; var ReturnValue: Text)
    begin
    end;

    local procedure ShipmentLines() ReturnValue: Text
    var
        ShipmentHeader: Record "Sales Shipment Header";
        Shipment_Lbl: Label 'Shipment No. %1 %2', Comment = '%1: Document No., %2: Posting Date';
        Tab: Text[1];
    begin
        Tab[1] := 9;
        if ShipmentLine.FindSet() then
            repeat
                if not ShipmentHeader.Get(ShipmentLine."Document No.") then
                    Clear(ShipmentHeader);
                ReturnValue += DocumentHelper.LineFeed() + Tab + StrSubstNo(Shipment_Lbl, ShipmentLine."Document No.", ShipmentHeader."Posting Date");
            until ShipmentLine.Next() = 0;
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
}