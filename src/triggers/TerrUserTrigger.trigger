trigger TerrUserTrigger on TerrUser__c (
		before insert, 
		before update, 
		before delete, 
		after insert, 
		after update, 
		after delete, 
		after undelete) {

  new TerrUserTriggerHandler().run();

}