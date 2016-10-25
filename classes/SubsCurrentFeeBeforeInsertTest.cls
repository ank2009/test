@isTest
public class SubsCurrentFeeBeforeInsertTest
{
    public static testMethod void testTrigger()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
    	
        List<ID> services     = TestData.createTestServices(2);
        Product__c prod       = TestData.createTestProductAndLineItems(services, false, true);

        Offer_Template__c ot          = TestData.createOfferTemplate(prod, false);
        List<Offer_Line_Item__c> olis = TestData.createTestOfferTemplateHierarchy(ot.Id, services);

        TST_OfferTemplateTestHelper.activateOfferTemplate(ot);

        List<ID> oliIds = new List<ID>();
        for (Offer_Line_Item__c oli : olis)
            oliIds.add(oli.Id);
		Account acc = TST_AccountTestHelper.createDummyAccount(true);
        Opportunity opp                       = TestData.createTestOpportunity(acc.Id);
        List<Opportunity_Line_Item__c> oppLis = TestData.createTestOpportunityHierarchy(opp.Id, oliIds);

        List<ID> oppliIds = new List<ID>();
        for (Opportunity_Line_Item__c oppli : oppLis)
            oppliIds.add(oppli.Id);

        Contract contract             = TestData.createTestContract(opp.AccountId);
        Subscription__c subs          = TestData.createTestSubscription(prod.Id, contract.Id);
        List<Subscription_Line_Item__c> subsLis = TestData.createTestSubscriptionHierarchy(subs.Id, oppliIds);

        Subs_Current_Fee__c scf       = new Subs_Current_Fee__c ();
        scf.Subscription__c           = subs.Id;
        scf.Subscription_Line_Item__c = [SELECT Id FROM Subscription_Line_Item__c WHERE Subscription__c = :subs.ID LIMIT 1].Id;

        insert scf;
    }
}