public class CtrlNewServiceAttributeTemplate
{
    private final ID servId;
    public Service_Attribute_Template__c srvAttrTpl {get; set;}
    public Boolean error {get; set;}
    
    public CtrlNewServiceAttributeTemplate(ApexPages.StandardController controller)
    {
        String url = System.currentPagereference().getParameters().get('retURL');
        servId = url.substring(1);
        
        error = false;
        
        Service__c serv = [SELECT Name, Status__c FROM Service__c WHERE Id = :servId];
        
        if (serv.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Service Attribute Templates can be created only if Service is under Pending status!'));
        }
    }

    public PageReference init()
    {
        this.srvAttrTpl= new Service_Attribute_Template__c();
        this.srvAttrTpl.Parent__c = this.servId;
        
        return null;
    }
    
    public PageReference Save() 
    {   
        try
        {
        	insert srvAttrTpl;
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0))); 
            return null;
        }
        
        return (Utilities.Redirect(this.srvAttrTpl.Id));
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.servId));
    }
}