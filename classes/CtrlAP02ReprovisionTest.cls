@isTest
public class CtrlAP02ReprovisionTest 
{
	public static testMethod void testCtrlAP02Reprovision() 
	{
        system.debug('------------- ' + Mapping_Organization_Country__c.getAll());
		// -------------
	    // Data creation
        // -------------
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        // Services
        List<ID> services = TestData.createTestServices(10);
        
        
        
        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
        serviceNbSA.put(id, 2);
        
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        
        // Product
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        
        // Account
        Account a = TST_AccountTestHelper.createDummyAccount(true);
        
        // Contact
        ID contactID = TST_ContactTestHelper.createDummyContact(a, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true).Id;
        
        // Contract
        Id contractId = TestData.createTestContract(a.Id).Id;
        
        // Subscription
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;
        
        // Provisioning
        Provisioning__c provisioning = TestData.createTestProvisioningAndServices(subsId, contractId, a.Id);
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioning.Id, servWithServAttributes); 
        
        // Rights Template
        Rights_Template__c rightsTpl = TestData.createRightsTemplate(provisioning, true);
        
        // User Profile
        User_Profile__c up = TestData.createTestUserProfile(contactID, provisioning.Id, provServices);
        up.Status__c = 'In Progress';
        update up;
        
        Test.StartTest(); 
	    
	    // Page preparation
	    PageReference pageRef = Page.Reprovision;
	    Test.setCurrentPage(pageRef);
	    
	    ApexPages.currentPage().getParameters().put('source', 'TGO');
	    
	    CtrlAP02Reprovision controller = new CtrlAP02Reprovision(new ApexPages.StandardController(provisioning));
	    
	    // Test 1 : Init() TGO 
	    String retUrl = controller.init().getUrl();
	    System.AssertEquals('/' + provisioning.Id, retUrl);
	    
	    // Test 2 : Init() Standard
	    ApexPages.currentPage().getParameters().put('source', 'std');
	    
	    controller = new CtrlAP02Reprovision(new ApexPages.StandardController(provisioning));
	     
	    retUrl = controller.init().getUrl();
	    System.AssertEquals('/' + provisioning.Id, retUrl);
	    	
	    Test.stopTest();
    }
}