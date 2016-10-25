global class BASubservice implements Database.Batchable<sObject>
{
    global final String query = 'SELECT Id, Status__c FROM Subservice__c WHERE Status__c = \'On Notice\'';
    global final String Entity;
    global final String Field;
    global final String Value;
    
    global BASubservice()
    {
             
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        System.Debug('## Execute scheduled job');
        List<Subservice__c> lstsubservice = new List<Subservice__c>();
     
        for (sObject s : scope)
        {
            Subservice__c sub = (Subservice__c)s;
            System.Debug('## Processing Subservice ' + sub.Id);
            
            Integer counter = [Select Count() from Subservice_Template_Line_Item__c where Subservice__c = :sub.Id];
            
            if (counter == 0)
            {
                System.Debug('## Setting subservice status to Inactive for id ' + sub.Id);
                sub.status__c = 'Inactive';
                lstsubservice.add(sub);
            }
        }  
        
        update lstsubservice;
    }

    global void finish(Database.BatchableContext BC)
    {

    }

}