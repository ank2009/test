/**
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2015 May
    * @description  daily email results of TFX Migration Job
    * @CM-440 JIRA TASK              
    */

global class TFXMigrationEmailResult implements Schedulable {    
    
    global void execute(SchedulableContext sc) {
        List<Account> TFXAcc = [SELECT TFX_Migration_DATE__c,
                                       TFX_Migration_Status__c 
                                  FROM Account 
                                 WHERE TFX_Migration_DATE__c = TODAY
                                    OR TFX_Migration_DATE__c = NEXT_N_DAYS:2];
        List<Account> todayTFXAcc = New List<Account>();
        List<Account> tomorrowTFXAcc = New List<Account>();                                  
        for(Account currAcc : TFXAcc)
        {
            if(currAcc.TFX_Migration_DATE__c == Date.today())
            {
                todayTFXAcc.Add(currAcc);
            }
            else
            {
                if((currAcc.TFX_Migration_DATE__c == Date.today().addDays(2) 
                && currAcc.TFX_Migration_Status__c == 'error in the pack and fee Name')
                || currAcc.TFX_Migration_DATE__c == Date.today().addDays(1))
                {
                    tomorrowTFXAcc.Add(currAcc);
                }    
            }
        }
                         
        if(!TFXAcc.isEmpty())
        {
            //calculate today results
            Integer colAll = todayTFXAcc.size(); //all today accounts
            Integer colOkk = 0; //successfully migrated accounts
            Integer colErr = 0; //accounts with migration errors
            Integer colUnp = 0; //unprocessed accounts            
            for(Account currAcc: todayTFXAcc)
            {
                if(String.isBlank(currAcc.TFX_Migration_Status__c))
                {
                    colUnp ++;
                }
                else if(currAcc.TFX_Migration_Status__c == 'TFX migration request was send')
                {
                    colOkk ++;
                }
                else
                {
                    colErr ++;
                }
            }
                                      
            //calculate results for tomorrow migration
            Integer colTomorrowAll = tomorrowTFXAcc.size(); //all tomorrow accounts
            Integer colTomorrowErr = 0; //accounts with package_name errors

            for(Account currAcc: tomorrowTFXAcc)
            {
                if(currAcc.TFX_Migration_Status__c == 'error in the pack and fee Name')
                {
                    colTomorrowErr ++;
                }
            }                                                                            
                        
            //prepare attachment
            Messaging.EmailFileAttachment attachLog = new Messaging.EmailFileAttachment();            
            String todayStr = date.today().format();  
            List<TFX_Migration_Daily_Log__c> todayLog = [SELECT Status_migration__c FROM TFX_Migration_Daily_Log__c WHERE Name =: todayStr];
            if (!todayLog.IsEmpty())
            {
                String textAttach = todayLog[0].Status_migration__c;
                Blob attachBody = Blob.valueOf(textAttach);            
                attachLog.setFileName('TFX_Migration_Daily_Log.txt');
                attachLog.setBody(attachBody);
            } 
                            
            //prepare recipients
            List<String> sysAdmEmails = New List<String>();   
            List<User> sysAdmUsrs = [SELECT Email, Profile.Name 
                                       FROM User 
                                      WHERE IsActive = TRUE
                                        AND (Profile.Name = 'Sys Admin Without  Exp Pwd'
                                         OR Profile.Name = 'System Administrator')];
            if(sysAdmUsrs.IsEmpty())
            {
                sysAdmEmails.add('minus@mail.by');
            }
            else
            {                             
                for(User currUsr :sysAdmUsrs)
                {
                    sysAdmEmails.add(currUsr.Email);
                }
            }
                     
            //prepare email
            Messaging.SingleEmailMessage dailyLogTFXmail = new Messaging.SingleEmailMessage();
            dailyLogTFXmail.setToAddresses(sysAdmEmails);
            dailyLogTFXmail.setSubject('TFX Migration Job :'+ datetime.now());
            dailyLogTFXmail.setSenderDisplayName('SF');
            dailyLogTFXmail.setPlainTextBody('Total Accounts in today migration: '+ colAll +
                                        '\n Requests was send: '+ colOkk +
                                        '\n Accounts with errors: '+ colErr +
                                        '\n Unprocessed Accounts: '+colUnp +
                                        '\n'+
                                        '\n Total Accounts for tomorrow TFX migration: '+ colTomorrowAll +
                                        '\n Accounts with Package Name errors: '+ colTomorrowErr);
            if (!todayLog.IsEmpty())
            {
                dailyLogTFXmail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachLog }); 
            }
            
           // send the email
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { dailyLogTFXmail });                                                              
        }                               
    }
}//end class