public class CtrlAP02Reprovision 
{
    private final Provisioning__c prov;
    
    public CtrlAP02Reprovision(ApexPages.StandardController controller) 
    {
        this.prov = [SELECT Id, Provisioning_Status__c, LastTransaction__c, Subscription__c, Subscription__r.End_Date__c FROM Provisioning__c WHERE Id = :controller.getRecord().Id];
    }
    
    public PageReference init()
    {
        System.Debug('## Init Reprovision');
        
        if (!Test.isRunningTest())
        {
            System.Debug('## Not Test');
            
            if (System.currentPagereference().getParameters().get('source') == 'TGO')
            {
                System.Debug('## Reprovisioning TGO');
                
                List<User_Profile__c> userProfiles = [SELECT Id FROM User_Profile__c WHERE Provisioning__c = :this.prov.Id];
                
                List<Id> userProfileIds = new List<Id>();
                for (User_Profile__c up : userProfiles)
                    userProfileIds.add(up.Id);
                
                System.Debug('## User profile ids: ' + userProfileIds);
                            
                if (userProfileIds.size() > 0)
                    ProvisioningMessages.SendReProvisioning(userProfileIds);
            }
            else if (System.currentPagereference().getParameters().get('source').startsWith(Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().getKeyPrefix()))
            {
                System.Debug('## Reprovisioning UP');
                
                ID upId = System.currentPagereference().getParameters().get('source');
                
                List<User_Profile__c> userProfiles = [SELECT Id FROM User_Profile__c WHERE Id = :upId];
                
                List<Id> userProfileIds = new List<Id>();
                for (User_Profile__c up : userProfiles)
                    userProfileIds.add(up.Id);
                
                System.Debug('## User profile ids: ' + userProfileIds);
                            
                if (userProfileIds.size() > 0)
                    ProvisioningMessages.SendReProvisioning(userProfileIds);
            }
            if (System.currentPagereference().getParameters().get('source') == 'CANCEL')
            {
                System.Debug('## Subscription Cancellation: ' + this.prov.Subscription__c + ' on ' + this.prov.Subscription__r.End_Date__c);
                
                ProvisioningMessages.CancelSubscription(this.prov.Subscription__c, this.prov.Subscription__r.End_Date__c);
            }
            else
            {
                System.Debug('## Standard Reprovisioning');
                
                // Goal = Send same provisioning request as the last sent one
                List<Provisioning__History> history = [SELECT Id, CreatedDate, NewValue 
                                                       FROM Provisioning__History
                                                       WHERE ParentId = :this.prov.Id
                                                       AND Field = 'Provisioning_Status__c'
                                                       ORDER BY CreatedDate DESC LIMIT 1];
                
                // Message is resent only is previous one was failed or is still in progress (>= 15 min)
                if (this.prov.Provisioning_Status__c == 'Failed' || 
                    (this.prov.Provisioning_Status__c == 'In Progress' &&
                     history.size() > 0 &&
                     history[0].NewValue == 'In Progress' &&
                     history[0].CreatedDate.addMinutes(15) <= DateTime.now()))
                {
                    System.Debug('## Processing validated: ' + this.prov.Provisioning_Status__c + ' - ' + history);
                    
                    // Retrieve last provisioning transaction and process to identify request to send
                    System.Debug('## Transaction to resend: ' + this.prov.LastTransaction__c);
                    
                    if (this.prov.LastTransaction__c != null)
                    {
                        List<String> tokens = this.prov.LastTransaction__c.split(';');
                        
                        // Resend transaction according to transaction type
                        if (tokens.size() > 0)
                        {
                            if (tokens[0] == 'Provisioning')
                            {
                                List<ID> userIds = new List<ID>();
                                for (Integer i = 1; i < tokens.size(); i++)
                                    userIds.add(tokens[i]);
                                    
                                if (userIds.size() > 0)
                                {
                                    ProvisioningMessages.SendInitialProvisioningRequests(userIds);
                                    System.Debug('## Users provisioned: ' + userIds);
                                }
                                else
                                    System.Debug('## No one to provision');
                            }
                            else if (tokens[0] == 'Update')
                            {
                                List<ID> userIds = new List<ID>();
                                for (Integer i = 1; i < tokens.size(); i++)
                                    userIds.add(tokens[i]);
                                    
                                if (userIds.size() > 0)
                                {
                                    ProvisioningMessages.SendReProvisioning(userIds);
                                    System.Debug('## Users updated: ' + userIds);
                                }
                                else
                                    System.Debug('## No one to update');
                            }
                            else if (tokens[0] == 'Cancellation')
                            {
                                if (tokens.size() == 3)
                                {
                                    ID subId        = tokens[1];
                                    Date cancelDate = Date.valueOf(tokens[2]);
                                        
                                    ProvisioningMessages.CancelSubscription(subId, cancelDate);
                                    System.Debug('## Subscription ' + subId + ' cancelled at date: ' + cancelDate);
                                }
                                else
                                    System.Debug('## Error in data');
                            }
                            else if (tokens[0] == 'Suspension')
                            {
                                if (tokens.size() > 2)
                                {
                                    ID subId = tokens[1];
                                    List<ID> userIds = new List<ID>();
                                    for (Integer i = 2; i < tokens.size(); i++)
                                        userIds.add(tokens[i]);
                                        
                                    ProvisioningMessages.SuspendUsersInSubscription(new Map<ID, List<ID>>{subId => userIds}, 'SuspendAll');
                                    System.Debug('## Users suspended: ' + userIds);
                                }
                                else
                                    System.Debug('## No one to suspend');
                            }
                            else if (tokens[0] == 'ServSusp')
                            {
                                if (tokens.size() > 2)
                                {
                                    ID subId = tokens[1];
                                    List<ID> userIds = new List<ID>();
                                    for (Integer i = 2; i < tokens.size(); i++)
                                        userIds.add(tokens[i]);
                                        
                                    ProvisioningMessages.SuspendUsersInSubscription(new Map<ID, List<ID>>{subId => userIds}, 'Standard');
                                    System.Debug('## Users with service (attributes) suspended: ' + userIds);
                                }
                                else
                                    System.Debug('## No one with service (attributes) to suspend');
                            }
                            else if (tokens[0] == 'Unsuspension')
                            {
                                if (tokens.size() > 2)
                                {
                                    ID subId = tokens[1];
                                    List<ID> userIds = new List<ID>();
                                    for (Integer i = 2; i < tokens.size(); i++)
                                        userIds.add(tokens[i]);
                                        
                                    ProvisioningMessages.UnsuspendUsersInSubscription(new Map<ID, List<ID>>{subId => userIds});
                                    System.Debug('## Users unsuspended: ' + userIds);
                                }
                                else
                                    System.Debug('## No one to unsuspend');
                            }
                            else
                                System.Debug('## Unknown transaction type');
                        }  
                        else
                            System.Debug('## Last transaction not found');
                    }
                    else
                        System.Debug('## Last transaction not found');
                }
                else
                    System.Debug('## Processing not validated: ' + this.prov.Provisioning_Status__c + ' - ' + history);
            }
        }
        
        System.Debug('## End Reprovision');
        
        return (Utilities.Redirect(this.prov.Id));
    }
}