/**
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         2016 April 12
* @description  Schedulable Batch process for checking National_Key_Account__c and International_Key_Account__c in hierarchy
**/
@isTest
public class CheckKeyAccountsForHierarchyBatchTest 
{
    public static testmethod void test1()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        List<Account> accs = TST_AccountTestHelper.createDummyAccountList(5, 'Belgium', true);
        accs[0].International_Key_Account__c = true;
        accs[1].ParentId = accs[0].Id;
        accs[2].ParentId = accs[0].Id;
        accs[3].National_Key_Account__c = true;
        accs[4].ParentId = accs[3].Id;
        update accs;        
        
        CheckKeyAccountsForHierarchyBatch batch = new CheckKeyAccountsForHierarchyBatch();
        Test.startTest();
	    Database.executeBatch(batch);
        Test.stopTest();
        
        system.assert(CheckKeyAccountsForHierarchyBatch.accHierMapForTest.get(accs[0].Id).children.size() == 2,'Incorrect children number for parentAcc1');
        system.assert(CheckKeyAccountsForHierarchyBatch.accHierMapForTest.get(accs[3].Id).children.size() == 1,'Incorrect children number for parentAcc2');
    }
    
    
    public static testmethod void test2()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		List<Account> accs = TST_AccountTestHelper.createDummyAccountList(5, 'Belgium', true);
        accs[0].International_Key_Account__c = true;
        accs[1].ParentId = accs[0].Id;
        accs[2].ParentId = accs[1].Id;
        accs[3].National_Key_Account__c = true;
        accs[4].ParentId = accs[3].Id;
		accs[4].National_Key_Account__c = true;
        update accs; 
        
        CheckKeyAccountsForHierarchyBatch batch = new CheckKeyAccountsForHierarchyBatch();
        Test.startTest();
	    Database.executeBatch(batch);
        Test.stopTest();
        
        system.assert(CheckKeyAccountsForHierarchyBatch.accHierMapForTest.get(accs[0].Id).children.size() == 2,'Incorrect children number for parentAcc1');
        system.assert(CheckKeyAccountsForHierarchyBatch.accHierMapForTest.get(accs[3].Id) == null,'parentAcc2 must not be selected');
        
    }

	public static testmethod void test3()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		List<Account> accs = TST_AccountTestHelper.createDummyAccountList(5, 'Belgium', true);
        accs[0].International_Key_Account__c = true;
        accs[1].ParentId = accs[0].Id;
        accs[2].ParentId = accs[1].Id;
		accs[2].International_Key_Account__c = true;
        accs[4].ParentId = accs[3].Id;
        update accs;     
        
        CheckKeyAccountsForHierarchyBatch batch = new CheckKeyAccountsForHierarchyBatch();        
        Test.startTest();
	    Database.executeBatch(batch);
        Test.stopTest();
        
        system.assert(CheckKeyAccountsForHierarchyBatch.accHierMapForTest.get( accs[0].Id).children.size() == 1,'Incorrect children number for parentAcc1');
        system.assert(CheckKeyAccountsForHierarchyBatch.accHierMapForTest.get( accs[3].Id) == null,'parentAcc2 must not be selected');
    }
        
    public static testmethod void test4()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		List<Account> accs = TST_AccountTestHelper.createDummyAccountList(4, 'Belgium', true);
        accs[0].International_Key_Account__c = true;
        accs[1].ParentId = accs[0].Id;
        accs[2].ParentId = accs[1].Id;
		accs[2].International_Key_Account__c = true;
        update accs;    
        
        CheckKeyAccountsForHierarchyBatch batch = new CheckKeyAccountsForHierarchyBatch();
        Test.startTest();
	    Database.executeBatch(batch);
        Test.stopTest();
        
        system.assert(CheckKeyAccountsForHierarchyBatch.accHierMapForTest.get( accs[0].Id).children.size() == 1,'Incorrect children number for parentAcc1');
        system.assert(CheckKeyAccountsForHierarchyBatch.accHierMapForTest.get( accs[3].Id) == null,'parentAcc2 must not be selected');
    }
}