// Warning Multi-Objects
namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Purchases.Document;
using Wanamics.WanaDoc.Excel;
using Microsoft.Foundation.ExtendedText;
pageextension 87321 "wan Purchase Order MemoPad" extends "Purchase Order Subform"
{
    actions
    {
        addlast(processing)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                Caption = 'MemoPad';
                Ellipsis = true;
                Image = Text;

                trigger OnAction()
                begin
                    if Rec.wanMemoPad(true) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}
pageextension 87322 "wan Purch. Invoice MemoPad" extends "Purch. Invoice Subform"
{
    actions
    {
        addlast(processing)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                Caption = 'MemoPad';
                Ellipsis = true;
                Image = Text;

                trigger OnAction()
                begin
                    if Rec.wanMemoPad(true) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}
pageextension 87323 "wan Purch. Quote MemoPad" extends "Purchase Quote Subform"
{
    actions
    {
        addlast(processing)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                Caption = 'MemoPad';
                Ellipsis = true;
                Image = Text;

                trigger OnAction()
                begin
                    if Rec.wanMemoPad(true) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}
pageextension 87324 "wan Purch. Cr. Memo MemoPad" extends "Purch. Cr. Memo Subform"
{
    actions
    {
        addlast(processing)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                Caption = 'MemoPad';
                Ellipsis = true;
                Image = Text;

                trigger OnAction()
                begin
                    if Rec.wanMemoPad(true) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}
pageextension 87325 "wan Blank. Purch. Order MemoP." extends "Blanket Purchase Order Subform"
{
    actions
    {
        addlast(processing)
        {
            action(wanMemoPad)
            {
                ApplicationArea = All;
                Caption = 'MemoPad';
                Ellipsis = true;
                Image = Text;

                trigger OnAction()
                begin
                    if Rec.wanMemoPad(true) then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}