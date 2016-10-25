public class CtrlNewSubserviceTemplate 
{
    private final ID servId;
    public Subservice_Template__c subsTpl {get; set;}
    public Boolean error {get; set;}
    
    public CtrlNewSubserviceTemplate(ApexPages.StandardController controller) 
    {
        String url = System.currentPagereference().getParameters().get('retURL');
        servId = url.substring(1);
        
        error = false;
        
        Service__c serv = [SELECT Name, Status__c FROM Service__c WHERE Id = :servId];
        
        if (serv.Status__c != 'Pending')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Subservice Templates can be created only if Service is under Pending status!'));
        }
    }

    public PageReference init()
    {
        this.subsTpl = new Subservice_Template__c();
        this.subsTpl.Parent_Service__c = this.servId;
        
        return null;
    }
    
    public PageReference Save() 
    {   
        try
        {
            insert subsTpl;
        }
        catch (DMLException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(0))); 
            return null;
        }
        
        return (Utilities.Redirect(this.subsTpl.Id));
    }
    
    public PageReference Cancel() 
    {
        return (Utilities.Redirect(this.servId));
    }
}