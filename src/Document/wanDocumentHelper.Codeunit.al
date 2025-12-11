namespace Wanamics.WanaDoc.Document;

using Microsoft.Foundation.Address;
using System.Text;
using Microsoft.Inventory.Item;
using Microsoft.Foundation.Company;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.DirectDebit;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Ledger;
using Microsoft.CRM.Contact;
using Microsoft.CRM.Setup;
using System.Reflection;
codeunit 87301 "wan Document Helper"
{
    var
        FormatAddress: Codeunit "Format Address";
        AutoFormat: Codeunit "Auto Format";
        Item: Record Item;
        CountryRegion: Record "Country/Region";
        CompanyInfo: Record "Company Information";
        BankAccount: Record "Bank Account";
        PaymentMethod: Record "Payment Method";
        DefaultBankAccount: Record "Bank Account";

    procedure GetCompanyInfo(var pCompanyAddress: Text; var pCompanyContactInfo: Text; var pCompanyLegalInfo: Text)
    var
        Addr: array[8] of Text[100];
        CompanyInfoRecordRef: RecordRef;
        frLegalFormCaption, frLegalFormValue : Text;
        frStockCapitalCaption, frStockCapitalValue : Text;
        frAPECodeCaption, frAPECodeValue : Text;
        frTradeRegisterCaption, frTradeRegisterValue : Text;
        frDefaultBalAccountCaption, frDefaultBalAccountValue : Text;
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

        CompanyInfoRecordRef.GetTable(CompanyInfo);
        GetLocalizationField(CompanyInfoRecordRef, 10801, frTradeRegisterCaption, frTradeRegisterValue);
        GetLocalizationField(CompanyInfoRecordRef, 10802, frAPECodeCaption, frAPECodeValue);
        GetLocalizationField(CompanyInfoRecordRef, 10803, frLegalFormCaption, frLegalFormValue);
        GetLocalizationField(CompanyInfoRecordRef, 10804, frStockCapitalCaption, frStockCapitalValue);
        GetLocalizationField(CompanyInfoRecordRef, 10810, frDefaultBalAccountCaption, frDefaultBalAccountValue);

        if (frLegalFormValue <> '') or (frStockCapitalValue <> '') then
            pCompanyLegalInfo += frLegalFormValue + ', ' + frStockCapitalCaption + ' ' + frStockCapitalValue + LineFeed();
        if CompanyInfo."Registration No." <> '' then
            pCompanyLegalInfo += CompanyInfo.FieldCaption("Registration No.") + ' ' + CompanyInfo."Registration No." + LineFeed();
        if frAPECodeValue <> '' then
            pCompanyLegalInfo += frAPECodeCaption + ' ' + frAPECodeValue + LineFeed();
        if frTradeRegisterValue <> '' then
            pCompanyLegalInfo += frTradeRegisterCaption + ' ' + frTradeRegisterValue + LineFeed();
        if CompanyInfo."VAT Registration No." <> '' then
            pCompanyLegalInfo += CompanyInfo.FieldCaption("VAT Registration No.") + ' ' + CompanyInfo."VAT Registration No." + LineFeed();

        if frDefaultBalAccountValue <> '' then
            DefaultBankAccount.Get(frDefaultBalAccountValue);
    end;

    local procedure GetLocalizationField(var pRecordRef: RecordRef; pFieldNo: Integer; var pCaption: Text; var pValue: Text)
    var
        FldRef: Fieldref;
        Field: Record Field;
    begin
        if not Field.Get(pRecordRef.Number(), pFieldNo) then
            exit;
        FldRef := pRecordRef.Field(pFieldNo);
        pCaption := FldRef.Caption;
        pValue := FldRef.Value;
    end;

    procedure PaymentMethodText(pLanguageCode: Code[10]; pPaymentMethodCode: Code[10]; pCompanyBankAccountNo: Code[20]; pCustomerNo: Code[20]; pSDDMandateId: Code[35]): Text;
    var
        PaymentMethodLbl: Label 'Pay by %1 to our bank account %2, IBAN %3, Code SWIFT %4', Comment = '%1:PaymentMethod.Description, %2:BankAccount.Name, %3:BankAccount.IBAN, %4:BankAccount."SWIFT Code")';
        DirectDebitLbl: Label 'Direct Debit ID %1 from your bank account %2 IBAN %3', Comment = '%1:SDDMandateId, %2:CustomerBankAccount.Name, %3:CustomerBankAccount.IBAN)';
        SDDMandate: Record "SEPA Direct Debit Mandate";
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        if pPaymentMethodCode <> PaymentMethod.Code then
            if pPaymentMethodCode = '' then
                PaymentMethod.Init()
            else begin
                PaymentMethod.Get(pPaymentMethodCode);
                if pLanguageCode <> '' then
                    PaymentMethod.TranslateDescription(pLanguageCode);
            end;
        if PaymentMethod."Direct Debit" then begin
            if SDDMandate.Get(pSDDMandateId) then
                if CustomerBankAccount.Get(pCustomerNo, SDDMandate."Customer Bank Account Code") then;
            exit(StrSubstNo(DirectDebitLbl, pSDDMandateId, CustomerBankAccount.Name, FormatIBAN(CustomerBankAccount.IBAN)));
        end else begin
            if pCompanyBankAccountNo = '' then
                BankAccount := DefaultBankAccount
            else
                BankAccount.Get(pCompanyBankAccountNo);
            exit(StrSubstNo(PaymentMethodLbl, PaymentMethod.Description, BankAccount.Name, FormatIBAN(BankAccount.IBAN), BankAccount."SWIFT Code"))
        end;
    end;

    local procedure FormatIBAN(pIBAN: Text) ReturnValue: Text
    var
        i: Integer;
    begin
        if (pIBAN.StartsWith('FR')) and (StrLen(pIBAN) > 27 /* FR IBAN without space */) then
            exit(pIBAN);
        pIBAN := DelChr(pIBAN, '=', ' ');
        for i := 1 to StrLen(pIBAN) do begin
            if (i - 1) mod 4 = 0 then
                ReturnValue += ' ';
            ReturnValue += pIBAN[i]
        end;
    end;

    procedure LineFeed() ReturnValue: Text[1];
    begin
        ReturnValue[1] := 10;
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
        VersionTxt: Label ' R%1';
    begin
        if pNoOfArchivedVersions = 0 then
            exit;
        exit(StrSubstNo(VersionTxt, pNoOfArchivedVersions));
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
        IntraStatErr: Label '%1 and %2 of item %3 are mandatory for an intrastat operation.', Comment = '%1:Item.FieldCaption("Tariff No."), %2:Item.FieldCaption("Country/Region of Origin Code", %3:Item."No.")';
    begin
        if pShipToCountryRegionCode = CompanyInfo."Country/Region Code" then
            exit;
        Item.Get(pItemNo);
        if not Item.IsServiceType() then begin
            if IsIntrastat(pShipToCountryRegionCode) and IsIntrastat(CompanyInfo."Country/Region Code") and
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

    // procedure Content(pReportId: Text; pPlaceHolder: Enum "wan Document Content Placement"; pLanguageCode: Code[10]) ReturnValue: Text
    // var
    //     ReportID: Integer;
    //     DocumentContent: Record "wan Document Content";
    //     ContentInStream: InStream;
    // begin
    //     Evaluate(ReportID, pReportId.Substring(8));
    //     DocumentContent.SetRange("Report ID", ReportID);
    //     DocumentContent.SetRange("Placement", pPlaceHolder);
    //     DocumentContent.SetFilter("Language Code", '%1|%2', pLanguageCode, '');
    //     if DocumentContent.FindLast() then begin
    //         DocumentContent.CalcFields("Content");
    //         DocumentContent."Content".CreateInStream(ContentInStream, TextEncoding::UTF8);
    //         ContentInStream.Read(ReturnValue);
    //     end;
    // end;
    procedure Content(pReportId: Text; pPlaceHolder: Enum "wan Document Content Placement"; pLanguageCode: Code[10]) ReturnValue: Text
    var
        DocumentContent: Record "wan Document Content";
    begin
        exit(DocumentContent.Fetch(pReportId, pPlaceHolder, pLanguageCode));
    end;

    procedure SameAddress(
        p1Name: Text; p1Name2: Text; p1Address: Text; p1Address2: Text; p1PostCode: Code[20]; p1City: Text; p1County: Text; p1CountryRegionCode: Code[10];
        p2Name: Text; p2Name2: Text; p2Address: Text; p2Address2: Text; p2PostCode: Code[20]; p2City: Text; p2County: Text; p2CountryRegionCode: Code[10]): Boolean
    begin
        exit((p1Name = p2Name) and (p1Name2 = p2Name2) and (p1Address = p2Address) and (p1Address2 = p2Address2) and (p1PostCode = p2PostCode) and (p1City = p2City) and (p1County = p2County) and (p1CountryRegionCode = p2CountryRegionCode));
    end;

    procedure ContactSalutation(pContact: Record Contact; pLanguageCode: Code[10]): Text
    var
        Salutation: Record "Salutation Formula";
    begin
        if pContact."Salutation Code" = '' then
            exit(pContact.CalculatedName())
        else
            exit(pContact.GetSalutation("Salutation Formula Salutation Type"::Formal, pLanguageCode));
    end;
}
