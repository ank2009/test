@isTest
public class updateDefaultFlagTest
{
    public static testMethod void testTrigger() 
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        List<ID> services          = TestData.createTestServices(2);
        
        Product__c prod            = TestData.createTestProductAndLineItems(services, false, true);
        
        Account account               = TST_AccountTestHelper.createDummyAccount(true);
        Contract contract             = TestData.createTestContract(account.Id); 
        Subscription__c subs          = TestData.createTestSubscription(prod.Id, contract.Id);
        Provisioning__c prov          = TestData.createTestProvisioningAndServices(subs.Id, contract.Id, account.Id);
        Rights_Template__c rt         = TestData.createRightsTemplate(prov, false);
        
        rt.Default__c = false;
        update rt;
    }
}