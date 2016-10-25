public class CtrlSwitchUPSrvAttrSuspension
{
    public User_Profile_Service_Attribute__c upsa {get; set;}
    public User_Profile_Service__c ups {get; set;}
    public User_Profile__c up {get; set;}
    public Id subscriptionId;
    public Boolean error {get; set;}
    public Boolean isSuspension {get; set;}

    public CtrlSwitchUPSrvAttrSuspension(ApexPages.StandardController controller)
    {
        ID upsaId = System.currentPagereference().getParameters().get('id');
        this.upsa = [SELECT Id, Name, Suspension_Start_Date__c,
                            Suspension_End_Date__c, Suspension_Reason__c,
                            Immediate_unsuspension__c, User_Profile_Service__c,
                            Provisioning_Status__c
                     FROM User_Profile_Service_Attribute__c WHERE Id = :upsaId];
        
        Id upsId = this.upsa.User_Profile_Service__c;
        this.ups = [SELECT Id, Name, Suspension_Start_Date__c,
                           Suspension_End_Date__c, Suspension_Reason__c,
                           Immediate_unsuspension__c, User_Profile__c,
                           Provisioning_Status__c
                    FROM User_Profile_Service__c WHERE Id = :upsId];

        Id upId = this.ups.User_Profile__c;
        this.up = [SELECT Id, Status__c, Provisioning__c, Provisioning__r.Subscription__c
                   FROM User_Profile__c WHERE Id = :upId];
        
        this.error = (this.up.Status__c != 'Activated');
        
        this.upsa.Immediate_unsuspension__c = false;
        
        this.error = false;
        
        if (this.up.Status__c != 'Activated')
        {
            this.error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
             'You cannot suspend or unsuspend a User Profile Service Attribute if the ' +
             'parent User Profile is not under "Activated" status.'));
        }
        else if (this.ups.Provisioning_Status__c != 'Activated')
        {
            this.error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
             'You cannot suspend or unsuspend a User Profile Service Attribute if the ' +
             'parent User Profile Service is not under "Activated" status.'));
        }
        else if (this.upsa.Provisioning_Status__c == 'In Progress' || this.upsa.Provisioning_Status__c == 'Cancelled')
        {
            this.error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
            'You cannot suspend or unsuspend a User Profile Service Attribute under "In Progress" or "Cancelled" status.'));
        }
        
        if (this.up.Provisioning__c == null)
        {
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This user profile service attribute cannot be (un)suspended as parent user profile is not linked with any subscription (empty Provisioning field)!'));
        }
        
        if (this.upsa.Provisioning_Status__c == 'Activated')
            this.isSuspension = true;

        if (this.upsa.Provisioning_Status__c == 'Suspended')
            this.isSuspension = false;
        
        /*if(upsa.Suspension_Start_Date__c != null)
        {
            if(upsa.Suspension_End_Date__c != null)
            {
                if(upsa.Suspension_Start_Date__c.daysBetween(Date.today()) >= 0
                    && upsa.Suspension_End_Date__c.daysBetween(Date.today()) <= 0)
                    this.isSuspension = false;
                else
                    this.isSuspension = true;
            }
            else // start date without end date
                 // --> check if today is before or after start date
            {
                if(upsa.Suspension_Start_Date__c.daysBetween(Date.today()) >= 0)
                    this.isSuspension = false;
                else
                    this.isSuspension = true;
            }
        }
        else // no suspension start date --> not suspended
        {
            this.isSuspension = true;
        }*/

        this.subscriptionId = up.Provisioning__r.Subscription__c;
    }

    public PageReference save() 
    {
        if(!isSuspension && !this.upsa.Immediate_Unsuspension__c && upsa.Suspension_End_Date__c == null)
        {
            this.error = true;
            return null;
        }
        if(isSuspension && upsa.Suspension_End_Date__c < upsa.Suspension_Start_Date__c)
        {
            this.error = true;
            return null;
        }
        if(!isSuspension && upsa.Suspension_End_Date__c < upsa.Suspension_Start_Date__c)
        {
            this.error = true;
            return null;        
        }
        
        if(this.upsa.Immediate_Unsuspension__c)
        {
            this.upsa.Suspension_Start_Date__c = null;
            this.upsa.Suspension_End_Date__c = null;
            this.upsa.Suspension_Reason__c = '';
        }
        
        update upsa;

        return null;
    }

    public PageReference cancel() 
    {
        return (Utilities.Redirect(this.upsa.Id));
    }
    
    public PageReference sendProvisioningMsg()
    {
        if(!this.error)
        {   
            // Suspensions:
            if(isSuspension && upsa.Suspension_Start_Date__c <= Date.today())
            {
                System.debug('## Suspend UP srv attr: ' + this.up.Id);
                ProvisioningMessages.SuspendUsersInSubscription(new Map<Id, List<Id>>{this.subscriptionId => new List<Id>{this.up.Id}}, 'Standard');
            }
            
            // Unsuspensions:
            if(!isSuspension)
            {
                if(this.upsa.Immediate_unsuspension__c || this.upsa.Suspension_End_Date__c < Date.today())
                {
                    if (this.upsa.Immediate_unsuspension__c)
                        this.ups.Suspension_End_Date__c = Date.today().addDays(-1);
                        
                    System.debug('## Unsuspend UP srv attr: ' + this.up.Id);
                    ProvisioningMessages.unsuspendUsersInSubscription(new Map<Id, List<Id>>{this.subscriptionId => new List<Id>{this.up.Id}});
                }
            }
            return (Utilities.Redirect(this.ups.Id));
        }
        else
        {   
            if(!isSuspension && !this.upsa.Immediate_Unsuspension__c && upsa.Suspension_End_Date__c == null)
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'For non-immediate unsuspension, please indicate the suspension end date.'));
            }
            if(isSuspension && upsa.Suspension_End_Date__c < upsa.Suspension_Start_Date__c)
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Suspension End Date must be greater than or equal to Suspension Start Date.'));
            }
            if(!isSuspension && upsa.Suspension_End_Date__c < upsa.Suspension_Start_Date__c)
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'For immediate unsuspenison, please tick the checkbox immediate unsuspension'));
            }
            return null;
                        
        }
    }
}