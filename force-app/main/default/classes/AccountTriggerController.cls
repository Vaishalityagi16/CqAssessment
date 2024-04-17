public class AccountTriggerController {
    public static void checkActiveAccountValidation(List<Account> newList){
        try{
            for(Account acc:newList){
                if(acc.Active__c){
                    acc.addError(System.Label.ActiveAccountError);
                }
            }
        }
        Catch(Exception e){
            System.debug('Exception'+e.getMessage()+'AtLineNumber'+e.getLineNumber());
        }
    }
    public static void createTeamMembersRelatedAccount(List<Account> newList){
        try{
            List<SQX_Team_Members__c> teamMemList = new List<SQX_Team_Members__c>();
            for(Account acc:newList){
                for(Integer i = 1; i<3; i++){
                    SQX_Team_Members__c teamMemInstance = new SQX_Team_Members__c();
                    teamMemInstance.Name = 'Team Member' +''+ i;
                    teamMemInstance.Account__c = acc.Id;
                    teamMemList.add(teamMemInstance);
                }
            }
            if(!teamMemList.isEmpty()){
                insert teamMemList;
            }
        }
        Catch(Exception e){
            System.debug('Exception'+e.getMessage()+'AtLineNumber'+e.getLineNumber());
        }
    }
    public static void checkAccountValidationOnUpdate(List<Account> newList){
        try{
            List<SQX_Team_Members__c> teamMemList = [SELECT Id FROM SQX_Team_Members__c WHERE Account__c IN :newList AND Member_Type__c IN ('HR','Admin') ];
            for(Account ac: newList){
                if(ac.Active__c){
                    //Check for account admin PS
                    if(!FeatureManagement.checkPermission('Account_Admin_Permission')){
                        ac.addError(System.Label.MissingAccountAdminPsError);
                    }
                    //check for HR and Admin team members
                    if(teamMemList.isEmpty()){
                        ac.addError(System.Label.HrAdminMissingFromAccount);
                    }
                }
            }
        }
        Catch(Exception e){
            System.debug('Exception'+e.getMessage()+'AtLineNumber'+e.getLineNumber());
        }
    }
}