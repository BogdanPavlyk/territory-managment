public class TerritoryUtils {

	public static void checkFieldsForUniquenessIfInsert(Boolean isInsert, List<Territory__c> triggerNew, Map<Id, Territory__c> oldMap) {

        Map<Id, Territory__c> territoryParents = new Map<Id, Territory__c>();
        Map<String, Territory__c> territoryNames = new Map<String, Territory__c>();

        for(Territory__c territory :  triggerNew) {
                        
            if(territory.Name == null) {
                territory.Name.addError(Label.User_field_is_blank_warning);
            } else if( isInsert){

                if(! territoryParents.containsKey(territory.Parent_Territory__c)) {
                    territoryParents.put(territory.Parent_Territory__c, territory);           
                } else {
                    territory.Parent_Territory__c.addError(Label.Territory_and_User_pair_uniqueness);
                }   

                if(! territoryNames.containsKey(territory.Name)) {
                    territoryNames.put(territory.Name, territory);           
                } else {
                    territory.Name.addError(Label.Territory_and_User_pair_uniqueness);
                }

            } else {

                if (territory.Name != oldMap.get(territory.Id).Name) {
                    territoryNames.put(territory.Name, territory);
                }

                if (territory.Parent_Territory__c != oldMap.get(territory.Id).Parent_Territory__c) {
                    territoryNames.put(territory.Parent_Territory__c, territory);
                }
            }    
        }

        addUniquenessErrors(territoryParents, territoryNames);
    }
    
    public static void addUniquenessErrors(   Map<Id, Territory__c> territoryParents,
                                                    Map<String, Territory__c> territoryNames          ) {

        for (Territory__c territory : [
                                    SELECT Parent_Territory__c, Name
                                    FROM Territory__c
                                    WHERE Parent_Territory__c IN :territoryParents.KeySet() AND Name IN :territoryNames.KeySet()
                                 ]){

            Territory__c newterritory = territoryParents.get(territory.Parent_Territory__c);
            newterritory.Parent_Territory__c.addError(Label.Territory_and_User_pair_uniqueness);
            newterritory.Name.addError(     Label.Territory_and_User_pair_uniqueness);

        }
    }
}