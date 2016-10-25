/**
* @author       Aleh Tsilko (aleh_tsilko@epam.com)
* @date         2015 Jule
* @description  test a schedule job for check PackageNames in Accounts for TFX Migration
* @CM-415 JIRA TASK              
*/

@isTest
    public class TFXMigration_CheckAccountsTest
    {
        static testmethod void testAccPackageName()
        { 
        //prepare test data
            //custom settings
            TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Albania'});
            
            List<Contact> testContacts = New List<Contact>();
            //france accounts with contacts           
            Integer numOfCont = 0;
            for(Account currAcc: getFranceAccounts())
            {
                if(numOfCont > 0)
                {
                    testContacts.addAll(createTestChildContacts(currAcc, numOfCont));
                }    
                numOfCont ++;
            }
            
            //albania accounts with contacts
            numOfCont = 0;
            for(Account currAcc: getAlbaniaAccounts())
            {
               if(numOfCont > 0)
                {
                    testContacts.addAll(createTestChildContacts(currAcc, numOfCont));
                }    
                numOfCont ++;
            }   
        
            //insert test Contacts         
            insert testContacts;
            
            //add profiles to test contacts
            activateContacts();  
            
            //run test
            Test.startTest(); 
            
            String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute()); String ss = String.valueOf(Datetime.now().second());
            String triggerNow = ss + ' ' + min + ' ' + hour + ' * * ?';

            String jobId = System.schedule('TFXMigration_CheckAccountsTest', triggerNow, new TFXMigration_CheckAccountsScedulable() );
            CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(triggerNow, ct.CronExpression); 
            TFXMigration_CheckParentAccScedulable s = new TFXMigration_CheckParentAccScedulable();
            s.execute(null) ;
            Test.stopTest(); 
        }
        
        //create France Account
        private static List<Account> getFranceAccounts()
        {
            List<Account> testAccts = New List<Account>();
     
            Account testAcc1 = TST_AccountTestHelper.createDummyAccount('France', FALSE);
            testAcc1.TFX_Migration_DATE__c = system.today().addDays(1);
            testAcc1.TFX_Migration_PackageName__c = 'FX_Start';
            testAccts.Add(testAcc1);
            
            Account testAcc2 = TST_AccountTestHelper.createDummyAccount('France', FALSE);
            testAcc2.TFX_Migration_DATE__c = system.today().addDays(1);
            testAcc2.TFX_Migration_PackageName__c = 'FX_Standard';
            testAccts.Add(testAcc2);            
            
            Account testAcc3 = TST_AccountTestHelper.createDummyAccount('France', FALSE);
            testAcc3.TFX_Migration_DATE__c = system.today().addDays(1);
            testAcc3.TFX_Migration_PackageName__c = 'FX_Business';
            testAccts.Add(testAcc3);            

            Account testAcc4 = TST_AccountTestHelper.createDummyAccount('France', FALSE);
            testAcc4.TFX_Migration_DATE__c = system.today().addDays(1);
            testAcc4.TFX_Migration_PackageName__c = 'Business_Plus';
            testAccts.Add(testAcc4);            
            
            Account testAcc5 = TST_AccountTestHelper.createDummyAccount('France', FALSE);
            testAcc5.TFX_Migration_DATE__c = system.today().addDays(11);
            testAcc5.TFX_Migration_PackageName__c = 'FX_One_To_One';
            testAccts.Add(testAcc5);            

            Account testAcc6 = TST_AccountTestHelper.createDummyAccount('France', FALSE);
            testAcc6.TFX_Migration_DATE__c = system.today().addDays(1);
            testAcc6.TFX_Migration_PackageName__c = 'FX_One_To_One';
            testAccts.Add(testAcc6);  
            
            insert testAccts;
            testAccts = [SELECT Id, 
                                TFX_Migration_DATE__c, 
                                TFX_Migration_PackageName__c,
                                TFX_Migration_Status__c
                           FROM Account WHERE BillingCountry = 'France'];
            return testAccts;
            return testAccts;
        }
        
        //create Albania accounts
        private static List<Account> getAlbaniaAccounts()
        {
            List<Account> testAccts = New List<Account>();
     
            Account testAcc1 = TST_AccountTestHelper.createDummyAccount('Albania', FALSE);
            testAcc1.TFX_Migration_DATE__c = system.today().addDays(1);
            testAcc1.TFX_Migration_PackageName__c = 'FX_Start';
            testAccts.Add(testAcc1);
            
            Account testAcc2 = TST_AccountTestHelper.createDummyAccount('Albania', FALSE);
            testAcc2.TFX_Migration_DATE__c = system.today().addDays(1);
            testAcc2.TFX_Migration_PackageName__c = 'FX_Standard';
            testAccts.Add(testAcc2);            
            
            Account testAcc3 = TST_AccountTestHelper.createDummyAccount('Albania', FALSE);
            testAcc3.TFX_Migration_DATE__c = system.today().addDays(1);
            testAcc3.TFX_Migration_PackageName__c = 'FX_Business';
            testAccts.Add(testAcc3);            

            Account testAcc4 = TST_AccountTestHelper.createDummyAccount('Albania', FALSE);
            testAcc4.TFX_Migration_DATE__c = system.today().addDays(1);
            testAcc4.TFX_Migration_PackageName__c = 'Business_Plus';
            testAccts.Add(testAcc4);            
            
            Account testAcc5 = TST_AccountTestHelper.createDummyAccount('Albania', FALSE);
            testAcc5.TFX_Migration_DATE__c = system.today().addDays(1);
            testAcc5.TFX_Migration_PackageName__c = 'FX_One_To_One';
            testAccts.Add(testAcc5);            

            Account testAcc6 = TST_AccountTestHelper.createDummyAccount('Albania', FALSE);
            testAcc6.TFX_Migration_DATE__c = system.today().addDays(1);
            testAcc6.TFX_Migration_PackageName__c = 'FX_One_To_One';
            testAccts.Add(testAcc6);  
            
            insert testAccts;
            testAccts = [SELECT Id, 
                                TFX_Migration_DATE__c, 
                                TFX_Migration_PackageName__c,
                                TFX_Migration_Status__c
                           FROM Account WHERE BillingCountry = 'Albania'];
            return testAccts;
        }        
        
        //create related contacts
        private static List<Contact> createTestChildContacts (Account parentAcc, Integer numOf)
        {
            List<Contact> testConts = New List<Contact>();
            for(Integer i = 1; i < numOf; i++)
            {
                Contact testCont = TST_ContactTestHelper.createDummyContact(parentAcc, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), FALSE);
                testConts.Add(testCont);            
            }
            return testConts;
        }
        
        //add profiles to test contacts for contact status=Active
        private static void activateContacts()
        {
            List<Contact> testContacts = [SELECT Id, ESB_BuisnessID__c FROM Contact];
            List<User_Profile__c> testUserProfiles = New List<User_Profile__c>();
            Id profileRecordTypeId = Schema.getGlobalDescribe().get('User_Profile__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile').getRecordTypeId();
            for(Contact currCont : testContacts)
            {
                User_Profile__c up = new User_Profile__c();
                up.RecordTypeId    = profileRecordTypeId;
                up.Private_Exchange_ID__c = 'OPEN';
                up.Contact__c             = currCont.Id;
                up.Test_login__c          = false;
                up.User_PUG_Name__c       = 'FCUGABPSTD';
                up.Status__c              = 'Activated';
                testUserProfiles.add(up);
                currCont.ESB_BuisnessID__c = 'U-123qwe1234';
            }
            
            upsert testContacts;
            insert testUserProfiles; 
        } 
        
    }//end class