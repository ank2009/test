/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2015 January 26
* @description  tests for Contact triggers, validation rules, workflows
*/
@isTest
public class TST_Contact_Tests 
{
	/** 
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2015 January 26
	* @description  test to cover clone contact trigger part
					it needs to clone all information except of following fields:
					ESB_User_status__c, ESB_BuisnessID__c
	*/
	public static testMethod void CloneTest()
	{
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
		Contact c = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TWD Contact'), false);
		
        c.ESB_BuisnessID__c = 'U-qqqwww';
		c.ESB_User_status__c = 'CREATED';
        insert c;
        
        // 0 check - values are set properly when inserting
		c = getContactById(c.Id);
		system.debug('---------- contact clonned_flag: ' + c.ClonnedFlag__c);
		system.AssertEquals('CREATED', c.ESB_User_status__c, 'Inserted ESB user status is not saved!');
		system.AssertEquals('U-qqqwww', c.ESB_BuisnessID__c, 'Inserted ESB business ID is not saved!');
		
		c.ESB_BuisnessID__c = 'U-123qwe';
		c.ESB_User_status__c = 'READY';
		update c;
		
		// 1st check - values are set properly when updating
		c = getContactById(c.Id);
		system.AssertEquals('READY', c.ESB_User_status__c, 'Updated ESB user status is not saved!');
		system.AssertEquals('U-123qwe', c.ESB_BuisnessID__c, 'Updated ESB business ID is not saved!');
		
		
		// clone contact
		Contact c1 = c.clone(); // actually 'clone' button works not like .clone() method. so test is not 100% accurate
		insert c1;
				
		c1 = getContactById(c1.Id);
		// 2nd check - 
		system.Assert(string.isEmpty(c1.ESB_User_status__c), 'Clonned ESB user status should be empty!');
		system.Assert(string.isEmpty(c1.ESB_BuisnessID__c), 'Clonned ESB business ID should be empty!');
	} //CloneTest
    
    
    public static testMethod void changeLanguageTestTest()
    {   //prepare test data
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
        Contact cont1 = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TWD Contact'), false);
        Contact cont2 = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TWD Contact'), false);
        Contact cont3 = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TWD Contact'), false);
        List<Contact> testContacts = New List<Contact>{Cont1,Cont2,Cont3};
        insert testContacts;
        testContacts = [SELECT Id, Language__c FROM Contact];
        
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='DMS Community User']; 
        User usr1 = New User(Alias = 'testUsr1', 
                             Username = 'testUsr1@test.ww',
                             CommunityNickname = 'testUsr1',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles',
                             ContactId = testContacts[0].Id);                                                                  
        User usr2 = New User(Alias = 'testUsr2', 
                             Username = 'testUsr2@test.ww',
                             CommunityNickname = 'testUsr2',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr2@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles',
                             ContactId = testContacts[1].Id);                                               
        User usr3 = New User(Alias = 'testUsr3', 
                             Username = 'testUsr3@test.ww',
                             CommunityNickname = 'testUsr3',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr3@test.ww',
                             EmailEncodingKey = 'UTF-8',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             ContactId = testContacts[2].Id);  
        List<User> testUsers = new List<User>{usr1, usr2, usr3}; 
            insert testUsers;
        
        //test of update Users from Contacts
        List<Contact> forUpsert = New List<Contact>();                               
        testContacts[0].Language__c = 'English';//was not change
        
        System.runAs(usr2)
        {
            testContacts[1].Language__c = 'French';//changed
            forUpsert.add(testContacts[1]);
            upsert forUpsert;
            forUpsert.clear();
        }    
        System.runAs(usr3)    
        {
            testContacts[2].Language__c = 'Russian';//changed
            forUpsert.add(testContacts[2]);
            upsert forUpsert;
        }
        
