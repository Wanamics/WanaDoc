namespace Wanamics.WanaDoc.Document;

using Microsoft.Sales.History;
using Microsoft.Foundation.Address;
using Microsoft.Sales.Document;
codeunit 87308 "wan Sales Addresses Helper"
{
    var
        FormatAddress: Codeunit "Format Address";
        DocumentHelper: Codeunit "wan Document Helper";

    procedure SetHeaderAddresses(pHeader: Record "Sales Header"; var pSellToAddress: Text; var pShipToAddress: Text; var pBillToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.SalesHeaderSellTo(Addr, pHeader);
        pSellToAddress := DocumentHelper.FullAddress(Addr);
        if DocumentHelper.SameAddress(
                pHeader."Ship-to Name", pHeader."Ship-to Name 2", pHeader."Ship-to Address", pHeader."Ship-to Address 2", pHeader."Ship-to Post Code", pHeader."Ship-to City", pHeader."Ship-to County", pHeader."Ship-to Country/Region Code",
                pHeader."Sell-to Customer Name", pHeader."Sell-to Customer Name 2", pHeader."Sell-to Address", pHeader."Sell-to Address 2", pHeader."Sell-to Post Code", pHeader."Sell-to City", pHeader."Sell-to County", pHeader."Sell-to Country/Region Code") then
            pShipToAddress := DocumentHelper.iIf(pHeader."Ship-to Contact" <> pHeader."Sell-to Contact", pHeader."Ship-to Contact", '')
        else begin
            FormatAddress.SalesHeaderShipTo(Addr, Addr, pHeader);
            pShipToAddress := DocumentHelper.FullAddress(Addr);
        end;
        if DocumentHelper.SameAddress(
                pHeader."Bill-to Name", pHeader."Bill-to Name 2", pHeader."Bill-to Address", pHeader."Bill-to Address 2", pHeader."Bill-to Post Code", pHeader."Bill-to City", pHeader."Bill-to County", pHeader."Bill-to Country/Region Code",
                pHeader."Sell-to Customer Name", pHeader."Sell-to Customer Name 2", pHeader."Sell-to Address", pHeader."Sell-to Address 2", pHeader."Sell-to Post Code", pHeader."Sell-to City", pHeader."Sell-to County", pHeader."Sell-to Country/Region Code") then
            pBillToAddress := DocumentHelper.iIf(pHeader."Bill-to Contact" <> pHeader."Sell-to Contact", pHeader."Bill-to Contact", '')
        else begin
            FormatAddress.SalesHeaderBillTo(Addr, pHeader);
            pBillToAddress := DocumentHelper.FullAddress(Addr);
        end;
    end;

    procedure SetShipmentAddresses(pHeader: Record "Sales Shipment Header"; var pSellToAddress: Text; var pShipToAddress: Text; var pBillToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.SalesShptSellTo(Addr, pHeader);
        pSellToAddress := DocumentHelper.FullAddress(Addr);
        if DocumentHelper.SameAddress(
                pHeader."Ship-to Name", pHeader."Ship-to Name 2", pHeader."Ship-to Address", pHeader."Ship-to Address 2", pHeader."Ship-to Post Code", pHeader."Ship-to City", pHeader."Ship-to County", pHeader."Ship-to Country/Region Code",
                pHeader."Sell-to Customer Name", pHeader."Sell-to Customer Name 2", pHeader."Sell-to Address", pHeader."Sell-to Address 2", pHeader."Sell-to Post Code", pHeader."Sell-to City", pHeader."Sell-to County", pHeader."Sell-to Country/Region Code") then
            pShipToAddress := DocumentHelper.iIf(pHeader."Ship-to Contact" <> pHeader."Sell-to Contact", pHeader."Ship-to Contact", '')
        else begin
            FormatAddress.SalesShptShipTo(Addr, pHeader);
            pShipToAddress := DocumentHelper.FullAddress(Addr);
        end;
        if DocumentHelper.SameAddress(
                pHeader."Bill-to Name", pHeader."Bill-to Name 2", pHeader."Bill-to Address", pHeader."Bill-to Address 2", pHeader."Bill-to Post Code", pHeader."Bill-to City", pHeader."Bill-to County", pHeader."Bill-to Country/Region Code",
                pHeader."Sell-to Customer Name", pHeader."Sell-to Customer Name 2", pHeader."Sell-to Address", pHeader."Sell-to Address 2", pHeader."Sell-to Post Code", pHeader."Sell-to City", pHeader."Sell-to County", pHeader."Sell-to Country/Region Code") then
            pBillToAddress := DocumentHelper.iIf(pHeader."Bill-to Contact" <> pHeader."Sell-to Contact", pHeader."Bill-to Contact", '')
        else begin
            FormatAddress.SalesShptBillTo(Addr, Addr, pHeader);
            pBillToAddress := DocumentHelper.FullAddress(Addr);
        end;
    end;

    procedure SetInvoiceAddresses(pHeader: Record "Sales Invoice Header"; var pSellToAddress: Text; var pShipToAddress: Text; var pBillToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.SalesInvSellTo(Addr, pHeader);
        pSellToAddress := DocumentHelper.FullAddress(Addr);
        if DocumentHelper.SameAddress(
                pHeader."Ship-to Name", pHeader."Ship-to Name 2", pHeader."Ship-to Address", pHeader."Ship-to Address 2", pHeader."Ship-to Post Code", pHeader."Ship-to City", pHeader."Ship-to County", pHeader."Ship-to Country/Region Code",
                pHeader."Sell-to Customer Name", pHeader."Sell-to Customer Name 2", pHeader."Sell-to Address", pHeader."Sell-to Address 2", pHeader."Sell-to Post Code", pHeader."Sell-to City", pHeader."Sell-to County", pHeader."Sell-to Country/Region Code") then
            pShipToAddress := DocumentHelper.iIf(pHeader."Ship-to Contact" <> pHeader."Sell-to Contact", pHeader."Ship-to Contact", '')
        else begin
            FormatAddress.SalesInvShipTo(Addr, Addr, pHeader);
            pShipToAddress := DocumentHelper.FullAddress(Addr);
        end;
        if DocumentHelper.SameAddress(
                pHeader."Bill-to Name", pHeader."Bill-to Name 2", pHeader."Bill-to Address", pHeader."Bill-to Address 2", pHeader."Bill-to Post Code", pHeader."Bill-to City", pHeader."Bill-to County", pHeader."Bill-to Country/Region Code",
                pHeader."Sell-to Customer Name", pHeader."Sell-to Customer Name 2", pHeader."Sell-to Address", pHeader."Sell-to Address 2", pHeader."Sell-to Post Code", pHeader."Sell-to City", pHeader."Sell-to County", pHeader."Sell-to Country/Region Code") then
            pBillToAddress := DocumentHelper.iIf(pHeader."Bill-to Contact" <> pHeader."Sell-to Contact", pHeader."Bill-to Contact", '')
        else begin
            FormatAddress.SalesInvBillTo(Addr, pHeader);
            pBillToAddress := DocumentHelper.FullAddress(Addr);
        end;
    end;

    procedure SetCrMemoAddresses(pHeader: Record "Sales Cr.Memo Header"; var pSellToAddress: Text; var pShipToAddress: Text; var pBillToAddress: Text)
    var
        Addr: array[8] of Text[100];
    begin
        FormatAddress.SalesCrMemoSellTo(Addr, pHeader);
        pSellToAddress := DocumentHelper.FullAddress(Addr);
        if DocumentHelper.SameAddress(
                pHeader."Ship-to Name", pHeader."Ship-to Name 2", pHeader."Ship-to Address", pHeader."Ship-to Address 2", pHeader."Ship-to Post Code", pHeader."Ship-to City", pHeader."Ship-to County", pHeader."Ship-to Country/Region Code",
                pHeader."Sell-to Customer Name", pHeader."Sell-to Customer Name 2", pHeader."Sell-to Address", pHeader."Sell-to Address 2", pHeader."Sell-to Post Code", pHeader."Sell-to City", pHeader."Sell-to County", pHeader."Sell-to Country/Region Code") then
            pShipToAddress := DocumentHelper.iIf(pHeader."Ship-to Contact" <> pHeader."Sell-to Contact", pHeader."Ship-to Contact", '')
        else begin
            FormatAddress.SalesCrMemoShipTo(Addr, Addr, pHeader);
            pShipToAddress := DocumentHelper.FullAddress(Addr);
        end;
        if DocumentHelper.SameAddress(
                pHeader."Bill-to Name", pHeader."Bill-to Name 2", pHeader."Bill-to Address", pHeader."Bill-to Address 2", pHeader."Bill-to Post Code", pHeader."Bill-to City", pHeader."Bill-to County", pHeader."Bill-to Country/Region Code",
                pHeader."Sell-to Customer Name", pHeader."Sell-to Customer Name 2", pHeader."Sell-to Address", pHeader."Sell-to Address 2", pHeader."Sell-to Post Code", pHeader."Sell-to City", pHeader."Sell-to County", pHeader."Sell-to Country/Region Code") then
            pBillToAddress := DocumentHelper.iIf(pHeader."Bill-to Contact" <> pHeader."Sell-to Contact", pHeader."Bill-to Contact", '')
        else begin
            FormatAddress.SalesCrMemoBillTo(Addr, pHeader);
            pBillToAddress := DocumentHelper.FullAddress(Addr);
        end;
    end;
}
