@isTest
public class TR004ProductLITest
{
    public static testMethod void testTR004ProductLI()
    {
     // Data creation
     
     test.startTest();
     List<ID> services = TestData.createTestServices(10);
     Product__c  product= TestData.createTestProductAndLineItems(services,true, false);
     LIST<Product_Line_Item__c> PLI = [SELECT Id, Name, Parent__c,Service__c
                                       FROM Product_Line_Item__c 
                                       WHERE Parent__c =: product.Id ];
     TR004ProductLI.UnlinkServicefromProduct(PLI);
     }
}