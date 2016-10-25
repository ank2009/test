@isTest
public class OpportunityAfterUpdateTest
{
    public static testMethod void testTrigger() 
    {
        // Data generation
        // Services
        List<ID> services = TestData.createTestServices(10);
        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
        serviceNbSA.put(id, 2);
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        // Product
        Product__c product = TestData.createTestProductAndLineItems(services, false, true);
        ID OfferTemplateId = TestData.createOfferTemplate(product,true).Id;
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        Opportunity Opp= TestData.createTestOpportunity(acc.Id);
        Opportunity InsertedOpp = [SELECT Id, Name, Offer_Template__c, CloseDate , Start_Usage_Payment_Date__c, Maximum_Invoice_Amount__c, CUG_Allowed__c 
                                    FROM Opportunity WHERE Id =: Opp.Id];
        
        Opp.Offer_Template__c=OfferTemplateId ;
        update InsertedOpp ;

    }
}