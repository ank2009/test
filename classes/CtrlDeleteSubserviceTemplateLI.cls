public class CtrlDeleteSubserviceTemplateLI 
{
	private final Subservice_Template_Line_Item__c subtli;
    public String name {get; set;}
    public ID retID;
    
    public CtrlDeleteSubserviceTemplateLI(ApexPages.StandardController controller) 
    {
        ID subtliID  = System.currentPagereference().getParameters().get('id');
        this.subtli  = [SELECT Id, Subservice__r.Name, Subservice__c,
                        Template__r.Parent_Service__r.Status__c, 
                        Template__r.Parent_Service__c, Template__c 
                        FROM Subservice_Template_Line_Item__c WHERE Id = :subtliID];
        this.name    = this.subtli.Subservice__r.Name;
        this.retID   = this.subtli.Template__c;
    }

    public PageReference init()
    {
        if (this.subtli.Template__r.Parent_Service__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Subservices can be unlinked only if Service is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                System.Debug('## Deletion in progress');
                
                List<Subservice_Template_Line_Item__c> lstSubTLI = [SELECT Id FROM Subservice_Template_Line_Item__c 
                               WHERE Template__r.Parent_Service__c = :this.subtli.Template__r.Parent_Service__c 
                               AND Subservice__c = :this.subtli.Subservice__c
                               AND Id != :this.subtli.Id];
                
                System.Debug('## List SubTLI:' + lstSubTLI);
                
                if (lstSubTLI.size() == 0)
                {
                    Subservice__c subserv = [SELECT Parent_Service__c FROM Subservice__c WHERE Id = :this.subtli.Subservice__c];
                    subserv.Parent_Service__c = null;
                    
                    System.Debug('## update subserv:' + subserv);
                    
                    update subserv;
                }
                               
                delete this.subtli;
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