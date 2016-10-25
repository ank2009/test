/**
 * @author Abdelali KARIM 
 * @date 10/08/2012
 * @description Test KeyAccountFlagsWithHierarchy functional
 *
 * 2015 March 25 aleh_tsilko@epam.com
 * added check results
 */
@isTest
public class KeyAccountFlagsWithHierarchyTest {

    public static testMethod void testTrigger() 
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account Parentacc = TST_AccountTestHelper.createDummyAccount('France',true);
        Account account=[SELECT Id, parentID,  BillingCountry , International_Key_Account__c, National_Key_Account__c
                        FROM  Account where Id =: Parentacc.Id];
        Account acc = TestDataTriggers.createTestAccountsWithHierarchy(account.Id);
        account.International_Key_Account__c=true;
        account.National_Key_Account__c = true;
        update account;
        system.assertEquals([SELECT Id FROM Account WHERE International_Key_Account__c = TRUE AND National_Key_Account__c = TRUE].Size(), 2);
    }

}