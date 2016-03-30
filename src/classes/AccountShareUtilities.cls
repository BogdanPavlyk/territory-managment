public without sharing class AccountShareUtilities{

	public static void createAccountSharingRuleForUser( Map<Id, Account> accountMap, User userOrGroup){

		List<AccountShare> sharingRuleList = createAccountShareForAccountMap(accountMap, userOrGroup);
        
        sharingInsertResult(sharingRuleList, accountMap);
	}	



    //Helpers
    public static List<AccountShare> createAccountShareForAccountMap( Map<Id, Account> accountMap, User userOrGroup){

        List<AccountShare> sharingRuleList = new List<AccountShare>();
 
        for(Account acc : accountMap.values()){
            AccountShare sharingRule = new AccountShare();
 
            sharingRule.AccountId = acc.Id;
            sharingRule.AccountAccessLevel = 'Read';
            sharingRule.OpportunityAccessLevel = 'None';
            sharingRule.CaseAccessLevel = 'None';
            sharingRule.UserOrGroupId = userOrGroup.Id;

            System.debug(loggingLevel.Info, '*** sharingRule: ' + sharingRule);
            sharingRuleList.add(sharingRule); 
        }

        return sharingRuleList;
    }

    public static List<ContactShare> createContactShareForContactSet( Set<Id> contactSet, User userOrGroup){

        List<ContactShare> sharingRuleList = new List<ContactShare>();
 
        for(Id conId : contactSet){
            ContactShare sharingRule = new ContactShare();
 
            sharingRule.ContactId = conId;
            sharingRule.ContactAccessLevel = 'Read';
            sharingRule.UserOrGroupId = userOrGroup.Id;

            System.debug(loggingLevel.Info, '*** sharingRule: ' + sharingRule);
            sharingRuleList.add(sharingRule); 
        }

        return sharingRuleList;
    }

    public static List<AccountShare> createAccountShareForAccountList( List<Account> accountList, User userOrGroup){

        List<AccountShare> sharingRuleList = new List<AccountShare>();
 
        for(Account acc : accountList){
            AccountShare sharingRule = new AccountShare();
 
            sharingRule.AccountId = acc.Id;
            sharingRule.AccountAccessLevel = 'Read';
            sharingRule.OpportunityAccessLevel = 'None';
            sharingRule.CaseAccessLevel = 'None';
            sharingRule.UserOrGroupId = userOrGroup.Id;

            System.debug(loggingLevel.Info, '*** sharingRule: ' + sharingRule);
            sharingRuleList.add(sharingRule); 
        }

        return sharingRuleList;
    }

    public static void sharingInsertResult(List<AccountShare> sharingRuleList, Map<Id, Account> accountMap){

        Database.SaveResult[] lsr = Database.insert(sharingRuleList, false);
        
        // Create counter
        Integer i=0;
         
        // Process the save results
        for(Database.SaveResult sr : lsr){

            if(!sr.isSuccess()){
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];
                 
                // Check if the error is related to a trivial access level
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
                                               &&  err.getMessage().contains('AccessLevel'))){
                    // Throw an error when the error is not related to trivial access level.
                    accountMap.get(sharingRuleList[i].AccountId).addError(
                       Label.Sharing_exeption +
                       err.getMessage());
                } else if( err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION){
                    System.debug(loggingLevel.Error, '*** StatusCode');
                } else {
                    System.debug(loggingLevel.Error, '*** AccessLevel: ');
                }
            }else {
                System.debug(loggingLevel.Info, '*** All inserted: ');
            }

            i++;
        }
    }
}