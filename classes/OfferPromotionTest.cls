@isTest
public class OfferPromotionTest
{
    public static testMethod void testTrigger() 
    {
        Promotion__c promo = TestData.createPromotionWithLineItems(2, true);
        
        List<ID> services = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false);
        Offer_Promo__c offp = TestData.createOfferPromoWithLineItemsAndLinks(ot.Id, promo.Id, new List<ID>()); 
                
        delete offp ; 
    }
}