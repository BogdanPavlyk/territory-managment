public class TerrUserTriggerHandler extends TriggerHandler {

    public TerrUserTriggerHandler() {}

    protected override void beforeInsert() {

        //Create two Maps <FieldId, sObject> for fields "Territory" and "User"
        //and check them for uniqueness
        TerrUserUtils.checkFieldsForUniquenessIfInsert(true);
    }

    protected override void beforeUpdate() {

        //Create two Maps <FieldId, sObject> for fields "Territory" and "User"
        //and check them for uniqueness
        TerrUserUtils.checkFieldsForUniquenessIfInsert(false);
    }
     
    protected override void afterInsert() {
    
        Set<Id> tuIds = ((Map<Id, TerrUser__c>)Trigger.newMap).keySet();
        Map<Id, User> userIds = new Map<Id, User>([SELECT Id FROM User WHERE Id IN (SELECT User__c FROM TerrUser__c WHERE Id In :tuIds)]);
        Map<Id, Account__c> accountsWithReferencesMap = new Map<Id, Account__c>([SELECT Id, ]);

        Map<Territory__c, Map<Id, Account>> territoryWithRelatedAccountsMap = new Map<Territory__c, Map<Id, Account>>();
        Map<Territory__c, Map<Id, User>>    territoryWithRelatedUsersMap    = new Map<Territory__c, Map<Id, User>>();
        Map<Territory__c, Set<Id>>          territoryWithRelatedContactsSet = new Map<Territory__c, Set<Id>>();

        for (Territory__c territory : [ SELECT Id, Name, (SELECT Id, Name FROM Accounts__r), (SELECT Id, User__c FROM TerrUsers__r)
                                        FROM Territory__c
                                        WHERE Id IN ( SELECT Territory__c
                                                       FROM TerrUser__c
                                                       WHERE Id IN :tuIds )
                                        ]) { 
            
            Map<Id, Account> accMap = new Map<Id, Account>();
            Set<Id> conSet = new Set<Id>();
            for (Account account : territory.Accounts__r) {                
                accMap.put(account.id, account);

                System.debug(loggingLevel.Error, '*** account.References__r: ' + account.References__r);
                for(Reference__c ref : account.References__r) {
                    conSet.add(ref.Contact__c);
                    System.debug(loggingLevel.Debug, '*** ref.Contact__c: ' + ref.Contact__c);
                }
            }
            territoryWithRelatedAccountsMap.put(territory, accMap);
            territoryWithRelatedContactsSet.put(territory, conSet);

            Map<Id, User>  userMap = new Map<Id, User>();
            for (TerrUser__c terrUser : territory.TerrUsers__r) {
                userMap.put(terrUser.User__c, userIds.get(terrUser.User__c));
            }
            territoryWithRelatedUsersMap.put(territory, userMap);                
        }        
        
        List<AccountShare> accountShareList = new List<AccountShare>();
        List<ContactShare> contactShareList = new List<ContactShare>();
        Map<Id, Account>   allAcountsMap    = new Map<Id, Account>();
        Map<Id, Contact>   allContactMap    = new Map<Id, Contact>();

        for (Territory__c territory : territoryWithRelatedAccountsMap.keySet()) {

            Map<Id, Account> newAccountMap = territoryWithRelatedAccountsMap.get(territory);
            Map<Id, User>    newUserMap    = territoryWithRelatedUsersMap.get(territory);
            Set<Id>          newContactSet = territoryWithRelatedContactsSet.get(territory);

            for(User user : newUserMap.values()) {
                List<AccountShare> accountShares = AccountShareUtilities.createAccountShareForAccountMap(newAccountMap, user);
                List<ContactShare> contactShares = AccountShareUtilities.createContactShareForContactSet(newContactSet, user);
                accountShareList.addAll(accountShares);
                contactShareList.addAll(contactShares);
            }

            allAcountsMap.putAll(newAccountMap);
        }

        AccountShareUtilities.sharingInsertResult(accountShareList, allAcountsMap);

        Database.SaveResult[] lsr = Database.insert(contactShareList, false);
    }
    //Helpers

}
