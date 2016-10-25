public class CreateSubserviceExt 
{
    private final Subservice_Template__c subtemp;
    public Subservice__c sub;
    
    public CreateSubserviceExt(ApexPages.StandardController controller) 
    {
        this.subtemp = (Subservice_Template__c)controller.getRecord();
    }
    
    public PageReference init()
    {
        this.sub = new Subservice__c();
        sub.OwnerId = UserInfo.getUserId();
        sub.Parent_Service__c = [SELECT Parent_Service__c FROM Subservice_Template__c WHERE Id = :this.subtemp.Id].Parent_Service__c;
        
        return null;
    }
    
    public Subservice__c getSub()
    {
        return sub;
    }
    
    public PageReference Save() 
    {   
        createRecord();
        
        return (Utilities.Redirect(this.subtemp.Id));
    }
    
    public PageReference SaveAndNew() 
    {   
        createRecord();
        
         return (Utilities.Redirect('apex/CreateSubservice?id=' + this.subtemp.Id));
    }
    
    public PageReference Cancel() 
    {
         return (Utilities.Redirect(this.subtemp.Id));
    }
    
    public void createRecord()
    {
    	if (sub.status__c != 'Active' && sub.Start_Date__c > Date.today())
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Start Date must be in the future and End Date must be higher than Start Date'));
       	else       
        	insert sub;
    	
    	
    	
    	
        Subservice_Template_Line_Item__c link = new Subservice_Template_Line_Item__c();
        link.Subservice__c = sub.Id;
        link.Template__c = this.subtemp.Id;
        insert link;
    }
}