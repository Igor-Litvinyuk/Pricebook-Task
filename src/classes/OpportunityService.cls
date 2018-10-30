/**
 * Created by Igor Litvinyuk on 22.10.2018.
 */

public with sharing class OpportunityService {

    public void changeCurrencyIsoCode(List<Opportunity> opportunities) {
        for (Opportunity opportunity : opportunities) {
            opportunity.CurrencyIsoCode = opportunity.Custom_Currency__c;
        }
    }

    public void changeRelatedOpportunityLineItems(List<Opportunity> oldOpportunities, List<Opportunity> newOpportunities) {
        List<Opportunity> opportunitiesWithChangedCurrency = getOpportunitiesWithChangedCurrency(oldOpportunities, newOpportunities);
        if (!opportunitiesWithChangedCurrency.isEmpty()) {
            List<Opportunity> opportunities = createNewOpportunityList(opportunitiesWithChangedCurrency);
            List<OpportunityLineItem> opportunityLineItems = getRelatedOpportunityLineItems(opportunities);
            delete opportunityLineItems;
            updateCurrencyIsoCode(opportunities);
            List<PricebookEntry> pricebookEntries = getPricebookEntries(opportunityLineItems);
            Map<String, Id> pricebookEntriesIdsByIdentifier = getPricebookEntriesIdsByOppLineItemsIds(pricebookEntries);
            List<OpportunityLineItem> newOpportunityLineItems = createNewOpportunityLineItemsList(opportunityLineItems, pricebookEntriesIdsByIdentifier);
            insert newOpportunityLineItems;
        }
    }

    private List<Opportunity> getOpportunitiesWithChangedCurrency(List<Opportunity> oldOpportunities, List<Opportunity> newOpportunities) {
        List<Opportunity> result = new List<Opportunity>();
        for (Integer i = 0; i < oldOpportunities.size(); i++) {
            if (oldOpportunities[i].Custom_Currency__c != newOpportunities[i].Custom_Currency__c) {
                result.add(newOpportunities[i]);
            }
        }
        return result;
    }

    private List<Opportunity> createNewOpportunityList(List<Opportunity> opportunities) {
        List<Opportunity> result = new List<Opportunity>();
        for (Opportunity opportunity : opportunities) {
            Opportunity newOpportunity = new Opportunity();
            newOpportunity.Id = opportunity.Id;
            newOpportunity.CurrencyIsoCode = opportunity.CurrencyIsoCode;
            newOpportunity.Custom_Currency__c = opportunity.Custom_Currency__c;
            newOpportunity.Pricebook2Id = opportunity.Pricebook2Id;
            result.add(newOpportunity);
        }
        return result;
    }

    private List<OpportunityLineItem> getRelatedOpportunityLineItems(List<Opportunity> opportunities) {
        return [
                SELECT
                        OpportunityId
                        , Quantity
                        , UnitPrice
                        , Product2Id
                        , Opportunity.Pricebook2Id
                        , Opportunity.Custom_Currency__c
                FROM OpportunityLineItem
                WHERE OpportunityId IN :opportunities
        ];
    }

    private void updateCurrencyIsoCode(List<Opportunity> opportunities) {
        changeCurrencyIsoCode(opportunities);
        update opportunities;
    }

    private List<PricebookEntry> getPricebookEntries(List<OpportunityLineItem> opportunityLineItems) {
        Set<Id> product2Ids = new Set<Id>();
        Set<Id> pricebook2Ids = new Set<Id>();
        Set<String> currencyIsoCodes = new Set<String>();
        for (OpportunityLineItem opportunityLineItem : opportunityLineItems) {
            product2Ids.add(opportunityLineItem.Product2Id);
            pricebook2Ids.add(opportunityLineItem.Opportunity.Pricebook2Id);
            currencyIsoCodes.add(opportunityLineItem.Opportunity.Custom_Currency__c);
        }
        List<PricebookEntry> pricebookEntries = [
                SELECT
                        Pricebook2Id
                        , CurrencyIsoCode
                        , Product2Id
                FROM PricebookEntry
                WHERE Product2Id IN :product2Ids
                AND Pricebook2Id IN :pricebook2Ids
                AND CurrencyIsoCode IN :currencyIsoCodes
        ];
        return pricebookEntries;
    }

    private Map<String, Id> getPricebookEntriesIdsByOppLineItemsIds(List<PricebookEntry> pricebookEntries) {
        Map<String, Id> resultMap = new Map<String, Id>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            resultMap.put(pricebookEntry.Pricebook2Id + pricebookEntry.CurrencyIsoCode + pricebookEntry.Product2Id, pricebookEntry.Id);
        }
        return resultMap;
    }

    private List<OpportunityLineItem> createNewOpportunityLineItemsList(List<OpportunityLineItem> opportunityLineItems, Map<String, Id> pricebookEntriesIdsByIdentifier) {
        List<OpportunityLineItem> result = new List<OpportunityLineItem>();
        for (OpportunityLineItem opportunityLineItem : opportunityLineItems) {
            OpportunityLineItem newOpportunityLineItem = new OpportunityLineItem();
            newOpportunityLineItem.OpportunityId = opportunityLineItem.OpportunityId;
            newOpportunityLineItem.Quantity = opportunityLineItem.Quantity;
            newOpportunityLineItem.UnitPrice = opportunityLineItem.UnitPrice;
            newOpportunityLineItem.PricebookEntryId = pricebookEntriesIdsByIdentifier.get(opportunityLineItem.Opportunity.Pricebook2Id
                    + opportunityLineItem.Opportunity.Custom_Currency__c + opportunityLineItem.Product2Id);
            result.add(newOpportunityLineItem);
        }
        return result;
    }
}