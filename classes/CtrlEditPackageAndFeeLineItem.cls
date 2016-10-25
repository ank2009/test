public class CtrlEditPackageAndFeeLineItem
{
    public Boolean error {get; set;}
    public Package_and_Fee_Line_Item__c pfLI {get; set;}
    
    public CtrlEditPackageAndFeeLineItem(ApexPages.StandardController controller) 
    {
        error = false;
        ID pfLIid = System.currentPagereference().getParameters().get('id');
        this.pfLI = [SELECT Name, Parent__c, Parent__r.Status__c, Service__c, PackFee__c, Weight__c FROM Package_and_Fee_Line_Item__c WHERE Id =:pfLIid];
        
        if (this.pfLI.Parent__r.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Package and Fee status must be Pending to edit line items!'));
        }
    }
    
    public PageReference Save() 
    {
        try 
        {
            update pfLI;        
            return (Utilities.Redirect(this.pfLI.Parent__c));
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0))); 
            return null;
        }
    }

    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.pfLI.Parent__c));
    }
}