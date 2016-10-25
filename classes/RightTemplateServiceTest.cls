@isTest
public class RightTemplateServiceTest {
    public static testMethod void testRTSTrigger() 
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Service__c service          = TestData.createTestService();
        
        Map<ID, Integer> idServices = new Map<ID, Integer>();
        idServices.put(service.Id, 1);
        
        Map<ID, List<ID>> services = TestData.createTestServiceAttributes(idServices);
        Product__c prod            = TestData.createTestProductAndLineItems(new List<ID>{service.Id}, false, true);
        
        Account account               = TST_AccountTestHelper.createDummyAccount('France',true);
        Contract contract             = TestData.createTestContract(account.Id); 
        Subscription__c subs          = TestData.createTestSubscription(prod.Id, contract.Id);
        Provisioning__c prov          = TestData.createTestProvisioningAndServices(subs.Id, contract.Id, account.Id);
        Rights_Template__c rt         = TestData.createRightsTemplate(prov, false); 
        Map<ID, List<Id>> rtHierarchy = TestData.createTestRightsTemplateHierarchy(rt.Id, services);
        
        Rights_Template_Service_Attribute__c rtsa = [SELECT Id FROM Rights_Template_Service_Attribute__c WHERE Id = :rtHierarchy.Values()[0]];
        
        delete rtsa;
    }

}