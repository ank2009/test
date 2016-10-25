/**
 * @author Nicolas Dolet
 * @date 16/01/2012
 * @description Test trigger deleteOfferPromoLinks
 */
@isTest
public class DeleteOfferPromoLinksTest {

    public static testMethod void testTrigger() {
        List<ID> services = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false);
        Promotion__c promo = TestData.createPromotion();
        Offer_Promo__c op = TestData.createOfferPromotion(ot, promo);
        op.Level__c = 'Package(s)/Fee(s)';
        update op;
    }
    
}