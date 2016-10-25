@isTest
public class PromotionLineItemTest
{
    public static testMethod void testTrigger() 
    {
        Promotion__c promo = TestData.createPromotionWithLineItems(2, false);
        
        List<Promotion_Line_Item__c> plis = [SELECT Id FROM Promotion_Line_Item__c WHERE Promotion__c = :promo.Id];
        
        delete plis[0];
    }
}