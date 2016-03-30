public class TerritoryTriggerHandler {

	public TerritoryTriggerHandler() {}
    
    public void beforeInsert(List<Territory__c> triggerNew) {
        //Create two Maps <FieldId, sObject> for fields "Territory" and "User"
        //and check them for uniqueness
        TerritoryUtils.checkFieldsForUniquenessIfInsert(true, triggerNew, null);
    }

    public void beforeUpdate(List<Territory__c> triggerNew, Map<Id, Territory__c> oldMap) {
        //Create two Maps <FieldId, sObject> for fields "Territory" and "User"
        //and check them for uniqueness
        TerritoryUtils.checkFieldsForUniquenessIfInsert(false, triggerNew, oldMap);
    }
     
    //Helpers
}