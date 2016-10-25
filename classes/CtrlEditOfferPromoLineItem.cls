public class CtrlEditOfferPromoLineItem
{
    public Boolean error {get; set;}
    public Offer_Promo_Line_Item__c opLI {get; set;}
    
    public CtrlEditOfferPromoLineItem(ApexPages.StandardController controller) 
    {
        error = false;
        ID opLIid = System.currentPagereference().getParameters().get('id');
        this.opLI = [SELECT Name, Max_Discount__c, Max_Discount_Percentage__c, 
                            Max_Duration__c, Max_Price__c, Min_Discount__c, 
                            Min_Discount_Percentage__c, Min_Duration__c, Min_Price__c,
                            Offer_Promotion__c, Promotion_Line_Item__c,
                            Offer_Promotion__r.Offer_Template__r.Status__c
                     FROM Offer_Promo_Line_Item__c WHERE Id =:opLIid];
        
        if (this.opLI.Offer_Promotion__r.Offer_Template__r.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Offer Template should be in status Pending to modify this Line Item!'));
        }
    }
    
    public PageReference Save() 
    {
        try 
        {
            update opLI;        
            return (Utilities.Redirect(this.opLI.Offer_Promotion__c));
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0))); 
            return null;
        }
    }

    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.opLI.Offer_Promotion__c));
    }
}