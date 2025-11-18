namespace Wanamics.WanaDoc.Document;

using Microsoft.Sales.History;
using Microsoft.Purchases.Document;
using Microsoft.Foundation.Address;
using System.Text;
using Microsoft.Inventory.Item;
using Microsoft.Foundation.Company;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.DirectDebit;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Ledger;
using Microsoft.Purchases.History;
codeunit 87306 "wan Purch. Addresses Helper"
{
    var
        FormatAddress: Codeunit "Format Address";
        DocumentHelper: Codeunit "wan Document Helper";

    local procedure IsCompanyAddress(pName: Text; pName2: Text; pAddress: Text; pAddress2: Text; pPostCode: Code[20]; pCity: Text; pCounty: Text; pCountryRegionCode: Code[10]): Boolean
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();
        exit(DocumentHelper.SameAddress(
            pName, pName2, pAddress, pAddress2, pPostCode, pCity, pCounty, pCountryRegionCode,
            CompanyInfo."Name", CompanyInfo."Name 2", CompanyInfo.Address, CompanyInfo."Address 2", CompanyInfo."Post Code", CompanyInfo."City", CompanyInfo.County, CompanyInfo."Country/Region Code"));
    end;

    procedure SetHeaderAddresses(pHeader: Record "Purchase Header"; var pSellToAddress: Text; var pShipToAddress: Text; var pPayToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.PurchHeaderBuyFrom(Addr, pHeader);
        pSellToAddress := DocumentHelper.FullAddress(Addr);
        if IsCompanyAddress(
                pHeader."Ship-to Name", pHeader."Ship-to Name 2", pHeader."Ship-to Address", pHeader."Ship-to Address 2", pHeader."Ship-to Post Code", pHeader."Ship-to City", pHeader."Ship-to County", pHeader."Ship-to Country/Region Code") then
            pShipToAddress := pHeader."Ship-to Contact"
        else begin
            FormatAddress.PurchHeaderShipTo(Addr, pHeader);
            pShipToAddress := DocumentHelper.FullAddress(Addr);
        end;
        if DocumentHelper.SameAddress(
                pHeader."Pay-to Name", pHeader."Pay-to Name 2", pHeader."Pay-to Address", pHeader."Pay-to Address 2", pHeader."Pay-to Post Code", pHeader."Pay-to City", pHeader."Pay-to County", pHeader."Pay-to Country/Region Code",
                pHeader."Buy-from Vendor Name", pHeader."Buy-from Vendor Name 2", pHeader."Buy-from Address", pHeader."Buy-from Address 2", pHeader."Buy-from Post Code", pHeader."Buy-from City", pHeader."Buy-from County", pHeader."Buy-from Country/Region Code") then
            pPayToAddress := DocumentHelper.iIf(pHeader."Pay-to Contact" <> pHeader."Buy-from Contact", pHeader."Pay-to Contact", '')
        else begin
            FormatAddress.PurchHeaderPayTo(Addr, pHeader);
            pPayToAddress := DocumentHelper.FullAddress(Addr);
        end;
    end;

    procedure SetReceiptAddresses(pHeader: Record "Purch. Rcpt. Header"; var pBuyFromAddress: Text; var pShipToAddress: Text; var pPayToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.PurchRcptBuyFrom(Addr, pHeader);
        pBuyFromAddress := DocumentHelper.FullAddress(Addr);
        if IsCompanyAddress(
                pHeader."Ship-to Name", pHeader."Ship-to Name 2", pHeader."Ship-to Address", pHeader."Ship-to Address 2", pHeader."Ship-to Post Code", pHeader."Ship-to City", pHeader."Ship-to County", pHeader."Ship-to Country/Region Code") then
            pShipToAddress := pHeader."Ship-to Contact"
        else begin
            FormatAddress.PurchRcptShipTo(Addr, pHeader);
            pShipToAddress := DocumentHelper.FullAddress(Addr);
        end;
        if IsCompanyAddress(
                pHeader."Pay-to Name", pHeader."Pay-to Name 2", pHeader."Pay-to Address", pHeader."Pay-to Address 2", pHeader."Pay-to Post Code", pHeader."Pay-to City", pHeader."Pay-to County", pHeader."Pay-to Country/Region Code") then
            pPayToAddress := DocumentHelper.iIf(pHeader."Pay-to Contact" <> pHeader."Buy-from Contact", pHeader."Pay-to Contact", '')
        else begin
            FormatAddress.PurchRcptPayTo(Addr, pHeader);
            pPayToAddress := DocumentHelper.FullAddress(Addr);
        end;
    end;

    procedure SetInvoiceAddresses(pHeader: Record "Purch. Inv. Header"; var pBuyFromAddress: Text; var pShipToAddress: Text; var pPayToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.PurchInvBuyFrom(Addr, pHeader);
        pBuyFromAddress := DocumentHelper.FullAddress(Addr);
        if IsCompanyAddress(
                pHeader."Ship-to Name", pHeader."Ship-to Name 2", pHeader."Ship-to Address", pHeader."Ship-to Address 2", pHeader."Ship-to Post Code", pHeader."Ship-to City", pHeader."Ship-to County", pHeader."Ship-to Country/Region Code") then
            pShipToAddress := pHeader."Ship-to Contact"
        else begin
            FormatAddress.PurchInvShipTo(Addr, pHeader);
            pShipToAddress := DocumentHelper.FullAddress(Addr);
        end;
        if DocumentHelper.SameAddress(
                pHeader."Pay-to Name", pHeader."Pay-to Name 2", pHeader."Pay-to Address", pHeader."Pay-to Address 2", pHeader."Pay-to Post Code", pHeader."Pay-to City", pHeader."Pay-to County", pHeader."Pay-to Country/Region Code",
                pHeader."Buy-from Vendor Name", pHeader."Buy-from Vendor Name 2", pHeader."Buy-from Address", pHeader."Buy-from Address 2", pHeader."Buy-from Post Code", pHeader."Buy-from City", pHeader."Buy-from County", pHeader."Buy-from Country/Region Code") then
            pPayToAddress := DocumentHelper.iIf(pHeader."Pay-to Contact" <> pHeader."Buy-from Contact", pHeader."Pay-to Contact", '')
        else begin
            FormatAddress.PurchInvPayTo(Addr, pHeader);
            pPayToAddress := DocumentHelper.FullAddress(Addr);
        end;
    end;

    procedure SetCrMemoAddresses(pHeader: Record "Purch. Cr. Memo Hdr."; var pBuyFromAddress: Text; var pShipToAddress: Text; var pPayToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.PurchCrMemoBuyFrom(Addr, pHeader);
        pBuyFromAddress := DocumentHelper.FullAddress(Addr);
        if IsCompanyAddress(
                pHeader."Ship-to Name", pHeader."Ship-to Name 2", pHeader."Ship-to Address", pHeader."Ship-to Address 2", pHeader."Ship-to Post Code", pHeader."Ship-to City", pHeader."Ship-to County", pHeader."Ship-to Country/Region Code") then
            pShipToAddress := pHeader."Ship-to Contact"
        else begin
            FormatAddress.PurchCrMemoShipTo(Addr, pHeader);
            pShipToAddress := DocumentHelper.FullAddress(Addr);
        end;
        if DocumentHelper.SameAddress(
                pHeader."Pay-to Name", pHeader."Pay-to Name 2", pHeader."Pay-to Address", pHeader."Pay-to Address 2", pHeader."Pay-to Post Code", pHeader."Pay-to City", pHeader."Pay-to County", pHeader."Pay-to Country/Region Code",
                pHeader."Buy-from Vendor Name", pHeader."Buy-from Vendor Name 2", pHeader."Buy-from Address", pHeader."Buy-from Address 2", pHeader."Buy-from Post Code", pHeader."Buy-from City", pHeader."Buy-from County", pHeader."Buy-from Country/Region Code") then
            pPayToAddress := DocumentHelper.iIf(pHeader."Pay-to Contact" <> pHeader."Buy-from Contact", pHeader."Pay-to Contact", '')
        else begin
            FormatAddress.PurchCrMemoPayTo(Addr, pHeader);
            pPayToAddress := DocumentHelper.FullAddress(Addr);
        end;
    end;
}
