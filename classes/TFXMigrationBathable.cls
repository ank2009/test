/**
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2015 April 23
    * @description  Batchable interface for TFX Migration Job
    * @CM-440 JIRA TASK              
    */

global class TFXMigrationBathable implements Database.batchable<Sobject> {
    
    global final String Query ='SELECT Id, Name, AccountNumber, TFX_Migration_HaveTProduct__c, TFX_Migration_DATE__c, TFX_Migration_Status__c, TFX_Migration_PackageName__c FROM Account WHERE TFX_Migration_DATE__c = TODAY AND (TFX_Migration_Status__c = NULL OR TFX_Migration_Status__c = \'\') LIMIT 10';
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) { 
        if(!scope.isEmpty()){
            System.Queueable jobTFXMigration = new TFXMigrationQueueable(scope);
            System.enqueueJob(jobTFXMigration);
        }            
    }

    global void finish(Database.BatchableContext BC){
    }

}//end class