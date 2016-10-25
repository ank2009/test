@isTest
public class RightsTemplateSABeforeDeleteTest
{
    public static testMethod void testTrigger() 
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Service__c service          = TestData.createTestService();
        
        Map<ID, Integer> idServices = new Map<ID, Integer>();
        idServices.put(service.Id, 1);
        
        Map<ID, List<ID>> services = TestData.createTestServiceAttributes(idServices);
        Product__c prod            = TestData.createTestProductAndLineItems(new List<ID>{service.Id}, false, true);
        
        Account account               = TST_AccountTestHelper.createDummyAccount(true);
        Contract contract             = TestData.createTestContract(account.Id); 
        Subscription__c subs          = TestData.createTestSubscription(prod.Id, contract.Id);
        Provisioning__c prov          = TestData.createTestProvisioningAndServices(subs.Id, contract.Id, account.Id);
        Rights_Template__c rt         = TestData.createRightsTemplate(prov, false); 
        Map<ID, List<Id>> rtHierarchy = TestData.createTestRightsTemplateHierarchy(rt.Id, services);
        
        Rights_Template_Service_Attribute__c rtsa = [SELECT Id FROM Rights_Template_Service_Attribute__c WHERE Id = :rtHierarchy.Values()[0]];
        
        delete rtsa;
        
        List <Id> RTsIds = new List <Id>();
        
        Rights_Template_Service__c Rts1 = new Rights_Template_Service__c();
        Rts1.Name = service.Name; 
        Rts1.Rights_Template__c = rt.Id;
        Rts1.Service__c = service.Id;
        insert Rts1;
        RTsIds.add(Rts1.Id); 

        Rights_Template_Service__c Rts2 = new Rights_Template_Service__c();
        Rts2.Name = service.Name; 
        Rts2.Rights_Template__c = rt.Id;
        Rts2.Service__c = service.Id;
        insert Rts2;
        RTsIds.add(Rts2.Id);
        
        List <Rights_Template_Service__c> RTsToDelete = [Select Id from Rights_Template_Service__c where Id in: RTsIds];
        
        Delete RTsToDelete ;
    }
}