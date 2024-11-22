namespace Wanamics.WanaDoc.IncomingDocument;

using Microsoft.EServices.EDocument;
using Microsoft.Purchases.Vendor;

pageextension 87305 "wan Incoming Document" extends "Incoming Document"
{
    layout
    {
        modify(FinancialInformation) { Editable = not Rec.Posted; }
        modify("Vendor VAT Registration No.") { Importance = Additional; }
        modify("Vendor Bank Branch No.") { Importance = Additional; Visible = false; }
        modify("Vendor Bank Account No.") { Importance = Additional; Visible = false; }
        addbefore("Vendor IBAN")
        {
            field(_PaymentMethodCode; Rec."Wan Payment Method Code")
            {
                Caption = 'Payment Method Code';
                ApplicationArea = All;
                Importance = Additional;
            }
        }
        modify("Vendor IBAN") { Importance = Additional; }
        modify("Vendor Phone No.") { Importance = Additional; Visible = false; }
        modify("Currency Code") { Editable = true; Importance = Additional; }
        modify("Vendor Invoice No.") { Editable = true; }
        modify("Order No.") { Editable = true; Importance = Additional; }
        modify("Vendor No.") { Editable = true; }
        modify("Document Date") { Editable = true; }
        modify("Due Date") { Editable = true; }
        modify("Amount Excl. VAT") { Editable = true; Importance = Additional; }
        modify("VAT Amount") { Editable = true; Importance = Additional; }
        modify("Amount Incl. VAT") { Editable = true; }
        addafter("Vendor Invoice No.")
        {
            field(_Description; Rec.Description)
            {
                Caption = 'Description';
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            // action(_GenJournalLines)
            // {
            //     Caption = 'Journal Lines';
            //     ApplicationArea = All;
            //     Image = EditLines;
            //     trigger OnAction()
            //     var
            //         GenJournalLine: Record "Gen. Journal Line";
            //         IncomingDocumentsSetup: Record "Incoming Documents Setup";
            //         DeleteLinesMsg: Label 'Do you want to replace %1 line(s) in %2?';
            //     begin
            //         GenJournalLine.SetCurrentKey("Incoming Document Entry No.");
            //         GenJournalLine.SetRange("Incoming Document Entry No.", Rec."Entry No.");
            //         if not GenJournalLine.IsEmpty then
            //             if Confirm(DeleteLinesMsg, false, GenJournalLine.Count, GenJournalLine.TableCaption) then
            //                 GenJournalLine.DeleteAll(true);
            //         if GenJournalLine.IsEmpty then
            //             Codeunit.Run(Codeunit::"_Incoming Doc. to GenJnlLine", GenJournalLine);
            //         IncomingDocumentsSetup.Get();
            //         GenJournalLine.SetRange("Journal Template Name", IncomingDocumentsSetup."General Journal Template Name");
            //         GenJournalLine.SetRange("Journal Batch Name", IncomingDocumentsSetup."General Journal Batch Name");
            //         Page.RunModal(Page::"General Journal", GenJournalLine);
            //     end;
            // }
            action(_CreatePurchInvCrMemo)
            {
                Caption = 'Create Purch. Inv./Cr.Memo';
                ApplicationArea = All;
                Image = PurchaseInvoice;
                trigger OnAction()
                begin
                    Rec.TestField("Vendor No.");
                    Rec.TestField("Vendor Invoice No.");
                    Rec.TestField("Document Date");
                    Rec.TestField("Amount Incl. VAT");
                    if Rec."Amount Incl. VAT" < 0 then
                        Rec.CreatePurchCreditMemo()
                    else
                        Rec.CreatePurchInvoice();
                end;
            }
        }
        addfirst(Category_Process)
        {
            group(_Create)
            {
                Caption = 'Create';
                ShowAs = SplitButton;
                actionref(_CreatePurchInvoicePromoted; _CreatePurchInvCrMemo) { }
                actionref(_CreateManually_Promoted; CreateManually) { }
                actionref(_CreateDocument_Promoted; CreateDocument) { }
                actionref(_CreateGenJnlLine_Promoted; CreateGenJnlLine) { }
            }
        }
        modify(CreateManually_Promoted) { Visible = false; }
        modify(CreateDocument_Promoted) { Visible = false; }
        modify(CreateGenJnlLine_Promoted) { Visible = false; }
    }

    var
        Vendor: Record Vendor;

    trigger OnAfterGetRecord()
    begin
        if Rec."Vendor No." <> '' then
            Vendor.Get(Rec."Vendor No.");
    end;
}
