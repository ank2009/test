public class CtrlDeleteAddOn 
{
    private final Add_on_Parent__c aop;
    public String name {get; set;}
    public ID prodId;
    
    public CtrlDeleteAddOn(ApexPages.StandardController controller) 
    {
        ID aopID  = System.currentPagereference().getParameters().get('id');
        prodID    = System.currentPagereference().getParameters().get('retURL').substring(1);
        
        this.aop  = [SELECT Id, Name, Product__c, Add_on__r.Status__c FROM Add_on_Parent__c WHERE Id = :aopID];
        this.name = this.aop.Name;
    }
    
    public PageReference init()
    {
    	System.Debug('## this.aop.Add_on__c:' + this.aop.Add_on__c);
    	System.Debug('## this.aop.Product__c:' + this.aop.Product__c);
    	System.Debug('## prodID:' + prodID);
    	
        if (this.aop.Product__c == prodID)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Add-ons cannot be unlinked from here. They must be unlinked from their own view!'));
            return null;
        }
        else if (this.aop.Add_on__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Parents can be deleted only if Add-On is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                delete this.aop;
                return (Utilities.Redirect(prodID));
            }
            catch (DMLException e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDMLMessage(0)));
                return null;
            }
        }
    }
    
    public PageReference Cancel()
    {
        return (Utilities.Redirect(prodID));
    }
}