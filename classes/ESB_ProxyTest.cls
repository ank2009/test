/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2014 November 24
* @description  unit tests for ESB Proxy class
*/
@isTest
private class ESB_ProxyTest 
{
    private static string xmlDateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss';
    private class TestData
    {
        public Account acc;
        public Contact cont;
        public Offer_template__c ot;
        public Opportunity opp;
        public Contract contr;
        public Subscription__c subs;
    }
    
    private static List<CtrlESBInteractionLogs.ESB_Parameter> parsedData;
    private static Map<string,CtrlESBInteractionLogs.ESB_Parameter> parsedDataMap;
    private static CtrlESBInteractionLogs.ESB_Parameter parsedParameter;
    
    public class EsbMock_assign_ok implements HttpCalloutMock 
	{
		public HTTPResponse respond(HTTPRequest req) 
		{
			Httpresponse resp = new Httpresponse();
			resp.SetStatusCode(200);
			return resp;
		}
	}
    public class EsbMock_assign_nok implements HttpCalloutMock 
	{
		public HTTPResponse respond(HTTPRequest req) 
		{
			Httpresponse resp = new Httpresponse();
			resp.SetStatusCode(500);
			return resp;
		}
	}
    
    static TestData InitTestData()
    {
        TestData retVal = new TestData();
        
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
            
		retVal.acc = TST_AccountTestHelper.createDummyAccount('France', false);
        retVal.acc.ESB_Company_Type__c = 'SHIPPER';
        retVal.acc.Company_Registration_Number__c = '1234';
        retVal.acc.Transport_Licence__c = 'qwer';
        retVal.acc.Email__c = 'qw@er.ty';
        retVal.acc.Website = 'qwer';
        retVal.acc.Customer_Since__c = Date.today();
        insert retVal.acc;
		retVal.cont = TST_ContactTestHelper.createDummyContact(retVal.acc, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        retVal.cont.Username__c = 'test username';
        retVal.cont.MobilePhone = '+32 2 1234567';
        retVal.cont.Fax = '+32 2 1234567';
        retVal.cont.Time_Zone__c = 'Europe/Brussels';
        update retVal.cont;
		retVal.ot = TST_OfferTemplateTestHelper.createDummyOfferTemplate(TLR_RecordTypeHelper.getId('Offer_template__c', 'TLR Offer Template'), true);
		retVal.opp = TST_OpportunityTestHelper.createDummyOpportunity(retVal.acc, retVal.ot, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity'), true);
		retVal.contr = TST_ContractTestHelper.createDummyContract(retVal.opp, TLR_RecordTypeHelper.getId('Contract', 'TLR Contract'), true);
		retVal.subs = TST_SubscriptionTestHelper.createDummySubscription(retVal.contr, retVal.opp, TLR_RecordTypeHelper.getId('Subscription__c', 'TLR Subscription'), true);
        Subs_Package_And_Fee__c subsPackFee = new Subs_Package_And_Fee__c();
        subsPackFee.Subscription__c = retVal.subs.Id;
        insert subsPackFee;
        Subs_Current_Fee__c subsCurrFee = new Subs_Current_Fee__c();
        subsCurrFee.Subscription__c = retVal.subs.Id;
        subsCurrFee.Subs_Package_And_Fee__c = subsPackFee.id;
        subsCurrFee.Start_Date__c = date.today();
        subsCurrFee.Name = 'CD_approved';
        insert subsCurrFee;
        
        return retVal;
    }
    
    public static testMethod void CreateGuestCompanyTestPositive()
    {
        // have no idea what to test here except of logs
        TestData data = InitTestData();
        
        data.acc.ESB_Company_Status__c = 'CREATED';
        update data.acc;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_ok());
		ESB_Proxy.CreateGuestCompany(data.acc.Id, data.cont.Id);
        Test.stopTest();
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Name, Message_direction__c, Message_type__c, ESB_response_status__c, Body__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.company.provision', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(200, logRecord.ESB_response_status__c, 'Wrong log record response status');
            
            TestLogPage('company',logRecord);
            CheckLogCompanyParse(data.acc.Id, data.cont.Id,logRecord.Id,'create');
            TestLogPageError(logRecord);
            
           // system.assert(false, logRecord.Body__c);///////////////////////////////////////////////////////////////////////////////////////////////////////////
        }
    } //CreateGuestCompanyTestPositive
    
