/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlDeleteOfferPromoLink
 */
@isTest
public class CtrlDeleteOfferPromoLinkTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        List<ID> services = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false);
        PackFee__c pf = TestData.createPackageAndFeeWithLineItems(services, true);
        Offer_Package_And_Fee__c opf = TestData.createOfferPackageAndFee(ot, pf);
        Promotion__c promo = TestData.createPromotion();
        Offer_Promo__c op = TestData.createOfferPromotion(ot, promo);
        Offer_Promo_Link__c opl = TestData.createOfferPromoLink(op, opf);
        
        // Page preparation
        PageReference pageRef = Page.DeleteOfferPromoLink;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', opl.Id);
        
        CtrlDeleteOfferPromoLink controller = new CtrlDeleteOfferPromoLink(new ApexPages.StandardController(opl));
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + op.Id, cancelPage);

        // Test correct init
        String correctDelete = controller.init().getUrl();
        System.assertEquals('/' + op.Id, correctDelete);

        // Test exception
        Offer_Promo_Link__c opl2 = TestData.createOfferPromoLink(op, opf);
        ApexPages.currentPage().getParameters().put('id', opl2.Id);
        controller = new CtrlDeleteOfferPromoLink(new ApexPages.StandardController(opl2));
        delete opl2;
        System.assertEquals(null, controller.init());

        // Test bad init
        /*Offer_Promo_Link__c opl3 = TestData.createOfferPromoLink(op, opf);
        ot.Status__c = 'Active';
        update ot;
        ApexPages.currentPage().getParameters().put('id', opl3.Id);
        controller = new CtrlDeleteOfferPromoLink(new ApexPages.StandardController(opl3));
        System.assertEquals(null, controller.init());
                */
        Test.stopTest();
                
    }

}