public class CtrlDeleteRightTemplateServiceAttribute {
	private final Rights_Template_Service_Attribute__c RTSAtt;
    public String name {get; set;}
    public ID retID;

    public CtrlDeleteRightTemplateServiceAttribute(ApexPages.StandardController controller)
    {
        ID RTSaId = System.currentPagereference().getParameters().get('id');
        this.RTSAtt = [SELECT Id, Name, Rights_Template_Service__r.Rights_Template__r.Status__c, Rights_Template_Service__c FROM Rights_Template_Service_Attribute__c WHERE Id = :RTSaId];
        this.name  = this.RTSAtt.Name;
        this.retID = this.RTSAtt.Rights_Template_Service__c;
    }

    public PageReference init()
    {
        if (this.RTSAtt.Rights_Template_Service__r.Rights_Template__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Service Attribute can be deleted only if Rights Template is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                delete this.RTSAtt;
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