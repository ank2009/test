// Below code is written for CR #WKTS CRM-4
// We will put all the business logic in helper class, for now we will keep in trigger itself
/**
* @ Description   : Automatically fill in current fee end date during subscription cancellation 
* @ Business rule : If subscription = cancelled and current fee/end_date is null then current fee/end_date = subscription_end date  
* @ Date          : 22-10-2012    
* @ Author        : HCL Technology
**/
@isTest
private class TLR_SubscriptionCancellationTest {

    static testMethod void testupdateEndDateCurrentFee(){
        
        // -------------
        // Data creation
        // -------------
        
        // Services
        List<ID> services = TestData.createTestServices(10);
        
        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
        serviceNbSA.put(id, 2);
        
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        
        // Product
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount(true);
        Contact c = TST_ContactTestHelper.createDummyContact(a, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        // Contract
        Id contractId = TestData.createTestContract(a.Id).Id;
        // Subscription
        Subscription__c subs = TestData.createTestSubscription(productId, contractId);
        subs.Status__c = 'Sent';
        update subs;
        
        PackFee__c PackFee = TestData.createPackageAndFee();
        Subs_Package_And_Fee__c SubsPackFee = new Subs_Package_And_Fee__c();
        SubsPackFee.Name='test Subs Pack fee';
        SubsPackFee.Package_and_Fee__c=PackFee.Id;
        SubsPackFee.Subscription__c=subs.Id;
        insert SubsPackFee;
        Subs_Current_Fee__c SubsKurFee = new Subs_Current_Fee__c();
        SubsKurFee.Name='test sub Current Fee';
        SubsKurFee.Subscription__c = subs.Id;
        SubsKurFee.Account__c= a.Id;
        SubsKurFee.Subs_Package_And_Fee__c=SubsPackFee.Id;
        SubsKurFee.Start_Date__c=Date.today();
        insert SubsKurFee;
        
        subs.Data_Quality__c = true;
        subs.Flag_IntegrityChecks__c = true;
        subs.Payment_information__c = true;
        subs.Status__c = 'Waiting For Verification';
        update subs;
        subs.Status__c = 'Waiting For Provisioning';
        update subs;
        subs.Status__c = 'Provisioning initiated';
        update subs; 
        subs.Status__c = 'Active';
        update subs;                 
        subs.Status__c = 'On Notice';
        update subs;
       
        
    }
}