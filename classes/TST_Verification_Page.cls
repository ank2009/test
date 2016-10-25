/**
* @author       Andrey Gordienko (andrey_gordienko@epam.com)
* @date         2016 April 16
* @description  Test class for Verification Page object
**/
@isTest
public class TST_Verification_Page 
{
    public static testMethod void ChecksDoneByMethod_FirstCheck()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        TST_VerificationPageTestHelper.CreateDummyVerificationPage(null,null,true);
        Verification_Page__c verPage = [Select ID, CreatedDate , Checks_done_by__c From Verification_Page__c Limit 1];
        String desiredResult = Userinfo.getName() + ', ' +  Datetime.valueOf(verPage.CreatedDate).format('dd/MM/yyyy hh:mm a'); 
        system.assertEquals(desiredResult, verPage.Checks_done_by__c, 'Method "ChecksDoneBy" from TRIG_VerificationPageTriggerHandler working not correctly. Test Method - ChecksDoneByMethod_FirstCheck');
    }
    
    public static testMethod void ChecksDoneByMethod_SecondCheck()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        TST_VerificationPageTestHelper.CreateDummyVerificationPage('Inactive','Open',true);
        Verification_Page__c verPage = [Select ID, CreatedDate,Integrity_Check_Status__c, Checks_done_by__c From Verification_Page__c Limit 1];
        String desiredResult = Userinfo.getName() + ', ' +  Datetime.valueOf(verPage.CreatedDate).format('dd/MM/yyyy hh:mm a'); 
        system.assertNotEquals(desiredResult, verPage.Checks_done_by__c, 'Method "ChecksDoneBy" from TRIG_VerificationPageTriggerHandler working not correctly. Test Method - ChecksDoneByMethod_SecondCheck, first assert');
        verPage.Integrity_Check_Status__c = 'Full Access';
        update verPage;
        verPage = [Select ID, LastModifiedDate,Integrity_Check_Status__c, Checks_done_by__c From Verification_Page__c Limit 1];
        desiredResult = Userinfo.getName() + ', ' +  Datetime.valueOf(verPage.LastModifiedDate).format('dd/MM/yyyy hh:mm a'); 
        system.assertEquals(desiredResult, verPage.Checks_done_by__c, 'Method "ChecksDoneBy" from TRIG_VerificationPageTriggerHandler working not correctly. Test Method - ChecksDoneByMethod_SecondCheck, second assert');  
    }
    
    public static testMethod void SetStateOfVereficationPagesForAccount_ForOneAccount()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Verification_Page__c verPage = TST_VerificationPageTestHelper.CreateDummyVerificationPage(null,null,true);
        Account acc = [Select ID, Has_Active_Verification_Page__c From Account Limit 1];
        System.assert(acc.Has_Active_Verification_Page__c, 'Method SetStateOfVereficationPagesForAccount working not correctly.Test Method - SetStateOfVereficationPagesForAccount_ForOneAccount, first check');
        verPage.Integrity_Check_Completed__c = 'Expired';
        update verPage;
        acc = [Select ID, Has_Active_Verification_Page__c From Account Limit 1];
        System.assert(!acc.Has_Active_Verification_Page__c, 'Method SetStateOfVereficationPagesForAccount working not correctly.Test Method - SetStateOfVereficationPagesForAccount_ForOneAccount, second check');
        verPage.Integrity_Check_Completed__c = 'Active';
        update verPage;
        delete verPage;
        acc = [Select ID, Has_Active_Verification_Page__c From Account Limit 1];
        System.assert(!acc.Has_Active_Verification_Page__c, 'Method SetStateOfVereficationPagesForAccount working not correctly.Test Method - SetStateOfVereficationPagesForAccount_ForOneAccount, third check');
    }
    
    public static testMethod void SetStateOfVereficationPagesForAccount_ForListOfAccount()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        List<Verification_Page__c> verPages = TST_VerificationPageTestHelper.CreateDummyVerificationPageList(4, null,null, true, true);
        List<Account> accs = [Select Id, Has_Active_Verification_Page__c From Account];
        for(Account acc : accs)
        {
            system.assert(acc.Has_Active_Verification_Page__c, 'Method SetStateOfVereficationPagesForAccount working not correctly.Test Method - SetStateOfVereficationPagesForAccount_ForListOfAccount, first check');
        }
        Verification_Page__c verPage = [Select Id, Integrity_Check_Completed__c From Verification_Page__c Where Integrity_Check_Completed__c = 'Active' Limit 1];
        verPage.Integrity_Check_Completed__c = 'Expired';
        update verPage;
        accs = [Select Id, Has_Active_Verification_Page__c From Account Where Has_Active_Verification_Page__c = false];
        system.assertEquals(1, accs.size(), 'Method SetStateOfVereficationPagesForAccount working not correctly.Test Method - SetStateOfVereficationPagesForAccount_ForListOfAccount, second check');
        accs = [Select Id, Has_Active_Verification_Page__c From Account Where Has_Active_Verification_Page__c = true];
        verPages = [Select Id, Integrity_Check_Completed__c From Verification_Page__c Where Account__c =: accs[0].Id];
        delete verPages;
        accs = [Select Id, Has_Active_Verification_Page__c From Account Where Has_Active_Verification_Page__c = false];
        system.assertEquals(2, accs.size(), 'Method SetStateOfVereficationPagesForAccount working not correctly.Test Method - SetStateOfVereficationPagesForAccount_ForListOfAccount, third check');
        verPages = [Select Id, Integrity_Check_Completed__c From Verification_Page__c];
        delete verPages;
        accs = [Select Id, Has_Active_Verification_Page__c From Account];
        for(Account acc : accs)
        {
            system.assert(!acc.Has_Active_Verification_Page__c, 'Method SetStateOfVereficationPagesForAccount working not correctly.Test Method - SetStateOfVereficationPagesForAccount_ForListOfAccount, fourth check');
        }
    }
    
    public static testMethod void LockUnlockRecord()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Verification_Page__c verPage = TST_VerificationPageTestHelper.CreateDummyVerificationPage('Inactive',null,true);
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='TLR Service']; 
        User user = new User(Alias = 'testUsr1', 
                             Username = 'testUsr1@test.ww',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles');
        boolean isError = false;
        system.runAs(user)
        {
            try
            {
                update verPage;
            }
            catch(Exception ex)
            {
                isError = true;
            }
        }
        system.assert(!isError, 'Method LockUnlockRecord working not correctly. Record did not locked. Test Method - SetStateOfVereficationPagesForAccount_ForListOfAccount, first check');
        verPage.Integrity_Check_Completed__c = 'Active';
        update verPage;
        isError = false;
        system.runAs(user)
        {
            try
            {
                update verPage;
            }
            catch(Exception ex)
            {
                isError = true;
            }
        }
        system.assert(isError, 'Method LockUnlockRecord working not correctly. Record must be locked. Test Method - SetStateOfVereficationPagesForAccount_ForListOfAccount, second check');
    }
    
    
    public static testMethod void CheckWorkflowSetStartAndEndDate()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Verification_Page__c verPage = TST_VerificationPageTestHelper.CreateDummyVerificationPage('Inactive',null,true);
        Date targetStartDate = Date.newInstance(2019, 5, 5);
        Date targetEndDate = Date.newInstance(2019, 6, 6);
        verPage.Active_Start_Date__c = targetStartDate;
        verPage.Active_End_Date__c = targetEndDate;
        verPage.Integrity_Check_Completed__c = 'Active';
        update verPage;
        verPage = [Select Id, Active_Start_Date__c, Active_End_Date__c From Verification_Page__c];
        system.assertEquals(targetStartDate,verPage.Active_Start_Date__c, 'Workflow SetStartAndEndDate working not correctly. Active_End_Date__c must be equals to 5/5/2019. Test Method - CheckWorkflowSetStartAndEndDate, seventh check');
        system.assertEquals(targetEndDate,verPage.Active_End_Date__c, 'Workflow SetStartAndEndDate working not correctly. Active_End_Date__c must be equals to 6/6/2019. Test Method - CheckWorkflowSetStartAndEndDate, eighth check');
        delete verPage; 
    }

    public static testMethod void CheckValidationRules()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Verification_Page__c verPage = TST_VerificationPageTestHelper.CreateDummyVerificationPage('Active',null,true);
        verPage.Active_Start_Date__c = Date.today();
        verPage.Active_End_Date__c = Date.newInstance(2005, 1, 1);
        boolean isError = false;
        try
        {
           update verPage;
        }
        catch(Exception ex)
        {
            isError = true;
        }
        System.assert(isError, 'End Date must be more than Start Date! Please, check the validation rule');
        
        verPage.Integrity_Check_Status__c = 'Open';
        isError = false;
        try
        {
           update verPage;
        }
        catch(Exception ex)
        {
            isError = true;
        }
        System.assert(isError, 'Integrity Check Completed field can be equals to \'Active\' only if Integrity Check Status not equals to \'Open\'! Please, check the validation rule');
        
        Account acc = [Select Id From Account limit 1];
        Verification_Page__c newVP = new Verification_Page__c();
        newVP.Integrity_Check_Status__c = 'Full Access';
        newVP.Integrity_Check_Completed__c = 'Active';
        newVP.Account__c = acc.Id;
        isError = false;
        try
        {
            insert newVP;
        }
        catch(Exception ex)
        {
            isError = true;
        }
        System.assert(isError, 'Account can\'t have more than one \'Active\' Verification Page! Please, check the validation rule');
        
    }
}