/** 
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         2016 June 21
* @description  this class tests the creation of DMS Community Users after either Contact update, or Subs Curr Fee insertion, or Subscription activation
*/
@isTest
public class TST_DMSUsersCreationByTriggersTest 
{
    private static Account acc;
    private static Contact cont1;
    private static Contact cont2;
    private static Contact cont3;
    private static Offer_Template__c OT;
    private static Opportunity opp;
    private static Contract contr;
    private static Subscription__c subs;
    private static Subs_Package_And_Fee__c spf;
    private static Subs_Current_Fee__c scf;
    private static TLR_SubscriptionExt subsExt;
    private static TLR_OpportunityExt oppExt;
    
    
    public static testMethod void testAfterContactUpdateNegative_1()
    {
        CreateTestData();
        Test.startTest();
        CreateDMSSubsCurrFee();          
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1; 
        Test.stopTest();
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 0, 'No users must be created if Account doesn\'t have active subscriptions'); 
    }
    
    public static testMethod void testAfterContactUpdateNegative_2()
    {
        CreateTestData();
        subs.Contact__c = cont2.Id;   
        subs.Status__c = 'Active';
        update subs;
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1;       
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 0, 'No users must be created if Account doesn\'t have DMS_approved fee');      
        
    }
    
    public static testMethod void testAfterContactUpdateNegative_3()
    {
        CreateTestData();  
        Test.startTest();
        subs.Contact__c = cont2.Id;   
        subs.Status__c = 'Active';
        update subs; 
        CreateDMSSubsCurrFee();    
        cont1.Username__c = 'qwer';
        cont1.ESB_User_status__c = 'APPROVED';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1;
        Test.stopTest();
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 0, 'No users must be created if Contact\'s ESB status is not READY');                                                 
    }
    
    public static testMethod void testAfterContactUpdateNegative_4()
    {
        CreateTestData();
        Test.startTest();
        subs.Contact__c = cont2.Id;   
        subs.Status__c = 'Active';
        update subs;         
        CreateDMSSubsCurrFee();        
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1; 
        cont2.ESB_User_status__c = 'READY';
        cont2.Username__c = 'qwer';
        cont2.Admin_Products__c = 'qwer, TFX, asdf';
        update cont2;
        cont3.ESB_User_status__c = 'READY';
        cont3.Username__c = 'qwer1';
        cont3.Admin_Products__c = 'qwer, TFX, asdf';
        update cont3;
        Test.stopTest();         
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 1, 'User must be created for first Contact');
        system.assertEquals([select count() from User where ContactId =: cont2.Id], 0, 'There can\'t be two users with the same Federation Id');
        system.assertEquals([select count() from User where ContactId =: cont3.Id], 1, 'User must be created for third Contact');
    }
    
    public static testMethod void testAfterContactUpdateNegative_5()
    {
        CreateTestData();
        Test.startTest();
        subs.Contact__c = cont2.Id;   
        subs.Status__c = 'Active';
        update subs;         
        CreateDMSSubsCurrFee();          
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer1';
        cont1.Admin_Products__c = 'qwer, asdf';
        update cont1; 
        cont2.ESB_User_status__c = 'READY';
        cont2.Username__c = 'qwer2';
        cont2.Admin_Products__c = 'qwer, TFX, asdf';
        update cont2;
        Test.stopTest(); 
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 0, 'User mustn\'t be created for first Contact without \'TFX\' in Admin_Products__c field');
        system.assertEquals([select count() from User where ContactId =: cont2.Id], 1, 'User must be created for second Contact');
        
    }
    
    public static testMethod void testAfterContactUpdatePositive()
    {
        CreateTestData();
        Test.startTest();
        subs.Contact__c = cont2.Id;   
        subs.Status__c = 'Active';
        update subs;         
        CreateDMSSubsCurrFee();          
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer1';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1; 
        cont2.ESB_User_status__c = 'READY';
        cont2.Username__c = 'qwer2';
        cont2.Admin_Products__c = 'qwer, TFX, asdf';
        update cont2;
        Test.stopTest(); 
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 1, 'User must be created for first Contact');
        system.assertEquals([select count() from User where ContactId =: cont2.Id], 1, 'User must be created for second Contact');
        
    }
    
    public static testMethod void testAfterSubscriptionActivationNegative_1()
    {    
        CreateTestData();  
        Test.startTest();
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1;
        subs.Contact__c = cont2.Id;
        update subs; 
        subsExt = new TLR_SubscriptionExt(subs.Id);                
        subsExt.InitCreateProvisioning();
        Test.stopTest();        
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 0, 'No users must be created if Account doesn\'t have DMS_approved fee'); 
    }
    
    public static testMethod void testAfterSubscriptionActivationNegative_2()
    {
        CreateTestData(); 
        Test.startTest(); 
        cont1.ESB_User_status__c = 'APPROVED';
        cont1.Username__c = 'qwer';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1;
        subs.Contact__c = cont2.Id;
        update subs;
        subsExt = new TLR_SubscriptionExt(subs.Id);                          
        CreateDMSSubsCurrFee();
        subsExt.InitCreateProvisioning();
        Test.stopTest();
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 0, 'No users must be created if Contact\'s ESB status is not READY'); 
    }
    
    public static testMethod void testAfterSubscriptionActivationNegative_3()
    {
        CreateTestData();
        Test.startTest();
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1;
        cont2.ESB_User_status__c = 'READY';
        cont2.Username__c = 'qwer';
        cont2.Admin_Products__c = 'qwer, TFX, asdf';
        update cont2;  
        cont3.ESB_User_status__c = 'READY';
        cont3.Username__c = 'qwer1';
        cont3.Admin_Products__c = 'qwer, TFX, asdf';
        update cont3;          
        subs.Contact__c = cont2.Id;          
        update subs; 
        subsExt = new TLR_SubscriptionExt(subs.Id);                           
        CreateDMSSubsCurrFee();
        subsExt.InitCreateProvisioning();
        Test.stopTest();
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 0, 'No users must be created for Contact whose Username is not unique for the batch'); 
        system.assertEquals([select count() from User where ContactId =: cont2.Id], 0, 'No users must be created for Contact whose Username is not unique for the batch'); 
        system.assertEquals([select count() from User where ContactId =: cont3.Id], 1, 'User must be created for Contact with unique Username'); 
    }
    
    public static testMethod void testAfterSubscriptionActivationNegative_4()
    {
        CreateTestData();
        Test.startTest();
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer1';
        cont1.Admin_Products__c = 'qwer, asdf';
        update cont1;
        cont2.ESB_User_status__c = 'READY';
        cont2.Username__c = 'qwer2';
        cont2.Admin_Products__c = 'qwer, TFX, asdf';
        update cont2;      
        subs.Contact__c = cont2.Id;         
        update subs; 
        subsExt = new TLR_SubscriptionExt(subs.Id);                           
        CreateDMSSubsCurrFee();
        subsExt.InitCreateProvisioning();
        Test.stopTest();
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 0, 'User mustn\'t be created for first Contact without \'TFX\' in Admin_Products__c field'); 
        system.assertEquals([select count() from User where ContactId =: cont2.Id], 1, 'User must be created for second Contact'); 
    }
    
    public static testMethod void testAfterSubscriptionActivationPositive()
    {
        CreateTestData();
        Test.startTest();
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer1';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1;
        cont2.ESB_User_status__c = 'READY';
        cont2.Username__c = 'qwer2';
        cont2.Admin_Products__c = 'qwer, TFX, asdf';
        update cont2;      
        subs.Contact__c = cont2.Id;         
        update subs; 
        subsExt = new TLR_SubscriptionExt(subs.Id);                           
        CreateDMSSubsCurrFee();
        subsExt.InitCreateProvisioning();
        Test.stopTest();
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 1, 'User must be created for first Contact'); 
        system.assertEquals([select count() from User where ContactId =: cont2.Id], 1, 'User must be created for second Contact'); 
    }
    
    public static testMethod void testAfterSubsCurrFeeCreationNegative_1()
    {
        CreateTestData();
        Test.startTest(); 
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1;      
        subs.Contact__c = cont2.Id;
        update subs;                       
        CreateDMSSubsCurrFee();
        Test.stopTest();       
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 0, 'No users must be created if Account doesn\'t have active subscriptions');
    }
    
    public static testMethod void testAfterSubsCurrFeeCreationNegative_2()
    {
        CreateTestData(); 
        Test.startTest();
        cont1.ESB_User_status__c = 'APPROVED';
        cont1.Username__c = 'qwer';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1;
        subs.Contact__c = cont2.Id;
        subs.Status__c = 'Active';
        update subs;        
        CreateDMSSubsCurrFee();
        Test.stopTest();
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 0, 'No users must be created if Contact\'s ESB status is not READY');
    }
    
    public static testMethod void testAfterSubsCurrFeeCreationNegative_3()
    {
        CreateTestData();  
        Test.startTest();
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1;
        cont2.ESB_User_status__c = 'READY';
        cont2.Username__c = 'qwer';
        cont2.Admin_Products__c = 'qwer, TFX, asdf';
        update cont2;   
        cont3.ESB_User_status__c = 'READY';
        cont3.Username__c = 'qwer1';
        cont3.Admin_Products__c = 'qwer, TFX, asdf';
        update cont3;  
        subs.Contact__c = cont2.Id; 
        subs.Status__c = 'Active';        
        update subs;        
        CreateDMSSubsCurrFee();  
        Test.stopTest();
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 0, 'No users must be created for Contact whose Username is not unique for the batch'); 
        system.assertEquals([select count() from User where ContactId =: cont2.Id], 0, 'No users must be created for Contact whose Username is not unique for the batch'); 
        system.assertEquals([select count() from User where ContactId =: cont3.Id], 1, 'User must be created for Contact with unique Username'); 
    }   
    
    public static testMethod void testAfterSubsCurrFeeCreationNegative_4()
    {
        CreateTestData();   
        Test.startTest();
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer1';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1;
        cont2.ESB_User_status__c = 'READY';
        cont2.Username__c = 'qwer2';
        cont2.Admin_Products__c = 'qwer, asdf';
        update cont2;       
        subs.Contact__c = cont2.Id; 
        subs.Status__c = 'Active';       
        update subs;        
        CreateDMSSubsCurrFee();  
        Test.stopTest();
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 1, 'User must be created for first Contact'); 
        system.assertEquals([select count() from User where ContactId =: cont2.Id], 0, 'User mustn\'t be created for second Contact without \'TFX\' in Admin_Products__c field'); 
    }   
    
    public static testMethod void testAfterSubsCurrFeeCreationPositive()
    {
        CreateTestData();   
        Test.startTest();
        cont1.ESB_User_status__c = 'READY';
        cont1.Username__c = 'qwer1';
        cont1.Admin_Products__c = 'qwer, TFX, asdf';
        update cont1;
        cont2.ESB_User_status__c = 'READY';
        cont2.Username__c = 'qwer2';
        cont2.Admin_Products__c = 'qwer, TFX, asdf';
        update cont2;       
        subs.Contact__c = cont2.Id; 
        subs.Status__c = 'Active';       
        update subs;        
        CreateDMSSubsCurrFee();  
        Test.stopTest();
        system.assertEquals([select count() from User where ContactId =: cont1.Id], 1, 'User must be created for first Contact'); 
        system.assertEquals([select count() from User where ContactId =: cont2.Id], 1, 'User must be created for second Contact'); 
    }   
    
    
    private static void CreateTestData()
    {
        Test.setMock(HttpCalloutMock.class, new TST_GenericHttpCalloutMock());
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        acc = TST_AccountTestHelper.createDummyAccount(false);
        acc.VAT__c = '123';
        acc.ESB_Company_status__c = 'APPROVED';
        insert acc;
        cont1 = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        cont2 = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        cont3 = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        OT = TST_OfferTemplateTestHelper.createDummyOfferTemplate(TLR_RecordTypeHelper.getId('Offer_template__c', 'TLR Offer Template'), false);
        OT.Use_new_Provisioning__c = true;
        insert OT;
        opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, OT, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity'), false);
        opp.Recurring_Revenue__c = 123;
        opp.Recurring_Revenue_Date__c = Date.today();
        opp.StageName = '01 New';
        insert opp;
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = cont1.Id;
        ocr.OpportunityId = opp.Id;
        insert ocr; 
        opp.StageName = '10 Closed Won';
        update opp;
        oppExt = new TLR_OpportunityExt(opp.Id);
        oppExt.InitCreateContractPage();        
        subs = [select Id, Account__c, Status__c from Subscription__c];
        subsExt = new TLR_SubscriptionExt(subs.Id);
        subsExt.InitVerifyTlrSybscription();
        spf = new Subs_Package_And_Fee__c();
        spf.Subscription__c = subs.Id;
        spf.Name = 'DMS_approved';
        insert spf;   
        spf = new Subs_Package_And_Fee__c();
        spf.Subscription__c = subs.Id;
        spf.Name = 'CD_approved';
        insert spf;
        scf = new Subs_Current_Fee__c();
        scf.Subs_Package_And_Fee__c = spf.Id;
        scf.Name = 'CD_approved';
        scf.Start_Date__c = date.today();
        scf.Account__c = subs.Account__c;
        scf.Subscription__c = subs.Id;
        insert scf;
        subs = [select Id, Account__c, Status__c from Subscription__c];
    }
    
    private static void CreateDMSSubsCurrFee()
    {
        subs = [select Id, Account__c from Subscription__c where Id =: subs.Id];
        scf = new Subs_Current_Fee__c();
        scf.Subs_Package_And_Fee__c = spf.Id;
        scf.Name = 'DMS_approved';
        scf.Start_Date__c = date.today();
        scf.Account__c = subs.Account__c;
        scf.Subscription__c = subs.Id;
        insert scf;
    }
}