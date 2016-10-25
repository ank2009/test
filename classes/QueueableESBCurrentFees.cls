public class QueueableESBCurrentFees implements Queueable 
{
    Set<Id> recordids;
    public QueueableESBCurrentFees(Set<Id> recordIds) {
        this.recordIds = recordIds;
    }
    
    public void execute(QueueableContext context) 
    {
        List<Subs_Current_Fee__c> fees = [Select ID, Account__c From Subs_Current_Fee__c Where Id =: recordIds];
        for(Subs_Current_Fee__c subFee: fees)
        {
        	ESB_Proxy.UpdateCompany(subFee.Account__c, true);
        }
    }
}