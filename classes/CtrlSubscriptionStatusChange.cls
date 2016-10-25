/**
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         2015 October 21
* @description  Controller for SubscriptionStatusChange page
**/
public class CtrlSubscriptionStatusChange 
{
    public string choosenStatus { get; set; }
    
    public string strSubsId { get; set; }
    
    public string isVisible { get; set; }
    
    public string subsName { get; set; }
    
    public string subsAccName { get; set; }
    
    public string subsAccNumber { get; set; }
    
    private Subscription__c subs;
    
    public Id subsid { get; set; }
    
    List<String> statuses; 
    public CtrlSubscriptionStatusChange()
    {
        statuses=Utilities.getPicklistValues('Subscription__c','Status__c');
    	isVisible='hidden';
    }
   
    public List<SelectOption> getOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        for(String s : statuses)
        {
            options.add(new SelectOption(s,s));
        }
        return options;
    }

    public void selectSubs()
    {
        subsid=null;
        try
        {
            subsId=strSubsId;
        }
        catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,'Invalid Id');
            ApexPages.addMessage(msg);
        }
        if(subsId!=null)
        {
            try
            {
                subs = [Select Id,Status__c,Name,Account__r.Name, Account__r.AccountNumber From Subscription__c Where Id =: subsId];
                subsName = subs.Name;
                subsAccName = subs.Account__r.Name;
                subsAccNumber = subs.Account__r.AccountNumber;
                choosenStatus = subs.Status__c;
                isVisible = 'visible';
            }
            catch (Exception e)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,'Subscription not found');
                ApexPages.addMessage(msg);
            }
        }
    }
    
    public void save()
    {
        
        if(subs != null)
        {
            User user = [Select id, Name, Disable_Validation_Rules_and_Workflows__c, Disable_All_Triggers__c From User Where id =: UserInfo.getUserId()];
            user.Disable_All_Triggers__c = false;
            user.Disable_Validation_Rules_and_Workflows__c = true;
            update user;
            
            subs.Status__c = choosenStatus;
            
            update subs;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,'Status has been changed successfully');
            ApexPages.addMessage(msg);
            
            user.Disable_Validation_Rules_and_Workflows__c = false;
            update user;
            
        }
    }
}