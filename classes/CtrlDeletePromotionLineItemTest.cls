/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlDeletePromotionLineItem
 */
@isTest
public class CtrlDeletePromotionLineItemTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        Promotion__c promo = TestData.createPromotion();
        Promotion_Line_Item__c pli = TestData.createPromotionLineItems(promo, 1)[0];
        
        // Page preparation
        PageReference pageRef = Page.DeletePromotionLineItem;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', pli.Id);
        ApexPages.currentPage().getParameters().put('retID', promo.Id);
        
        CtrlDeletePromotionLineItem controller = new CtrlDeletePromotionLineItem(new ApexPages.StandardController(pli));
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + promo.Id, cancelPage);

        // Test correct init
        String correctDelete = controller.init().getUrl();
        System.assertEquals('/' + promo.Id, correctDelete);

        // Test exception
        Promotion_Line_Item__c pli2 = TestData.createPromotionLineItems(promo, 1)[0];
        ApexPages.currentPage().getParameters().put('id', pli2.Id);
        controller = new CtrlDeletePromotionLineItem(new ApexPages.StandardController(pli2));
        delete pli2;
        System.assertEquals(null, controller.init());

        // Test bad init
        Promotion_Line_Item__c pli3 = TestData.createPromotionLineItems(promo, 1)[0];
        ApexPages.currentPage().getParameters().put('id', pli3.Id);
        controller = new CtrlDeletePromotionLineItem(new ApexPages.StandardController(pli3));
        promo.Status__c = 'Active';
        update promo;
        ApexPages.currentPage().getParameters().put('id', pli3.Id);
        controller = new CtrlDeletePromotionLineItem(new ApexPages.StandardController(pli3));
        System.assertEquals(null, controller.init());
                
        Test.stopTest();
                
    }

}