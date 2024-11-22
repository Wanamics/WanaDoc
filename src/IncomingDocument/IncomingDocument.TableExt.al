namespace Wanamics.WanaDoc.IncomingDocument;

using Microsoft.EServices.EDocument;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Bank.BankAccount;
using Microsoft.Purchases.Vendor;

tableextension 87306 "wan Incoming Document" extends "Incoming Document"
{
    fields
    {
        modify("Vendor No.")
        {
            trigger OnAfterValidate()
            var
                VendorBankAccount: Record "Vendor Bank Account";
            begin
                if "Vendor No." = '' then
                    exit;
                Vendor.Get("Vendor No.");
                "Vendor Name" := Vendor.Name;
                "Vendor VAT Registration No." := Vendor."VAT Registration No.";
                if Vendor."Preferred Bank Account Code" <> '' then
                    if VendorBankAccount.Get("Vendor No.", Vendor."Preferred Bank Account Code") then
                        "Vendor IBAN" := VendorBankAccount.IBAN;
            end;
        }
        modify("Document Date")
        {
            trigger OnAfterValidate()
            var
                PaymentTerms: Record "Payment Terms";
            begin
                if Vendor.Get("Vendor No.") and PaymentTerms.Get(Vendor."Payment Terms Code") then
                    "Due Date" := CalcDate(PaymentTerms."Due Date Calculation", "Document Date");
            end;
        }
        modify("Amount Incl. VAT")
        {
            BlankZero = true;
            trigger OnAfterValidate()
            begin
                // if CurrFieldNo = FieldNo("Amount Incl. VAT") then
                if "Amount Excl. VAT" <> 0 then
                    "VAT Amount" := "Amount Incl. VAT" - "Amount Excl. VAT";
            end;
        }
        modify("Amount Excl. VAT")
        {
            BlankZero = true;
            trigger OnAfterValidate()
            begin
                if "Amount Incl. VAT" <> 0 then
                    "VAT Amount" := "Amount Incl. VAT" - "Amount Excl. VAT";
            end;
        }
        modify("VAT Amount")
        {
            BlankZero = true;
            trigger OnAfterValidate()
            begin
                if "Amount Incl. VAT" <> 0 then
                    "Amount Excl. VAT" := "Amount Incl. VAT" - "VAT Amount";
            end;
        }
        field(87300; "Wan Payment Method Code"; Code[20])
        {
            Caption = 'Payment Method Code';
            FieldClass = FlowField;
            TableRelation = "Payment Method";
            CalcFormula = lookup(Vendor."Payment Method Code" where("No." = field("Vendor No.")));
        }
    }
    var
        Vendor: Record Vendor;

}
