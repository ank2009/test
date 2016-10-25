/*
 .d8888b.                         888                                                                                  888 
d88P  Y88b                        888                                                                                  888 
888    888                        888                                                                                  888 
888         8888b.  88888b.       88888b.   .d88b.       888d888 .d88b.  88888b.d88b.   .d88b.  888  888  .d88b.   .d88888 
888            "88b 888 "88b      888 "88b d8P  Y8b      888P"  d8P  Y8b 888 "888 "88b d88""88b 888  888 d8P  Y8b d88" 888 
888    888 .d888888 888  888      888  888 88888888      888    88888888 888  888  888 888  888 Y88  88P 88888888 888  888 
Y88b  d88P 888  888 888  888      888 d88P Y8b.          888    Y8b.     888  888  888 Y88..88P  Y8bd8P  Y8b.     Y88b 888 
 "Y8888P"  "Y888888 888  888      88888P"   "Y8888       888     "Y8888  888  888  888  "Y88P"    Y88P    "Y8888   "Y88888 

main class (CtrlAP04CancelSubscription) moved to TLR_SubscriptionExt class
*/
@isTest
public class CtrlAP04CancelSubscriptionTest 
{
	public static testMethod void testCtrlAP04CancelSubscription() 
	{
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
        subs.Status__c = 'Waiting For Verification';
        update subs;
        subs.Flag_IntegrityChecks__c = true;
		subs.Status__c = 'Waiting For Provisioning';
        update subs;
        subs.Status__c = 'Provisioning initiated';
        update subs;
        subs.Status__c = 'Active';
        update subs;
        
        
		Test.StartTest(); 
	    
	    // Page preparation
	    PageReference pageRef = Page.CancelSubscription;
	    Test.setCurrentPage(pageRef);
	    
	    ApexPages.currentPage().getParameters().put('id', subs.Id);
	    
	    CtrlAP04CancelSubscription controller = new CtrlAP04CancelSubscription(new ApexPages.StandardController(subs));
	    
	    // Test 1 : Init() Fail : no provisioning
	    System.AssertEquals(null, controller.init());
	    System.AssertEquals(true, controller.error);
	    
	    // Test 2 : Init() Success
	    Provisioning__c   provisioning = TestData.createTestProvisioningAndServices(subs.Id, contractId, a.Id);
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioning.Id, servWithServAttributes); 
        
        System.AssertEquals(null, controller.init());
	    System.AssertEquals(false, controller.error);
	    System.AssertEquals(Date.Today(), controller.sub.End_Date__c);
	    
	    // Test 3 : Save Success
	    String retUrl = controller.Save().getUrl();
	    System.AssertEquals('/' + subs.Id, retUrl);
	    System.AssertEquals('On Notice', controller.sub.Status__c);
	    
	    // Test 4 : Save Fail : End Date <= Start Date
	    controller.sub.End_Date__c = Date.Today() - 10;
	    System.AssertEquals(null, controller.Save());	
	    
	    // Test 5 : Cancel 
	    retUrl = controller.Cancel().getUrl();
	    System.AssertEquals('/' + subs.Id, retUrl);   
	    	
	    Test.stopTest();
    }
}