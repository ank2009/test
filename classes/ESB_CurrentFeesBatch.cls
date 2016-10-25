global class ESB_CurrentFeesBatch implements Database.Batchable<sObject>, Schedulable
{
    
	public ESB_CurrentFeesBatch()
	{
		
	}
	
	global final String queryCurrentFees = 'Select Subscription__r.Contact__c, Subscription__c, Subscription__r.Status__c,'+
	 'Start_Date__c, Id, End_Date__c, Account__c From Subs_Current_Fee__c '+ 
	 'Where Subscription__r.Contact__c != null And (Start_Date__c = Today  or End_Date__c = Today) ' +
     'AND Subscription__r.Offer_template__r.Use_new_Provisioning__c = true '+   
	 'And Subscription__r.Status__c IN (\'Active\',\'On Notice\',\'Cancelled\')';
	
	global Database.QueryLocator start(Database.BatchableContext BC)
    {
    	 return Database.getQueryLocator(queryCurrentFees);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {            
        System.enqueueJob(new QueueableESBCurrentFees(new Map<Id, sObject>(scope).keySet()));
    }
    
    global void finish(Database.BatchableContext BC)
    {
		
    }
 	
 	global void execute(SchedulableContext sc)
	{
		ESB_CurrentFeesBatch batch = new ESB_CurrentFeesBatch();
	    Database.executeBatch(batch, 2);
	} 
}