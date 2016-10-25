/**
 * @author Nicolas Dolet
 * @date 13/02/2012
 * @description Test trigger UpdatePriceListCode
 */
@isTest
public class UpdatePriceListCodeTest {

    public static testMethod void testTrigger() {
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        // Services
        List<ID> services = TestData.createTestServices(10);
        
        // Product
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        
        // Account
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        Id accountId = acc.Id;
                
        //String oc = [SELECT Organization_Country__c FROM Account WHERE Id = :accountId].Organization_Country__c;
        
        //System.AssertEquals('Belgium', oc);
        
        // Contract
        Id contractId = TestData.createTestContract(accountId).Id;
        
        // Subscription
        Subscription__c subs = TestData.createTestSubscription(productId, contractId);
    
    }
}