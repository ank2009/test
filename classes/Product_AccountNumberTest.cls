/*
* Test for Account Debtor Number Management
* Author: aleh_tsilko@epam.com
*/
@isTest 
private class Product_AccountNumberTest {
    public static testMethod void checkAccDbNm(){
        //prepare test data
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});        
        List<Account> TWDaccList = TST_AccountTestHelper.createDummyAccountList(5, 'France', true);
        List<Account> TASaccList = TST_AccountTestHelper.createDummyAccountList(5, 'Belgium', true);          
        test.startTest();
            Product_AccountNumberHelper.getAccountNumbers(TWDaccList,TASaccList);
        test.stopTest();            
        List<Debtor_Number_Products__c> prodNums = New List<Debtor_Number_Products__c>([SELECT Name, Current_Number__c FROM Debtor_Number_Products__c ]);
        for(Debtor_Number_Products__c currNum: prodNums){
            System.assertEquals(CurrNum.Current_Number__c,6); //6=Current 1 + 5 New accounts
        }        
    }
    
}//end class