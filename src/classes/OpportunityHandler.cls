/**
 * Created by Igor Litvinyuk on 22.10.2018.
 */

public with sharing class OpportunityHandler {

    OpportunityService service = new OpportunityService();

    public void onBeforeInsert(List<Opportunity> newOpportunities) {
        service.changeCurrencyIsoCode(newOpportunities);
    }

    public void onAfterUpdate(List<Opportunity> oldOpportunities, List<Opportunity> newOpportunities) {
        service.changeRelatedOpportunityLineItems(oldOpportunities, newOpportunities);
    }
}