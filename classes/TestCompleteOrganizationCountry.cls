@isTest
public class TestCompleteOrganizationCountry 
{
    static testMethod void TestCompleteOrganizationCountry_Trigger() 
    {
    //prepare Data
    TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
    List<Account> accounts = TST_AccountTestHelper.createDummyAccountList(10,false);
    test.startTest();
    insert accounts;
    
    // Thomas: pragmatique
    Test.stopTest();
    
    /*List<Account> insertedAccounts = [SELECT Id, Name,BillingCountry,Organization_Country__c, Organization__c, RecordTypeId 
                                      FROM Account
                                      WHERE Id IN :accounts];
                                      
    for(Account a : insertedAccounts){
      System.assertEquals('France',a.Organization_Country__c);
      System.assertEquals('France -> France International -> West',a.Organization__c);
    }
    accounts.clear();
    Account a2 = new Account(Name = 'Test Account 20', BillingStreet='', BillingCity='', BillingState='', BillingPostalCode='',BillingCountry='',RecordTypeId=recordTypeId);
    accounts.add(a2);
    try {
         insert accounts;
        } catch (DmlException e) {
            Boolean Flag=e.getMessage().contains('The Billing Address is mandatory');
            System.assertEquals(true,Flag);
        }
    accounts.clear();
    Account a3 = new Account(Name = 'Test Account 30', BillingStreet='12 rue de la pointe', BillingCity='Seclin', BillingState='Nord-pas-de-Calais', BillingPostalCode='59113', BillingCountry='Chile',RecordTypeId=recordTypeId);
    accounts.add(a3);
    try {
         insert accounts;
        } catch (DmlException e) {
            Boolean Flag=e.getMessage().contains('not in teleroute list of countries');
            System.assertEquals(true,Flag);
        }
    accounts.clear();
    Account a4 = new Account(Name = 'Test Account 40', BillingStreet='12 rue de la pointe', BillingCity='Seclin', BillingState='Nord-pas-de-Calais', BillingPostalCode='59113', Organization_Country__c='',BillingCountry='France');
    accounts.add(a4);
    insert accounts;
    List<Account> insertedAccounts3 = [SELECT Id, Name,BillingCountry,Organization_Country__c, Organization__c, RecordTypeId 
                                      FROM Account
                                      WHERE Id IN :accounts];
                                      
    for(Account a : insertedAccounts3){
    System.assertEquals('France',a.Organization_Country__c);
    }
    accounts.clear();
    Account a5 = new Account(Name = 'Test Account 50', BillingStreet='12 rue de la pointe', BillingCity='Seclin', BillingState='Nord-pas-de-Calais', BillingPostalCode='59113', Organization__c='', Organization_Country__c='Chile',BillingCountry='France');
    accounts.add(a5);
    try {
         insert accounts;
        } catch (DmlException e) {
            Boolean Flag=e.getMessage().contains('not in teleroute list of countries');
            System.assertEquals(true,Flag);
        }*/
    accounts.clear();
    Account a6 = TST_AccountTestHelper.createDummyAccount(false);
    accounts.add(a6);
    insert accounts;
    List<Account> insertedAccounts6 = [SELECT Id, Name,Account_Life_Cycle__c, Level_of_Certification__c, ABC_Segmentation_Date__c, SML_Segmentation_Date__c , BillingCountry,Organization_Country__c, Organization__c, RecordTypeId 
                                      FROM Account
                                      WHERE Id IN :accounts];
                                      
    for(Account a : insertedAccounts6){
    Date myDate = Date.today();
   // System.assertEquals(myDate,a.SML_Segmentation_Date__c);
   // System.assertEquals(myDate,a.ABC_Segmentation_Date__c);
    Date myDate1=myDate.addDays(-1);
    a.SML_Segmentation_Date__c=myDate1;
    a.ABC_Segmentation_Date__c=myDate1;
    a.Account_Life_Cycle__c='New Customer';
    }
    update insertedAccounts6;
    List<Account> updatedAccounts = [SELECT Id, Name,Account_Life_Cycle__c, Level_of_Certification__c , ABC_Segmentation_Date__c, SML_Segmentation_Date__c, RecordTypeId 
                                      FROM Account
                                      WHERE Id IN :insertedAccounts6];
    for(Account a : updatedAccounts ){
    String LevelCert='2';
    System.assertEquals('New Customer',a.Account_Life_Cycle__c);
    System.assertEquals(LevelCert,a.Level_of_Certification__c);
    }  
  }
}