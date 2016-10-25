public class CtrlDeleteServiceAttributeTemplateLI 
{
    private final Service_Attribute_Template_Line_Item__c satli;
    public String name {get; set;}
    public ID retID;
    
    public CtrlDeleteServiceAttributeTemplateLI(ApexPages.StandardController controller) 
    {
        ID satliID   = System.currentPagereference().getParameters().get('id');
        this.satli   = [SELECT Id, Service_Attribute__r.Name, Service_Attribute__c,
                        Service_Attribute_Template__r.Parent__r.Status__c, 
                        Service_Attribute_Template__r.Parent__c, Service_Attribute_Template__c 
                        FROM Service_Attribute_Template_Line_Item__c WHERE Id = :satliID];
        this.name    = this.satli.Service_Attribute__r.Name;
        this.retID   = this.satli.Service_Attribute_Template__c;
    }

    public PageReference init()
    {
        if (this.satli.Service_Attribute_Template__r.Parent__r.Status__c != 'Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Service Attributes can be unlinked only if Service is under Pending status.'));
            return null;
        }
        else
        {
            try
            {
                System.Debug('## Deletion in progress');
                
                List<Service_Attribute_Template_Line_Item__c> lstSATLI = [SELECT Id FROM Service_Attribute_Template_Line_Item__c 
                               WHERE Service_Attribute_Template__r.Parent__c = :this.satli.Service_Attribute_Template__r.Parent__c 
                               AND Service_Attribute__c = :this.satli.Service_Attribute__c
                               AND Id != :this.satli.Id];
                
                System.Debug('## List SATLI:' + lstSATLI);
                
                if (lstSATLI.size() == 0)
                {
                    Service_Attribute__c servAttr = [SELECT Parent__c FROM Service_Attribute__c WHERE Id = :this.satli.Service_Attribute__c];
                    servAttr.Parent__c = null;
                    
                    System.Debug('## update servAttr:' + servAttr);
                    
                    update servAttr;
                }
                               
                delete this.satli;
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