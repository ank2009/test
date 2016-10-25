/**
* @author       Aleh Tsilko (aleh_tsilko@epam.com)
* @date         2015 Jule
* @description  schedule job for check PackageNames in Accounts for TFX Migration
* @CM-415 JIRA TASK              
*/

global class TFXMigration_CheckAccountsScedulable  implements Schedulable{
 
    global void execute(SchedulableContext SC) 
    {   
        List<Account> checkAccts = [SELECT Id,
                                           BillingCountry,
                                           TFX_Migration_DATE__c,
                                           TFX_Migration_Status__c, 
                                           TFX_Migration_PackageName__c,
                                           TFX_Migration_HaveTProduct__c,
                                           ESB_ShippingAddress_ID__c,
                                           PLC_FX_Summary__c  
                                      FROM Account 
                                     WHERE TFX_Migration_DATE__c = TOMORROW];
        //prepare references                                     
        Map<Id, Integer> numRelContacts = New Map<Id, Integer>();
        Set<Id> nonBuisnIdRelContacts = New Set<Id>();
        
        List<Id> checkAccIds = New List<Id>();
        for(Account currAcc : checkAccts)
        {
            numRelContacts.Put(currAcc.Id, 0);                    
            checkAccIds.Add(currAcc.Id);
        }
        List<Contact> relatedContacts = [SELECT Account.Id,
                                                ESB_BuisnessID__c
                                           FROM Contact
                                          WHERE Contact_Status__c = 'Active'
                                            AND Product__c != 'TFC'
                                            AND Account.Id IN:checkAccIds];
        for(Contact currCon: relatedContacts)
        {                                  
            numRelContacts.Put(currCon.Account.Id,numRelContacts.Get(currCon.Account.Id) + 1);
            if(String.isBlank(currCon.ESB_BuisnessID__c))
            {
                nonBuisnIdRelContacts.add(currCon.Account.Id);
            }
        }

        //check all Accounts
        List<Account> accToUpdate = New List<Account>();
        for(Account currAcc:checkAccts)
        {
            Integer currAccConts = numRelContacts.get(currAcc.Id);
            String oldTFX_Migration_Status = currAcc.TFX_Migration_Status__c;
            Date oldTFX_Migration_DATE = currAcc.TFX_Migration_DATE__c;
            Boolean oldTFX_Migration_HaveTProduct = currAcc.TFX_Migration_HaveTProduct__c;
            
            if(currAcc.PLC_FX_Summary__c == 'Customer' || currAcc.PLC_FX_Summary__c == 'Free Member')
            {
                currAcc.TFX_Migration_HaveTProduct__c = TRUE;
            }
            
            if(String.isNotBlank(currAcc.TFX_Migration_PackageName__c))
            {
            
                if(currAcc.BillingCountry == 'Belgium' 
                || currAcc.BillingCountry == 'France'
                || currAcc.BillingCountry == 'Luxembourg'
                || currAcc.BillingCountry == 'United Kingdom'
                || currAcc.BillingCountry == 'Netherlands')
                {   
                    if((currAcc.TFX_Migration_PackageName__c.Contains('Start') && (currAccConts < 2))
                     ||(currAcc.TFX_Migration_PackageName__c.Contains('Standard') && (currAccConts < 3))
                     ||(currAcc.TFX_Migration_PackageName__c.Contains('Business') && (!currAcc.TFX_Migration_PackageName__c.Contains('Plus')) && (currAccConts < 4 ))
                     ||(currAcc.TFX_Migration_PackageName__c.Contains('Business_Plus') && (currAccConts < 5))
                     ||(currAcc.TFX_Migration_PackageName__c.Contains('Premium') && (currAccConts < 6))
                     ||(currAcc.TFX_Migration_PackageName__c.Contains('One_To_One')))
                    {
                        currAcc.TFX_Migration_Status__c = '';                                    
                    }
                    else
                    {
                        currAcc.TFX_Migration_Status__c = 'error in the pack and fee Name';
                    }                                                            
                }
                else //Billing Country != Belgium, France, Luxembourg, United Kingdom, Netherlands
                {
                    if((currAcc.TFX_Migration_PackageName__c.Contains('Start') && (currAccConts < 2))
                     ||(currAcc.TFX_Migration_PackageName__c.Contains('Standard') && (currAccConts < 4))
                     ||(currAcc.TFX_Migration_PackageName__c.Contains('Business') && (currAccConts < 5 ))
                     ||(currAcc.TFX_Migration_PackageName__c.Contains('Premium') && (currAccConts < 6 ))                
                     ||(currAcc.TFX_Migration_PackageName__c.Contains('One_To_One')))
                    {
                        currAcc.TFX_Migration_Status__c = '';                                    
                    }
                    else
                    {
                        currAcc.TFX_Migration_Status__c = 'error in the pack and fee Name';
                    }                                                                                
                }
            }
            else
            {
                currAcc.TFX_Migration_Status__c = 'the pack and fee Name is absent';
            }
            
            if(String.isBlank(currAcc.ESB_ShippingAddress_ID__c))
            {
                currAcc.TFX_Migration_Status__c = 'the ESB chipping Address ID is absent';
            }
            
            if(nonBuisnIdRelContacts.contains(currAcc.Id))
            {
                currAcc.TFX_Migration_Status__c = currAcc.TFX_Migration_Status__c + ' related Contact doesn\'t have ESB BuisnessID';
            }
            
            //make list accounts for update
            if((oldTFX_Migration_Status != currAcc.TFX_Migration_Status__c)
             ||(oldTFX_Migration_DATE != currAcc.TFX_Migration_DATE__c)
             ||(oldTFX_Migration_HaveTProduct != currAcc.TFX_Migration_HaveTProduct__c))
            {
                accToUpdate.add(currAcc);
            }
        }//for
        
        //Update accounts
        if(! accToUpdate.isEmpty()) 
        {
            try
            {
                update accToUpdate;
            }
            catch (System.DmlException ex)
            {
                TFXMigrationHelper.addTFXCheckLog(' error in update Account with mistake,' +TFXMigrationHelper.getDMLErrors(ex));
            }   
        }    
    }//end execute    
 }