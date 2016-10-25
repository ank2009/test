@isTest
public class OppPromotionAfterUpdateTest
{
    public static testMethod void testTrigger()
    {
        List<ID> services     = TestData.createTestServices(2);
        Product__c prod       = TestData.createTestProductAndLineItems(services, false, true);

        Promotion__c promo    = TestData.createPromotionWithLineItems(2, true);

        Offer_Template__c ot  = TestData.createOfferTemplate(prod, false);
        Offer_Promo__c oP     = TestData.createOfferPromoWithLineItemsAndLinks(ot.Id, promo.Id, new List<ID>());

        TST_OfferTemplateTestHelper.activateOfferTemplate(ot);
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        Opportunity opp       = TestData.createTestOpportunity(acc.Id);
        Opp_Promotion__c oppP = TestData.createOppPromoWithLineItemsAndLinks(opp.Id, oP.Id);

        oppP.Name = 'Updated';
        update oppP;
    }
}