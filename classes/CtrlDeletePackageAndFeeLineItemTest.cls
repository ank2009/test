/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlDeletePackageAndFeeLineItem
 */
@isTest
public class CtrlDeletePackageAndFeeLineItemTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        PackFee__c pf = TestData.createPackageAndFee();
        Service__c s = TestData.createTestService();
        Package_and_Fee_Line_Item__c pfli = TestData.createPackageAndFeeLineItem(pf, s);
        
        
        // Page preparation
        PageReference pageRef = Page.DeletePackageAndFeeLineItem;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', pfli.Id);
        ApexPages.currentPage().getParameters().put('retID', pf.Id);
        
        CtrlDeletePackageAndFeeLineItem controller = new CtrlDeletePackageAndFeeLineItem(new ApexPages.StandardController(pfli));
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + pf.Id, cancelPage);

        // Test correct init
        String correctDelete = controller.init().getUrl();
        System.assertEquals('/' + pf.Id, correctDelete);

        // Test exception
        Package_and_Fee_Line_Item__c pfli2 = TestData.createPackageAndFeeLineItem(pf, s);
        ApexPages.currentPage().getParameters().put('id', pfli2.Id);
        controller = new CtrlDeletePackageAndFeeLineItem(new ApexPages.StandardController(pfli2));
        delete pfli2;
        System.assertEquals(null, controller.init());

        // Test bad init
        Package_and_Fee_Line_Item__c pfli3 = TestData.createPackageAndFeeLineItem(pf, s);
        pf.Status__c = 'Active';
        update pf;
        ApexPages.currentPage().getParameters().put('id', pfli3.Id);
        controller = new CtrlDeletePackageAndFeeLineItem(new ApexPages.StandardController(pfli3));
        System.assertEquals(null, controller.init());
                
        Test.stopTest();
                
    }

}