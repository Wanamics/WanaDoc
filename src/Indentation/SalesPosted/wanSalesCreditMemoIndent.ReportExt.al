namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Sales.History;
using System.Text;
using Wanamics.WanaDoc.MemoPad;
reportextension 87312 "wan Sales Credit Memo Indent." extends "Standard Sales - Credit Memo"
{
    dataset
    {
        modify(Line)
        {
            trigger OnAfterAfterGetRecord()
            var
                MemoPadManagement: Codeunit "wan MemoPad Management";
                i: Integer;
            begin
                MemoPadManagement.Indent(wanMemo, "wan Indentation");
                wanTitleLineMemo := '';
                wanTotalLineMemo := '';
                wanTotalLineAmount := '';
                case true of
                    wanIsTitle():
                        begin
                            wanTitleLineMemo := wanMemo;
                            wanMemo := '';
                            for i := "wan Indentation" + 1 to ArrayLen(wanTotalLines) do
                                wanTotalLines[i].Init();
                        end;
                    wanIsTotal():
                        begin
                            wanTotalLineMemo := wanMemo;
                            wanMemo := '';
                            SetTotalAmounts(wanTotalLines["wan Indentation"], wanTotalLineAmount, wanTotalPrepmtLineAmount, wanTotalPrepmtAmtInvLineAmount);
                        end;
                    "wan Indentation" > 0:
                        begin
                            for i := "wan Indentation" to ArrayLen(wanTotalLines) do begin
                                wanTotalLines[i]."wan Order Amount" += "wan Order Amount"; // for Invoice and CreditMemo
                                wanTotalLines[i]."Line Amount" += "Line Amount";
                                wanTotalLines[i]."wan Prepmt. Line Amount" += "wan Prepmt. Line Amount";
                                wanTotalLines[i]."wan Prepmt. Amt. Inv." += "wan Prepmt. Amt. Inv.";
                            end;
                        end;
                end;
            end;
        }
        add(line)
        {
            column(wanTitleMemoPad; wanTitleLineMemo) { }
            column(wanTotalMemoPad; wanTotalLineMemo) { }
            column(wanTotalLineAmount; wanTotalLineAmount) { }
            column(wanTotalPrepmtLineAmount; wanTotalPrepmtLineAmount) { }
            column(wanTotalPrepmtAmtInvLineAmount; wanTotalPrepmtAmtInvLineAmount) { }
        }
    }
    local procedure SetTotalAmounts(var pTotalLine: Record "Sales Cr.Memo Line"; var pTotalLineAmount: Text; var pTotalPrepmtLineAmount: Text; var pTotalPrepmtAmtInvLineAmount: Text);
    var
        AutoFormat: Codeunit "Auto Format";
        AutoFormatType: Enum "Auto Format";
    begin
        if pTotalLine."Line Amount" <> 0 then
            pTotalLineAmount := Format(pTotalLine."Line Amount", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, pTotalLine.GetCurrencyCode()));
        if pTotalLine."wan Prepmt. Line Amount" <> 0 then
            pTotalPrepmtLineAmount := Format(pTotalLine."wan Prepmt. Line Amount", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, pTotalLine.GetCurrencyCode()));
        if pTotalLine."wan Prepmt. Amt. Inv." <> 0 then
            pTotalPrepmtAmtInvLineAmount := Format(pTotalLine."wan Prepmt. Amt. Inv.", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, pTotalLine.GetCurrencyCode()));
    end;

    var
        wanTotalLines: array[10] of Record "Sales Cr.Memo Line" temporary;
        wanTitleLineMemo: Text;
        wanTotalLineMemo: Text;
        wanTotalLineAmount: Text;
        wanTotalPrepmtLineAmount: Text;
        wanTotalPrepmtAmtInvLineAmount: Text;
}
