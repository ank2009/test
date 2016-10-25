/**
* @author       Aleh Tsilko (aleh_tsilko@epam.com)
* @date         2015 Oct
* @description  schedule job for check Subscriptions in Accounts for TFX Migration
* @2000 JIRA TASK              
*/

global class TFXMigration_CheckParentAccScedulable  implements Schedulable{
 
    global void execute(SchedulableContext SC) 
    {  
        List<Account> checkAccts = [SELECT Id,
                                           TFX_Migration_HaveTProduct__c
                                      FROM Account 
                                     WHERE TFX_Migration_DATE__c >= TODAY ];
        List<Id> checkAccIds = New List<Id>(); 
        for(Account currAccount:checkAccts)
        {
            checkAccIds.add(currAccount.Id);
        } 
                                        
        List<Contact> relatedActiveContacts = [ SELECT Id,
                                                       Account.Id
                                                  FROM Contact
                                                 WHERE Contact_Status__c = 'Active'
                                                   AND Product__c = 'T-PRO'
                                                   AND Account.Id IN :checkAccIds];                                     
        Set<Id> acctWithActiveContactIds = New Set<Id>();
        for(Contact currCon:relatedActiveContacts)
        {
             acctWithActiveContactIds.add(currCon.Account.Id);         
        }
        
        List<Subscription__c> relatedActiveSubscriptions = [ SELECT Id,
                                                              Account__r.Id
                                                         FROM Subscription__c
                                                        WHERE Status__c = 'Active'
                                                          AND (Product__r.Name = 'T-PRO'
                                                           OR  Product__r.Name = 'T-ACTIVE')
                                                          AND Account__r.Id IN :checkAccIds];                                     
        Set<Id> acctWithActiveSubsIds = New Set<Id>();
        for(Subscription__c currSub:relatedActiveSubscriptions)
        {
             acctWithActiveSubsIds.add(currSub.Account__r.Id);         
        }
        
        for(Account currAcc:checkAccts)
        {
             if(acctWithActiveContactIds.contains(currAcc.Id)
             && ! acctWithActiveSubsIds.contains(currAcc.Id))
             {
                 currAcc.TFX_Migration_HaveTProduct__c = true;
             }    
             else             
             {
                 currAcc.TFX_Migration_HaveTProduct__c = false;             
             }            
        }
        upsert checkAccts;        
    }//end execute    
 }