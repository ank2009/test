/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlEditOfferItemSubVDLineItem
 */
@isTest
public class CtrlEditOfferItemSubVDLineItemTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        List<ID> services = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false);
        Service__c serv = [SELECT Id, Name FROM Service__c WHERE Id =: services[0]];
        List<Subservice__c> subservices = [SELECT Id, Name FROM Subservice__c WHERE Parent_Service__c =: serv.Id];
        List<Service__c> servicesObj = new List<Service__c>();
        servicesObj.add(serv);
        Offer_Line_Item__c oli = TestData.createOfferLineItems(ot, servicesObj)[0];
        Offer_Item_Subservice__c ois = TestData.createOfferItemSubservices(oli, subservices)[0];
        Offer_Item_Sub_VD_Line_Item__c oisvdLI1 = TestData.createOfferItemSubservices(ois, 1)[0];
        Offer_Item_Sub_VD_Line_Item__c oisvdLI2 = TestData.createOfferItemSubservices(ois, 1)[0];

        // Page preparation
        PageReference pageRef = Page.EditOfferItemSubVDLineItem;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', oisvdLI1.Id);
        
        CtrlEditOfferItemSubVDLineItem controller = new CtrlEditOfferItemSubVDLineItem(new ApexPages.StandardController(oisvdLI1));
        System.assertEquals(controller.error, false);
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + ois.Id, cancelPage);

        // Test correct save
        String correctSave = controller.save().getUrl();
        System.assertEquals('/' + ois.Id, correctSave);

        // Test exception
        delete oisvdLI1;
        System.assertEquals(null, controller.save());

        // Test bad init
        /*ApexPages.currentPage().getParameters().put('id', oisvdLI2.Id);
        ot.Status__c = 'Active';
        update ot;
        controller = new CtrlEditOfferItemSubVDLineItem(new ApexPages.StandardController(oisvdLI2));
        System.assertEquals(controller.error, true);*/
                
        Test.stopTest();
        
    }

}