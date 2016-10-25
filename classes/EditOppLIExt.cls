public class EditOppLIExt 
{    
    public EditOppLIExt(ApexPages.StandardSetController controller) 
    {
        ID idOpp = System.currentPagereference().getParameters().get('id');
        List<Opportunity_Promo_Line_Item__c> oppplis = [SELECT Id, Name, Min_Duration__c, Max_Duration__c, Duration_Value__c, Duration_Type__c, Min_Discount_Percentage__c, Max_Discount_Percentage__c, Discount_Percentage__c, Min_Price__c, Max_Price__c, Sales_Price__c, Min_Discount__c, Max_Discount__c, Discount__c FROM Opportunity_Promo_Line_Item__c WHERE Opp_Promotion__r.Opportunity__c = :idOpp];
        controller.setSelected(oppplis);
    }
}