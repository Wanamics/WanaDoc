#if FALSE
namespace Wanamics.WanaDoc.Document;

using Microsoft.Sales.Reminder;
using System.Reflection;
using System.Globalization;
using Microsoft.Sales.Customer;
using Microsoft.Sales.FinanceCharge;
using System.Text;

codeunit 87305 "WanaDoc Reminder Events"
{
    [EventSubscriber(ObjectType::Report, report::Reminder, OnLetterTextOnPreDataItemOnAfterSetAmtDueTxt, '', false, false)]
    local procedure OnLetterTextOnPreDataItemOnAfterSetAmtDueTxt(var IssuedReminderHeader: Record "Issued Reminder Header"; var AmtDueTxt: Text)
    var
        ReminderEmailText: Record "Reminder Email Text";
        TypeHelper: Codeunit "Type Helper";
    begin
        ReminderEmailText.SetAutoCalcFields("Body Text");
        if GetReminderEmailText(IssuedReminderHeader, ReminderEmailText) then begin
            AmtDueTxt := ReminderEmailText.GetBodyText();
            SubstituteRelatedValues(AmtDueTxt, IssuedReminderHeader, IssuedReminderHeader.CalculateTotalIncludingVAT(), CopyStr(CompanyName, 1, 100));
            AmtDueTxt := TypeHelper.HtmlDecode(AmtDueTxt);
        end;
    end;

    // Copy from codeunit 1890 "Reminder Communication"
    local procedure GetReminderEmailText(var IssuedReminderHeader: Record "Issued Reminder Header"; var ReminderEmailText: Record "Reminder Email Text"): Boolean
    var
        ReminderLevel: Record "Reminder Level";
        ReminderTerms: Record "Reminder Terms";
        LanguageCode: Code[10];
        ReminderLevelNotFoundErr: Label 'Reminder Level %1 on Reminder Term %2 was not found.', Comment = '%1 = Reminder Level No., %2 = Reminder Term Code';
        ReminderTermNotFoundErr: Label 'Reminder Term %1 was not found.', Comment = '%1 = Reminder Term Code';

    begin
        if (IssuedReminderHeader."Reminder Level" = 0) or (IssuedReminderHeader."Reminder Terms Code" = '') then
            exit(false);

        if not ReminderLevel.Get(IssuedReminderHeader."Reminder Terms Code", IssuedReminderHeader."Reminder Level") then
            Error(ReminderLevelNotFoundErr, IssuedReminderHeader."Reminder Level", IssuedReminderHeader."Reminder Terms Code");

        LanguageCode := GetCustomerLanguageOrDefaultUserLanguage(IssuedReminderHeader."Customer No.");
        if ReminderEmailText.Get(ReminderLevel."Reminder Email Text", LanguageCode) then
            exit(true);

        if not ReminderTerms.Get(IssuedReminderHeader."Reminder Terms Code") then
            Error(ReminderTermNotFoundErr, IssuedReminderHeader."Reminder Terms Code");

        if ReminderEmailText.Get(ReminderTerms."Reminder Email Text", LanguageCode) then
            exit(true);

        exit(false);
    end;
    //Copy from codeunit 1890 "Reminder Communication"
    local procedure GetCustomerLanguageOrDefaultUserLanguage(CustomerNo: Code[20]): Code[10]
    var
        Customer: Record Customer;
        Language: Codeunit Language;
        LanguageCode: Code[10];
    begin
        if Customer.Get(CustomerNo) then
            LanguageCode := Customer."Language Code";

        if LanguageCode = '' then
            LanguageCode := Language.GetUserLanguageCode();

        if LanguageCode = '' then
            LanguageCode := Language.GetLanguageCode(Language.GetDefaultApplicationLanguageId());

        exit(LanguageCode);
    end;

    //Copy from codeunit 1890 "Reminder Communication"
    local procedure SubstituteRelatedValues(var BodyTxt: Text; var IssuedReminderHeader: Record "Issued Reminder Header"; NNC_TotalInclVAT: Decimal; CompanyName: Text[100])
    var
        FinanceChargeTerms: Record "Finance Charge Terms";
        AutoFormat: Codeunit "Auto Format";
        AutoFormatType: Enum "Auto Format";
    begin
        if IssuedReminderHeader."Fin. Charge Terms Code" <> '' then
            FinanceChargeTerms.Get(IssuedReminderHeader."Fin. Charge Terms Code");

        BodyTxt := StrSubstNo(
            BodyTxt,
            IssuedReminderHeader."Document Date",
            IssuedReminderHeader."Due Date",
            FinanceChargeTerms."Interest Rate",
            Format(IssuedReminderHeader."Remaining Amount", 0,
                AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, IssuedReminderHeader."Currency Code")),
            IssuedReminderHeader."Interest Amount",
            IssuedReminderHeader."Additional Fee",
            Format(NNC_TotalInclVAT, 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, IssuedReminderHeader."Currency Code")),
            IssuedReminderHeader."Reminder Level",
            IssuedReminderHeader."Currency Code",
            IssuedReminderHeader."Posting Date",
            CompanyName,
            IssuedReminderHeader."Add. Fee per Line");
    end;
}
#endif