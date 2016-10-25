global class BAProduct implements Database.Batchable<sObject>
{
    global final String query ='SELECT Id,Status__c FROM Product__c WHERE Status__c = \'On Notice\'';
    global final String Entity;
    global final String Field;
    global final String Value;

    global BAProduct()
    {
             
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,   List<sObject> scope)
    {
        System.Debug('## Execute scheduled job');
        List<Product__c> lstproduct = new List<Product__c>();

        for(sObject p : scope)
        {
            Product__c prod = (Product__c)p;
            System.Debug('## Processing Product ' + prod.Id);
            
            //Integer counter = [Select Count() from Offer_template__c where Base_Product__c =:prod.Id];
            
            //if (counter == 0)
            //{
                System.Debug('## Setting Product status to Inactive for id ' + prod.Id);
                prod.status__c = 'Inactive';
                lstproduct.add(prod);
            //}
        }  
        
        update lstproduct;
    }

    global void finish(Database.BatchableContext BC)
    {

    }

}