        //check results
        testUsers = [SELECT Id, LanguageLocaleKey FROM User WHERE Profile.Id IN:TLR_UserLanguageHelper.COMMUNITY_PROFILE_IDS ];
        Set<String>usrLocales = New Set<String>();
        for(User currUsr: testUsers)
        {
            usrLocales.add(currUsr.LanguageLocaleKey);
        }
        System.assert(usrLocales.contains('en_US'));//testUser1 language was not changed
        System.assert(usrLocales.contains('fr'));//testUser2 language was change to French
        System.assert(usrLocales.contains('ru'));//testUser3 language was change to Russian     
        
        //test of update Contacts from Users 
        usr2.LanguageLocaleKey = 'en_US';//change back
        usr3.LanguageLocaleKey = 'en_US';//change back 
        System.runAs(usr2)
        {
            update usr2;
        }
        System.runAs(usr3)
        {
            update usr3;
        }
        usrLocales.Clear();               
        testContacts = [SELECT Id, Language__c FROM Contact];
        for(Contact currCon: testContacts)
        {
            usrLocales.add(currCon.Language__c);
        }
        System.assert(usrLocales.contains('English'));//testUser1 language was not changed
        System.assert(!usrLocales.contains('French'));//testUser2 language was change to English
        System.assert(!usrLocales.contains('Russian'));//testUser3 language was change to English
    } //changeLanguageTestTest
    
    public static testMethod void PhoneValidationTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
		Contact c = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TWD Contact'), true);
        
        string nbr = '';
        
        // case 1: correct phone
        c.Fax = '+32 123 4567';
        c.Phone = c.MobilePhone = c.Fax;
        try { update c; }
        catch(Exception ex) { system.assert(true, 'This update should be successful! (case 1)'); }
        
        
        // case 2: correct phone format, but wrong country code
        nbr = '+99 123 4567';
        c.Fax = nbr;
        try { update c; system.assert(true, 'This Fax update should not be successful! (case 2)'); }
        catch(Exception ex) {  }
        c.Phone = nbr;
        try { update c; system.assert(true, 'This Phone update should not be successful! (case 2)'); }
        catch(Exception ex) {  }
        c.MobilePhone = nbr;
        try { update c; system.assert(true, 'This MobilePhone update should not be successful! (case 2)'); }
        catch(Exception ex) {  }
        
        // case 3: incorrect phone format: without spaces
        nbr = '+321234567';
        c.Fax = nbr;
        try { update c; system.assert(true, 'This Fax update should not be successful! (case 3)'); }
        catch(Exception ex) {  }
        c.Phone = nbr;
        try { update c; system.assert(true, 'This Phone update should not be successful! (case 3)'); }
        catch(Exception ex) {  }
        c.MobilePhone = nbr;
        try { update c; system.assert(true, 'This MobilePhone update should not be successful! (case 3)'); }
        catch(Exception ex) {  }
        
        // case 4: incorrect phone format: too many spaces
        nbr = '+32 123 45 67';
        c.Fax = nbr;
        try { update c; system.assert(true, 'This Fax update should not be successful! (case 4)'); }
        catch(Exception ex) {  }
        c.Phone = nbr;
        try { update c; system.assert(true, 'This Phone update should not be successful! (case 4)'); }
        catch(Exception ex) {  }
        c.MobilePhone = nbr;
        try { update c; system.assert(true, 'This MobilePhone update should not be successful! (case 4)'); }
        catch(Exception ex) {  }
        
        // case 5: incorrect phone format: too long
        nbr = '+32 12345 67890123456789';
        c.Fax = nbr;
        try { update c; system.assert(true, 'This Fax update should not be successful! (case 5)'); }
        catch(Exception ex) {  }
        c.Phone = nbr;
        try { update c; system.assert(true, 'This Phone update should not be successful! (case 5)'); }
        catch(Exception ex) {  }
        c.MobilePhone = nbr;
        try { update c; system.assert(true, 'This MobilePhone update should not be successful! (case 5)'); }
        catch(Exception ex) {  }
        
        // case 6: incorrect phone format: no plus sign
        nbr = '32 123 4567';
        c.Fax = nbr;
        try { update c; system.assert(true, 'This Fax update should not be successful! (case 6)'); }
        catch(Exception ex) {  }
        c.Phone = nbr;
        try { update c; system.assert(true, 'This Phone update should not be successful! (case 6)'); }
        catch(Exception ex) {  }
        c.MobilePhone = nbr;
        try { update c; system.assert(true, 'This MobilePhone update should not be successful! (case 6)'); }
        catch(Exception ex) {  }
        
    } //PhoneValidationTest
    
    public static testMethod void ValidateLanguageTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
        Contact c = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TWD Contact'), false);
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'testUsr1', 
                             Username = 'testUsr1@test.ww',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles');       
        c.Language__c = 'EN';
        try
        {
            system.runAs(u)
            {
                insert c;
            }  
            system.assert(false,'Contact with the wrong Language was created');
        }
        catch(DmlException e)
        {
            system.debug('-------------------------'+e.getMessage());
        }
        c.Language__c = utilities.getPicklistValues('Contact', 'Language__c')[0];
        system.runAs(u)
        {
            insert c;
        }
        system.debug('-------------------------------Language = '+c.Language__c);
        delete c;
        c.Language__c = 'EN';
        c.Id = null;
        u = new User(Alias = 'testUsr1', 
                             Username = 'testUsr2@test.ww',
                             LastName = 'ESBTesting', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles');       
        system.runAs(u)
        {
            insert c;
        }
    }
    
    
    /* user and workflows are disabled
    public static testMethod void WorkflowContactsCreatedByTWATest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
		
        User u = [SELECT Id, Name FROM User WHERE Name='TWA Integration' LIMIT 1];
        
        // case 1: create contact as usual, no field updates should be in place
        Contact c1 = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TWD Contact'), false);
        c1.Contact_Type__c = 'Sales';
        insert c1;
        
        c1 = getContactById(c1.Id);
        system.assertNotEquals('Operations', c1.Contact_Type__c, 'Contact type contains wrong value! (case 1)');
        
        // case 2: create contact by TWA Integaration user, field update should work
        Contact c2;
        system.runAs(u)
        {
            c2 = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TWD Contact'), false);
            c2.Contact_Type__c = 'Sales';
            insert c2;
        }
        c2 = getContactById(c2.Id);
        system.assertEquals('Operations', c2.Contact_Type__c, 'Contact type contains wrong value! (case 2)');
        
        // case 3: the same as case 1 but fot UPDATE
        c1.Description += '1';
        update c1;
        system.assertNotEquals('Operations', c1.Contact_Type__c, 'Contact type contains wrong value! (case 3)');
        
        // case 4: the same as case 2 but fot UPDATE
        c2.Description += '1';
        c2.Contact_Type__c = 'Sales';
        update c2;
        system.assertEquals('Operations', c2.Contact_Type__c, 'Contact type contains wrong value! (case 4)');
        
    } //WorkflowContactsCreatedByTWATest
	*/
    
    public static testMethod void DisableUsernameEditingForESBValidationTest()
    {
        boolean isError;
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
        Contact testContact = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), false);
        testContact.Username__c = 'Contact1';
        insert testContact;
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User awlInterfaceESBUser = new User(Alias = 'testUsr1', 
                                            Username = 'testUsr1@test.ww',
                                            FirstName = 'AWL Interface',
                                            LastName = 'ESB', 
                                            LanguageLocaleKey = 'en_US', 
                                            LocaleSidKey = 'en_US', 
                                            ProfileId = commProfile.Id, 
                                            Email = 'testUsr1@test.ww',
                                            EmailEncodingKey = 'UTF-8',                                 
                                            TimeZoneSidKey = 'America/Los_Angeles'); 
        User ESBCmUser = new User(Alias = 'testUsr2', 
                                  Username = 'testUsr2@test.ww',
                                  FirstName = '',
                                  LastName = 'ESB CM', 
                                  LanguageLocaleKey = 'en_US', 
                                  LocaleSidKey = 'en_US', 
                                  ProfileId = commProfile.Id, 
                                  Email = 'testUsr2@test.ww',
                                  EmailEncodingKey = 'UTF-8',                                 
                                  TimeZoneSidKey = 'America/Los_Angeles');
        User ordinaryUser = new User(Alias = 'testUsr3', 
                                     Username = 'testUsr3@test.ww',
                                     FirstName = 'Qwer',
                                     LastName = 'Zxcv', 
                                     LanguageLocaleKey = 'en_US', 
                                     LocaleSidKey = 'en_US', 
                                     ProfileId = commProfile.Id, 
                                     Email = 'testUsr3@test.ww',
                                     EmailEncodingKey = 'UTF-8',                                 
                                     TimeZoneSidKey = 'America/Los_Angeles'); 
        insert awlInterfaceESBUser;
        insert ESBCmUser;
        insert ordinaryUser;       

        testContact.Username__c = 'Contact2';  
        isError = false;
        try
        {
            system.runAs(awlInterfaceESBUser)
            {
                update testContact;
            }
        }
        catch(Exception e)
        {
            isError = true;
        }
        system.assert( isError,'The User called AWL Interface ESB mustn\'t have ability to update the Username__c field');
        isError = false;  
        try
        {
            system.runAs(ESBCmUser)
            {
                update testContact;
            }
        }
        catch(Exception e)
        {
            isError = true;
        }
        system.assert( isError,'The User called ESB CM mustn\'t have ability to update the Username__c field');
        isError = false;  
        try
        {
            system.runAs(ordinaryUser)
            {
                update testContact;
            }
        }
        catch(Exception e)
        {
            isError = true;
        }
        system.assert(! isError,'The User with name not equals ESB CM or AWL Interface ESB must have ability to update the Username__c field.');
        testContact = [select Id, Username__c from Contact where Id =: testContact.Id];
        system.assertEquals('Contact2', testContact.Username__c,'Username__c must equal Contact2');         
        testContact.Username__c = '';
        update testContact;
        system.assertEquals('', testContact.Username__c,'Username__c must be blank');
        testContact.Username__c = 'Contact1';
        isError = false; 
        try
        {
            system.runAs(awlInterfaceESBUser)
            {
                update testContact;
            }
        }
        catch(Exception e)
        {
            isError = true;
        }
        system.assert(! isError,'The User called AWL Interface ESB must have ability to update the Username__c field if it is blank.');          
        testContact = [select Id, Username__c from Contact where Id =: testContact.Id];
        system.assertEquals('Contact1', testContact.Username__c,'Username__c must equal Contact1');
        testContact.Username__c = '';
        update testContact;
        system.assertEquals('', testContact.Username__c,'Username__c must be blank');
        testContact.Username__c = 'Contact2';
        isError = false;
        try
        {
            system.runAs(ESBCmUser)
            {
                update testContact;
            }
        }
        catch(Exception e)
        {
            isError = true;
        }
        system.assert(! isError,'The User called ESB CM must have ability to update the Username__c field if it is blank.');
        testContact = [select Id, Username__c from Contact where Id =: testContact.Id];
        system.assertEquals('Contact2', testContact.Username__c,'Username__c must equal Contact2');    
    } //DisableUsernameEditingForESBTest   
    
    private static Contact getContactById(Id cId)
    {
        return [
            SELECT 
            Id, Salutation, FirstName, LastName, Gender__c, Email, AccountId, RecordTypeId,
            Language__c, Phone, Fax, MobilePhone, 
            MailingCountry, MailingCity, MailingStreet, MailingPostalCode,
            ESB_User_status__c, ESB_BuisnessID__c,
            ClonnedFlag__c, Contact_Type__c
            FROM Contact
            WHERE Id = :cId
        ];
    }
}