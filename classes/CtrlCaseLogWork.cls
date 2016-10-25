public class CtrlCaseLogWork 
{
    private Case currCase {get; set;}
    public Boolean error {get; set;}    
    public Case_Timelog__c log {get; set;}
	public CtrlCaseLogWork(ApexPages.StandardSetController  controller)
    {
        currCase = [select Id, Work_Start_Time__c from Case where Id =: ApexPages.currentPage().getParameters().get('Id')];       
    }
    
    public PageReference init()
    {
        if(currCase.Work_Start_Time__c == null)
        {
            try
            {
                currCase.Work_Start_Time__c = datetime.now();
                update currCase;
                return Utilities.Redirect(currCase.Id); 
            }
            catch(Exception e)
            {
                error = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occured during setting of work start time'));
            }            
        }
        
        log = new Case_Timelog__c();
        log.Case__c = currCase.Id;
        log.Start_Time__c = currCase.Work_Start_Time__c;
        return null;
    }
    
    public PageReference Save()
    {
        Savepoint sp = Database.setSavepoint();
        try
        {
            log.Intervention_minutes__c = (DateTime.now().getTime() - currCase.Work_Start_Time__c.getTime())/60000; 
            if(log.Intervention_minutes__c > 480)
                log.Intervention_minutes__c = 480;
            insert log;        
            currCase.Work_Start_Time__c = null;
            update currCase;
            return Utilities.Redirect(currCase.Id);
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occured during creation of Time Log'));
            return null;
        }                 
    }
    
    public PageReference Cancel()
    {
        return Utilities.Redirect(currCase.Id);
    }

}