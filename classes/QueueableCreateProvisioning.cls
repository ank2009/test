public class QueueableCreateProvisioning implements Queueable {
    Set<Id> recordids;
    boolean resend = false;
    public QueueableCreateProvisioning(Set<Id> recordIds, boolean res) {
        this.recordIds = recordIds;
        this.resend = res;
    }
    public void execute(QueueableContext context) 
    {
        if(!resend)
        { 
             List<Subscription__c> subs = [Select ID, Name, Account__r.Id,Contact__c, Account__c, Contract__r.Account.ESB_Company_status__c From Subscription__c Where Opportunity__r.Name = 'Nolis Migration - 2015' and Id =: recordids];
             for(Subscription__c sub:subs)
             {
                List<Subs_Package_And_Fee__c> subPack = [Select ID, Name From Subs_Package_And_Fee__c Where Subscription__c =: sub.Id And Name = 'CD_approved'];
                Subs_Current_Fee__c fee = new Subs_Current_Fee__c();
                fee.Start_Date__c = date.today();
                fee.Name = subPack[0].Name;
                fee.Subs_Package_And_Fee__c = subPack[0].Id;
                fee.Subscription__c = sub.Id;
                fee.Account__c = sub.Account__c;
                insert fee;
                List<Contact> conts = [Select ID,Email From Contact Where AccountID =: sub.Account__c and Product__c = 'Nolis'];
                conts[0].Email += '.fake';
                update conts[0];
                sub.Contact__c = conts[0].Id;
                update sub;
                TLR_SubscriptionExt ext = new TLR_SubscriptionExt(sub.Id);
                ext.InitCreateProvisioning();
             }
        }
        else
        {
             List<Subscription__c> subs = [Select Name From Subscription__c Where CreatedById = '005D0000002UKdK' and Status__c='Provisioning initiated' and Id =: recordids];
             for(Subscription__c sub:subs)
             {
                sub.Status__c = 'Waiting for Provisioning';
                update sub;
                TLR_SubscriptionExt ext = new TLR_SubscriptionExt(sub.Id);
                ext.InitCreateProvisioning();
             }
        }
        
    }
}