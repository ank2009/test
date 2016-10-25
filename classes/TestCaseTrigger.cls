@isTest
private class TestCaseTrigger {

    static User initUser()
    {
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'testUsr1', 
                             Username = 'testUsr1@test.ww',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles',
                             Disable_Validation_Rules_and_Workflows__c = true,
                             Disable_All_Triggers__c = true,
                             Disable_ESB_automatic_updates__c = true,
                             Disable_ESB_calls__c = true);
        insert u;
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        return u;        
    }
    
    static testMethod void caseTestTriggers() 
    {                               
    //prepare test data
        Account acctComp = New Account();
        Account acct = New Account();
        Contact CompContact = New Contact();
        User testUser = initUser(); 
        system.runas(testUser)
        {            
             acctComp          = TST_AccountTestHelper.createDummyAccount('France',true);                                
             acct          = TST_AccountTestHelper.createDummyAccount('France',true);  
             CompContact = new Contact (LastName='Contact', FirstName='Test', AccountId=acctComp.id, MailingCountry=acctComp.ShippingCountry,Key_contact_or_decision_maker__c=true
                                         , Language__c = utilities.getPicklistValues('Contact', 'Language__c')[0]);
             insert CompContact;      
             User manager = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1];      
             User u = [SELECT Id, ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
             u.ManagerId = manager.Id;
             update u;
        }  

      //test Case Approval
        testUser.Disable_All_Triggers__c = false;
        
        system.runas(testUser)
        {            
            test.startTest();      
            ID recordTypenCase = TLR_RecordTypeHelper.getId('Case', 'TLR Complaint Case');
            Case testCase = new Case ( Status = 'New',
                                     RecordTypeId = recordTypenCase,
                                     Subject = 'Test Service Case',
                                     Description = 'Test Service Case',
                                     Priority = 'Medium',
                                     Origin = 'Phone',
                                     Complaint_Reason__c = 'Payment',
                                     ContactId = CompContact.Id,
                                     AccountId = acctComp.Id,
                                     Defaulter_Account_Name__c = acct.Id,
                                     Is_Counted_Star_Index__c = true);  
            insert testCase;
            testCase.Status ='Need Approval';            
            update testCase;
            testCase.Status ='Pending Approval';         
            update testCase;
            testCase.Action_Start_Date__c = Date.Today();
            testCase.Action_End_Date__c = Date.Today().AddDays(1);
            testCase.TlrGenerateSanctionActivities__c = true;
            testCase.Status ='Action Applied';           
            update testCase;    
            delete testCase;
            undelete testCase;
            test.stoptest();
        }
                 
    //test email2Case          
        system.runas(testUser)
        {    
            Case emailTestCase = TST_CaseTestHelper.createDummyCase(TLR_RecordTypeHelper.getId('Case', 'TWD Case') , false);         
            emailTestCase.Account = acctComp;
            emailTestCase.Defaulter_Account_Name__c = acct.Id;
            emailTestCase.Description = 'Preferee company:(' + [SELECT AccountNumber FROM Account WHERE Id =: acctComp.Id][0].AccountNumber + ')';
            emailTestCase.TWD_Prefere_company__c = null;         
            insert emailTestCase;
            system.Assert([SELECT TWD_Prefere_company__c FROM Case WHERE Id =: emailTestCase.Id][0] != null, 'Preferee Company isn\'t filling for email2Case !!!');        
        }
    }
}