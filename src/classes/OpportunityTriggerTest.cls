/**
 * Created by Igor Litvinyuk on 22.10.2018.
 */

@isTest
private class OpportunityTriggerTest {

    @isTest
    static void testInsertNewOpportunitiesWithAnotherCustomCurrencyField() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 300; i++) {
            if (i < 100){
                Opportunity opportunity = new Opportunity(Name = 'Test Opportunity ' + i, CurrencyIsoCode = 'EUR', Custom_Currency__c = 'UAH', CloseDate = System.today(), StageName = 'Prospecting');
                opportunities.add(opportunity);
            }
            else if (i < 200){
                Opportunity opportunity = new Opportunity(Name = 'Test Opportunity ' + i, CurrencyIsoCode = 'EUR', Custom_Currency__c = 'USD', CloseDate = System.today(), StageName = 'Prospecting');
                opportunities.add(opportunity);
            }
            else {
                Opportunity opportunity = new Opportunity(Name = 'Test Opportunity ' + i, CurrencyIsoCode = 'EUR', Custom_Currency__c = 'EUR', CloseDate = System.today(), StageName = 'Prospecting');
                opportunities.add(opportunity);
            }
        }
        Test.startTest();
        insert opportunities;
        Test.stopTest();
        List<Opportunity> verifyOpportunitiesWithCurrencyIsoCodeFieldUAH = [SELECT CurrencyIsoCode FROM Opportunity WHERE CurrencyIsoCode = 'UAH'];
        List<Opportunity> verifyOpportunitiesWithCurrencyIsoCodeFieldUSD = [SELECT CurrencyIsoCode FROM Opportunity WHERE CurrencyIsoCode = 'USD'];
        List<Opportunity> verifyOpportunitiesWithCurrencyIsoCodeFieldEUR = [SELECT CurrencyIsoCode FROM Opportunity WHERE CurrencyIsoCode = 'EUR'];
        System.assertEquals(100, verifyOpportunitiesWithCurrencyIsoCodeFieldUAH.size());
        System.assertEquals(100, verifyOpportunitiesWithCurrencyIsoCodeFieldUSD.size());
        System.assertEquals(100, verifyOpportunitiesWithCurrencyIsoCodeFieldEUR.size());
    }

    @isTest
    static void testUpdateOpportunitiesWithAnotherCustomCurrencyField() {
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Opportunity> opportunitiesForUpdate = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            Opportunity opportunity = new Opportunity(Name = 'Test Opportunity ' + i, CurrencyIsoCode = 'EUR', Custom_Currency__c = 'UAH', CloseDate = System.today(), StageName = 'Prospecting');
        }
        insert opportunities;
        for (Opportunity opportunity : opportunities){
            opportunity.Custom_Currency__c = 'USD';
            opportunitiesForUpdate.add(opportunity);
        }
        Test.startTest();
        update opportunitiesForUpdate;
        Test.stopTest();
        List<Opportunity> verifyOpportunities = [SELECT CurrencyIsoCode FROM Opportunity];
        for (Opportunity opportunity : verifyOpportunities) {
            System.assertEquals('USD', opportunity.CurrencyIsoCode);
        }
    }
}