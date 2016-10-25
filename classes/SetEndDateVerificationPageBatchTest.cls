/**
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         2016 April 6
* @description  Test class for SetEndDateVerificationPageBatch
**/
@isTest
public class SetEndDateVerificationPageBatchTest 
{
    private static List<Verification_Page__c> vps = new List<Verification_Page__c>();
    private static Verification_Page__c vp;
    private static SetEndDateVerificationPageBatch batch = new SetEndDateVerificationPageBatch();
    private static integer testRecordsNumber = 20;

    public static testMethod void testPositive()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        TST_VerificationPageTestHelper.CreateDummyVerificationPageList(testRecordsNumber,Date.today(), Date.today(),true, true);
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        validateChangedData('Expired',20);
    }
    
    public static testMethod void testNegative_Date()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        TST_VerificationPageTestHelper.CreateDummyVerificationPageList(testRecordsNumber,Date.today(), Date.today()+1,true, true);
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        validateChangedData('Active',20);
    }

    public static testMethod void testNegative_ICC()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        vps = TST_VerificationPageTestHelper.CreateDummyVerificationPageList(testRecordsNumber,Date.today(), Date.today(),false, true);
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        validateChangedData('Inactive',400);
    }   
    
    private static void validateChangedData(string ICC, integer expectedNumber)
    {
        vps = [select Id, Active_End_Date__c, Integrity_Check_Completed__c from Verification_Page__c where Integrity_Check_Completed__c =: ICC];
        system.assert(vps.size() == expectedNumber, 'Data hasn\'t been correctly updated');
    }
}