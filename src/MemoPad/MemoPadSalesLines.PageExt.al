// Warning Multi-Objects
namespace Wanamics.WanaDoc.MemoPad;

using Microsoft.Sales.Document;
using Microsoft.Foundation.ExtendedText;
using Wanamics.WanaDoc.Excel;
pageextension 87346 "wan Sales Order MemoPad" extends "Sales Order Subform"
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
pageextension 87347 "wan Sales Invoice MemoPad" extends "Sales Invoice Subform"
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
pageextension 87395 "wan Sales Quote MemoPad" extends "Sales Quote Subform"
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
pageextension 87396 "wan Sales Cr.Memo MemoPad" extends "Sales Cr. Memo Subform"
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
pageextension 87308 "wan Blanket Sales Order MemoP." extends "Blanket Sales Order Subform"
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