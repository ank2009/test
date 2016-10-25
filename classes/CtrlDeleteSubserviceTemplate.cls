public class CtrlDeleteSubserviceTemplate 
{
	private final Subservice_Template__c subst;
    public String name {get; set;}
    public ID retID;
    
    public CtrlDeleteSubserviceTemplate(ApexPages.StandardController controller) 
    {
        ID substID = System.currentPagereference().getParameters().get('id');
        this.subst = [SELECT Id, Name, Parent_Service__r.Status__c, Parent_Service__c FROM Subservice_Template__c WHERE Id = :substID];
        this.name  = this.subst.Name;
        this.retID = this.subst.Parent_Service__c;
    }

    public PageReference init()
    {
        if (this.subst.Parent_Service__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Subservice Templates can be deleted only if Service is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                delete this.subst;
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