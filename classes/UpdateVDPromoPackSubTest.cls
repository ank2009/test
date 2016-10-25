@isTest
public class UpdateVDPromoPackSubTest 
{
    public static testMethod void testTrigger() 
    {
        Volume_Discount__c vd = TestData.createVolumeDiscountWithBrackets(2, true);
    
        List<ID> services    = TestData.createTestServices(2);
        Product__c prod      = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false); 
        
        List<Offer_Line_Item__c> olis = TestData.createTestOfferTemplateHierarchy(ot.Id, services);
        
        List<Offer_Item_Subservice__c> oisubs = [SELECt Id FROM Offer_Item_Subservice__c WHERE Offer_Line_Item__c IN :olis];
        
        TestData.createOfferItemSubVDLI(oisubs[0], vd.Id);
    }
}