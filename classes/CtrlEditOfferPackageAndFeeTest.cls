/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlEditOfferPackageAndFee
 */
@isTest
public class CtrlEditOfferPackageAndFeeTest {

    public static testMethod void testCtrl() {

        // Data generation
        List<ID> services = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false);
        List<Offer_Line_Item__c> olis = TestData.createTestOfferTemplateHierarchy(ot.Id, services);
        PackFee__c pf = TestData.createPackageAndFeeWithLineItems(services, true);
        Offer_Package_And_Fee__c opf = TestData.createOfferPackageAndFee(ot, pf);

        // Page preparation
        PageReference pageRef = Page.EditOfferPackageAndFee;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', opf.Id);
        ApexPages.currentPage().getParameters().put('retURL', opf.Id);

        CtrlEditOfferPackageAndFee controller = new CtrlEditOfferPackageAndFee(new ApexPages.StandardController(opf));

        Test.startTest();


        // Test correct save
        System.assertEquals('/' + opf.Id, controller.save().getUrl());

        // Test incorrect save
        Offer_Package_And_Fee__c opf2 = TestData.createOfferPackageAndFee(ot, pf);
        ApexPages.currentPage().getParameters().put('id', opf2.Id);
        controller = new CtrlEditOfferPackageAndFee(new ApexPages.StandardController(opf2));
        delete opf2;
        System.assertEquals(null, controller.save());

        // Test error
        /*Offer_Package_And_Fee__c opf3 = TestData.createOfferPackageAndFee(ot, pf);
        TST_OfferTemplateTestHelper.activateOfferTemplate(ot);
        ApexPages.currentPage().getParameters().put('id', opf3.Id);
        controller = new CtrlEditOfferPackageAndFee(new ApexPages.StandardController(opf3));
        System.assertEquals(controller.error, true);
*/
        Test.stopTest();

    }

}