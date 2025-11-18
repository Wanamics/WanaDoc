namespace Wanamics.WanaProj.BlkOrderLines;

using Microsoft.Sales.Document;
tableextension 87390 "wan Sales Header BlkOrder" extends "Sales Header"
{
    fields
    {
        field(87390; "wan Blanket Order No."; Code[20])
        {
            Caption = 'Blanket Order No.';
            DataClassification = ToBeClassified;
            TableRelation = "Sales Header"."No." where("Document Type" = const("Blanket Order"));
            trigger OnLookup()
            var
                BlanketOrder: Record "Sales Header";
            begin
                BlanketOrder.SetRange("Document type", BlanketOrder."Document Type"::"Blanket Order");
                BlanketOrder.SetRange("Bill-to Customer No.", Rec."Bill-to Customer No.");
                if Page.RunModal(Page::"wan Sales BlkOrder Lookup", BlanketOrder) = Action::LookupOK then
                    Rec."wan Blanket Order No." := BlanketOrder."No.";
            end;
        }
    }
}
