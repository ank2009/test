/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlEditOfferPromotion
 */
@isTest
public class CtrlEditOfferPromotionTest {

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
        PageReference pageRef = Page.EditOfferPromotion;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', op.Id);
        ApexPages.currentPage().getParameters().put('retURL', op.Id);
        
        CtrlEditOfferPromotion controller = new CtrlEditOfferPromotion(new ApexPages.StandardController(op));
        
        Test.startTest();

        // Test correct init
        System.assertEquals(controller.error, false);
        
        // Test correct save
        System.assertEquals('/' + op.Id, controller.save().getUrl());

        // Test exception
        delete op;
        System.assertEquals(null, controller.save());

        // Test error init
        /*Offer_Promo__c op2 = TestData.createOfferPromotion(ot, promo);
        ot.Status__c = 'Active';
        update ot;
        ApexPages.currentPage().getParameters().put('id', op2.Id);
        controller = new CtrlEditOfferPromotion(new ApexPages.StandardController(op2));
        System.assertEquals(controller.error, true);
                */
        Test.stopTest();
                
    }

}