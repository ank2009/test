@isTest
public class OppPromotionLIAfterUpdateTest
{
    public static testMethod void testTrigger()
    {
        List<ID> services     = TestData.createTestServices(2);
        Product__c prod       = TestData.createTestProductAndLineItems(services, false, true);

        Promotion__c promo    = TestData.createPromotionWithLineItems(1, true);

        Offer_Template__c ot  = TestData.createOfferTemplate(prod, false);
        Offer_Promo__c oP     = TestData.createOfferPromoWithLineItemsAndLinks(ot.Id, promo.Id, new List<ID>());

        Offer_Promo_Line_Item__c opli = [SELECT Id, Max_Price__c FROM Offer_Promo_Line_Item__c WHERE Offer_Promotion__c = :oP.Id];

        opli.Max_Price__c = 100;
        update opli;

        TST_OfferTemplateTestHelper.activateOfferTemplate(ot);
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        Opportunity opp       = TestData.createTestOpportunity(acc.Id);
        Opp_Promotion__c oppP = TestData.createOppPromoWithLineItemsAndLinks(opp.Id, oP.Id);

        Opportunity_Promo_Line_Item__c oppli = [SELECT Id, Sales_Price__c FROM Opportunity_Promo_Line_Item__c WHERE Opp_Promotion__c = :oppP.Id];

        oppli.Sales_Price__c = 50;
        update oppli;
    }
}