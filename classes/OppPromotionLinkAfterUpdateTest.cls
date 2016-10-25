@isTest
public class OppPromotionLinkAfterUpdateTest
{
    public static testMethod void testTrigger()
    {
        List<ID> services     = TestData.createTestServices(2);
        Product__c prod       = TestData.createTestProductAndLineItems(services, false, true);

        Promotion__c promo    = TestData.createPromotionWithLineItems(1, true);
        PackFee__c pf         = TestData.createPackageAndFeeWithLineItems(services, true);

        Offer_Template__c ot         = TestData.createOfferTemplate(prod, false);
        Offer_Package_And_Fee__c opf =  TestData.createOfferPackageAndFeeAndLineItems(ot.Id, pf.Id);
        Offer_Promo__c oP            = TestData.createOfferPromoWithLineItemsAndLinks(ot.Id, promo.Id, new List<ID>{opf.Id});

        TST_OfferTemplateTestHelper.activateOfferTemplate(ot);
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        Opportunity opp       = TestData.createTestOpportunity(acc.Id);
        Opp_Promotion__c oppP = TestData.createOppPromoWithLineItemsAndLinks(opp.Id, oP.Id);

        Opp_Promo_Link__c opppl = [SELECT Id, Opp_Package_And_Fee__c FROM Opp_Promo_Link__c WHERE Opp_Promotion__c = :oppP.Id];

        opppl.Opp_Package_And_Fee__c = null;
        update opppl;
    }
}