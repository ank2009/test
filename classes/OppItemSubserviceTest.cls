/**
 * @author Nicolas Dolet
 * @date 17/01/2012
 * @description Test trigger OppItemSubservice
 */
@isTest
public class OppItemSubserviceTest {

    public static testMethod void testTrigger() {
    
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
        ois.Min_Price__c = 0;
        ois.Max_Price__c = 100;
        update ois;
        
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        List<Opportunity_Line_Item__c> oppLI = TestData.createTestOpportunityWithLI(acc.Id, 1);
        Opp_Item_Subservice__c oppItemSubservice = TestData.createOppItemSubservice(oppLI[0]);
        oppItemSubservice.Offer_Item_Subservice__c = ois.Id;
        
        oppItemSubservice.Sales_Price__c = 50;
        oppItemSubservice.Estimated_Quantity__c = 10;
        update oppItemSubservice;
    
    }
}