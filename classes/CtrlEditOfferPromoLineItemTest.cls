/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlEditOfferPromoLineItem
 */
@isTest
public class CtrlEditOfferPromoLineItemTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        List<ID> services = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false);
        PackFee__c pf = TestData.createPackageAndFeeWithLineItems(services, true);
        Offer_Package_And_Fee__c opf = TestData.createOfferPackageAndFee(ot, pf);
        Promotion__c promo = TestData.createPromotion();
        List<Promotion_Line_Item__c> promoLIs = TestData.createPromotionLineItems(promo, 2);
        Offer_Promo__c op = TestData.createOfferPromotion(ot, promo);
        List<Offer_Promo_Line_Item__c> opLIs = TestData.createOfferPromoLIs(op, promoLIs);

        // Page preparation
        PageReference pageRef = Page.EditOfferPromoLineItem;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', opLIs[0].Id);
        
        CtrlEditOfferPromoLineItem controller = new CtrlEditOfferPromoLineItem(new ApexPages.StandardController(opLIs[0]));
        System.assertEquals(controller.error, false);
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + op.Id, cancelPage);

        // Test correct save
        String correctSave = controller.save().getUrl();
        System.assertEquals('/' + op.Id, correctSave);

        // Test exception
        delete opLIs[0];
        System.assertEquals(null, controller.save());

        // Test bad init
        /*ot.Status__c = 'Active';
        update ot;
        ApexPages.currentPage().getParameters().put('id', opLIs[1].Id);
        controller = new CtrlEditOfferPromoLineItem(new ApexPages.StandardController(opLIs[1]));
        System.assertEquals(controller.error, true);
                */
        Test.stopTest();
                
    }

}