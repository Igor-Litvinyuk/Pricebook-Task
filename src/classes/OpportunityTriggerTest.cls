/**
 * Created by Igor Litvinyuk on 22.10.2018.
 */

@isTest
private class OpportunityTriggerTest {

    private static final Integer AMOUNT = 200;
    private static final List<String> CURRENCIES = new List<String>{'EUR', 'USD', 'UAH'};

    @isTest
    static void testUpdateOpportunitiesWithProducts() {
        Pricebook2 testPricebook = createPricebook('Test');
        List<Product2> products = createProducts();
        List<Opportunity> opportunities = createOpportunities(testPricebook.Id);
        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> standardPricebookEntriesEUR = createPricebookEntries(standardPricebookId, products, CURRENCIES[0]);
        List<PricebookEntry> standardPricebookEntriesUSD = createPricebookEntries(standardPricebookId, products, CURRENCIES[1]);
        List<PricebookEntry> testPricebookEntriesEUR = createPricebookEntries(testPricebook.Id, products, CURRENCIES[0]);
        List<PricebookEntry> testPricebookEntriesUSD = createPricebookEntries(testPricebook.Id, products, CURRENCIES[1]);
        List<PricebookEntry> pricebookEntriesEUR = getPricebookEntries(testPricebook.Id, CURRENCIES[0]);
        List<OpportunityLineItem> opportunityLineItems = createOpportunityLineItems(testPricebook.Id, products, opportunities, pricebookEntriesEUR);
        List<Opportunity> opportunitiesForUpdate = getOpportunitiesForUpdate(opportunities);
        Test.startTest();
        update opportunitiesForUpdate;
        Test.stopTest();
        List<PricebookEntry> pricebookEntriesUSD = getPricebookEntries(testPricebook.Id, CURRENCIES[1]);
        List<OpportunityLineItem> opportunityLineItemsAfterUpdate = getOpportunityLineItems();
        for (Integer i = 0; i < AMOUNT; i++){
            System.assertEquals(opportunityLineItemsAfterUpdate[i].PricebookEntryId, pricebookEntriesUSD[i].Id);
        }
    }

    private static Pricebook2 createPricebook(String pricebookName) {
        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = pricebookName;
        pricebook.isActive = true;
        insert pricebook;
        return pricebook;
    }

    private static List<Product2> createProducts() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < AMOUNT; i++) {
            Product2 product = new Product2();
            product.Name = 'Test Product' + i;
            products.add(product);
        }
        insert products;
        return products;
    }

    private static List<Opportunity> createOpportunities(Id pricebookId) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < AMOUNT; i++) {
            Opportunity opportunity = new Opportunity();
            opportunity.Name = 'Test Opportunity' + i;
            opportunity.CloseDate = System.today();
            opportunity.StageName = 'Prospecting';
            opportunity.Pricebook2Id = pricebookId;
            opportunity.Custom_Currency__c = CURRENCIES[0];
            opportunities.add(opportunity);
        }
        insert opportunities;
        return opportunities;
    }

    private static List<PricebookEntry> createPricebookEntries(Id pricebookId, List<Product2> products, String currencyIsoCode) {
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Integer i = 0; i < AMOUNT; i++) {
            PricebookEntry pricebookEntry = new PricebookEntry();
            pricebookEntry.Pricebook2Id = pricebookId;
            pricebookEntry.Product2Id = products[i].Id;
            pricebookEntry.CurrencyIsoCode = currencyIsoCode;
            pricebookEntry.UnitPrice = Math.random();
            pricebookEntry.isActive = true;
            pricebookEntries.add(pricebookEntry);
        }
        insert pricebookEntries;
        return pricebookEntries;
    }

    private static List<OpportunityLineItem> createOpportunityLineItems(Id pricebookId, List<Product2> products,
            List<Opportunity> opportunities, List<PricebookEntry> pricebookEntries) {
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for (Integer i = 0; i < AMOUNT; i++) {
            OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
            opportunityLineItem.OpportunityId = opportunities[i].Id;
            opportunityLineItem.Quantity = Math.random();
            opportunityLineItem.UnitPrice = pricebookEntries[i].UnitPrice;
            opportunityLineItem.PricebookEntryId = pricebookEntries[i].Id;
            opportunityLineItems.add(opportunityLineItem);
        }
        insert opportunityLineItems;
        return opportunityLineItems;
    }

    private static List<Opportunity> getOpportunitiesForUpdate(List<Opportunity> opportunities) {
        List<Opportunity> result = new List<Opportunity>();
        for (Opportunity opportunity : opportunities) {
            opportunity.Custom_Currency__c = 'USD';
            result.add(opportunity);
        }
        return result;
    }

    private static List<PricebookEntry> getPricebookEntries(Id pricebookId, String currencyIsoCode) {
        return [
                SELECT
                        Id
                        , UnitPrice
                FROM PricebookEntry
                WHERE CurrencyIsoCode =: currencyIsoCode
                AND Pricebook2Id =: pricebookId
                ORDER BY Id
        ];
    }

    private static List<OpportunityLineItem> getOpportunityLineItems() {
        return [
                SELECT
                        PricebookEntryId
                FROM OpportunityLineItem
                ORDER BY PricebookEntryId
        ];
    }
}