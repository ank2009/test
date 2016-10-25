public class CtrlDeleteRightTemplateService {
	private final Rights_Template_Service__c RTServ;
    public String name {get; set;}
    public ID retID;

    public CtrlDeleteRightTemplateService(ApexPages.StandardController controller)
    {
        ID RtsId = System.currentPagereference().getParameters().get('id');
        this.RTServ = [SELECT Id, Name, Rights_Template__r.Status__c, Rights_Template__c FROM Rights_Template_Service__c WHERE Id = :RtsId];
        this.name  = this.RTServ.Name;
        this.retID = this.RTServ.Rights_Template__c;
    }

    public PageReference init()
    {
        if (this.RTServ.Rights_Template__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Rights Template Service can be deleted only if Rights Template is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                delete this.RTServ;
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