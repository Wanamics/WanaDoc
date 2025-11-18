namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Sales.History;
using Wanamics.WanaDoc.MemoPad;
using System.Text;
reportextension 87311 "wan Sales Invoice Indent" extends "Standard Sales - Invoice"
{
    dataset
    {
        modify(Line)
        {
            trigger OnAfterAfterGetRecord()
            var
                IndentHelper: Codeunit "wan Indent Helper";
                i: Integer;
            begin
                IndentHelper.Indent(wanMemo, "wan Indentation");
                wanTitleLineMemo := '';
                wanTotalLineMemo := '';
                wanTotalOrderLineAmount := '';
                wanTotalPrepmtLineAmount := '';
                wanTotalPrepmtAmtInvLineAmount := '';
                wanTotalLineAmount := '';
                case true of
                    wanIsTitle():
                        begin
                            wanTitleLineMemo := wanMemo;
                            wanMemo := '';
                            Clear(wanColumn);
                            for i := "wan Indentation" + 1 to ArrayLen(wanTotalLines) do
                                wanTotalLines[i].Init();
                        end;
                    wanIsTotal():
                        begin
                            wanTotalLineMemo := wanMemo;
                            wanMemo := '';
                            Clear(wanColumn);
                            wanTotalOrderLineAmount := DocumentHelper.BlankZero(wanTotalLines["wan Indentation"]."wan Order Amount", wanAutoFormat::AmountFormat, Header."Currency Code");
                            wanTotalPrepmtLineAmount := DocumentHelper.BlankZero(wanTotalLines["wan Indentation"]."wan Prepmt. Line Amount", wanAutoFormat::AmountFormat, Header."Currency Code");
                            wanTotalPrepmtAmtInvLineAmount := DocumentHelper.BlankZero(wanTotalLines["wan Indentation"]."wan Prepmt. Amt. Inv.", wanAutoFormat::AmountFormat, Header."Currency Code");
                            wanTotalLineAmount := DocumentHelper.BlankZero(wanTotalLines["wan Indentation"]."Line Amount", wanAutoFormat::AmountFormat, Header."Currency Code");
                        end;
                    "wan Indentation" > 0:
                        begin
                            for i := "wan Indentation" to ArrayLen(wanTotalLines) do begin
                                wanTotalLines[i]."wan Order Amount" += "wan Order Amount"; // for Invoice and CreditMemo
                                wanTotalLines[i]."wan Prepmt. Line Amount" += "wan Prepmt. Line Amount";
                                wanTotalLines[i]."wan Prepmt. Amt. Inv." += "wan Prepmt. Amt. Inv.";
                                wanTotalLines[i]."Line Amount" += "Line Amount";
                            end;
                        end;
                end;
            end;
        }
        add(line)
        {
            column(wanTitleMemoPad; wanTitleLineMemo) { }
            column(wanTotalMemoPad; wanTotalLineMemo) { }
            column(wanTotalOrderLineAmount; wanTotalOrderLineAmount) { }
            column(wanTotalPrepmtLineAmount; wanTotalPrepmtLineAmount) { }
            column(wanTotalPrepmtAmtInvLineAmount; wanTotalPrepmtAmtInvLineAmount) { }
            column(wanTotalLineAmount; wanTotalLineAmount) { }
        }
    }
    // local procedure SetTotalAmounts(var pTotalLine: Record "Sales Invoice Line"; var pTotalOrderLineAmount: Text; var pTotalPrepmtLineAmount: Text; var pTotalPrepmtAmtInvLineAmount: Text; var pTotalLineAmount: Text);
    // var
    //     AutoFormat: Codeunit "Auto Format";
    // // AutoFormatType: Enum "Auto Format";
    // begin
    //     // if pTotalLine."wan Order Amount" <> 0 then
    //     //     pTotalOrderLineAmount := Format(pTotalLine."wan Order Amount", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, pTotalLine.GetCurrencyCode())) + MemoPad.LineFeed + pTotalLine."Unit of Measure";
    //     // if pTotalLine."wan Prepmt. Line Amount" <> 0 then
    //     //     pTotalPrepmtLineAmount := Format(pTotalLine."wan Prepmt. Line Amount", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, pTotalLine.GetCurrencyCode())) + MemoPad.LineFeed + DocumentHelper.BlankZeroPercent(pTotalLine."wan Prepayment %");
    //     // if pTotalLine."wan Prepmt. Amt. Inv." <> 0 then
    //     //     pTotalPrepmtAmtInvLineAmount := Format(pTotalLine."wan Prepmt. Amt. Inv.", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, pTotalLine.GetCurrencyCode()));
    //     // if pTotalLine."Line Amount" <> 0 then
    //     //     pTotalLineAmount := Format(pTotalLine."Line Amount", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, pTotalLine.GetCurrencyCode()));
    //     pTotalOrderLineAmount := DocumentHelper.BlankZero(pTotalLine."wan Order Amount", wanAutoFormat::AmountFormat, Header."Currency Code") + MemoPad.LineFeed + pTotalLine."Unit of Measure";
    //     pTotalPrepmtLineAmount := DocumentHelper.BlankZero(pTotalLine."wan Prepmt. Line Amount", wanAutoFormat::AmountFormat, Header."Currency Code") + MemoPad.LineFeed + DocumentHelper.BlankZeroPercent(pTotalLine."wan Prepayment %");
    //     pTotalPrepmtAmtInvLineAmount := DocumentHelper.BlankZero(pTotalLine."wan Prepmt. Amt. Inv.", wanAutoFormat::AmountFormat, Header."Currency Code");
    //     pTotalLineAmount := DocumentHelper.BlankZero(pTotalLine."Line Amount", wanAutoFormat::AmountFormat, Header."Currency Code");
    // end;

    var
        wanTotalLines: array[10] of Record "Sales Invoice Line" temporary;
        wanTitleLineMemo: Text;
        wanTotalLineMemo: Text;
        wanTotalOrderLineAmount: Text;
        wanTotalPrepmtLineAmount: Text;
        wanTotalPrepmtAmtInvLineAmount: Text;
        wanTotalLineAmount: Text;
}
