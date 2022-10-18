reportextension 87308 "Standard Sales - Shipment" extends "Standard Sales - Shipment"
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
            column(wanSellToContact_Lbl; Header.FieldCaption("Sell-to Contact")) { }
            column(wanSellToContact; Header."Sell-to Contact") { }
            column(wanSellToEmail_Lbl; Header.FieldCaption("Sell-to E-mail")) { }
            column(wanSellToEmail; Header."Sell-to E-mail") { }
            column(wanSellToPhoneNo_Lbl; PhoneNo_Lbl) { }
            column(wanSellToPhoneNo; "Sell-to Phone No.") { }
            column(wanShippingAgentName_Lbl; ShippingAgent.TableCaption()) { }
            column(wanShippingAgentName; ShippingAgent.Name) { }
            column(wanShippingAgentServices_Lbl; ShippingAgentServices.TableCaption()) { }
            column(wanShippingAgentServices; ShippingAgentServices.Description) { }
        }
        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            var
                Addr: array[8] of Text[100];
            begin
                DocumentHelper.SetSalesShipmentAddresses(Header, SellToAddress, ShipToAddress, BillToAddress);

                Customer.Get("Sell-to Customer No.");
                if not ShippingAgent.Get(Header."Shipping Agent Code") then
                    ShippingAgent.Init();
                if not ShippingAgentServices.Get(Header."Shipping Agent Code", Header."Shipping Agent Service Code") then
                    ShippingAgentServices.Init();
            end;
        }
        modify(Line)
        {
            trigger OnBeforePreDataItem()
            begin
                SetRange("Attached To Line No.", 0);
                if not ShowLinesWithoutQuantity then
                    SetFilter(Quantity, '<>0');
            end;
        }
        add(Line)
        {
            column(wanMemoPad; GetMemo(Header, Line)) { }
            column(wanQuantity_UOM; DocumentHelper.iif(Line.Type = Line.Type::" ", '', Format(Line.Quantity) + MemoPad.LineFeed + Line."Unit of Measure")) { }
        }
    }
    requestpage
    {
        layout
        {
            addlast(Options)
            {
                field(wanShowLinesWithoutQuantity; ShowLinesWithoutQuantity)
                {
                    ApplicationArea = All;
                    Caption = 'Show lines without quantity';
                }
            }
        }
    }
    var
        MemoPad: Codeunit "wan MemoPad Sales Shipment";
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
        PhoneNo_Lbl: Label 'Phone No.';
        ShippingAgent: Record "Shipping Agent";
        ShippingAgentServices: Record "Shipping Agent Services";
        ShowLinesWithoutQuantity: Boolean;

    trigger OnPreReport()
    begin
        DocumentHelper.GetCompanyInfo(CompanyAddress, CompanyContactInfo, CompanyLegalInfo);
    end;

    local procedure GetMemo(pHeader: Record "Sales Shipment Header"; pLine: Record "Sales Shipment Line") ReturnValue: Text;
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
            ReturnValue += DocumentHelper.TrackingLines(ItemLedgerEntry."Document Type"::"Sales Shipment".AsInteger(), pLine."Document No.", pLine."Line No.");
        end;
        AttachedLines := MemoPad.GetAttachedLines(pLine);
        if AttachedLines = '' then
            AttachedLines := MemoPad.GetExtendedText(pHeader, pLine);
        if AttachedLines <> '' then
            ReturnValue += DocumentHelper.LineFeed() + AttachedLines;
        OnAfterGetMemo(pHeader, pLine, ReturnValue);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetMemo(pHeader: Record "Sales Shipment Header"; pLine: Record "Sales Shipment Line"; var ReturnValue: Text)
    begin
    end;

    local procedure OnAfterGetMemo(pHeader: Record "Sales Shipment Header"; pLine: Record "Sales Shipment Line"; var ReturnValue: Text)
    begin
    end;


}