public class TLR_CtrlDeleteRTSADefault {
	private final Rights_Template_Service_Attribute_Def__c RTSAtt;
	private final Rights_Template_Service_Default__c RTSDtt;
    public String name {get; set;}
    public ID retID;

    public TLR_CtrlDeleteRTSADefault(ApexPages.StandardController controller)
    {
        ID RTSaId = System.currentPagereference().getParameters().get('id');
        
		this.RTSAtt = [Select Id, Name,Rights_Template_Service__c,Rights_Template_Service__r.Id From Rights_Template_Service_Attribute_Def__c where id =:RTSaId];
		
		RTSDtt = [Select Rights_Template__r.Status__c, Id From Rights_Template_Service_Default__c where id =: this.RTSAtt.Rights_Template_Service__c];
		
		this.name  = this.RTSAtt.Name;
        this.retID = this.RTSAtt.Rights_Template_Service__c;
    }

    public PageReference init()
    {
        if (RTSDtt.Rights_Template__r.Status__c != 'Pending')
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