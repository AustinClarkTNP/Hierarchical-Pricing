codeunit 50100 "Hierarchical Price Calc.TNP"
{
    local procedure SetHierarchicalSourceList(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var PriceSourceList: Codeunit "Price Source List")
    begin
        PriceSourceList.Init();
        PriceSourceList.Add("Price Source Type"::"All Customers"); // "All Customers" will have lowest priority
        PriceSourceList.IncLevel();
        PriceSourceList.Add("Price Source Type"::"Customer Price Group", SalesLine."Customer Price Group");
        PriceSourceList.Add("Price Source Type"::"Customer Disc. Group", SalesLine."Customer Disc. Group");
        PriceSourceList.IncLevel();
        PriceSourceList.Add("Price Source Type"::Customer, SalesHeader."Bill-to Customer No.");
        PriceSourceList.IncLevel();
        PriceSourceList.Add("Price Source Type"::Customer, SalesHeader."Sell-to Customer No.");
        PriceSourceList.IncLevel();
        PriceSourceList.Add("Price Source Type"::Campaign, SalesHeader."Campaign No."); //Campaign will have the highest priority 
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Price Calculation Mgt.", 'OnFindSupportedSetup', '', false, false)]
    local procedure OnFindSupportedSetup(var TempPriceCalculationSetup: Record "Price Calculation Setup")
    begin
        TempPriceCalculationSetup.Init();
        TempPriceCalculationSetup.Method := TempPriceCalculationSetup.Method::Hierarchical;
        TempPriceCalculationSetup.Enabled := true;
        TempPriceCalculationSetup.Type := TempPriceCalculationSetup.Type::Sale;
        TempPriceCalculationSetup."Asset Type" := TempPriceCalculationSetup."Asset Type"::" ";
        TempPriceCalculationSetup.Validate(Implementation, TempPriceCalculationSetup.Implementation::"Business Central (Version 16.0)");
        TempPriceCalculationSetup.Default := true;
        TempPriceCalculationSetup.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Line - Price", 'OnAfterAddSources', '', false, false)]
    local procedure OnAfterAddSources(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; PriceType: Enum "Price Type"; var PriceSourceList: Codeunit "Price Source List")
    begin
        if SalesLine."Price Calculation Method" = "Price Calculation Method"::Hierarchical then
            SetHierarchicalSourceList(SalesHeader, SalesLine, PriceSourceList);
    end;

}
