public class CtrlEditPromotionLineItem 
{
    public Boolean error {get; set;}
    public Promotion_Line_Item__c pLI {get; set;}
    
    public CtrlEditPromotionLineItem(ApexPages.StandardController controller) 
    {
        error = false;
        ID pLI = System.currentPagereference().getParameters().get('id');
        this.pLI = [SELECT Name, Promotion__c, Promotion__r.Status__c, Sort_Order__c, Duration_Type__c, Min_Duration__c, Max_Duration__c FROM Promotion_Line_Item__c WHERE Id =:pLI];
        
        if (this.pLI.Promotion__r.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Promotion status must be Pending to edit line items!'));
        }
    }
    
    public PageReference Save() 
    {
        try 
        {
            update pLI;        
            return (Utilities.Redirect(this.pLI.Promotion__c));
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0))); 
            return null;
        }
    }

    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.pLI.Promotion__c));
    }
}