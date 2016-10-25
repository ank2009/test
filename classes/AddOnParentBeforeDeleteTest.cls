@isTest
public class AddOnParentBeforeDeleteTest
{
    public static testMethod void testTrigger() 
    {
        List<ID> services    = TestData.createTestServices(2);
        Product__c prod      = TestData.createTestProductAndLineItems(services, false, true);
        Product__c addOn     = TestData.createTestProductAndLineItems(services, true, false);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, true); 
        
        Add_on_Parent__c addOnParent = TestData.createTestAddOnParent(addOn.Id, prod.Id);
        
        addOn.Status__c = 'Pending Activation Approval';
        update addOn;
        addOn.Status__c = 'Active';
        update addOn;
        
        try {
        
        delete addOnParent;
        } catch (Exception ex)
        {
        
        }
        
        //System.AssertEquals(1, [SELECT Count() FROM Add_on_Parent__c WHERE Id = :addOnParent.Id]);
    }
}