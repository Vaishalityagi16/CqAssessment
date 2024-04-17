@IsTest
public class AccountTriggerControllerTest {
    @TestSetup
    static void makeData(){
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User stdUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = stdProfile.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='123standarduser@testorg.com');
        insert stdUser;
    }
    
    @IsTest
    static void givenAccount_WhenActiveAccountInserted_ThenThrowError(){
        User stdUser = [SELECT Id FROM User WHERE UserName = '123standarduser@testorg.com'];
        System.runAs(stdUser){
            //Given
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.Active__c = true;
            
            //When
            Database.insert(acc, false);
            
            //Then
            System.assertEquals(true, [SELECT Id FROM Account].size() == 0, 'Account should not be inserted as active');
        }
    }
    
    @IsTest
    static void givenAccount_WhenInActiveAccountInserted_ThenDontThrowError(){
        User stdUser = [SELECT Id FROM User WHERE UserName = '123standarduser@testorg.com'];
        System.runAs(stdUser){
            //Given
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.Active__c = false;
            
            //When
            Database.insert(acc, false);
            
            //Then
            System.assertEquals(true, [SELECT Id FROM Account].size() == 1, 'Account should inserted as in-active');
        }
    }
    
    @IsTest
    static void givenInActiveAccount_WhenHrAndAdminTeamMemberPresent_ThenAllowAccountActivation(){
        User stdUser = [SELECT Id FROM User WHERE UserName = '123standarduser@testorg.com'];
        assignPermissionSetToUser(stdUser);
        System.runAs(stdUser){
            //Given
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.Active__c = false;
            Database.insert(acc, false);
            
            //When
            List<SQX_Team_Members__c> teamMembers = new List<SQX_Team_Members__c>();
            SQX_Team_Members__c hrTeamMember = new SQX_Team_Members__c();
            hrTeamMember.Account__c = acc.Id;
            hrTeamMember.Member_Type__c  = 'HR';
            teamMembers.add(hrTeamMember);
            SQX_Team_Members__c adminTeamMember = new SQX_Team_Members__c();
            adminTeamMember.Account__c = acc.Id;
            adminTeamMember.Member_Type__c  = 'Admin';
            teamMembers.add(adminTeamMember);
            insert teamMembers;
            
            acc.Active__c = true;
            update acc;
            
            //Then
            System.assertEquals(true, [SELECT Id FROM Account WHERE Active__c = True].size() == 1, 'Account should get updated as active');
        }
    }
    
    static void assignPermissionSetToUser(User stdUser){
        PermissionSet accountAdminPs = [SELECT Id 
                            FROM PermissionSet 
                            WHERE Name = 'Account_Admin'];
        Insert new PermissionSetAssignment(AssigneeId = stdUser.Id, PermissionSetId = accountAdminPs.Id);
    }
    
}