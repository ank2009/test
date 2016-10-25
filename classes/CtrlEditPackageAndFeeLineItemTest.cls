/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlEditPackageAndFeeLineItem
 */
@isTest
public class CtrlEditPackageAndFeeLineItemTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        PackFee__c pf = TestData.createPackageAndFee();
        Service__c s = TestData.createTestService();
        Package_and_Fee_Line_Item__c pfli = TestData.createPackageAndFeeLineItem(pf, s);
        
        
        // Page preparation
        PageReference pageRef = Page.EditPackageAndFeeLineItem;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', pfli.Id);
        
        CtrlEditPackageAndFeeLineItem controller = new CtrlEditPackageAndFeeLineItem(new ApexPages.StandardController(pfli));
        
        Test.startTest();

        // Test correct init
        System.assertEquals(controller.error, false);

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + pf.Id, cancelPage);

        // Test correct save
        System.assertEquals('/' + pf.Id, controller.save().getUrl());

        // Test exception
        delete pfli;
        System.assertEquals(null, controller.save());

        // Test bad init
        Package_and_Fee_Line_Item__c pfli2 = TestData.createPackageAndFeeLineItem(pf, s);
        pf.Status__c = 'Active';
        update pf;
        ApexPages.currentPage().getParameters().put('id', pfli2.Id);
        controller = new CtrlEditPackageAndFeeLineItem(new ApexPages.StandardController(pfli2));
        System.assertEquals(controller.error, true);
               
        Test.stopTest();
                
    }

}