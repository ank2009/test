/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2013 September 17
* @description  Batch processor for Total Maintenance recalculation for Subs CurrentFees
                Database.Stateful needed for saving class state between execute() calls. See apex code reference for details.
                
                General idea - is to calculate Total Maintenance price. I will do it using trigger.
                I will call trigger once for each subscription
*/
global class TLR_SubsCurrentFeesTotalMaintBatchable implements Database.Batchable<sObject>, Database.Stateful
{
	/** 
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 September 17
	* @description  query string
	*/
	private string query;
	
	private Set<Id> alreadyProcessedSubscriptions;
	
	public TLR_SubsCurrentFeesTotalMaintBatchable()
	{
		query = 'SELECT Id, Name, Notes__c, Subscription__c ';
		query += 'FROM Subs_Current_Fee__c WHERE ';
		query += 'Subscription__r.Status__c = \'Active\' ';
		query += 'AND Subscription__r.RecordTypeId = \'' + TLR_RecordTypeHelper.getId('Subscription__c', 'TAS Subscription') + '\'';
		
		alreadyProcessedSubscriptions = new Set<Id>();
		 
		system.debug('TLR_SubsCurrentFeesTotalMaintBatchable: query: ' + query);
	}
	
	/** 
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 September 17
	* @description  Database.Batchable implementation
	*/
	global Database.QueryLocator start(Database.BatchableContext bc)
	{
		alreadyProcessedSubscriptions.clear(); // just in case
		return Database.getQueryLocator(query);
	}
	
	/** 
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 September 17
	* @description  Database.Batchable implementation
	*/
	global void execute(Database.BatchableContext bc, List<sObject> scope)
	{
		for(sObject obj : scope)
		{
			Subs_Current_Fee__c cf = (Subs_Current_Fee__c)obj;
			if(alreadyProcessedSubscriptions.contains(cf.Subscription__c))
				continue;
			
			// just call a trigger, and it will do its job
			update cf;
			alreadyProcessedSubscriptions.add(cf.Subscription__c);
		}
	}
	
	/** 
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 September 17
	* @description  Database.Batchable implementation
	*/
	global void finish(Database.BatchableContext bc)
	{
		
	}
}