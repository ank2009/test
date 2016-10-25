@isTest
private class TLR_RightTemplateDefaultTriggerTest {

    static testMethod void RTdefualtTriggersTest() { 
        // TO DO: implement unit test
        List<ID> services    = TestData.createTestServices(2);
        Product__c prod      = TestData.createTestProductAndLineItems(services, false, true);
        Product__c addOn     = TestData.createTestProductAndLineItems(services, true, false);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false); 
        Rights_Template_Default__c rtDef = TestData.createRightsTemplateDefault(ot,true); 
                          ot = TestData.createOfferTemplate(prod, true);  
    }
}