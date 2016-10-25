@isTest
public class VolumeDiscountBracketTest
{
    public static testMethod void testTrigger() 
    {
        Volume_Discount__c vd = TestData.createVolumeDiscountWithBrackets(2, false); 
        
        List<Volume_Discount_Bracket__c> vdbs = [SELECT Id FROM Volume_Discount_Bracket__c WHERE Volume_Discount__c = :vd.Id];
        
        delete vdbs[0];
    }
}