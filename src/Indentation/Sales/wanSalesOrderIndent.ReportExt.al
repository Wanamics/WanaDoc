namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Sales.Document;
using Wanamics.WanaDoc.MemoPad;
using System.Text;
reportextension 87313 "wan Sales Order Indent." extends "Standard Sales - Order Conf."
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
                            SetTotalAmounts(wanTotalLines["wan Indentation"], wanTotalLineAmount);
                        end;
                    "wan Indentation" > 0:
                        begin
                            for i := "wan Indentation" to ArrayLen(wanTotalLines) do begin
                                // wanTotalLines[i]."Order Amount" += "Order Amount"; // for Invoice and CreditMemo
                                wanTotalLines[i]."Line Amount" += "Line Amount";
                                wanTotalLines[i]."Prepmt. Line Amount" += "Prepmt. Line Amount";
                                wanTotalLines[i]."Prepmt. Amt. Inv." += "Prepmt. Amt. Inv.";
                            end;
                        end;
                end;
            end;
        }
        add(Line)
        {
            column(wanTitleMemoPad; wanTitleLineMemo) { }
            column(wanTotalMemoPad; wanTotalLineMemo) { }
            column(wanTotalLineAmount; wanTotalLineAmount) { }
        }
    }
    local procedure SetTotalAmounts(var pTotalLine: Record "Sales Line"; var pTotalLineAmount: Text);
    var
        AutoFormat: Codeunit "Auto Format";
        AutoFormatType: Enum "Auto Format";
    begin
        if pTotalLine."Line Amount" <> 0 then
            pTotalLineAmount := Format(pTotalLine."Line Amount", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, pTotalLine."Currency Code"));
        // if pTotalLine."Prepmt. Line Amount" <> 0 then
        //     pTotalPrepmtLineAmount := Format(pTotalLine."Prepmt. Line Amount", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, pTotalLine."Currency Code"));
        // if pTotalLine."Prepmt. Amt. Inv." <> 0 then
        //     pTotalPrepmtAmtInvLineAmount := Format(pTotalLine."Prepmt. Amt. Inv.", 0, AutoFormat.ResolveAutoFormat(AutoFormatType::AmountFormat, pTotalLine."Currency Code"));
    end;

    var
        wanTotalLines: array[10] of Record "Sales Line" temporary;
        wanTitleLineMemo: Text;
        wanTotalLineMemo: Text;
        wanTotalLineAmount: Text;
    // wanTotalPrepmtLineAmount: Text;
    // wanpTotalPrepmtAmtInvLineAmount: Text;
}
