/**
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2015 May
    * @description  Queueable job for call future methods in ESB_Proxy for TFX Migration Job
    * @CM-440 JIRA TASK              
    */
    
public class TFXMigrationQueueable implements System.Queueable 
{
    private List<Account> accountTFXlist = New List<Account>();
    
    public TFXMigrationQueueable(List<Account> accountTFXlist)
    {
       this.accountTFXlist = accountTFXlist;
    }
    
    public void execute(System.QueueableContext context) 
    {  
        Boolean skipTriggers = [Select Disable_All_Triggers__c From User where id =: Userinfo.getUserId()  Limit 1][0].Disable_All_Triggers__c;
        Integer currentCallLimit = 100;
        Id subsActiveRecordType = TLR_RecordTypeHelper.getId('Subscription__c', 'TLR Subscription Active');
        for(Account accountTFX :accountTFXlist)
        {            
            //check
            String statusMigtationMessage = '';
            List<Id> tfxProductsIds = TFXMigrationHelper.TFX_PRODUCTNAME_IDS;
            Id tfxRecTypeId = TFXMigrationHelper.RECORD_TYPE_MIGR_ID;
            List<Subscription__c> currentAccProds = [SELECT Id, 
                                                           Product__c, 
                                                           Status__c 
                                                      FROM Subscription__c
                                                     WHERE RecordTypeId = :tfxRecTypeId
                                                       AND Account__c = :accountTFX.Id
                                                       AND Product__c IN :tfxProductsIds ]; 
            if(currentAccProds.isEmpty()
            && !accountTFX.TFX_Migration_HaveTProduct__c)
            {
                statusMigtationMessage = 'error: Account doesn\'t have T-PRO or T-Active products';
            }
            
            List<Subscription__c>  currentAccSubs = [SELECT Id
                                                       FROM Subscription__c
                                                      WHERE Account__c = :accountTFX.Id  
                                                        AND Name = :TFXMigrationHelper.TFXSUBSNAME];
            if(currentAccSubs.isEmpty())
            {
                statusMigtationMessage = statusMigtationMessage + 'error: Account doesn\'t have TFX Migration Subscription';
            }
            
            List<Contact> relContacts = [SELECT Id, 
                                                Name, 
                                                CreatedDate, 
                                                ESB_BuisnessID__c, 
                                                Account.AccountNumber
                                           FROM Contact 
                                          WHERE AccountId = :accountTFX.Id
                                            AND Contact_Status__c = 'Active'
                                            AND Product__c != 'TFC'];
            if(relContacts.isEmpty())
            {
                statusMigtationMessage = statusMigtationMessage + 'error: Account doesn\'t have related Active Contacts';
            }
            else
            {
            	for(Contact currCon:relContacts)
            	{
                	if(String.isEmpty(currCon.ESB_BuisnessID__c))
                	{
            		    statusMigtationMessage = statusMigtationMessage + 'error: related Contact doesn\'t have ESB BuisnessID ';
                	}
            	}
            }
            
            //update 
            Savepoint noChangesSavepoint = Database.setSavepoint();
            if((currentCallLimit - relContacts.size()) > 1)
            {
                if(statusMigtationMessage == ''
                && !accountTFX.TFX_Migration_HaveTProduct__c)
                {
                    currentCallLimit = currentCallLimit - relContacts.size() -1;
                    For(Subscription__c currSubs:currentAccProds)
                    {
                        currSubs.RecordTypeId = subsActiveRecordType;  
                        currSubs.Status__c = 'Migration';                                               
                    }
                    try
                    {
                        update currentAccProds;
                    }
                    catch (System.DmlException ex)
                    {
                        statusMigtationMessage = ' update Subscription error:' + TFXMigrationHelper.getDMLErrors(ex);                        
                    }
                }                                  
                if(statusMigtationMessage == '')
                {                                      
                    List<Subs_Current_Fee__c> newPKFs = New List<Subs_Current_Fee__c>();  
                    For(Subscription__c currSubs:currentAccSubs)
                    {
                        Subs_Current_Fee__c newFee = new Subs_Current_Fee__c();
                        newFee.Start_Date__c = date.today();
                        newFee.Name = accountTFX.TFX_Migration_PackageName__c;
                        List<Subs_Package_And_Fee__c> relPF = [SELECT Id 
                                                                 FROM Subs_Package_And_Fee__c 
                                                                WHERE Subscription__c = : currSubs.Id 
                                                                  AND Name = :accountTFX.TFX_Migration_PackageName__c];                        
                        if(!relPF.isEmpty())
                        {                                     
                            newFee.Subs_Package_And_Fee__c = relPF[0].Id;
                            newFee.Subscription__c = currSubs.Id;
                            newFee.Account__c = accountTFX.Id; 
                            newFee.Account_Number__c = accountTFX.AccountNumber;                   
                            newPKFs.add(newFee);                                               
                        }
                        else
                        {
                            Database.rollback(noChangesSavepoint);
                            statusMigtationMessage = statusMigtationMessage + ' make Current_Fee error: subscription for '+ accountTFX.TFX_Migration_PackageName__c + ' is absent ';                                                 
                        }
                    }        
                    try
                    {
                        if (!Test.isRunningTest() && statusMigtationMessage == '')
                        {
                            insert newPKFs;
                        }
                    }
                    catch (System.DmlException ex)
                    {
                        Database.rollback(noChangesSavepoint);
                        statusMigtationMessage = statusMigtationMessage + ' make Current_Fee error:' + TFXMigrationHelper.getDMLErrors(ex); 
                    }        
                } 
                    
                
                if(statusMigtationMessage == '')
                {                   
                    if(skipTriggers)
                    {
                        List<Id> contactIds = New List<Id>();
                        for(Contact c : relContacts)
                        {
                            contactIds.Add(c.Id);
                        }                   
                        ESB_Proxy.SerialUpdateCompany(accountTFX.Id, contactIds);
                    }                                              
                }
                else
                {
                    accountTFX.TFX_Migration_Status__c = statusMigtationMessage;
                    update accountTFX;
                    TFXMigrationHelper.addTFXMigrationLog(accountTFX,statusMigtationMessage);
                }                   
            }
            else
            {
                break;
            }
         }//for                            
    }        
}