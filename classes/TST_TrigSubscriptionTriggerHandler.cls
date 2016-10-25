/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TST_TrigSubscriptionTriggerHandler {
    
    static Account a;
    static Subs_Current_Fee__c subsCurrFee;
    static Id contractId;
    static Id subsId;
    static Id productId;
    
    
    public static testMethod void testRecordTypeUpdate() 
    {
        Map<String,Schema.RecordTypeInfo> mapByName = Schema.getGlobalDescribe().get('Subscription__c').getDescribe().getRecordTypeInfosByName();
        Id subsProvRecordType       = mapByName.get('TLR Subscription Prov').getRecordTypeId();
        Id subsProvInitRecordType   = mapByName.get('TLR Subscription Prov Init').getRecordTypeId();
        Id subsActiveRecordType     = mapByName.get('TLR Subscription Active').getRecordTypeId();
        Id subsCancelledRecordType  = mapByName.get('TLR Subscription Cancelled').getRecordTypeId();
        Id subsTLRRecordType        = mapByName.get('TLR Subscription').getRecordTypeId();
        Id subsTASRecordType        = mapByName.get('TAS Subscription').getRecordTypeId();
        
    	createTestData();
        Subscription__c subs = [select Id, Status__c, Contract__c, RecordTypeId from Subscription__c where Id =: subsId];
        
        
        subs.RecordTypeId = subsTASRecordType;
        update subs;
        subs = [select Id, Status__c, Contract__c, RecordTypeId from Subscription__c where Id =: subsId];
        system.assert(subs.RecordTypeId == subsTASRecordType, 'record must be "TAS Subscription"');
        
        subs.Flag_IntegrityChecks__c  = true;
        subs.Status__c = 'Sent';
        update subs;
        
        subs.Status__c = 'Waiting For Provisioning';
        subs.RecordTypeId = subsTLRRecordType;
        update subs;
        subs = [select Id, Status__c, Contract__c, RecordTypeId from Subscription__c where Id =: subsId];
        system.assert(subs.RecordTypeId == subsProvRecordType, 'record must be "TLR Subscription Prov"');
        
        subs.Status__c = 'Provisioning initiated';
        update subs;
        subs = [select Id, Status__c, Contract__c, RecordTypeId from Subscription__c where Id =: subsId];
        system.assert(subs.RecordTypeId == subsProvInitRecordType, 'record must be "TLR Subscription Prov Init"');
        
        subs.Status__c = 'Active';
        update subs;
        subs = [select Id, Status__c, Contract__c, RecordTypeId from Subscription__c where Id =: subsId];
        system.assert(subs.RecordTypeId == subsActiveRecordType, 'record must be "TLR Subscription Active"');
        
        subs.Status__c = 'On Notice';
        update subs;
        subs = [select Id, Status__c, Contract__c, RecordTypeId from Subscription__c where Id =: subsId];
        system.assert(subs.RecordTypeId == subsCancelledRecordType, 'record must be "TLR Subscription Cancelled"');
                        
        subs.Status__c = 'Cancelled';
        update subs;
        subs = [select Id, Status__c, Contract__c, RecordTypeId from Subscription__c where Id =: subsId];
        system.assert(subs.RecordTypeId == subsCancelledRecordType, 'record must be "TLR Subscription Cancelled"');
        /*
        subs.Status__c = 'Migration';
        update subs;
        subs = [select Id, Status__c, Contract__c, RecordTypeId from Subscription__c where Id =: subsId];
        system.assert(subs.RecordTypeId == subsTLRRecordType, 'record must be "TLR Subscription"');
		*/
    }
    
    public static testMethod void testUpdatePriceListCode() 
    {
    	createTestData();
        Subscription__c subs = [select Id, Status__c, Contract__c, Price_List_Code__c from Subscription__c where Id =: subsId];        
        system.assert(subs.Price_List_Code__c == 'Offer Template Test','initial value of Price_List_Code__c must be "Offer Template Test"');
        
        Offer_Template__c ot = new Offer_Template__c();
        ot.name = 'New Offer Template';
        insert ot;
        
		subs.Offer_Template__c = ot.Id;
        update subs;
        subs = [select Id, Status__c, Contract__c, Price_List_Code__c from Subscription__c where Id =: subsId];        
        system.assert(subs.Price_List_Code__c == 'New Offer Template','value of Price_List_Code__c must be "New Offer Template"');
    }
    
    public static testMethod void testUpdateSubsCurrFee() 
    {
        createTestData();
        subsCurrFee = [select Id, End_Date__c from Subs_Current_Fee__c where id =: subsCurrFee.id];
        system.assert(subsCurrFee.End_Date__c == null,'The End Date of Subscription Current Fee must be equal null');
        Subscription__c subs = [select Id, Status__c, End_Date__c from Subscription__c where Id =: subsId];
        subs.Flag_IntegrityChecks__c  = true;
        subs.Status__c = 'Sent';
        update subs;
        subs.Status__c = 'Waiting For Provisioning';
        update subs;
        subs.Status__c = 'Provisioning initiated';
        update subs;
        subs.Status__c = 'Active';
        update subs;
        subs.Status__c = 'On Notice';
        update subs;
        subsCurrFee = [select Id, End_Date__c from Subs_Current_Fee__c where id =: subsCurrFee.id];
        system.assert(subsCurrFee.End_Date__c == subs.End_Date__c,'The End Date of Subscription Current Fee must be updated');
    }
    
    
    private static void createTestData()
    {
        List<ID> services = TestData.createTestServices(10);
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
        
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        a = TST_AccountTestHelper.createDummyAccount(true);
        List<Contact> cList = TST_ContactTestHelper.createDummyContactList(a, 10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        contractId = TestData.createTestContract(a.Id).Id;
        subsId = TestData.createTestSubscription(productId, contractId).Id;
        Subs_Package_And_Fee__c subsPackFee = new Subs_Package_And_Fee__c();
        subsPackFee.Subscription__c = subsId;
        insert subsPackFee;
        subsCurrFee = new Subs_Current_Fee__c();
        subsCurrFee.Subscription__c = subsId;
        subsCurrFee.Subs_Package_And_Fee__c = subsPackFee.id;
        insert subsCurrFee;
    }
    

   
}