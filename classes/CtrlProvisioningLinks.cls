public with sharing class CtrlProvisioningLinks 
{
    public Boolean dataToDisplay {get; set;}
    public List<User_Profile__c> links;
    public Contact con {get; set;}
    
    public CtrlProvisioningLinks(ApexPages.StandardController controller) 
    {
        ID idContact = System.currentPagereference().getParameters().get('id');
        this.con = [SELECT Id, AccountId FROM Contact WHERE Id = :idContact];
        
        if (links == null)
        {
            Set<ID> accountIds = new Set<ID>();
            
            ID accnId = this.con.AccountId;
            
            while (accnId != null)
            {
                accountIds.add(accnId);
                List<Account> accounts = [SELECT ParentId FROM Account WHERE Id = :accnId];
                accnId = (accounts.size() > 0 ? accounts[0].ParentId : null);
            }
            
            List<Provisioning__c> provs = [SELECT Id, Account__c FROM Provisioning__c 
                                           WHERE Account__c IN :accountIds
                                           AND (Subscription__r.Status__c = 'Provisioning initiated' OR Subscription__r.Status__c = 'Active')];
                                           
            links = new List<User_Profile__c>();
            for (Provisioning__c prov : provs)
            {
                User_Profile__c up = new User_Profile__c();
                up.Provisioning__c = prov.Id;
                up.Account_name__c = prov.Account__c;
                links.add(up);
            }
        }
        
        dataToDisplay = (links.size() > 0);
    }
    
    public List<User_Profile__c> getLinks()
    {
        return links;
    }
}