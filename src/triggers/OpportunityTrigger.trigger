/**
 * Created by Igor Litvinyuk on 22.10.2018.
 */

trigger OpportunityTrigger on Opportunity (before insert, after update) {

    OpportunityHandler handler = new OpportunityHandler();

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.onBeforeInsert(Trigger.new);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            handler.onAfterUpdate(Trigger.old, Trigger.new);
        }
    }
}