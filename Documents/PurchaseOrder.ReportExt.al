reportextension 87322 "Standard Purchase - Order" extends "Standard Purchase - Order"
{
    WordLayout = './ReportLayouts/wanPurchaseOrder.docx';
    dataset
    {
        add("Purchase Header")
        {
            column(wanCompanyAddress; CompanyAddress) { }
            column(wanCompanyContactInfo; CompanyContactInfo) { }
            column(wanCompanyLegalInfo; CompanyLegalInfo) { }
            column(wanBuyFromAddress_Lbl; BuyFromAddress_Lbl) { }
            column(wanBuyFromAddress; BuyFromAddress) { }
            column(wanShipToAddress_Lbl; ShipToAddress_Lbl) { }
            column(wanShipToAddress; ShipToAddress) { }
            column(wanPayToAddress_Lbl; PayToAddress_Lbl) { }
            column(wanPayToAddress; PayToAddress) { }
            column(wanRequestedReceiptDate; DocumentHelper.FormatDate("Requested Receipt Date")) { }
            column(wanVersion; DocumentHelper.GetVersion("No. of Archived Versions")) { }
        }
        modify("Purchase Header")
        {
            CalcFields = "No. of Archived Versions";
            trigger OnAfterAfterGetRecord()
            begin
                DocumentHelper.SetPurchaseHeaderAddresses("Purchase Header", BuyFromAddress, ShipToAddress, PayToAddress);
            end;
        }
        modify("Purchase Line")
        {
            trigger OnBeforePreDataItem()
            begin
                SetRange("Attached To Line No.", 0);
            end;
        }
        add("Purchase Line")
        {
            column(wanMemoPad; GetMemo("Purchase Header", "Purchase Line")) { }
            column(wanQuantity_UOM; DocumentHelper.iIf(Type = Type::" ", '', Format(Quantity) + MemoPad.LineFeed + "Unit of Measure")) { }
            column(wanVATPercent; DocumentHelper.iIf(Type = Type::" ", '', format("Purchase Line"."VAT %"))) { }
            column(wanVATPercent_lbl; "Purchase Line".fieldcaption("VAT %")) { }
            column(wanLineDiscPercent; DocumentHelper.BlankZero("Purchase Line"."Line Discount %")) { }
        }
        add(LetterText)
        {
            column(wanBeginningContent; DocumentHelper.Content(CurrReport.ObjectId(false), enum::"wan Document Content Placement"::Beginning, "Purchase Header"."Language Code")) { }
            column(wanEndingContent; DocumentHelper.Content(CurrReport.ObjectId(false), enum::"wan Document Content Placement"::Ending, "Purchase Header"."Language Code")) { }
        }
    }
    var
        MemoPad: Codeunit "wan MemoPad Purchase";
        FormatAddress: Codeunit "Format Address";
        BuyFromAddress_Lbl: Label 'Buy-from';
        BuyFromAddress: Text;
        ShipToAddress_Lbl: Label 'Ship-to';
        ShipToAddress: Text;
        PayToAddress_Lbl: Label 'Pay-to';
        PayToAddress: Text;
        CompanyAddress: Text;
        CompanyContactInfo: Text;
        CompanyLegalInfo: Text;
        DocumentHelper: Codeunit "wan Document Helper";
    /*
    wanMailGreeting_Lbl: Label 'Dear vendor', FRA = 'Cher fournisseur,';
    wanMailBody_Lbl: Label 'Please find enclosed an order, to which we kindly ask you to acknowledge receipt as soon as possible.', FRA = 'Veuillez trouver ci-joint une commande, à laquelle nous vous demandons de bien vouloir accuser réception dès que possible';
    wanMailClosing_Lbl: Label 'Sincerely', FRA = 'Bonne réception.';7
    */

    trigger OnPreReport()
    begin
        DocumentHelper.GetCompanyInfo(CompanyAddress, CompanyContactInfo, CompanyLegalInfo);
    end;

    local procedure GetMemo(pHeader: Record "Purchase Header"; pLine: Record "Purchase Line") ReturnValue: Text;
    var
        AttachedLines: Text;
        Item: Record Item;
    begin
        ReturnValue := pLine.Description;
        OnBeforeGetMemo(pHeader, pLine, ReturnValue);
        if pLine.Type = pLine.Type::Item then
            ReturnValue += DocumentHelper.ItemReferences(pLine."No.", pLine."Item Reference No.");
        AttachedLines := MemoPad.GetAttachedLines(pLine);
        if AttachedLines = '' then
            AttachedLines := MemoPad.GetExtendedText(pHeader, pLine);
        if AttachedLines <> '' then
            ReturnValue += MemoPad.LineFeed() + AttachedLines;
        OnAfterGetMemo(pHeader, pLine, ReturnValue);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetMemo(pHeader: Record "Purchase Header"; pLine: Record "Purchase Line"; var ReturnValue: Text)
    begin
    end;

    local procedure OnAfterGetMemo(pHeader: Record "Purchase Header"; pLine: Record "Purchase Line"; var ReturnValue: Text)
    begin
    end;
}