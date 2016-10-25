/**
* @author       Aleh Tsilko (aleh_tsilko@epam.com)
* @date         2015 May
* @description  test for TFX Migration Job
* @CM-440 JIRA TASK              
*/

@isTest
public class TFXMigrationTest {
    static testmethod void testMigration()
    {
        //prepare test data
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        
        Account testAcc = TST_AccountTestHelper.createDummyAccount('France', TRUE);
        testAcc.AccountNumber = 'testAccNum1';
        testAcc.TFX_Migration_DATE__c = system.today();
        testAcc.TFX_Migration_PackageName__c = 'FX_Basic';
        testAcc.TFX_Migration_Status__c = '';
        update testAcc;

        //test mistake Account
        Test.startTest();        
        TFXMigrationBathable testTFXMigrationJob1 = new TFXMigrationBathable();
        Database.executeBatch(testTFXMigrationJob1);    
        
        testAcc.TFX_Migration_Status__c = '';
        update testAcc;        
        
        //Test good Account
        Contact testCont = TST_ContactTestHelper.createDummyContact(testAcc, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), TRUE);
        testCont.ESB_BuisnessID__c = 'U-123qwe1234';
        upsert testCont;
        testCont = [SELECT Id FROM Contact][0];
        User_Profile__c up = new User_Profile__c();
        up.RecordTypeId    = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile').getRecordTypeId();
        up.Private_Exchange_ID__c = 'OPEN';
        up.Contact__c             = testCont.Id;
        up.Test_login__c          = false;
        up.User_PUG_Name__c       = 'FCUGABPSTD';
        up.Status__c              = 'Activated';
        insert up;
        testCont = [SELECT CreatedDate, ESB_BuisnessID__c, AccountId, Contact_Status__c FROM Contact][0];

        Offer_template__c testOt = TST_OfferTemplateTestHelper.createDummyOfferTemplate(TLR_RecordTypeHelper.getId('Offer_template__c', 'TLR Offer Template'), TRUE);
        
        Opportunity testOpp = TST_OpportunityTestHelper.createDummyOpportunity(testAcc, testOt, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity'), TRUE);
        
        Contract testContr = TST_ContractTestHelper.createDummyContract(testOpp, TLR_RecordTypeHelper.getId('Contract', 'TLR Contract'), TRUE);    
        
        Product__c testProduct = TST_ProductTestHelper.createDummyProduct('T-PRO',TLR_RecordTypehelper.getId('Product__c', 'TLR Product'), TRUE);        
        testProduct.Status__c = 'Pending Activation Approval';
        upsert testProduct;
        testProduct.Status__c = 'Active';
        upsert testProduct;
        
        Subscription__c testSubsProd = TST_SubscriptionTestHelper.createDummySubscription(testContr, testOpp, TLR_RecordTypeHelper.getId('Subscription__c', 'TLR Subscription'), FALSE);        
        testSubsProd.Name = TFXMigrationHelper.TFXSUBSNAME;
        testSubsProd.Account__c = testAcc.Id;
        insert testSubsProd;
        Subs_Package_And_Fee__c testSPaF = New Subs_Package_And_Fee__c (Name = 'FX_Basic', Subscription__c = testSubsProd.Id);
        insert testSPaF;
        
        Subscription__c testSubs = TST_SubscriptionTestHelper.createDummySubscription(testContr, testOpp, TFXMigrationHelper.RECORD_TYPE_MIGR_ID, FALSE);
        testSubs.Status__c = 'Active';
        testSubs.Product__c = testProduct.Id;
        testSubs.Account__c = testAcc.Id;
        insert testSubs;
        testSubs = [SELECT Id FROM Subscription__c WHERE Status__c = 'Active'][0];
        testSPaF = New Subs_Package_And_Fee__c (Name = 'FX_Basic', Subscription__c = testSubs.Id);
        insert testSPaF;     

        //Test Migration Helper
        TFXMigrationHelper.addTFXMigrationLog (testAcc, 'Test error 1');
        TFXMigrationHelper.addTFXMigrationLog (testAcc, 'Test error 2');
        TFXMigrationHelper.addTFXCheckLog ('Test error in Pack Fee check');
        TFXMigrationBathable testTFXMigrationJob2 = new TFXMigrationBathable();       
        Database.executeBatch(testTFXMigrationJob2);
         
        //Test result email 
        TFXMigrationEmailResult emailJob = New TFXMigrationEmailResult();
        SchedulableContext sc = null;
        emailJob.execute(sc);
        
        //Test Migration Page Controller
        PageReference pageRef = Page.TFX_Migration;
        Test.setCurrentPage(pageRef);
        TFX_MigrationController controller = new TFX_MigrationController();
        
        //normal flow
        controller.RunImmediatly();
        controller.SceduleToTomorrow();
        controller.SceduleToMonday();
system.debug('***** testAcc='+testAcc);

        //test activate list
        controller.init();
        controller.Activate();
        controller.companiesList = testAcc.AccountNumber; 
        controller.Activate();        
        Test.stopTest();           
    }
}