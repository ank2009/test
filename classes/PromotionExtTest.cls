@isTest
public class PromotionExtTest
{
    public static testMethod void testPromotionExt()
    {
    test.startTest();
    PromotionExt    promoExt=new PromotionExt(); 
    Promotion__c promo = TestData.createPromotion();
    List<Promotion_Line_Item__c> promoLI = TestData.createPromotionLineItems(promo,5);
    PromotionExt.LineItemBeforeDelete(promoLI);
    Id[] ids = new Id[]{};
    for( Promotion_Line_Item__c lineitem : promoLI ) 
    {    
              ids.add(lineitem.Id);           
    }
    List<Promotion_Line_Item__c> pLI = [Select Promotion__r.Status__c 
                                               From Promotion_Line_Item__c 
                                               Where Id IN : ids];
    PromotionExt.LineItemBeforeDelete(pLI);
    // Page preparation
    PageReference pageRef = Page.NewPromotion;
    Test.setCurrentPage(pageRef);
        
    ApexPages.currentPage().getParameters().put('id', promo.Id);
    PromotionExt controller = new PromotionExt(new ApexPages.StandardController(promo));
    test.stopTest();
}

public static testMethod void testPromotionExt1()
    {
    test.startTest();
    
    Promotion__c promo = TestData.createPromotion();
    List<Promotion_Line_Item__c> promoLI = TestData.createPromotionLineItems(promo,5);
    PromotionExt.LineItemBeforeDelete(promoLI);
    promo.Status__c ='Active';
    update promo;
    Id[] ids = new Id[]{};
    for( Promotion_Line_Item__c lineitem : promoLI ) 
    {    
              ids.add(lineitem.Id);           
    }
    List<Promotion_Line_Item__c> pLI = [Select Promotion__r.Status__c 
                                               From Promotion_Line_Item__c 
                                                  Where Id IN : ids];
    try {
            PromotionExt.LineItemBeforeDelete(pLI);
        } catch (Generic.StandardException e) {
            String message = 'Could not delete Promotion Line Item because parent is not in status Pending';
            System.assertEquals(e.getMessage(), message);
        }
    
    // Page preparation
    PageReference pageRef = Page.NewPromotion;
    Test.setCurrentPage(pageRef);
        
    ApexPages.currentPage().getParameters().put('id', promo.Id);
    PromotionExt controller = new PromotionExt(new ApexPages.StandardController(promo));
    test.stopTest();
}
}