@isTest
public class CtrlAP01ModifyPermissionsTest
{
    public static testMethod void testCtrlAP01ModifyPermissions()
    {
	/*
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
        
        // Account
        Id accountId = TestData.createTestAccounts().Id;
        
        // Contacts
        List<ID> contacts = TestData.createTestContacts(accountId, 10);
            
        // Contract
        Id contractId = TestData.createTestContract(accountId).Id;
        
        // Subscription
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;
        
        // Provisioning
        Provisioning__c provisioning = TestData.createTestProvisioningAndServices(subsId, contractId, accountId);
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioning.Id, servWithServAttributes); 
        
        // Rights Template
        Rights_Template__c rightsTpl = TestData.createRightsTemplate(provisioning, true);
        
        // User Profiles
        List<ID> userProfiles = TestData.createTestUserProfiles(contacts, provisioning.Id, provServices);
        
        
        // Page preparation
        PageReference pageRef = Page.ModifyPermissions;
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', provisioning.Id);
        ApexPages.currentPage().getParameters().put('user', 'all');
        
        CtrlAP01ModifyPermissions controller = new CtrlAP01ModifyPermissions(new ApexPages.StandardController(provisioning));
        
        controller.init0();
        
        // First checks via getters
        System.Assert(controller.getAvailableCUGs().size() > 1);
        System.Assert(controller.getAvailablePUGs().size() > 0);
        System.AssertEquals(10, controller.getServiceHeaders().size());
        for (CtrlAP01ModifyPermissions.WrapperService ws : controller.getServiceHeaders())
            System.AssertEquals(2, ws.serviceAttr.size());
            
        System.AssertEquals(0, controller.getPackageHeaders().size());
        System.AssertEquals(true, controller.noPackages);  
        System.AssertEquals(1, controller.getRightsTemplates().size()); 
        System.AssertEquals(10, controller.getUsers().size()); 
        
        // Test selectAllContact method
        controller.selAllUsers = true;
        controller.selectAllContacts();
        
        Integer nbSelected = 0;
        for (CtrlAP01ModifyPermissions.WrapperUser u : controller.getUsers())
        {
            if (u.userSelected)
                nbSelected++;
        }
        System.AssertEquals(10, nbSelected); 
        
        // Test applyRT
        System.AssertEquals(true, controller.getUsers()[0].getCurrentSelection().services[0].checked);
         
        controller.rightsTemplate = controller.getRightsTemplates()[0].getValue();
        controller.applyRT();
        
        System.AssertEquals(false, controller.getUsers()[0].getCurrentSelection().services[0].checked);
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.AssertEquals('User Rights applied to 10 contacts.', messages[messages.size() - 1].getSummary());
        
        // Test applyCUG
        System.AssertEquals(controller.getAvailableCUGs()[0].getValue(), controller.getUsers()[0].getCurrentSelection().cug);
        
        controller.selectedCUG = controller.getAvailableCUGs()[2].getValue();
        controller.applyCUG();
        
        System.AssertEquals(controller.getAvailableCUGs()[2].getValue(), controller.getUsers()[0].getCurrentSelection().cug);
        
        // Test applyPUGs
        System.AssertEquals(0, controller.getUsers()[0].getCurrentSelection().pugs.size());
        
        controller.selectedPUGs = new List<String>{controller.getAvailablePUGs()[2].getValue()};
        controller.applyPUGs();
        
        System.AssertEquals(1, controller.getUsers()[0].getCurrentSelection().pugs.size());
        
        // Test applyService
        System.AssertEquals(false, controller.getUsers()[0].getCurrentSelection().services[3].checked);
        
        controller.serviceToApply = 3;
        controller.getServiceHeaders()[3].checked = true;
        controller.applyService();
        
        System.AssertEquals(true, controller.getUsers()[0].getCurrentSelection().services[3].checked); 
        
        // Test applyServiceAttribute
        System.AssertEquals(false, controller.getUsers()[0].getCurrentSelection().services[3].serviceAttr[1].checked);
        
        controller.serviceToApply = 3;
        controller.serviceAttrToApply = 1;
        controller.getServiceHeaders()[3].serviceAttr[1].checked = true;
        controller.applyServiceAttribute();
        
        System.AssertEquals(true, controller.getUsers()[0].getCurrentSelection().services[3].serviceAttr[1].checked);
        
        // Test Cancel
        String cancelPage = controller.Cancel().getUrl();
        System.assertEquals('/' + provisioning.Id, cancelPage);
        
        // Test Finish
        controller.Finish();
        System.AssertEquals(10, controller.userProfileIds.size());
        
        Map<ID, List<User_Profile_Service__c>> upServices = ProvisioningMessages.getUserProfileServices(new List<Id>{userProfiles[0]});
        System.AssertEquals(1, upServices.get(userProfiles[0]).size());
        System.AssertEquals(1, upServices.get(userProfiles[0])[0].User_Profile_Service_Attributes__r.size());
		*/
    }
}