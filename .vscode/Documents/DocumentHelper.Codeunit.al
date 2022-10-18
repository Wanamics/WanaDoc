codeunit 87001 "wan Document Helper"
{
    var
        FormatAddress: Codeunit "Format Address";
        AutoFormat: Codeunit "Auto Format";
        Item: Record Item;
        CountryRegion: Record "Country/Region";

    [EventSubscriber(ObjectType::Table, Database::"Custom Report Selection", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomReportSelection(var Rec: Record "Custom Report Selection")
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange(Usage, Rec.Usage);
        if ReportSelections.FindFirst() then
            Rec."Report ID" := ReportSelections."Report ID";
    end;

    procedure GetCompanyInfo(var pCompanyAddress: Text; var pCompanyContactInfo: Text; var pCompanyLegalInfo: Text)
    var
        CompanyInfo: Record "Company Information";
        Addr: array[8] of Text[100];
    begin
        CompanyInfo.Get();
        FormatAddress.Company(Addr, CompanyInfo);
        pCompanyAddress := FullAddress(Addr);

        if CompanyInfo."Phone No." <> '' then
            pCompanyContactInfo += CompanyInfo."Phone No.";
        if CompanyInfo."E-Mail" <> '' then
            pCompanyContactInfo += LineFeed() + CompanyInfo."E-Mail";
        if CompanyInfo."Home Page" <> '' then
            pCompanyContactInfo += LineFeed() + CompanyInfo."Home Page";

        if (CompanyInfo."Legal Form" <> '') or (CompanyInfo."Stock Capital" <> '') then
            pCompanyLegalInfo += CompanyInfo."Legal Form" + ', ' + CompanyInfo.FieldCaption("Stock Capital") + ' ' + CompanyInfo."Stock Capital";
        if (CompanyInfo."Registration No." <> '') then
            pCompanyLegalInfo += LineFeed() + CompanyInfo.FieldCaption("Registration No.") + ' ' + CompanyInfo."Registration No.";
        if CompanyInfo."APE Code" <> '' then
            pCompanyLegalInfo += LineFeed() + CompanyInfo.FieldCaption("APE Code") + ' ' + CompanyInfo."APE Code";
        if CompanyInfo."Trade Register" <> '' then
            pCompanyLegalInfo += LineFeed() + CompanyInfo.FieldCaption("Trade Register") + ' ' + CompanyInfo."Trade Register";
        if CompanyInfo."VAT Registration No." <> '' then
            pCompanyLegalInfo += LineFeed() + CompanyInfo.FieldCaption("VAT Registration No.") + ' ' + CompanyInfo."VAT Registration No.";
    end;

    procedure LineFeed() ReturnValue: Text[2];
    begin
        ReturnValue[1] := 13;
        ReturnValue[2] := 10;
    end;

    procedure FullAddress(pAddr: array[8] of Text[100]) ReturnValue: Text;
    var
        i: Integer;
        LastOne: Integer;
    begin
        LastOne := 8;
        while (pAddr[LastOne] = '') and (LastOne > 1) do
            LastOne -= 1;
        ReturnValue := pAddr[1];
        for i := 2 to LastOne do
            ReturnValue += LineFeed() + pAddr[i];
    end;

    procedure FormatDate(pDate: Date): Text
    begin
        exit(Format(pDate, 0, '<Day,2>/<Month,2>/<Year4>'));
    end;

    procedure iIf(pIf: Boolean; pThen: Text; pElse: Text): Text
    begin
        if pIf then
            exit(pThen)
        else
            exit(pElse);
    end;

    procedure BlankZero(pDecimal: Decimal): Text
    begin
        if pDecimal = 0 then
            exit('')
        else
            exit(format(pDecimal));
    end;

    procedure BlankZero(pDecimal: Decimal; pAutoFormatType: Enum "Auto Format"; pCurrencyCode: Code[10]): Text
    begin
        if pDecimal = 0 then
            exit('')
        else
            exit(Format(pDecimal, 0, AutoFormat.ResolveAutoFormat(pAutoFormatType, pCurrencyCode)));
    end;

    procedure BlankZeroPercent(pDecimal: Decimal): Text
    begin
        if pDecimal = 0 then
            exit('')
        else
            exit(format(pDecimal) + '%');
    end;

    procedure GetVersion(pNoOfArchivedVersions: Integer): Text;
    var
        tVersion: Label ' R%1';
    begin
        if pNoOfArchivedVersions = 0 then
            exit;
        exit(StrSubstNo(tVersion, pNoOfArchivedVersions));
    end;

    procedure ItemReferences(pItemNo: Code[20]; pItemReferenceNo: Code[50]) ReturnValue: Text
    var
        Item: Record Item;
        Line: Record "Sales Line"; // for FieldCaption, no matter Sales or Purchase
    begin
        if (pItemReferenceNo <> '') and (pItemReferenceNo <> pItemNo) then
            ReturnValue += LineFeed() + Line.FieldCaption("Item Reference No.") + ' : ' + pItemReferenceNo + ', ' + Line.FieldCaption("No.") + ' : ' + pItemNo
        else
            if Item.Get(pItemNo) and Item.IsInventoriableType() then
                ReturnValue += LineFeed() + Line.FieldCaption("No.") + ' : ' + pItemNo;
    end;

    procedure Tariff(pItemNo: Code[20]; pShipToCountryRegionCode: Code[10]) ReturnValue: Text;
    var
        Item: Record Item;
        IntraStatErr: TextConst
            ENU = '%1 and %2 of item %3 are mandatory for an intrastat operation.',
            FRA = '%1 et %2 de l''article %3 doivent être définis pour une opération intracommunautaire.';
    begin
        Item.Get(pItemNo);
        if Item.IsInventoriableType() then begin
            if IsIntrastat(pShipToCountryRegionCode) and
                ((Item."Tariff No." = '') or (Item."Country/Region of Origin Code" = '')) then
                error(IntraStatErr, Item.FieldCaption("Tariff No."), Item.FieldCaption("Country/Region of Origin Code"), Item."No.");
            if Item."Tariff No." <> '' then
                ReturnValue += LineFeed() +
                    Item.FieldCaption("Tariff No.") + ' ' + Item."Tariff No." + ', ' +
                    Item.FieldCaption("Country/Region of Origin Code") + ' ' + Item."Country/Region of Origin Code";
        end;
    end;

    local procedure IsIntrastat(pShipToCountryRegionCode: code[10]): Boolean
    var
        CompanyInfo: Record "Company Information";
    begin
        if pShipToCountryRegionCode = '' then
            exit(false);
        CompanyInfo.Get();
        if pShipToCountryRegionCode = CompanyInfo."Country/Region Code" then
            exit(false);
        if pShipToCountryRegionCode <> CountryRegion.Code then
            CountryRegion.Get(pShipToCountryRegionCode);
        exit(CountryRegion."Intrastat Code" <> '');
    end;

    procedure TrackingLines(pDocumentType: Integer; pDocumentNo: Code[20]; pLineNo: Integer) ReturnValue: Text
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Tab: Text[1];
    begin
        Tab[1] := 9;
        ItemLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Document Line No.");
        ItemLedgerEntry.SetRange("Document Type", pDocumentType);
        ItemLedgerEntry.SetRange("Document No.", pDocumentNo);
        ItemLedgerEntry.SetRange("Document Line No.", pLineNo);
        ItemLedgerEntry.SetFilter("Lot No.", '<>%1', '');
        if ItemLedgerEntry.FindSet() then
            repeat
                ReturnValue += LineFeed() + Tab + ItemLedgerEntry.FieldCaption("Lot No.") + ' ' + ItemLedgerEntry."Lot No." + ' : ' + Format(abs(ItemLedgerEntry."Quantity"));
            until ItemLedgerEntry.Next() = 0;
        ItemLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Document Line No.");
        ItemLedgerEntry.SetRange("Document Type", pDocumentType);
        ItemLedgerEntry.SetRange("Document No.", pDocumentNo);
        ItemLedgerEntry.SetRange("Document Line No.", pLineNo);
        ItemLedgerEntry.SetFilter("Serial No.", '<>%1', '');
        if ItemLedgerEntry.FindSet() then begin
            ReturnValue += LineFeed() + Tab + ItemLedgerEntry.FieldCaption("Serial No.") /*+ Tab + ItemLedgerEntry.FieldCaption("Quantity")*/;
            repeat
                ReturnValue += LineFeed() + Tab + ItemLedgerEntry."Serial No."; // + ' : ' + Format(abs(ItemLedgerEntry."Quantity"));
            until ItemLedgerEntry.Next() = 0;
        end;
    end;

    procedure SetSalesHeaderAddresses(pHeader: Record "Sales Header"; var pSellToAddress: Text; var pShipToAddress: Text; var pBillToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.SalesHeaderSellTo(Addr, pHeader);
        pSellToAddress := FullAddress(Addr);
        FormatAddress.SalesHeaderShipTo(Addr, Addr, pHeader);
        pShipToAddress := FullAddress(Addr);
        pHeader."Bill-to Contact" := '';
        pHeader."Bill-to Contact No." := '';
        FormatAddress.SalesHeaderBillTo(Addr, pHeader);
        pBillToAddress := FullAddress(Addr);
    end;

    procedure SetSalesShipmentAddresses(pHeader: Record "Sales Shipment Header"; var pSellToAddress: Text; var pShipToAddress: Text; var pBillToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.SalesShptSellTo(Addr, pHeader);
        pSellToAddress := FullAddress(Addr);
        FormatAddress.SalesShptShipTo(Addr, pHeader);
        pShipToAddress := FullAddress(Addr);
        pHeader."Bill-to Contact" := '';
        pHeader."Bill-to Contact No." := '';
        FormatAddress.SalesShptBillTo(Addr, Addr, pHeader);
        pBillToAddress := FullAddress(Addr);
    end;

    procedure SetSalesInvoiceAddresses(pHeader: Record "Sales Invoice Header"; var pSellToAddress: Text; var pShipToAddress: Text; var pBillToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.SalesInvSellTo(Addr, pHeader);
        pSellToAddress := FullAddress(Addr);
        FormatAddress.SalesInvShipTo(Addr, Addr, pHeader);
        pShipToAddress := FullAddress(Addr);
        pHeader."Bill-to Contact" := '';
        pHeader."Bill-to Contact No." := '';
        FormatAddress.SalesInvBillTo(Addr, pHeader);
        pBillToAddress := FullAddress(Addr);
    end;

    procedure SetSalesCrMemoAddresses(pHeader: Record "Sales Cr.Memo Header"; var pSellToAddress: Text; var pShipToAddress: Text; var pBillToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.SalesCrMemoSellTo(Addr, pHeader);
        pSellToAddress := FullAddress(Addr);
        FormatAddress.SalesCrMemoShipTo(Addr, Addr, pHeader);
        pShipToAddress := FullAddress(Addr);
        pHeader."Bill-to Contact" := '';
        pHeader."Bill-to Contact No." := '';
        FormatAddress.SalesCrMemoBillTo(Addr, pHeader);
        pBillToAddress := FullAddress(Addr);
    end;

    procedure SetPurchaseHeaderAddresses(pHeader: Record "Purchase Header"; var pSellToAddress: Text; var pShipToAddress: Text; var pBillToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.PurchHeaderBuyFrom(Addr, pHeader);
        pSellToAddress := FullAddress(Addr);
        FormatAddress.PurchHeaderShipTo(Addr, pHeader);
        pShipToAddress := FullAddress(Addr);
        pHeader := pHeader;
        pHeader."Pay-to Contact" := '';
        pHeader."Pay-to Contact No." := '';
        FormatAddress.PurchHeaderPayTo(Addr, pHeader);
        pBillToAddress := FullAddress(Addr);
    end;

    procedure SetPurchaseReceiptAddresses(pHeader: Record "Purch. Rcpt. Header"; var pBuyFromAddress: Text; var pShipToAddress: Text; var pPayToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.PurchRcptBuyFrom(Addr, pHeader);
        pBuyFromAddress := FullAddress(Addr);
        FormatAddress.PurchRcptShipTo(Addr, pHeader);
        pShipToAddress := FullAddress(Addr);
        pHeader."Pay-to Contact" := '';
        pHeader."Pay-to Contact No." := '';
        FormatAddress.PurchRcptPayTo(Addr, pHeader);
        pPayToAddress := FullAddress(Addr);
    end;

    procedure SetPurchaseInvoiceAddresses(pHeader: Record "Purch. Inv. Header"; var pBuyFromAddress: Text; var pShipToAddress: Text; var pPayToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.PurchInvBuyFrom(Addr, pHeader);
        pBuyFromAddress := FullAddress(Addr);
        FormatAddress.PurchInvShipTo(Addr, pHeader);
        pShipToAddress := FullAddress(Addr);
        pHeader."Pay-to Contact" := '';
        pHeader."Pay-to Contact No." := '';
        FormatAddress.PurchInvPayTo(Addr, pHeader);
        pPayToAddress := FullAddress(Addr);
    end;

    procedure SetPurchaseCrMemoAddresses(pHeader: Record "Purch. Cr. Memo Hdr."; var pBuyFromAddress: Text; var pShipToAddress: Text; var pPayToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.PurchCrMemoBuyFrom(Addr, pHeader);
        pBuyFromAddress := FullAddress(Addr);
        FormatAddress.PurchCrMemoShipTo(Addr, pHeader);
        pShipToAddress := FullAddress(Addr);
        pHeader."Pay-to Contact" := '';
        pHeader."Pay-to Contact No." := '';
        FormatAddress.PurchCrMemoPayTo(Addr, pHeader);
        pPayToAddress := FullAddress(Addr);
    end;
}
