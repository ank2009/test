@isTest
public class PackageAndFeeLineItemTest
{
    public static testMethod void testTrigger() 
    {
        List<ID> services = TestData.createTestServices(2);
        PackFee__c pf = TestData.createPackageAndFeeWithLineItems(services, false);
        
        List<Package_and_Fee_Line_Item__c> pflis = [SELECT Id FROM Package_and_Fee_Line_Item__c WHERE Parent__c = :pf.Id];
        
        delete pflis[0];
    }
}