global class BAService implements Database.Batchable<sObject>
{
    global final String query ='SELECT Id,Status__c FROM Service__c WHERE Status__c = \'On Notice\'';
    global final String Entity;
    global final String Field;
    global final String Value;

    global BAService()
    {
             
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	System.Debug('## Execute scheduled job');
        List<Service__c> lstservice = new List<Service__c>();

        for(sObject s : scope)
        {
            Service__c serv = (Service__c)s;
            System.Debug('## Processing Service ' + serv.Id);
            
            Integer counter = [Select Count() from Product_Line_Item__c where Service__c=:serv.Id];
            
            if (counter == 0)
            {
            	System.Debug('## Setting Service status to Inactive for id ' + serv.Id);
                serv.status__c = 'Inactive';
                lstservice.add(serv);
            }
        }
        
        update lstservice;
    }

    global void finish(Database.BatchableContext BC)
    {

    }

}