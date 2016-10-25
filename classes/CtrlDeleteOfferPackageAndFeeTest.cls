/**
 * @author Nicolas Dolet
 * @date 21/12/2011
 * @description Test CtrlDeleteOfferPackageAndFee
 */
@isTest
public class CtrlDeleteOfferPackageAndFeeTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        List<ID> services = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false);
        PackFee__c pf = TestData.createPackageAndFeeWithLineItems(services, true);
        Offer_Package_And_Fee__c opf = TestData.createOfferPackageAndFee(ot, pf);
        
        // Page preparation
        PageReference pageRef = Page.DeleteOfferPackageAndFee;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', opf.Id);
        
        CtrlDeleteOfferPackageAndFee controller = new CtrlDeleteOfferPackageAndFee(new ApexPages.StandardController(opf));
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + ot.Id, cancelPage);

        // Test correct init
        String correctDelete = controller.init().getUrl();
        System.assertEquals('/' + ot.Id, correctDelete);

        // Test exception
        Offer_Package_And_Fee__c opf2 = TestData.createOfferPackageAndFee(ot, pf);
        ApexPages.currentPage().getParameters().put('id', opf2.Id);
        controller = new CtrlDeleteOfferPackageAndFee(new ApexPages.StandardController(opf2));
        delete opf2;
        System.assertEquals(null, controller.init());

        // Test bad init
        /*Offer_Package_And_Fee__c opf3 = TestData.createOfferPackageAndFee(ot, pf);
        ot.Status__c = 'Active';
        update ot;
        ApexPages.currentPage().getParameters().put('id', opf3.Id);
        controller = new CtrlDeleteOfferPackageAndFee(new ApexPages.StandardController(opf3));
        System.assertEquals(null, controller.init());
                */
        Test.stopTest();
                
    }

}