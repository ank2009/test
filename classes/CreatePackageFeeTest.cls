/**
 * @author Nicolas Dolet
 * @date 17/01/2012
 * @description Test trigger CreatePackageFee
 */
@isTest
public class CreatePackageFeeTest {

    public static testMethod void testTrigger() {
    
        List<ID> services = TestData.createTestServices(10);
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);        
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount(true);
        Contact c = TST_ContactTestHelper.createDummyContact(a, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        Id contractId = TestData.createTestContract(a.Id).Id;
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;
        Provisioning__c provisioning = TestData.createTestProvisioningAndServices(subsId, contractId, a.Id);
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioning.Id, servWithServAttributes); 
        Rights_Template__c rightsTpl = TestData.createRightsTemplate(provisioning, true);
        User_Profile__c up = TestData.createTestUserProfile(c.Id, provisioning.Id, provServices);
    
    }

}