    public static testMethod void CreateCompanyTestPositive()
	{
        TestData data = InitTestData();
        
        data.subs.Contact__c = data.cont.Id;
		data.subs.Flag_IntegrityChecks__c = true;
        data.subs.Status__c = 'Waiting For Provisioning';
		update data.subs;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_ok());
		ESB_Proxy.CreateCompany(data.acc.Id, data.cont.Id, true, data.subs.Id);
        Test.stopTest();
        
		Account updatedAcc = [SELECT Id, Name, AccountNumber, ESB_Company_status__c FROM Account WHERE Id=:data.acc.Id];
        System.Debug('---------- updatedAcc: ' + updatedAcc);
        system.AssertEquals('APPROVED', updatedAcc.ESB_Company_status__c, 'Account ESB company status should be updated, but no.');
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Body__c, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.company.provision', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(200, logRecord.ESB_response_status__c, 'Wrong log record response status');
            
            
            TestLogPage('company',logRecord);
            CheckLogCompanyParse(data.acc.Id, data.cont.Id,logRecord.Id,'create');
         //   system.assert(false, logRecord.Body__c);///////////////////////////////////////////////////////////////////////////////////////////////////////////
        }
	} //CreateCompanyTestPositive
    
    public static testMethod void CreateCompanyTestNegative_1()
	{
        TestData data = InitTestData();
        
        data.subs.Contact__c = data.cont.Id;
		data.subs.Flag_IntegrityChecks__c = true;
        data.subs.Status__c = 'Waiting For Provisioning';
		update data.subs;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_nok());
		ESB_Proxy.CreateCompany(data.acc.Id, data.cont.Id, true, data.subs.Id);
        Test.stopTest();
        
		Account updatedAcc = [SELECT Id, Name, AccountNumber, ESB_Company_status__c FROM Account WHERE Id=:data.acc.Id];
        System.Debug('---------- updatedAcc: ' + updatedAcc);
        system.Assert(updatedAcc.ESB_Company_status__c == null, 'Account ESB company status should not be updated');
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing', logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.company.provision', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(500, logRecord.ESB_response_status__c, 'Wrong log record response status');
            TestLogPage('company',logRecord);
        }
	} //CreateCompanyTestNegative
  
    public static testMethod void CreateCompanyTestNegative_2()
	{
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = New User(Alias = 'testUsr1', 
                             Username = 'testUsr1@test.ww',
                             CommunityNickname = 'testUsr1',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles');   
        usr.Disable_Validation_Rules_and_Workflows__c = true;
        insert usr;
        
        TestData data = InitTestData();
        
        system.runAs(usr)
        {
            data.acc.ShippingCity = '';
            update data.acc;
        }
        
        data.subs.Contact__c = data.cont.Id;
		data.subs.Flag_IntegrityChecks__c = true;
        data.subs.Status__c = 'Waiting For Provisioning';
		update data.subs;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_ok());
		ESB_Proxy.CreateCompany(data.acc.Id, data.cont.Id, true, data.subs.Id);
        Test.stopTest();
        
		Account updatedAcc = [SELECT Id, Name, AccountNumber, ESB_Company_status__c FROM Account WHERE Id=:data.acc.Id];
        System.Debug('---------- updatedAcc: ' + updatedAcc);
        system.Assert(updatedAcc.ESB_Company_status__c == null, 'Account ESB company status should not be updated');
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Body__c, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.company.provision', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(200, logRecord.ESB_response_status__c, 'Wrong log record response status');
            
            
            TestLogPage('company',logRecord);
            CheckLogCompanyParse(data.acc.Id, data.cont.Id,logRecord.Id,'create');
         //   system.assert(false, logRecord.Body__c);///////////////////////////////////////////////////////////////////////////////////////////////////////////
        }
	} //CreateCompanyTestNegative_2
    
    public static testMethod void ApproveCompanyTestPositive()
	{
        TestData data = InitTestData();
        
        // company is created in WKTSA, it has user with BusinessID
        data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
        data.cont.ESB_User_status__c = 'READY';
        update data.cont;
        
        data.subs.Contact__c = data.cont.Id;
		data.subs.Flag_IntegrityChecks__c = true;
        data.subs.Status__c = 'Waiting For Provisioning';
		update data.subs;
        
        data.subs.Status__c = 'Provisioning Initiated';
		update data.subs;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_ok());
		ESB_Proxy.ApproveCompany(data.acc.Id, data.cont.Id, data.subs.Id);
        Test.stopTest();
        
		Account updatedAcc = [SELECT Id, Name, AccountNumber, ESB_Company_status__c FROM Account WHERE Id=:data.acc.Id];
        Subscription__c subs = [SELECT Id, Name, Status__c FROM Subscription__c WHERE Id=:data.subs.Id];
        System.Debug('---------- updatedAcc: ' + updatedAcc);
        system.AssertEquals('APPROVED', updatedAcc.ESB_Company_status__c, 'Account ESB company status should be updated, but no.');
        system.assertEquals('Active', subs.Status__c, 'Subscription must be activated after successfull approval call, but no.');
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Name, Message_direction__c, Message_type__c, ESB_response_status__c, Body__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.company.approve', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(200, logRecord.ESB_response_status__c, 'Wrong log record response status');
            
            TestLogPage('company',logRecord);
            CheckLogCompanyParse(data.acc.Id, data.cont.Id,logRecord.Id,'approve');
           // system.assert(false, logRecord.Body__c);///////////////////////////////////////////////////////////////////////////////////////////////////////////
        }
	} //ApproveCompanyTestPositive
    
    public static testMethod void ApproveCompanyTestNegative_1()
	{
        TestData data = InitTestData();
        
        // company is created in WKTSA, it has user with BusinessID
        data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
        data.cont.ESB_User_status__c = 'READY';
        update data.cont;
        
        data.subs.Contact__c = data.cont.Id;
		data.subs.Flag_IntegrityChecks__c = true;
        data.subs.Status__c = 'Waiting For Provisioning';
		update data.subs;
        data.subs.Status__c = 'Provisioning Initiated';
		update data.subs;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_nok());
		ESB_Proxy.ApproveCompany(data.acc.Id, data.cont.Id, data.subs.Id);
        Test.stopTest();
        
		Account updatedAcc = [SELECT Id, Name, AccountNumber, ESB_Company_status__c FROM Account WHERE Id=:data.acc.Id];
        Subscription__c subs = [SELECT Id, Name, Status__c FROM Subscription__c WHERE Id=:data.subs.Id];
        System.Debug('---------- updatedAcc: ' + updatedAcc);
        system.Assert(updatedAcc.ESB_Company_status__c == null, 'Account ESB company status should not be updated');
        system.assertEquals('Waiting For Provisioning', subs.Status__c, 'Subscription status must be re-set to after failed approval call, but no.');
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.company.approve', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(500, logRecord.ESB_response_status__c, 'Wrong log record response status');
            TestLogPage('company',logRecord);
        }
	} //ApproveCompanyTestNegative_1

    public static testMethod void ApproveCompanyTestNegative_2()
	{
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = New User(Alias = 'testUsr1', 
                             Username = 'testUsr1@test.ww',
                             CommunityNickname = 'testUsr1',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles');   
        usr.Disable_Validation_Rules_and_Workflows__c = true;
        insert usr;
        
        TestData data = InitTestData();
        
        system.runAs(usr)
        {
            data.acc.ShippingCity = '';
            update data.acc;
        }
        
        // company is created in WKTSA, it has user with BusinessID
        data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
        data.cont.ESB_User_status__c = 'READY';
        update data.cont;
        
        data.subs.Contact__c = data.cont.Id;
		data.subs.Flag_IntegrityChecks__c = true;
        data.subs.Status__c = 'Waiting For Provisioning';
		update data.subs;
        data.subs.Status__c = 'Provisioning Initiated';
		update data.subs;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_ok());
		ESB_Proxy.ApproveCompany(data.acc.Id, data.cont.Id, data.subs.Id);
        Test.stopTest();
        
        Account updatedAcc = [SELECT Id, Name, AccountNumber, ESB_Company_status__c FROM Account WHERE Id=:data.acc.Id];
        Subscription__c subs = [SELECT Id, Name, Status__c FROM Subscription__c WHERE Id=:data.subs.Id];
        System.Debug('---------- updatedAcc: ' + updatedAcc);
        system.Assert(updatedAcc.ESB_Company_status__c == null, 'Account ESB company status should not be updated');
        system.assertEquals('Waiting For Provisioning', subs.Status__c, 'Subscription status must be re-set after exception is catched, but no.');        
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Name, Message_direction__c, Message_type__c, ESB_response_status__c, Body__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.company.approve', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(200, logRecord.ESB_response_status__c, 'Wrong log record response status');            
            TestLogPage('company',logRecord);
            CheckLogCompanyParse(data.acc.Id, data.cont.Id,logRecord.Id,'approve');
        }
    } //ApproveCompanyTestNegative_2
    
    public static testMethod void UpdateCompanyTestPositive_1()
	{
        TestData data = InitTestData();
        
        data.acc.ESB_Company_Status__c = 'APPROVED';
        update data.acc;
        
        data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
        data.cont.ESB_User_status__c = 'READY';
        update data.cont;
        
        data.subs.Contact__c = data.cont.Id;
		data.subs.Flag_IntegrityChecks__c = true;
        data.subs.Status__c = 'Waiting For Provisioning';
		update data.subs;
        data.subs.Status__c = 'Provisioning Initiated';
		update data.subs;
        data.subs.Status__c = 'Active';
		update data.subs;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_ok());
		ESB_Proxy.UpdateCompany(data.acc.Id, true);
        Test.stopTest();
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Body__c, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.company.update', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(200, logRecord.ESB_response_status__c, 'Wrong log record response status');
            
            TestLogPage('company',logRecord);
            CheckLogCompanyParse(data.acc.Id, data.cont.Id, logRecord.Id,'update');
           // system.assert(false, logRecord.Body__c);///////////////////////////////////////////////////////////////////////////////////////////////////////////
        }
	} //UpdateCompanyTestPositive_1
    
    public static testMethod void UpdateCompanyTestPositive_2()
	{
        
        TestData data = InitTestData();
        
        
        
        data.acc.ESB_Company_Status__c = 'APPROVED';
        update data.acc;

        
        data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
        data.cont.ESB_User_status__c = 'READY';
        update data.cont;
        
        data.subs.Contact__c = data.cont.Id;
		data.subs.Flag_IntegrityChecks__c = true;
        data.subs.Status__c = 'Waiting For Provisioning';
		update data.subs;
        data.subs.Status__c = 'Provisioning Initiated';
		update data.subs;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_ok());
		ESB_Proxy.UpdateCompany(data.acc.Id, true, data.subs.Id);        
        Test.stopTest();
        
        Subscription__c subs = [SELECT Id, Name, Status__c FROM Subscription__c WHERE Id=:data.subs.Id];
        system.assertEquals('Active', subs.Status__c, 'Subscription must be activated after successfull update call, but no.');
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Body__c, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.company.update', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(200, logRecord.ESB_response_status__c, 'Wrong log record response status');
            
            TestLogPage('company',logRecord);
            CheckLogCompanyParse(data.acc.Id, data.cont.Id, logRecord.Id,'update');
        }
	} //UpdateCompanyTestPositive_2
    
    public static testMethod void UpdateCompanyTestNegative_1()
	{
        TestData data = InitTestData();
        
        data.acc.ESB_Company_Status__c = 'APPROVED';
        update data.acc;
        
        data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
        data.cont.ESB_User_status__c = 'READY';
        update data.cont;
        
        data.subs.Contact__c = data.cont.Id;
		data.subs.Flag_IntegrityChecks__c = true;
        data.subs.Status__c = 'Waiting For Provisioning';
		update data.subs;
        data.subs.Status__c = 'Provisioning Initiated';
		update data.subs;
        data.subs.Status__c = 'Active';
		update data.subs;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_nok());
		ESB_Proxy.UpdateCompany(data.acc.Id, true);
        Test.stopTest();
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.company.update', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(500, logRecord.ESB_response_status__c, 'Wrong log record response status');
            TestLogPage('company',logRecord);
        }
	} //UpdateCompanyTestNegative_1
    
    public static testMethod void UpdateCompanyTestNegative_2()
	{
        
        TestData data = InitTestData();

        data.acc.ESB_Company_Status__c = 'APPROVED';
        update data.acc;
        
        data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
        data.cont.ESB_User_status__c = 'READY';
        update data.cont;
        
        data.subs.Contact__c = data.cont.Id;
		data.subs.Flag_IntegrityChecks__c = true;
        data.subs.Status__c = 'Waiting For Provisioning';
		update data.subs;
        data.subs.Status__c = 'Provisioning Initiated';
		update data.subs;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_nok());
		ESB_Proxy.UpdateCompany(data.acc.Id, true, data.subs.Id);        
        Test.stopTest();
        
        Subscription__c subs = [SELECT Id, Name, Status__c FROM Subscription__c WHERE Id=:data.subs.Id];
        system.assertEquals('Waiting For Provisioning', subs.Status__c, 'Subscription must be rerturned to the state before provisioning if the call is not successfull.');
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Body__c, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.company.update', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(500, logRecord.ESB_response_status__c, 'Wrong log record response status');
            
            TestLogPage('company',logRecord);
            CheckLogCompanyParse(data.acc.Id, data.cont.Id, logRecord.Id,'update');
        }
	} //UpdateCompanyTestNegative_2
    
    public static testMethod void UpdateCompanyTestNegative_3()
	{
        
        TestData data = InitTestData();        
        
        Subs_Package_And_Fee__c subsPackFee = new Subs_Package_And_Fee__c();
        subsPackFee.Subscription__c = data.subs.Id;
        insert subsPackFee;
        Subs_Current_Fee__c subsCurrFee = new Subs_Current_Fee__c();
        subsCurrFee.Subscription__c = data.subs.Id;
        subsCurrFee.Subs_Package_And_Fee__c = subsPackFee.id;
        subsCurrFee.Start_Date__c = date.today();
        subsCurrFee.Name = 'CD_guest';
        insert subsCurrFee;
        
        data.acc.ESB_Company_Status__c = 'APPROVED';
        update data.acc;

        
        data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
        data.cont.ESB_User_status__c = 'READY';
        update data.cont;
        
        data.subs.Contact__c = data.cont.Id;
		data.subs.Flag_IntegrityChecks__c = true;
        data.subs.Status__c = 'Waiting For Provisioning';
		update data.subs;
        data.subs.Status__c = 'Provisioning Initiated';
		update data.subs;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_ok());
        ESB_Proxy.UpdateCompany(data.acc.Id, true, data.subs.Id); 
        Test.stopTest();      

        Subscription__c subs = [SELECT Id, Name, Status__c FROM Subscription__c WHERE Id=:data.subs.Id];
        system.assertEquals('Waiting For Provisioning', subs.Status__c, 'Subscription must be returned to the state before provisioning if an error occurs.');
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Body__c, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assertEquals(0, logRecords.size(), 'No log rows must be added because an error occurs before call start');
	} //UpdateCompanyTestNegative_3
    
    public static testMethod void UpdateSuperUserTestPositive()
	{
        TestData data = InitTestData();
        
        data.acc.ESB_Company_Status__c = 'APPROVED';
        update data.acc;
        
        data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
        data.cont.ESB_User_status__c = 'READY';
        update data.cont;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_ok());
		ESB_Proxy.UpdateSuperUser(data.cont.Id);
        Test.stopTest();
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Body__c, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.user.update', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(200, logRecord.ESB_response_status__c, 'Wrong log record response status');
            TestLogPage('user',logRecord);
            CheckLogUserParse(data.cont.Id, logRecord.Id, false);
           // system.assert(false, parsedData);///////////////////////////////////////////////////////////////////////////////////////////////////////////
        }
	} //UpdateSuperUserTestPositive
    
    public static testMethod void UpdateSuperUserTestNegative()
	{
        TestData data = InitTestData();
        
        data.acc.ESB_Company_Status__c = 'APPROVED';
        update data.acc;
        
        data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
        data.cont.ESB_User_status__c = 'READY';
        update data.cont;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_nok());
		ESB_Proxy.UpdateSuperUser(data.cont.Id);
        Test.stopTest();
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.user.update', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(500, logRecord.ESB_response_status__c, 'Wrong log record response status');
            TestLogPage('user',logRecord);
        }
	} //UpdateSuperUserTestNegative
    
    public static testMethod void CreateUserTestPositive()
	{
        TestData data = InitTestData();
        
        data.acc.ESB_Company_Status__c = 'APPROVED';
        update data.acc;
        
        data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
        data.cont.ESB_User_status__c = 'READY';
        update data.cont;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_ok());
		ESB_Proxy.CreateUser(data.cont.Id, true);
        Test.stopTest();
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Body__c, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.user.create', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(200, logRecord.ESB_response_status__c, 'Wrong log record response status');            
            TestLogPage('user',logRecord);
            CheckLogUserParse(data.cont.Id, logRecord.Id, false);
          //  system.assert(false, logRecord.Body__c);///////////////////////////////////////////////////////////////////////////////////////////////////////////
        }
	} //CreateUserTestPositive
    
    public static testMethod void CreateUserTestNegative()
	{
        TestData data = InitTestData();
        
        data.acc.ESB_Company_Status__c = 'APPROVED';
        update data.acc;
        
        data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
        data.cont.ESB_User_status__c = 'READY';
        update data.cont;
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_nok());
		ESB_Proxy.CreateUser(data.cont.Id, true);
        Test.stopTest();
        
        // check the logging
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.user.create', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(500, logRecord.ESB_response_status__c, 'Wrong log record response status');
            TestLogPage('user',logRecord);
        }
	} //CreateUserTestNegative

    public static testMethod void TestDisabledESBCalls()
	{
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = New User(Alias = 'testUsr1', 
                             Username = 'testUsr1@test.ww',
                             CommunityNickname = 'testUsr1',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles');   
        usr.Disable_ESB_calls__c = true;
        insert usr;
        
        TestData data = InitTestData();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_ok());
        system.runAs(usr)
        {
            Test.startTest();
            data.acc.ESB_Company_Status__c = 'CREATED';
            update data.acc;
            ESB_Proxy.CreateGuestCompany(data.acc.Id, data.cont.Id);
            data.acc.ESB_Company_Status__c = '';
            update data.acc;
            data.subs.Contact__c = data.cont.Id;
            data.subs.Flag_IntegrityChecks__c = true;
            data.subs.Status__c = 'Waiting For Provisioning';
            update data.subs;
            ESB_Proxy.CreateCompany(data.acc.Id, data.cont.Id, true, data.subs.Id); 
            data.acc.ESB_Company_Status__c = '';
            update data.acc;
            data.cont.ESB_BuisnessID__c = 'U-123qwe1234';
            data.cont.ESB_User_status__c = 'READY';
            update data.cont;
            data.subs.Status__c = 'Provisioning Initiated';
            update data.subs;
            ESB_Proxy.ApproveCompany(data.acc.Id, data.cont.Id, data.subs.Id); 
            data.acc.ESB_Company_Status__c = 'APPROVED';
            update data.acc;
            data.subs.Status__c = 'Active';
            update data.subs;
            ESB_Proxy.UpdateCompany(data.acc.Id, true);
            ESB_Proxy.UpdateSuperUser(data.cont.Id);
            ESB_Proxy.CreateUser(data.cont.Id, true);
            ESB_Proxy.ActivateUser('businessId', Date.today());
            Test.stopTest();
            
            List<ESB_Interaction_Logs__c> logRecords = [
                SELECT Id
                FROM ESB_Interaction_Logs__c
            ];
            system.assertEquals(0, logRecords.size(), 'No logs must be created if ESB calls are disabled.');
        }
    } //TestDisabledESBCalls
    
    private static testMethod void ActivateUserTestPositive()
    {
        TestData data = InitTestData();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_ok());
		ESB_Proxy.ActivateUser('business id', Date.today());
        Test.stopTest();
        
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Body__c, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.user.activate', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(200, logRecord.ESB_response_status__c, 'Wrong log record response status');            
            TestLogPage('user',logRecord);
        } 
    } //ActivateUserTestPositive
    
    private static testMethod void ActivateUserTestNegative()
    {
        TestData data = InitTestData();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_assign_nok());
		ESB_Proxy.ActivateUser('business id', Date.today());
        Test.stopTest();
        
        List<ESB_Interaction_Logs__c> logRecords = [
            SELECT Id, Body__c, Name, Message_direction__c, Message_type__c, ESB_response_status__c
            FROM ESB_Interaction_Logs__c 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
        system.assert(logRecords.size() > 0, 'No log rows has beed added, but it shuold be at least one');
        
        if(logRecords.size() > 0)
        { 
            ESB_Interaction_Logs__c logRecord = logRecords[0];
            system.assertEquals('Outgoing' , logRecord.Message_direction__c, 'Wrong log record message direction');
            system.assertEquals('cm.user.activate', logRecord.Message_type__c, 'Wrong log record message type or wrong request type');
            system.assertEquals(500, logRecord.ESB_response_status__c, 'Wrong log record response status');            
            TestLogPage('user',logRecord);
        } 
    } //ActivateUserTestNegative
    
    private static  void CheckLogUserParse(Id contactId, Id logId,boolean innerusers)
    {
        Contact currentUser = [select Id, AccountId, CreatedDate, FirstName, LastName, ESB_BuisnessID__c
                               , Email, ESB_User_status__c from Contact where Id =: contactId];
        Account currentCompany = [select Id, AccountNumber from Account where Id =: currentUser.AccountId];
        
        parsedData = CtrlESBInteractionLogs.GetBodyParameters(logId);
        
        if(innerusers)
        {
            for( integer i = 0; i< parsedData.size(); i++)
            {
                if(parsedData[i].ParName == 'users')
                {
                    parsedData = parsedData[i].InnerPars;
                    break;
                }
            }
        }
        
        parsedDataMap = new Map<string,CtrlESBInteractionLogs.ESB_Parameter>();
        for(integer i = 0 ;i<parsedData.size();i++)
        {
            parsedDataMap.put(parsedData[i].ParName,parsedData[i]);
        }
        
        if(!innerusers)
        {
            system.assert(!innerusers && string.valueOf(currentUser.CreatedDate.format(xmlDateFormat)) == parsedDataMap.get('creationDate').ParValue,'creationDate hasn\'t been correctly parsed');
        }
        else
        {
            system.assert(parsedDataMap.get('creationDate').ParValue != null,'creationDate hasn\'t been correctly parsed');            
        }
        system.assert(currentUser.FirstName == parsedDataMap.get('firstName').ParValue,'firstName hasn\'t been correctly parsed');
        system.assert(currentUser.LastName == parsedDataMap.get('lastName').ParValue,'lastName hasn\'t been correctly parsed');
        system.assert(currentUser.ESB_BuisnessID__c == parsedDataMap.get('businessId').ParValue
                      || currentUser.ESB_BuisnessID__c == null && parsedDataMap.get('businessId').ParValue == 'FAKE'
                      ,'businessId hasn\'t been correctly parsed');
        system.assert(currentCompany.AccountNumber == parsedDataMap.get('companyBusinessAccount').ParValue, 'companyBusinessAccount hasn\'t been correctly parsed');
        system.assert(currentUser.Email == parsedDataMap.get('email').ParValue, 'email hasn\'t been correctly parsed');
        system.assert(currentUser.ESB_User_status__c == parsedDataMap.get('status').ParValue 
                      || currentUser.ESB_User_status__c == null && parsedDataMap.get('status').ParValue == 'CREATED', 'status hasn\'t been correctly parsed');
        system.assert(parsedDataMap.get('userType').ParValue != null,  'userType hasn\'t been parsed');
        system.assert(parsedDataMap.get('userTitle').ParValue != null,  'userTitle hasn\'t been parsed');
        system.assert(parsedDataMap.get('visible').ParValue !=  null,  'visible hasn\'t been parsed');
        system.assert(parsedDataMap.get('preferredLanguage').ParValue != null,  'preferredLanguage hasn\'t been parsed');
        system.assert(parsedDataMap.get('phone').InnerPars != null && parsedDataMap.get('phone').InnerPars.size() == 3,  'phone hasn\'t been parsed');  
    }
    
    private static void CheckLogCompanyParse(Id accountId, Id contactId, Id logId, string operationType)
    {
        Account currentCompany = [select Id, AccountNumber, CreatedDate, LastModifiedDate from Account where Id =: accountId];
        parsedData = CtrlESBInteractionLogs.GetBodyParameters(logId);
        
        parsedDataMap = new Map<string,CtrlESBInteractionLogs.ESB_Parameter>();
        for(integer i = 0 ;i<parsedData.size();i++)
        {
            parsedDataMap.put(parsedData[i].ParName,parsedData[i]);
        }
        
        system.assert(string.valueOf(currentCompany.CreatedDate.format(xmlDateFormat)) == parsedDataMap.get('creationDate').ParValue,'creationDate hasn\'t been correctly parsed');
        system.assert(parsedDataMap.get('modificationDate').ParValue != null,'modificationDate hasn\'t been parsed');
        system.assert(currentCompany.AccountNumber == parsedDataMap.get('businessId').ParValue, 'businessId hasn\'t been parsed');
        system.assert(parsedDataMap.get('companyType').ParValue != null,'companyType hasn\'t been parsed');
        system.assert(parsedDataMap.get('productsAccesses').InnerPars != null,'productsAccesses hasn\'t been parsed');
        system.assert(parsedDataMap.get('companyState').ParValue != null,'companyState hasn\'t been parsed');
        if(operationType != 'approve')
        {
            system.assert(parsedDataMap.get('addresses').InnerPars != null,'addresses hasn\'t been parsed');
            system.assert(parsedDataMap.get('name').ParValue != null,'name hasn\'t been parsed');
            system.assert(parsedDataMap.get('parentCompanyBusinessAccount').ParValue != null,'parentCompanyBusinessAccount hasn\'t been parsed');
            system.assert(parsedDataMap.get('operationalParentCompanyBusinessAccount').ParValue != null,'operationalParentCompanyBusinessAccount hasn\'t been parsed');
            system.assert(parsedDataMap.get('vat').ParValue != null,'vat hasn\'t been parsed');
            system.assert(parsedDataMap.get('fax').ParValue != null,'fax hasn\'t been parsed');
            system.assert(parsedDataMap.get('phone').ParValue != null,'phone hasn\'t been parsed');
        }
        if(operationType == 'create' && contactId != null)
        {
            CheckLogUserParse(contactId, logId, true);
        }
    }
    
    private static void TestLogPage(string dataType, ESB_Interaction_Logs__c log)
    {
        ApexPages.StandardController scontroller = new ApexPages.StandardController(log);
        CtrlESBInteractionLogs controller = new CtrlESBInteractionLogs(scontroller);
        system.assert(CtrlESBInteractionLogs.dataType == dataType);
        system.assert(CtrlESBInteractionLogs.getLogId() == log.Id,'Log Id is incorrect');
        PageReference redirectAddress = controller.checkForRedirect();   
        PageReference resendAddress = controller.resend(); 
        if(log.ESB_response_status__c == 200)
        {
            system.assert(redirectAddress == null,'redirect address must equal null');
        }
        else
        {
            system.assert(redirectAddress.getUrl() == ('/'+log.Id+'?nooverride=1'),'wrong redirect address');
        }
        system.assert(resendAddress.getUrl() == ('/apex/ESB_Interaction_Log?id='+log.Id),'wrong resend address');
    }
    
    private static void TestLogPageError(ESB_Interaction_Logs__c log)
    {
        if(log.ESB_response_status__c == 200)
        {
            ApexPages.StandardController scontroller = new ApexPages.StandardController(log);
            CtrlESBInteractionLogs controller = new CtrlESBInteractionLogs(scontroller);
            PageReference redirectAddress = controller.checkForRedirect();
            system.assert(redirectAddress == null,'redirect address must equal null');
            
            scontroller = new ApexPages.StandardController(log);
            log.Id = null;
            controller = new CtrlESBInteractionLogs(null);
            redirectAddress = controller.checkForRedirect();
            system.assert(redirectAddress.getUrl() == ('/'+log.Id+'?nooverride=1'),redirectAddress.getUrl()+'wrong redirect address');
        }
    }
}