/**
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2015 March 16
* @description  Controller for TFX migration script (WKTSCRM-1899)
*/
public with sharing class TFX_MigrationController
{
    public class ValidationException extends Exception
    {
        public List<string> errors { get; set; }
    }
    
    public string companiesList { get; set; }
    
    public void init()
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please put here AccountNumbers one in line'));
    }
    
    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 March 16
    * @description  Perform activation of companies and users. Main working method
    */
    public PageReference Activate()
    {
        // we have list of accountNumbers in companiesList. We need to send 1 message per company and 1 message per user to activate
        
        system.debug('---------- TFX_MigrationController: Activate: companiesList: ' + companiesList);
        
        try
        {
            if(string.isEmpty(companiesList))
            {
                init();
                return null;
            }
            List<string> tmp = companiesList.split('\n');
            
            List<string> accountNumbersList = new List<string>();
            
            for(string s : tmp)
                if(string.isNotEmpty(s.trim()))
                    accountNumbersList.add(s.trim());
            
            system.debug('---------- TFX_MigrationController: Activate: accountNumbersList: ' + accountNumbersList);
            
            List<Account> accounts = [SELECT Id, Name, AccountNumber, TFX_Migration_DATE__c, TFX_Migration_Status__c, TFX_Migration_PackageName__c FROM Account WHERE AccountNumber IN :accountNumbersList];
            if(!accounts.isEmpty()){
                for(Account currAcc:accounts)
                {
                   currAcc.TFX_Migration_Status__c = '';
                   currAcc.TFX_Migration_DATE__c = date.today();
                }
                System.Queueable jobTFXMigration = new TFXMigrationQueueable(accounts);
                System.enqueueJob(jobTFXMigration);
            }         
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown error: ' + ex.getMessage()));
        }
        
        return null;
    } // Activate
    
    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 March 16
    * @description  Perform validation of entered info
    */
/*    public void ValidateInput(List<string> accountNumbersList, List<Account> accounts, List<Contact> contacts)
    {
        ValidationException ex = new ValidationException();
        ex.errors = new List<string>();
        
        // 1) do we have all the companies?
        for(string accNum : accountNumbersList)
        {
            boolean hasAccount = false;
            for(Account a : accounts)
                hasAccount |= a.AccountNumber.equals(accNum);
            
            if(!hasAccount)
                ex.errors.add('There is no account with AccountNumber ' + accNum);
        }
        
        // 2) do we have ESB BusinesID for all the users?
        for(Contact c : contacts)
        {
            if(string.isEmpty(c.ESB_BuisnessID__c))
                ex.errors.add('There is no business ID for contact ' + c.Name + ' company ' + c.Account.AccountNumber);
        }
        
        // all the companies has FX xubscriptions?
        List<Subs_Current_Fee__c> scfList = [
            SELECT Id, 
                   Name, 
                   Subscription__r.Opportunity__r.Offer_Template__r.Name,
                   Account_Number__c,
                   Account_Number_Formula__c
              FROM Subs_Current_Fee__c
             WHERE Account_Number_Formula__c IN :accountNumbersList 
        ];
        // accoutnNumber => scf list
        Map<string, List<Subs_Current_Fee__c>> scfMap = new Map<string, List<Subs_Current_Fee__c>>();
        for(Subs_Current_Fee__c scf : scfList)
        {
            if(!scfMap.containsKey(scf.Account_Number_Formula__c))
                scfMap.put(scf.Account_Number_Formula__c, new  List<Subs_Current_Fee__c>());
                scfMap.get(scf.Account_Number_Formula__c).add(scf);
        }
        for(Account a : accounts)
        {
            boolean hasFX = false;
            if(scfMap.containsKey(a.AccountNumber))
            {
                for(Subs_Current_Fee__c scf : scfMap.get(a.AccountNumber))
                    if(scf.Name.startsWith('FX'))
                    {
                        hasFX = TRUE;
                    }
            }
            if(!hasFX)
                ex.errors.add('There is no FX product attached to account ' + a.AccountNumber);
        }
        
        if(ex.errors.size() > 0)
            throw ex;
    } // ValidateInput */
    
    public PageReference RunImmediatly()
    {
        Boolean resultSceduling = true;
        for(Integer i=1; i<20; i++)
        {
            TFXMigrationBathable TFXMigrBat = New TFXMigrationBathable();
            String jobName = 'TFXjobNumber' + String.ValueOf(i);
            try
            {
                if (!Test.isRunningTest())
                {
                    String cronID = System.scheduleBatch(TFXMigrBat, jobName, i*5);
                }    
            }
            catch (Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown error: ' + ex.getMessage()));
                resultSceduling = false;
                break;
            }    
        }
        if(resultSceduling)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'TFX Migration job was started'));
        }        
        return null;
    } //runImmediatly
    
    
    public PageReference SceduleToTomorrow()
    {
        Integer minUntilTomorrow;
        DateTime d = datetime.now(); 
        Boolean resultSceduling = true;
        minUntilTomorrow = 1450 - (d.hour() * 60 + d.minute()); //1450 = 1440 min per day + 10 min after midnight 
        
        for(Integer i=1; i<64; i++)
        {
            TFXMigrationBathable TFXMigrBat = New TFXMigrationBathable();
            String jobName = 'TFXscJobNightumber' + String.ValueOf(i);
            try
            {
                 if (!Test.isRunningTest())
                 {
                     String cronID = System.scheduleBatch(TFXMigrBat, jobName, minUntilTomorrow + i*5);
                 }
            }
            catch (Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Scedule error: ' + ex.getMessage()));
                resultSceduling = false;
                break;
            }    
        }
        if(resultSceduling)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'TFX Migration job was sceduled to tomorrow'));
        }
        return null;
    } //SceduleToTomorrow


    public PageReference SceduleToMonday()
    {
        Integer minUntilMonday;
        Boolean resultSceduling = true;
        DateTime isNow = System.now();
        Integer daysUntillMonday = 7 - Integer.valueOf(isNow.format('u'));//calculate days until Monday 
        minUntilMonday = 1450 - (isNow.hour() * 60 + isNow.minute()) + 1440 * daysUntillMonday; //1450 = 1440 min per day + 10 min after midnight 
        
        for(Integer i=1; i<64; i++)
        {
            TFXMigrationBathable TFXMigrBat = New TFXMigrationBathable();
            String jobName = 'TFXscJobMondayNumber' + String.ValueOf(i);
            try
            {
                if (!Test.isRunningTest())
                {
                    String cronID = System.scheduleBatch(TFXMigrBat, jobName, minUntilMonday + i*5);
                }
            }
            catch (Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Scedule error: ' + ex.getMessage()));
                resultSceduling = false;
                break;
            }    
        }
        if(resultSceduling)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'TFX Migration job was sceduled to next Monday'));
        }
        return null;
    } //SceduleToMonday


}