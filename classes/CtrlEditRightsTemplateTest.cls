/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlEditRightsTemplate
 */
@isTest
public class CtrlEditRightsTemplateTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        List<ID> services = TestData.createTestServices(10);
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
		
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
    	Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        
		Account a = TST_AccountTestHelper.createDummyAccount('France', true);
		List<Contact> cList = TST_ContactTestHelper.createDummyContactList(a, 10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        Id contractId = TestData.createTestContract(a.Id).Id;
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;
        Provisioning__c provisioning = TestData.createTestProvisioningAndServices(subsId, contractId, a.Id);
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioning.Id, servWithServAttributes); 
        Rights_Template__c rightsTpl = TestData.createRightsTemplate(provisioning, false);

        rightsTpl.PUG_Name__c = 'Test PUG Name';
        update rightsTpl;
        
        // Page preparation
        PageReference pageRef = Page.EditRightsTemplate;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', rightsTpl.Id);
        ApexPages.currentPage().getParameters().put('retURL', provisioning.Id);
        
        CtrlEditRightsTemplate controller = new CtrlEditRightsTemplate(new ApexPages.StandardController(rightsTpl));
        controller.cugAllowed = true;
        
        Test.startTest();

        // Test getters
        System.assertNotEquals(null,controller.getRT());

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + provisioning.Id, cancelPage);

        // Test correct save
        String correctSave = controller.save().getUrl();
        System.assertEquals('/' + provisioning.Id, correctSave);

        // Test exception
        delete rightsTpl;
        System.assertEquals(null, controller.save());

        Test.stopTest();
                
    }

}