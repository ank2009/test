@isTest
public class UpdateContactProvisioningMessageTest
{
    public static testMethod void testTrigger() 
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount(true);
        Contact c = TST_ContactTestHelper.createDummyContact(a, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        
        c.FirstName = 'Updated';
        update c;
    }
}