/**
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         2016 April 6
* @description  Schedulable Batch process for updating Active_End_Date__c in Verification_Page__c
**/
global class SetEndDateVerificationPageBatch implements Database.Batchable<sObject>, Schedulable 
{
    global final string query = 'select Id, Active_End_Date__c, Integrity_Check_Completed__c from Verification_Page__c where Active_End_Date__c = Today and Integrity_Check_Completed__c = \'Active\'';

    
	public SetEndDateVerificationPageBatch()
	{
		
	}
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
       	return DataBase.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Verification_Page__c> scope)
    {            
        for(integer i=0; i<scope.size();i++)
        {
            scope[i].Integrity_Check_Completed__c = 'Expired';
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC)
    {
		
    }
 	
 	global void execute(SchedulableContext sc)
	{
		SetEndDateVerificationPageBatch batch = new SetEndDateVerificationPageBatch();
	    Database.executeBatch(batch);
	} 
}