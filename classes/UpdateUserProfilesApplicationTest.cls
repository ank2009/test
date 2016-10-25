@isTest
public class UpdateUserProfilesApplicationTest
{
    public static testMethod void testUpdateUserProfilesApplication()
    {
    
        // Services
        List<ID> services = TestData.createTestServices(10);
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        // Product
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        // Account
        Account a = TST_AccountTestHelper.createDummyAccount(true);
		List<Contact> cList = TST_ContactTestHelper.createDummyContactList(a, 10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        // Contract
        Id contractId = TestData.createTestContract(a.Id).Id;
        // Subscription
        Subscription__c subs= TestData.createTestSubscription(productId, contractId);
        subs.Access_Kind__c='O3E';
        update subs;
        // Provisioning
        Provisioning__c provisioning = TestData.createTestProvisioningAndServices(subs.Id, contractId, a.Id);
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioning.Id, servWithServAttributes); 
        // User Profiles
        List<Id> cListIds = new List<Id>();
        for(Contact c : cList)
        	cListIds.add(c.Id);
        	
        List<ID> userProfiles = TestData.createTestUserProfiles(cListIds, provisioning.Id, provServices);
        
        subs.Access_Kind__c='WEB3N';
        update subs;
        User_Profile__c UP=[SELECT Id, Activated__c FROM User_Profile__c WHERE Id=: userProfiles[0]];
        UP.Activated__c= true;
        update UP;
        
    }
}