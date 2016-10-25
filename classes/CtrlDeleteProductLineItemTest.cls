/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlDeleteProductLineItem
 */
@isTest
public class CtrlDeleteProductLineItemTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        List<ID> services = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(services, false, false);
        Product_Line_Item__c pli = [SELECT Id FROM Product_Line_Item__c WHERE Parent__c =: prod.Id];
        
        // Page preparation
        PageReference pageRef = Page.DeleteProductLineItem;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', pli.Id);
        ApexPages.currentPage().getParameters().put('retID', prod.Id);
        
        CtrlDeleteProductLineItem controller = new CtrlDeleteProductLineItem(new ApexPages.StandardController(pli));
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + prod.Id, cancelPage);

        // Test correct init
        String correctDelete = controller.init().getUrl();
        System.assertEquals('/' + prod.Id, correctDelete);

        // Test exception
        Product__c prod2 = TestData.createTestProductAndLineItems(services, false, false);
        Product_Line_Item__c pli2 = [SELECT Id FROM Product_Line_Item__c WHERE Parent__c =: prod2.Id];
        ApexPages.currentPage().getParameters().put('id', pli2.Id);
        ApexPages.currentPage().getParameters().put('retID', prod2.Id);
        controller = new CtrlDeleteProductLineItem(new ApexPages.StandardController(pli2));
        delete pli2;
        System.assertEquals(null, controller.init());

        // Test bad init
        Product__c prod3 = TestData.createTestProductAndLineItems(services, false, true);
        Product_Line_Item__c pli3 = [SELECT Id FROM Product_Line_Item__c WHERE Parent__c =: prod3.Id];
        ApexPages.currentPage().getParameters().put('id', pli3.Id);
        controller = new CtrlDeleteProductLineItem(new ApexPages.StandardController(pli3));
        System.assertEquals(null, controller.init());
                
        Test.stopTest();
                
    }

}