namespace WanaProj.WanaProj;

using Microsoft.Inventory.Item.Catalog;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Item;

codeunit 87390 "wan Sales BlkOrder Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Reference Management", OnAfterSalesItemItemRefNotFound, '', false, false)]
    local procedure OnAfterSalesItemItemRefNotFound(var SalesLine: Record "Sales Line"; var ItemVariant: Record "Item Variant"; SalesLineBeforeChanges: Record "Sales Line")
    begin
        SalesLine.Description := SalesLineBeforeChanges.Description;
        SalesLine."Description 2" := SalesLineBeforeChanges."Description 2";
    end;
}
