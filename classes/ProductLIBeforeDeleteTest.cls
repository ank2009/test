/**
 * @author Nicolas Dolet
 * @date 16/01/2012
 * @description Test trigger ProductLIBeforeDelete
 */
@isTest
public class ProductLIBeforeDeleteTest {

    public static testMethod void testTrigger() {

        List<ID> services = TestData.createTestServices(1);        
        Product__c product = TestData.createTestProductAndLineItems(services, false, true);
        Product_Line_Item__c prodLI = [SELECT Id FROM Product_Line_Item__c WHERE Parent__c =: product.Id];
        delete prodLI;
        
    }

}