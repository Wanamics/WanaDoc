codeunit 87302 "wan Sales Pro Forma Inv."
{
[EventSubscriber(ObjectType::Report, Report::"Standard Sales - Pro Forma Inv", 'OnAfterLineOnPreDataItem', '', false, false)]
    local procedure OnAfterLineOnPreDataItem(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SalesLine.SetRange(Type); // Reset SetRange(Type, Type::Item)
    end;
[EventSubscriber(ObjectType::Report, Report::"Standard Sales - Pro Forma Inv", 'OnBeforeGetItemForRec', '', false, false)]
    local procedure OnBeforeGetItemForRec(ItemNo: Code[20]; var IsHandled: Boolean)
    var
        Item : Record Item;
    begin
        // Unfortunately, SalesLine is not a parm
        if not Item.Get(ItemNo) then
            IsHandled := true;
    end;
/*
[EventSubscriber(ObjectType::Report, Report::"Standard Sales - Pro Forma Inv", 'OnBeforeLineOnAfterGetRecord', '', false, false)]
    local procedure OnBeforeLineOnAfterGetRecord(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;
*/
}
