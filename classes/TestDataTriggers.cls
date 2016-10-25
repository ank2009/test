@isTest
public class TestDataTriggers
{
    
    public static Account createTestAccounts() 
    {
        Account accnt                   = new Account();
        accnt.Phone                     = '+33 123456789';
        accnt.ParentId                  = null;
        accnt.Name                      = 'Test Account';
        accnt.Fax                       = '+33 123456789';
        accnt.Activation_Date__c        = Datetime.now();
        accnt.Deactivation_Date__c      = null;
        accnt.BillingStreet             = 'Rue de la pointe';
        accnt.BillingState              = 'Nord';
        accnt.BillingCountry            = 'Belgium';
        accnt.Organization_Country__c   = accnt.BillingCountry;
        accnt.BillingPostalCode         = '59113';
        accnt.BillingCity               = 'Seclin';
        accnt.Account_Level__c          = 'Company';
        accnt.Level_of_Certification__c = '2';
        
        
        insert accnt;
        
        return accnt;
    }
    
    public static Account createTestAccountsWithHierarchy(ID accParentID) 
    {
        Account accnt                   = new Account();
        accnt.Phone                     = '+33 123456789';
        accnt.ParentId                  = accParentID;
        accnt.Name                      = 'Test Account 1';
        accnt.Fax                       = '+33 123456789';
        accnt.Activation_Date__c        = Datetime.now();
        accnt.Deactivation_Date__c      = null;
        accnt.BillingStreet             = 'Rue de la pointe';
        accnt.BillingState              = 'Nord';
        accnt.BillingCountry            = 'Belgium';
        accnt.Organization_Country__c   = accnt.BillingCountry;
        accnt.BillingPostalCode         = '59113';
        accnt.BillingCity               = 'Seclin';
        accnt.Account_Level__c          = 'Site';
        accnt.Level_of_Certification__c = '2';
       
        
        insert accnt;
        
        return accnt;
    }
    
}