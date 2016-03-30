public class TerrUserUtils {

	public static void checkFieldsForUniquenessIfInsert(Boolean isInsert) {

        Map<Id, TerrUser__c> terrUserTerritories = new Map<Id, TerrUser__c>();
        Map<Id, TerrUser__c> terrUserUsers = new Map<Id, TerrUser__c>();

        for(TerrUser__c terrUser: (List<TerrUser__c>) Trigger.new) {
                        
            if(terrUser.User__c == null) {
                terrUser.User__c.addError(Label.User_field_is_blank_warning);
            } else if( isInsert){

                if(! terrUserTerritories.containsKey(terrUser.Territory__c)) {
                    terrUserTerritories.put(terrUser.Territory__c, terrUser);           
                } else {
                    terrUser.Territory__c.addError(Label.Territory_and_User_pair_uniqueness);
                }   

                if(! terrUserUsers.containsKey(terrUser.User__c)) {
                    terrUserUsers.put(terrUser.User__c, terrUser);           
                } else {
                    terrUser.User__c.addError(Label.Territory_and_User_pair_uniqueness);
                }

            } else {

                if (terrUser.User__c != ((Map<Id, TerrUser__c>)Trigger.oldMap).get(terrUser.Id).User__c) {
                    terrUserUsers.put(terrUser.User__c, terrUser);
                }

                if (terrUser.Territory__c != ((Map<Id, TerrUser__c>)Trigger.oldMap).get(terrUser.Id).Territory__c) {
                    terrUserUsers.put(terrUser.Territory__c, terrUser);
                }
            }    
        }

        addUniquenessErrors(terrUserTerritories, terrUserUsers);
    }
    
    public static void addUniquenessErrors(Map<Id, TerrUser__c> terrUserTerritories, Map<Id, TerrUser__c> terrUserUsers) {

        for (TerrUser__c terrUser : [
                                    SELECT Territory__c, User__c
                                    FROM TerrUser__c
                                    WHERE Territory__c IN :terrUserTerritories.KeySet() AND User__c IN :terrUserUsers.KeySet()
                                 ]){

            TerrUser__c newterrUser = terrUserTerritories.get(terrUser.Territory__c);
            newterrUser.Territory__c.addError(Label.Territory_and_User_pair_uniqueness);
            newterrUser.User__c.addError(     Label.Territory_and_User_pair_uniqueness);

        }
    }

    
}