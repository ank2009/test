public class CtrlDeleteServiceAttributeTemplate 
{
    private final Service_Attribute_Template__c sat;
    public String name {get; set;}
    public ID retID;
    
    public CtrlDeleteServiceAttributeTemplate(ApexPages.StandardController controller) 
    {
        ID satID   = System.currentPagereference().getParameters().get('id');
        this.sat   = [SELECT Id, Name, Parent__r.Status__c, Parent__c FROM Service_Attribute_Template__c WHERE Id = :satID];
        this.name  = this.sat.Name;
        this.retID = this.sat.Parent__c;
    }

    public PageReference init()
    {
        if (this.sat.Parent__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Service Attribute Templates can be deleted only if Service is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                delete this.sat;
                return (Utilities.Redirect(retID));
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Error during deletion: ' + e.getMessage()));
                return null;
            }
        }
    }
    
    public PageReference Cancel()
    {
        return (Utilities.Redirect(retID));
    }
}