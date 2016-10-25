public with sharing class CtrlSwitchUPSuspension
{
    public User_Profile__c up {get; set;}
    private String status;
    public Id subscriptionId;
    public Boolean error {get; set;}
    public Boolean isSuspension {get; set;}
    
    
    public CtrlSwitchUPSuspension(ApexPages.StandardController controller)
    {
        ID upId = System.currentPagereference().getParameters().get('id');
        this.up = [SELECT Id, Name, CurrencyIsoCode, Suspension_Start_Date__c, Suspension_End_Date__c, Suspension_Reason__c, Immediate_unsuspension__c, Provisioning__c, Provisioning__r.Subscription__c FROM User_Profile__c WHERE Id = :upId];
        this.status = [SELECT Status__c FROM User_Profile__c WHERE Id = :upId].Status__c;
        this.error = (this.status != 'Activated' && this.status != 'Suspended');
        this.up.Immediate_unsuspension__c = false;
        if (error)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can only suspend User Profiles under "Activated" status or unsuspend User Profiles under "Suspended" status.'));
        
        if (this.up.Provisioning__c == null)
        {
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This user cannot be (un)suspended as it is not linked with any subscription (empty Provisioning field)!'));
        }
        
        if(this.status == 'Activated')
            this.isSuspension = true;

        if(this.status == 'Suspended')
            this.isSuspension = false;
        
        this.subscriptionId = up.Provisioning__r.Subscription__c;
    }
    
    public PageReference init()
    {
      try 
      {
            String upCur= this.up.CurrencyIsoCode;
            this.up.CurrencyIsoCode=upCur;
            update this.up;
      } catch (System.DmlException e) 
      {
            error = true;
            if(e.getmessage().contains('Insufficient Privileges'))
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient Privileges!'));
            return null;
      }
      return null;
     }
     
    public PageReference save() 
    {
        if(!isSuspension && !this.up.Immediate_unsuspension__c && up.Suspension_End_Date__c == null)
        {
            this.error = true;
            return null;
        }
        
        if(isSuspension && up.Suspension_End_Date__c < up.Suspension_Start_Date__c)
        {
            this.error = true;        
            return null; 
        }
        
        if(!isSuspension && up.Suspension_End_Date__c < up.Suspension_Start_Date__c-1)
        {
            this.error = true;        
            return null; 
        }       
        
        if (this.up.Immediate_Unsuspension__c)
            this.up.Suspension_End_Date__c = Date.Today() - 1;
        
        update up;

        return null;
    }

    public PageReference cancel() 
    {
        return (Utilities.Redirect(this.up.Id));
    }
    
    public PageReference sendProvisioningMsg()
    {
        if(!this.error)
        {
            // Suspensions:
            if(isSuspension && up.Suspension_Start_Date__c <= Date.today())
            {
                    System.debug('## Suspend user: ' + this.up.Id );
                    ProvisioningMessages.SuspendUsersInSubscription(new Map<ID, List<ID>>{this.subscriptionId => new List<Id>{this.up.Id}}, 'SuspendAll');
            }
            
            // Unsuspensions:
            if(!isSuspension)
            {
                if(this.up.Immediate_unsuspension__c || up.Suspension_End_Date__c < Date.today())
                {
                    System.debug('## Unsuspend user: ' + this.up.Id);
                    ProvisioningMessages.UnsuspendUsersInSubscription(new Map<ID, List<ID>>{this.subscriptionId => new List<Id>{this.up.Id}});
                }
            }
            
            if(isSuspension && up.Suspension_Start_Date__c <= Date.today() && up.Suspension_Reason__c !='Bad Payer')
            {
                    List<Subs_Current_Fee__c> SubsCurFees = [SELECT Id, End_Date__c, Subs_Package_And_Fee__r.Type__c
                                                             FROM Subs_Current_Fee__c 
                                                             WHERE  Subs_Package_And_Fee__r.Type__c='Package' 
                                                             AND Subscription__r.Product__r.Name='T-ACTIVE' AND User_Profile__c =: this.up.Id ]; 
                                                
                     for (Subs_Current_Fee__c SubsCurFee : SubsCurFees)
                     {
                         if ( SubsCurFee.End_Date__c == null)
                         {
                             SubsCurFee.End_Date__c = this.up.Suspension_Start_Date__c;
                             System.debug('## Subs Current Fee: ' + SubsCurFee);                        
                             update SubsCurFee;
                         }
                     }
             }
            return (Utilities.Redirect(this.up.Id));
        }
        else
        {   
            if(!isSuspension && !this.up.Immediate_unsuspension__c && up.Suspension_End_Date__c == null)
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'For non-immediate unsuspension, please indicate the suspension end date.'));
            }
            if(isSuspension && up.Suspension_End_Date__c < up.Suspension_Start_Date__c)
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Suspension End Date must be greater than or equal to Suspension Start Date.'));
            }
            if(!isSuspension && up.Suspension_End_Date__c < up.Suspension_Start_Date__c -1)
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'For immediate unsuspenison, please tick the checkbox immediate unsuspension'));
            }
            return null;
        }
    }
}