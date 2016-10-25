/**
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         2016 April 6
* @description  This class is intended to facilitate creating and populating dummy Verification_Page__c for unit testing.
**/
@isTest
public class TST_VerificationPageTestHelper 
{
	public static List<Verification_Page__c> CreateDummyVerificationPageList(integer pagesNumber,Date activeStartDate, Date activeEndDate, boolean haveAcitveVP, boolean insertNow)
    {
        List<Verification_Page__c> vps = new List<Verification_Page__c>();
        List<Account> accounts;
        TST_AccountTestHelper.createDummyAccountList(pagesNumber,true);
        accounts = [select Id from Account];
        for(Account acc : accounts)
        {
            for(integer i = 0; i < pagesNumber; i++)
            {
                Verification_Page__c vp = new Verification_Page__c();
                if(activeEndDate != null)
                {
                    
                    vp.Active_End_Date__c = activeEndDate;
                }
                if(activeStartDate != null)
                {
                    vp.Active_Start_Date__c = activeStartDate;
                }
                vp.Integrity_Check_Status__c = 'Full Access';
                vp.Account__c = acc.Id;
                vp.Integrity_Check_Completed__c = haveAcitveVP ? (i == 0 ? 'Active' : 'Inactive') : 'Inactive';
                vps.add(vp);
            }
        }
        if(insertNow)
        {
            insert vps;
        }
        return vps;
    }
    
    public static Verification_Page__c CreateDummyVerificationPage(string IntegrityCheckCompleted, string IntegrityCheckStatus, boolean insertNow)
    {
        Account account = TST_AccountTestHelper.createDummyAccount('Belgium', true);
        Verification_Page__c vp = new Verification_Page__c();
        vp.Integrity_Check_Status__c = String.isBlank(IntegrityCheckStatus) ? 'Full Access' : IntegrityCheckStatus;
        vp.Account__c = account.Id;
        vp.Integrity_Check_Completed__c = String.isBlank(IntegrityCheckCompleted) ? 'Active' : IntegrityCheckCompleted;
        if(insertNow)
        {
            insert vp;
        }
        return vp;
    }
}