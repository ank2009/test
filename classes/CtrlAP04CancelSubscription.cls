/*
 .d8888b.                         888                                                                                  888 
d88P  Y88b                        888                                                                                  888 
888    888                        888                                                                                  888 
888         8888b.  88888b.       88888b.   .d88b.       888d888 .d88b.  88888b.d88b.   .d88b.  888  888  .d88b.   .d88888 
888            "88b 888 "88b      888 "88b d8P  Y8b      888P"  d8P  Y8b 888 "888 "88b d88""88b 888  888 d8P  Y8b d88" 888 
888    888 .d888888 888  888      888  888 88888888      888    88888888 888  888  888 888  888 Y88  88P 88888888 888  888 
Y88b  d88P 888  888 888  888      888 d88P Y8b.          888    Y8b.     888  888  888 Y88..88P  Y8bd8P  Y8b.     Y88b 888 
 "Y8888P"  "Y888888 888  888      88888P"   "Y8888       888     "Y8888  888  888  888  "Y88P"    Y88P    "Y8888   "Y88888 

moved to TLR_SubscriptionExt class
*/
public with sharing class CtrlAP04CancelSubscription 
{
    public Subscription__c sub   {get; set;}
    public Boolean         error {get; set;}
    
    public CtrlAP04CancelSubscription(ApexPages.StandardController controller) 
    {
        ID subId = System.currentPagereference().getParameters().get('id');
        this.sub = [SELECT Id, Start_Date__c, End_Date__c, Status__c FROM Subscription__c WHERE Id = :subId];
    }

    public PageReference init()
    {
        error = false;
        
        List<Provisioning__c> prov = [SELECT Id FROM Provisioning__c WHERE Subscription__c = :this.sub.Id];
        
        if (prov.size() == 0)
        {
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient Privileges!'));
            return null;
        }
        
        this.sub.End_Date__c = Date.Today();
        return null;
    }
    
    public PageReference Save()
    {
        if (this.sub.End_Date__c < this.sub.Start_Date__c)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'End date must be greater or equal to Start date!'));
            return null;
        }
        /*else if (this.sub.End_Date__c < Date.Today())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'End Date has to be in Future.'));
            return null;
        }*/
        else
        {
            // Call Provisioning module
            if (!Test.isRunningTest())
                ProvisioningMessages.CancelSubscription(this.sub.Id, this.sub.End_Date__c);
            
            this.sub.Status__c = 'On Notice';
            update this.sub;
        }
        
        return (Utilities.Redirect(this.sub.Id));
    }
    
    public PageReference Cancel()
    {
        return (Utilities.Redirect(this.sub.Id));
    }
}