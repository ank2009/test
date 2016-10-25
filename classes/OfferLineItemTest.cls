/**
 * @author Nicolas Dolet
 * @date 16/01/2012
 * @description Test trigger OfferLineItem
 */
@isTest
public class OfferLineItemTest {

     public static testMethod void testTrigger() {
     
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
        oli1.Applied_To__c = 'User';
        update oli1;
     
     }

}