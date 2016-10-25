/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlDeleteOfferPromotion
 */
@isTest
public class CtrlDeleteOfferPromotionTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        List<ID> services = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false);
        PackFee__c pf = TestData.createPackageAndFeeWithLineItems(services, true);
        Offer_Package_And_Fee__c opf = TestData.createOfferPackageAndFee(ot, pf);
        Promotion__c promo = TestData.createPromotion();
        Offer_Promo__c op = TestData.createOfferPromotion(ot, promo);
        
        // Page preparation
        PageReference pageRef = Page.DeleteOfferPromotion;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', op.Id);
        ApexPages.currentPage().getParameters().put('retID', ot.Id);
        
        CtrlDeleteOfferPromotion controller = new CtrlDeleteOfferPromotion(new ApexPages.StandardController(op));
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + ot.Id, cancelPage);

        // Test correct init
        String correctDelete = controller.init().getUrl();
        System.assertEquals('/' + ot.Id, correctDelete);

        // Test exception
        Offer_Promo__c op2 = TestData.createOfferPromotion(ot, promo);
        ApexPages.currentPage().getParameters().put('id', op2.Id);
        controller = new CtrlDeleteOfferPromotion(new ApexPages.StandardController(op2));
        delete op2;
        System.assertEquals(null, controller.init());

        // Test bad init
        /*Offer_Promo__c op3 = TestData.createOfferPromotion(ot, promo);
        ot.Status__c = 'Active';
        update ot;
        ApexPages.currentPage().getParameters().put('id', op3.Id);
        controller = new CtrlDeleteOfferPromotion(new ApexPages.StandardController(op3));
        System.assertEquals(null, controller.init());*/
                
        Test.stopTest();
                
    }

}