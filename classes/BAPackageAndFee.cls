global class BAPackageAndFee implements Database.Batchable<sObject>
{
    global final String query ='SELECT Id,Status__c FROM PackFee__c WHERE Status__c = \'On notice\'';
    global final String Entity;
    global final String Field;
    global final String Value;

    global BAPackageAndFee()
    {
    	
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	System.Debug('## Execute scheduled job');
        List<PackFee__c> lstPF = new List<PackFee__c>();

        for(sObject s : scope)
        {
            PackFee__c currentPF = (PackFee__c)s;
            System.Debug('## Processing Pack & Fee ' + currentPF.Id);
            
            Integer countOffPF = [Select Count() from Offer_Package_And_Fee__c where Package_Fee__c=:currentPF.Id];
            Integer countSubsPF = [Select Count() from Subs_Package_And_Fee__c where Package_and_Fee__c=:currentPF.Id];
            
            if (countOffPF + countSubsPF == 0)
            {
            	System.Debug('## Setting Pack & Fee to Inactive for id ' + currentPF.Id);
                currentPF.status__c = 'Inactive';
                lstPF.add(currentPF);
            }
        }
        
        update lstPF;
    }

    global void finish(Database.BatchableContext BC)
    {

    }

}