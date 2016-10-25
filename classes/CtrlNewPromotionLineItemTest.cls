/**
 * @author AK
 */
@isTest
public class CtrlNewPromotionLineItemTest 
{
    /*public static testMethod void testCtrlNewPromotionLineItem() 
    {
        Test.startTest();
        
        // Data generation
        Promotion__c Promo = TestData.createPromotion();
        Promotion_Line_Item__c promotionLI = new Promotion_Line_Item__c();
        promotionLI.Promotion__c = Promo.Id;
        promotionLI.Sort_Order__c = 1;
        promotionLI.Duration_Type__c = 'Months';
        promotionLI.Min_Duration__c = 0;
        promotionLI.Max_Duration__c = 12;
        
        // Page preparation
        PageReference pageRef = Page.NewPromotionLineItem;
        Test.setCurrentPage(pageRef);
        
        CtrlNewPromotionLineItem  controller = new CtrlNewPromotionLineItem(new ApexPages.StandardController(promotionLI));
        
        // Test correct save
        String correctSave = controller.save().getUrl();
//      String prefix      = Schema.SObjectType.Promotion_Line_Item__c.getKeyPrefix();
//      String prefix  = Schema.getGlobalDescribe().get('Promotion_Line_Item__c').getDescribe().getKeyPrefix();
        System.AssertEquals('/' + Promo.Id,correctSave);//.startsWith('/' + prefix));
                        
        
        // Test cancel
        String cancelPage = controller.cancel().getUrl();
//      System.AssertEquals('/' + prefix + '/a', cancelPage);
        System.AssertEquals('/' + Promo.Id, cancelPage);
        
        Promo.Status__c= 'Active';
        update Promo;
        controller = new CtrlNewPromotionLineItem(new ApexPages.StandardController(promotionLI));
        System.AssertEquals(null, controller.save());
    
        Test.stopTest();
    }*/
}