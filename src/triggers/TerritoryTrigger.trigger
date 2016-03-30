trigger TerritoryTrigger on Territory__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

 	//new TerritoryTriggerHandler().run();

 	if(Trigger.isBefore) {

 		if(Trigger.isInsert) {
 			new TerritoryTriggerHandler().beforeInsert(Trigger.new);
 		} else if(Trigger.isUpdate) {
 			new TerritoryTriggerHandler().beforeUpdate(Trigger.new, Trigger.oldMap);
 		}
 		
 	}
}