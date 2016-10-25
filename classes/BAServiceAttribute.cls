global class BAServiceAttribute implements Database.Batchable<sObject>
{
    global final String query ='SELECT Id,Status__c FROM Service_Attribute__c WHERE Status__c = \'On Notice\'';
    global final String Entity;
    global final String Field;
    global final String Value;

    global BAServiceAttribute()
    {
             
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        System.Debug('## Execute scheduled job');
        List<Service_Attribute__c> lstserviceattribute = new List<Service_Attribute__c>();
     
        for(sObject s : scope)
        {
            Service_Attribute__c sa = (Service_Attribute__c)s;
            System.Debug('## Processing ServiceAttribute ' + sa.Id);
            
            Integer counter = [Select Count() from Service_Attribute_Template_Line_Item__c where Service_Attribute__c=:sa.Id];
            
            if (counter == 0)
            {
            	System.Debug('## Setting ServiceAttribute status to Inactive for id ' + sa.Id);
                sa.status__c = 'Inactive';
                lstserviceattribute.add(sa);
            }
        }
        
        update lstserviceattribute;
    }

    global void finish(Database.BatchableContext BC)
    {

    }

}