global class BAOfferTemplate implements Database.Batchable<sObject>
{
    global final String query ='SELECT Id,Status__c FROM Offer_template__c WHERE Status__c = \'On notice\'';
    global final String Entity;
    global final String Field;
    global final String Value;

    global BAOfferTemplate()
    {
    	
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	System.Debug('## Execute scheduled job');
        List<Offer_template__c> lstOT = new List<Offer_template__c>();

        for(sObject s : scope)
        {
            Offer_template__c currentOT = (Offer_template__c)s;
            System.Debug('## Processing Offer Template ' + currentOT.Id);
            
            Integer countOppOT = [Select Count() from Opportunity where Offer_Template__c=:currentOT.Id];
            Integer countSubsOT = [Select Count() from Subscription__c where Offer_Template__c=:currentOT.Id];
            
            if (countOppOT + countSubsOT == 0)
            {
            	System.Debug('## Setting Offer Template to Inactive for id ' + currentOT.Id);
                currentOT.status__c = 'Inactive';
                lstOT.add(currentOT);
            }
        }
        
        update lstOT;
    }

    global void finish(Database.BatchableContext BC)
    {

    }

}