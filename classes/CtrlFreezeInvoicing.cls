public with sharing class CtrlFreezeInvoicing
{
    public Contract con {get; set;}
    public Boolean FollowupInvoicing {get; set;}
    public Boolean error {get; set;}
    public Boolean FollowupAction {get; set;}
    private Map<ID, List<ID>> mapSubUps;
    
    public CtrlFreezeInvoicing(ApexPages.StandardController controller) 
    {
        this.con = [SELECT Id, AccountId, Invoice_Status__c, 
                            Account.Account_Life_Cycle__c, CurrencyIsoCode
                    FROM Contract WHERE Id=:((Contract)controller.getRecord()).Id];
    }
    
    public PageReference init()
    {
        try {
            String cur= this.con.CurrencyIsoCode;
            this.con.CurrencyIsoCode=cur;
            update this.con;
            } 
        catch (System.DmlException e) {
            error=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient Privileges!'));
            return null;    
            }
            
        if(con.Invoice_Status__c == 'Frozen') 
        {
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invoicing Status must be different from Frozen !'));
         } 
         else if (con.Account.Account_Life_Cycle__c !='Customer at Risk' && con.Account.Account_Life_Cycle__c!='Customer Indelicate' && con.Account.Account_Life_Cycle__c!='Customer on Notice')
         { 
             error=true;
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Only Accounts with an ALC as -Customer at Risk- or -Customer Indelicate- or -Customer on Notice- can be Frozen !'));
          }
        return null;
    }

    public PageReference Freeze()
    {
                  List<User_Profile__c> upToUpdate = new List<User_Profile__c>();
                   
                   if (FollowupInvoicing == true)
                   {
                        // Retrieve contract subscriptions
                        List<Subscription__c> Subs = [SELECT Id, Status__c 
                                                     FROM Subscription__c
                                                     WHERE Status__c = 'Active' 
                                                     AND Contract__c =: this.con.Id];
                                                    
                        Set<Id> SubsTosuspendIds = new Set<Id>();
                        for (Subscription__c sub : Subs)
                            SubsTosuspendIds.add(sub.Id);
    
                        // Retrieve provisionings from subscriptions
                        List<Provisioning__c> ProvsToSuspend = [SELECT Id, Subscription__c 
                                                                FROM Provisioning__c
                                                                WHERE Subscription__c 
                                                                IN :SubsTosuspendIds];
                       
                       Set<Id> ProvToSuspendIds = new Set<Id>();
                       for (Provisioning__c pprov : ProvsToSuspend)
                            ProvToSuspendIds.add(pprov.Id);
    
                        // Retrieve user profiles from provisionings
                       List<User_Profile__c> lstUp = [SELECT Id, Suspension_Start_Date__c, 
                                                             Suspension_End_Date__c, Suspension_Reason__c, Provisioning__r.Subscription__c
                                                      FROM User_Profile__c 
                                                      WHERE Status__c != 'Suspended' 
                                                      AND Provisioning__c 
                                                      IN :ProvToSuspendIds];
                                                      
                       // Matching Subscription / List of user profiles
                       mapSubUps = new Map<ID, List<ID>>();
                       for (User_Profile__c up : lstUp)
                       {
                           if (mapSubUps.get(up.Provisioning__r.Subscription__c) == null)
                               mapSubUps.put(up.Provisioning__r.Subscription__c, new List<ID>());
                               
                           mapSubUps.get(up.Provisioning__r.Subscription__c).add(up.Id);
                       }   
                          
                        for (User_Profile__c userProfile : lstUp)
                        {
                            if (con.Account.Account_Life_Cycle__c =='Customer at Risk')
                                userProfile.Suspension_Reason__c = 'Bad payer';
                            else if (con.Account.Account_Life_Cycle__c =='Customer on Notice')
                                userProfile.Suspension_Reason__c = 'Commercial Demand';
                            else
                                userProfile.Suspension_Reason__c = 'Indelicate Customer';
                            
                            userProfile.Suspension_Start_Date__c = Date.Today() - 1;
                            userProfile.Suspension_End_Date__c   = null;
                            upToUpdate.add(userProfile);
                        }
                        
                        update upToUpdate;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'UP traités:' + upToUpdate.size()));
                    }
                    
                    this.con.Invoice_Status__c = 'Frozen';
                    update this.con;
                    return null;
          
    }
  
    public PageReference Cancel()
    {
        return (Utilities.Redirect(this.con.Id));
    }
    
     public PageReference sendProvisioningMsg()
    {
        if (mapSubUps != null && mapSubUps.keySet().size() > 0)
            ProvisioningMessages.SuspendUsersInSubscription(mapSubUps, 'SuspendAll');
        return (Utilities.Redirect(this.con.Id));
    }
 
}