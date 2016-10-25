/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlEditOfferLineItem
 */
@isTest
public class CtrlEditOfferLineItemTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        List<ID> services = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false);
        Service__c serv = [SELECT Id, Name FROM Service__c WHERE Id =: services[0]];
        List<Subservice__c> subservices = [SELECT Id, Name FROM Subservice__c WHERE Parent_Service__c =: serv.Id];
        List<Service__c> servicesObj = new List<Service__c>();
        servicesObj.add(serv);
        Offer_Line_Item__c oli1 = TestData.createOfferLineItems(ot, servicesObj)[0];
        Offer_Line_Item__c oli2 = TestData.createOfferLineItems(ot, servicesObj)[0];

        // Page preparation
        PageReference pageRef = Page.EditOfferLineItem;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', oli1.Id);
        
        CtrlEditOfferLineItem controller = new CtrlEditOfferLineItem(new ApexPages.StandardController(oli1));
        System.assertEquals(controller.error, false);

        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + ot.Id, cancelPage);

        // Test correct save
        String correctSave = controller.save().getUrl();
        System.assertEquals('/' + ot.Id, correctSave);

        // Test exception
        delete oli1;
        System.assertEquals(null, controller.save());

        // Test bad init
        /*ApexPages.currentPage().getParameters().put('id', oli2.Id);
        ot.Status__c = 'Active';
        update ot;
        controller = new CtrlEditOfferLineItem(new ApexPages.StandardController(oli2));
        System.assertEquals(controller.error, true);
             */   
        Test.stopTest();
        
    }

}