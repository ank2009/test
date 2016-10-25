@isTest
public class CtrlNewCampaignPromoFromSubsTest
{
	public static testMethod void testCtrlNewCampaignPromoFromSubs()
    {
		// Data preparation
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount('France',true);
        // Services
        List<ID> services = TestData.createTestServices(10);

        // Product
        Product__c product = TestData.createTestProductAndLineItems(services, false, true);

        // Package
        PackFee__c pf = TestData.createPackageAndFeeWithLineItems(services, true);

        // Offer Template
        Offer_Template__c ot 			  = TestData.createOfferTemplate(product, false);
        List<Offer_Line_Item__c> offerLIs = TestData.createTestOfferTemplateHierarchy(ot.Id, services);
        Offer_Package_And_Fee__c opf 	  = TestData.createOfferPackageAndFeeAndLineItems(ot.Id, pf.Id);

        TST_OfferTemplateTestHelper.activateOfferTemplate(ot);

        List<ID> offerLineItems = new List<ID>();
        for (Offer_Line_Item__c oli : offerLIs)
        	offerLineItems.add(oli.Id);

        // Opportunity  (and Account)
		Opportunity opp 					  = TestData.createTestOpportunity(acc.Id);
		List<Opportunity_Line_Item__c> oppLIs = TestData.createTestOpportunityHierarchy(opp.Id, offerLineItems);
		Opp_Package_And_Fee__c opppf          = TestData.createOppPackageAndFeeWithLineItems(opp.Id, opf.Id);

		List<ID> oppLineItems = new List<ID>();
        for (Opportunity_Line_Item__c oppli : oppLIs)
        	oppLineItems.add(oppli.Id);

        // Contract
        Contract contract = TestData.createTestContract(opp.AccountId);

		// Subscriptions
		Subscription__c subs   					= TestData.createTestSubscription(product.Id, contract.Id);
		List<Subscription_Line_Item__c> subsLIs = TestData.createTestSubscriptionHierarchy(subs.Id, oppLineItems);
		Subs_Package_And_Fee__c subsPF			= TestData.createSubsPackageAndFeeWithLineItems(subs.Id, opppf.Id);
		subs.Offer_Template__c = ot.Id;
		update subs;

        // Start Test
        Test.StartTest();

        PageReference pageRef = Page.NewCampaignPromoFromSubs;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', subs.Id);

        CtrlNewCampaignPromoFromSubs controller  = new CtrlNewCampaignPromoFromSubs(new ApexPages.StandardController(subs));

        // Test 1 : init
        controller.init();
        System.AssertEquals(10, controller.getSubservices().size());
        System.AssertEquals(1, controller.getPafs().size());

        Test.StopTest();
	}
}