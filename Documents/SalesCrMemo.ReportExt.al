reportextension 87307 "Standard Sales - Credit Memo" extends "Standard Sales - Credit Memo"
{
    WordLayout = './ReportLayouts/wanSalesCrMemo.docx';
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
        }
        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            begin
                DocumentHelper.SetSalesCrMemoAddresses(Header, SellToAddress, ShipToAddress, BillToAddress);
                Customer.Get("Sell-to Customer No.");
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
        Customer: Record Customer;

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
        end;
        DocumentHelper.TrackingLines(ItemLedgerEntry."Document Type"::"Sales Return Receipt".AsInteger(), pLine."Return Receipt No.", pLine."Return Receipt Line No.");
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

    local procedure OnAfterGetMemo(pHeader: Record "Sales Cr.Memo Header"; pLine: Record "Sales Cr.Memo Line"; var ReturnValue: Text)
    begin
    end;
}