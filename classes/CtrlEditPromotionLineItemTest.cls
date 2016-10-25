/**
 * @author Nicolas Dolet
 * @date 19/12/2011
 * @description Test EditPromotionLineItem controller
 */
@isTest
public class CtrlEditPromotionLineItemTest {

    /*public static testMethod void testCtrl() {
    
        // Data generation
        Promotion__c promo = TestData.createPromotion();
        List<Promotion_Line_Item__c> plis = TestData.createPromotionLineItems(promo, 1);
                
        // Page preparation
        PageReference pageRef = Page.EditPromotionLineItem;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', plis[0].Id);

        CtrlEditPromotionLineItem controller = new CtrlEditPromotionLineItem(new ApexPages.StandardController(plis[0]));
                
        // Test correct save
        String correctSave = controller.save().getUrl();
        System.assertEquals('/' + promo.Id, correctSave);
                
        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + promo.Id, cancelPage);
        
        // Test status error
        promo.Status__c = 'Active';
        update promo;
        controller = new CtrlEditPromotionLineItem(new ApexPages.StandardController(plis[0]));

        // Test incorrect save
        promo.Status__c = 'On Notice';
        update promo;
        promo.Status__c = 'Inactive';
        update promo;
        promo.Status__c = 'Pending';
        update promo;
        delete plis[0];
        System.assertEquals(null, controller.save());

    }*/

}