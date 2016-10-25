/*
* @ Author		:- HCL Technologies LTD.
* @ Description :- Class use to update Top Account Number on every account. 	
*				   Class is schedule oone time for Account update	
* @ Date 		:- 10-05-2013
***/

global with sharing class IKAMassUpdateBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
	
	global final String query;

	global IKAMassUpdateBatch(){
		
		query= 'Select a.Top_Account_Number__c, a.Id, a.AccountNumber From Account a where Top_Account_Number__c=null';
	}
	/*
	* @ PARAM 		: BatchableContect 
	* @ Description : Method get all records of account where Top Account number is null. 
	* @ Date 		: 10-05-2013
	*/
	global Database.querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	
	/*
	* @ PARAM 		: BatchableContect 
	* @ PARAM		: List<Sobject>
	* @ Description : Method process available for not having Top parent account number and execute in a batch of 20 
	* @ Date 		: 10-05-2013
	*/
	
	global void execute(Database.BatchableContext BC,List<sObject> scope){
		try {
			  List<Account> accsToUpdate = new List<Account>();
				for (sObject obj : scope){
					Account up = (Account)obj;
					accsToUpdate.add(up);
				}
				 update accsToUpdate;
				 System.debug('accsToUpdate==>'+accsToUpdate);
			
		} catch (Exception e){
			system.debug('Error !!!!! '+e.getMessage());
		}		
		
	}
	
	/*
	* @ PARAM 		: BatchableContect 
	* @ Description : Method execute after all batches are processed for account update.  
	* @ Date 		: 10-05-2013
	*/
	
	global void finish(Database.BatchableContext BC){
	
	}	
}