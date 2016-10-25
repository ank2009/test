/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlDeleteVolumeDiscountBracket
 */
@isTest
public class CtrlDeleteVolumeDiscountBracketTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        Volume_Discount__c vd = TestData.createVolumeDiscount();
        Volume_Discount_Bracket__c vdb1 = TestData.createVolumeDiscountBrackets(vd, 1)[0];
        Volume_Discount_Bracket__c vdb2 = TestData.createVolumeDiscountBrackets(vd, 1)[0];
        Volume_Discount_Bracket__c vdb3 = TestData.createVolumeDiscountBrackets(vd, 1)[0];
        
        // Page preparation
        PageReference pageRef = Page.DeleteVolumeDiscountBracket;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', vdb1.Id);
        ApexPages.currentPage().getParameters().put('retID', vd.Id);
        
        CtrlDeleteVolumeDiscountBracket controller = new CtrlDeleteVolumeDiscountBracket(new ApexPages.StandardController(vdb1));
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + vd.Id, cancelPage);

        // Test correct init
        String correctDelete = controller.init().getUrl();
        System.assertEquals('/' + vd.Id, correctDelete);

        // Test exception
        ApexPages.currentPage().getParameters().put('id', vdb2.Id);
        controller = new CtrlDeleteVolumeDiscountBracket(new ApexPages.StandardController(vdb2));
        delete vdb2;
        System.assertEquals(null, controller.init());

        // Test bad init
        ApexPages.currentPage().getParameters().put('id', vdb3.Id);
        vd.Status__c = 'Active';
        update vd;
        controller = new CtrlDeleteVolumeDiscountBracket(new ApexPages.StandardController(vdb3));
        System.assertEquals(null, controller.init());
                
        Test.stopTest();
        
    }

}