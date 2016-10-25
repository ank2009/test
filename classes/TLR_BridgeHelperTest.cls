/**
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2013 October 7
* @description  Bridge operations helper tests
**/
@isTest
public class TLR_BridgeHelperTest
{
	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 October 7
	* @description  WebService mock object for correct bridge response to assignment
	**/
	public class BridgeWSMock_assign_ok implements HttpCalloutMock
	{
		public HTTPResponse respond(HTTPRequest req)
		{
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'text/xml');
			string body = '<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body>';
			body += '<ns1:assignToProfileResponse xmlns:ns1=\"http://ws.proxy.bridge.teleroute.wkts.com/\">';
			body += '<result>1</result>';
			body += '</ns1:assignToProfileResponse></soap:Body></soap:Envelope>';
			res.setBody(body);
			res.setStatusCode(200);
			system.debug('----- BridgeWSMock_assign_ok: request: ' + req.getBody());
			return res;
		}
	} // BridgeWSMock_assign_ok class

	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 October 7
	* @description  WebService mock object for correct bridge response to assignment
	**/
	public class BridgeWSMock_suppress_ok implements HttpCalloutMock
	{
		public HTTPResponse respond(HTTPRequest req)
		{
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'text/xml');
			string body = '<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body>';
			body += '<ns1:suppressAssignationResponse xmlns:ns1=\"http://ws.proxy.bridge.teleroute.wkts.com/\">';
			body += '<result>1</result>';
			body += '</ns1:suppressAssignationResponse></soap:Body></soap:Envelope>';
			res.setBody(body);
			res.setStatusCode(200);
			system.debug('----- BridgeWSMock_suppress_ok: request: ' + req.getBody());
			return res;
		}
	} // BridgeWSMock_suppress_ok class

	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 October 7
	* @description  WebService mock object for wrong bridge response to assignment
	**/
	public class BridgeWSMock_error implements HttpCalloutMock
	{
		public HTTPResponse respond(HTTPRequest req)
		{
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'text/xml');
			string body = '<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body>';
			body += '<soap:Fault><faultcode>soap:Server</faultcode><faultstring>';
			// real error message
			body += 'One of the object is null while invoking public int com.wkts.teleroute.bridge.proxy.ws.BridgeForSalesForceWS.assignToProfile(int,java.lang.String,java.lang.String[]) throws com.wkts.teleroute.bridge.proxy.ws.exception.AssignException with params [56, ACCOUNT_NUMBER, [Ljava.lang.String;@104a8f91].';
			body += '</faultstring></soap:Fault>';
			body += '</soap:Body></soap:Envelope>';
			res.setBody(body);
			res.setStatusCode(200);
			system.debug('----- BridgeWSMock_error: request: ' + req.getBody());
			return res;
		}
	} // BridgeWSMock_assign_error class

    private static void Init()
	{
		Bridge_Profile_Settings__c bridge1 = new Bridge_Profile_Settings__c( Name = 'Bursa', value__c = '1' );
		Bridge_Profile_Settings__c bridge2 = new Bridge_Profile_Settings__c( Name = 'Nolis', value__c = '2' );
		insert bridge1;
		insert bridge2;
		
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
	} // Init

	private static List<User_Profile__c> CreateUserProfiles(integer cnt, string bridgeProfile)
	{
		List<User_Profile__c> retVal = new List<User_Profile__c>();
		Account acc = TST_AccountTestHelper.createDummyAccount('France',false);
		insert acc;
		Contact cont = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), false);
		cont.Username__c = 'FXUser1111';
		insert cont;
		cont.Account = acc;
		for(integer i = 0; i < cnt; i++)
		{
			User_Profile__c up = new User_Profile__c();
			//up.Name = 'User profile ' + EncodingUtil.convertToHex((System.Crypto.generateAesKey(128))).substring(0, 5);
			up.Contact__r = cont;
			up.Contact__c = cont.Id;
			up.WKTS_Profiles__c = bridgeProfile;
			up.Status__c = 'Activated';
			retVal.add(up);
		}
		insert retVal;
		return retVal;
	} //CreateUserProfiles

	private static Map<string, string> getAvailableProfilesFromSettings()
	{
		Map<string, string> retVal = new Map<string, string>();

		// get settings map
		Map<String, Bridge_Profile_Settings__c> settingsMap = Bridge_Profile_Settings__c.getAll();
		for(string nm : settingsMap.keySet())
			retVal.put(settingsMap.get(nm).Name, settingsMap.get(nm).value__c);

		return retVal;
	} // getAvailableProfilesFromSettings
    
	public static testMethod void assignationTestCorrect()
	{
		Init();
		Map<string, string> bridgeProfilesMap = getAvailableProfilesFromSettings();

		Test.setMock(HttpCalloutMock.class, new BridgeWSMock_assign_ok());

		List<User_Profile__c> userProfiles1 = CreateUserProfiles(2, 'Bursa1');
		List<Id> upIds1 = new List<Id>();
		for(User_Profile__c up : userProfiles1)
			upIds1.add(up.Id);

		List<User_Profile__c> userProfiles2 = CreateUserProfiles(3, 'Bursa');
		List<Id> upIds2 = new List<Id>();
		for(User_Profile__c up : userProfiles2)
			upIds2.add(up.Id);

		System.debug('------- START TEST assignationTestCorrect ---------');
		Test.StartTest();
		// 1. missing profile setting
		TLR_BridgeHelper.AssignBridgeProfiles(upIds1, bridgeProfilesMap);
		// 2. correct assignation
		TLR_BridgeHelper.AssignBridgeProfiles(upIds2, bridgeProfilesMap);
		Test.StopTest();

		// 1. missing profile setting
		userProfiles1 = [SELECT Id, Name, Bridge_Error__c FROM User_Profile__c WHERE Id IN :upIds1];
		System.debug('---- TEST: assignationTestCorrect ---- current user profile errors: ' + userProfiles1[0].Bridge_Error__c);
		System.assertEquals(userProfiles1[0].Bridge_Error__c, 'Incorrect Bridge profile string: Bursa1. Check FXSettings.', 'Incorrect behavior for missing Bridge Profile settings.');
		System.assertEquals(userProfiles1[1].Bridge_Error__c, 'Incorrect Bridge profile string: Bursa1. Check FXSettings.', 'Incorrect behavior for missing Bridge Profile settings.');

		// 2. correct assignation
		userProfiles2 = [SELECT Id, Name, Bridge_Error__c FROM User_Profile__c WHERE Id IN :upIds2];
		for(User_Profile__c up : userProfiles2)
			system.assert(string.isEmpty(up.Bridge_Error__c), 'Some bridge errors occured during assignation, but shouldn\'t');

		System.debug('------- END TEST assignationTestCorrect ---------');
	} // assignationTestCorrect

	public static testMethod void assignationTestIncorrect()
	{
		Init();
		Map<string, string> bridgeProfilesMap = getAvailableProfilesFromSettings();
		Test.setMock(HttpCalloutMock.class, new BridgeWSMock_error());

		List<User_Profile__c> userProfiles2 = CreateUserProfiles(3, 'Bursa');
		List<Id> upIds2 = new List<Id>();
		for(User_Profile__c up : userProfiles2)
			upIds2.add(up.Id);
		System.debug('------- START TEST assignationTestIncorrect ---------');
		// 3. wrong response from Bridge
		Test.StartTest();
		TLR_BridgeHelper.AssignBridgeProfiles(upIds2, bridgeProfilesMap);
		Test.StopTest();
		userProfiles2 = [SELECT Id, Name, Bridge_Error__c FROM User_Profile__c WHERE Id IN :upIds2];
		for(User_Profile__c up : userProfiles2)
		{
			System.debug('---- TEST: assignationTestIncorrect ---- current user profile errors: ' + up.Bridge_Error__c);
			system.assert(!string.isEmpty(up.Bridge_Error__c), 'Some bridge errors occured during assignation, but not shown!');
		}

		System.debug('------- END TEST assignationTestIncorrect ---------');
	} // assignationTestIncorrect

	public static testMethod void suppressionTestCorrect()
	{
		Init();
		Map<string, string> bridgeProfilesMap = getAvailableProfilesFromSettings();
		Test.setMock(HttpCalloutMock.class, new BridgeWSMock_suppress_ok());

		TLR_BridgeHelper helper = new TLR_BridgeHelper();
		List<User_Profile__c> userProfiles1 = CreateUserProfiles(2, 'Bursa1');
		Map<Id, string> upIds1 = new Map<Id, string>();
		for(User_Profile__c up : userProfiles1)
			upIds1.put(up.Id, up.WKTS_Profiles__c);

		List<User_Profile__c> userProfiles2 = CreateUserProfiles(3, 'Bursa');
		Map<Id, string> upIds2 = new Map<Id, string>();
		for(User_Profile__c up : userProfiles2)
			upIds2.put(up.Id, up.WKTS_Profiles__c);

		Test.startTest();
		// 1. incorrect profile value call
		TLR_BridgeHelper.SuppressBridgeProfiles(upIds1, bridgeProfilesMap);
		// 1. positive case call
		TLR_BridgeHelper.SuppressBridgeProfiles(upIds2, bridgeProfilesMap);
		Test.stopTest();

		// 2. incorrect profile value assert
		userProfiles1 = [SELECT Id, Name, Bridge_Error__c FROM User_Profile__c WHERE Id IN :upIds1.keySet()];
		for(User_Profile__c up : userProfiles1)
		{
			System.debug('---- TEST: suppressionTestCorrect1 ---- current user profile errors: ' + up.Bridge_Error__c);
			System.assertEquals(up.Bridge_Error__c, 'Incorrect Bridge profile string: Bursa1. Check FXSettings.', 'Incorrect behavior for missing Bridge Profile settings.');
		}

		// 2. positive case assert
		TLR_BridgeHelper.SuppressBridgeProfiles(upIds2, bridgeProfilesMap);
		userProfiles2 = [SELECT Id, Name, Bridge_Error__c FROM User_Profile__c WHERE Id IN :upIds2.keySet()];
		for(User_Profile__c up : userProfiles2)
		{
			System.debug('---- TEST: suppressionTestCorrect2 ---- current user profile errors: ' + up.Bridge_Error__c);
			System.assert(string.isEmpty(up.Bridge_Error__c), 'Some bridge errors occured during suppression, but shouldn\'t');
		}

	} // suppressionTestCorrect

	public static testMethod void suppressionTestIncorrect()
	{
		Init();
		Map<string, string> bridgeProfilesMap = getAvailableProfilesFromSettings();
		Test.setMock(HttpCalloutMock.class, new BridgeWSMock_error());

		List<User_Profile__c> userProfiles2 = CreateUserProfiles(3, 'Bursa');
		Map<Id, string> upIds2 = new Map<Id, string>();
		for(User_Profile__c up : userProfiles2)
			upIds2.put(up.Id, up.WKTS_Profiles__c);

		Test.startTest();
		TLR_BridgeHelper.SuppressBridgeProfiles(upIds2, bridgeProfilesMap);
		Test.stopTest();
		userProfiles2 = [SELECT Id, Name, Bridge_Error__c FROM User_Profile__c WHERE Id IN :upIds2.keySet()];
		for(User_Profile__c up : userProfiles2)
		{
			System.debug('---- TEST: suppressionTestIncorrect ---- current user profile errors: ' + up.Bridge_Error__c);
			system.assert(!string.isEmpty(up.Bridge_Error__c), 'Some bridge errors occured during suppression, but not shown!');
		}

	} // suppressionTestIncorrect

	
	
	public static testMethod void triggerAssignCorrectAnswer()
	{
		Init();
		system.debug('---------triggerAssignCorrectAnswer: Bridge_Profile_Settings__c: ' + Bridge_Profile_Settings__c.getAll());
		Test.setMock(HttpCalloutMock.class, new BridgeWSMock_assign_ok());
		
		User_Profile__c up = CreateUserProfiles(1, null)[0];
		User_Profile__c up2 = CreateUserProfiles(1, null)[0];
		
		Test.startTest();
		up.WKTS_Profiles__c = 'Bursa';
		update up;
		up2.WKTS_Profiles__c = 'Bursasasa';
		update up2;
		Test.stopTest();
		
		User_Profile__c uup = [SELECT Id, Name, Bridge_Error__c FROM User_Profile__c WHERE Id = :up.id];
		system.assert(string.isEmpty(uup.Bridge_Error__c), 'Some bridge errors occured during assignation, but shouldn\'t');
		
		User_Profile__c uup2 = [SELECT Id, Name, Bridge_Error__c FROM User_Profile__c WHERE Id = :up2.id];
		system.assert(!string.isEmpty(uup2.Bridge_Error__c), 'Some bridge errors occured during suppression, but not shown!');
	} //triggerAssignCorrectAnswer
	
	public static testMethod void triggerAssignIncorrectAnswer()
	{
		Init();
		system.debug('---------triggerAssignIncorrectAnswer: Bridge_Profile_Settings__c: ' + Bridge_Profile_Settings__c.getAll());
		Test.setMock(HttpCalloutMock.class, new BridgeWSMock_error());
		
		User_Profile__c up = CreateUserProfiles(1, null)[0];
		
		Test.startTest();
		up.WKTS_Profiles__c = 'Bursa';
		update up;
		Test.stopTest();
		
		User_Profile__c uup = [SELECT Id, Name, Bridge_Error__c FROM User_Profile__c WHERE Id = :up.id];
		system.debug('---------triggerAssignIncorrectAnswer: uup: ' + uup);
		system.assert(string.isEmpty(up.Bridge_Error__c), 'Some bridge errors occured during assignation, but not shown!');
	} //triggerAssignIncorrectAnswer
	
	public static testMethod void triggerSuppressCorrectAnswer1()
	{
		Init();
		system.debug('---------triggerSuppressCorrectAnswer1: Bridge_Profile_Settings__c: ' + Bridge_Profile_Settings__c.getAll());
		Test.setMock(HttpCalloutMock.class, new BridgeWSMock_suppress_ok());
		
		User_Profile__c up = CreateUserProfiles(1, null)[0];
		
		Test.startTest();
		// 1. suppression of empty profile
		up.WKTS_Profiles__c = '';
		update up;
		Test.stopTest();
		
		User_Profile__c uup = [SELECT Id, Name, Bridge_Error__c FROM User_Profile__c WHERE Id = :up.id];
		system.assert(string.isEmpty(uup.Bridge_Error__c), 'Some bridge errors occured during suppression, but should not!');
	} //triggerSuppressCorrectAnswer1
    
    public static testMethod void triggerSuppressCorrectAnswer2()
	{
		Init();
		system.debug('---------triggerSuppressCorrectAnswer2: Bridge_Profile_Settings__c: ' + Bridge_Profile_Settings__c.getAll());
		Test.setMock(HttpCalloutMock.class, new BridgeWSMock_suppress_ok());
		
		User_Profile__c up2 = CreateUserProfiles(1, 'Nolis123')[0];
		
		Test.startTest();
		// 2. suppression of incorrect profile
		up2.WKTS_Profiles__c = '';
		update up2;
		Test.stopTest();
				
		User_Profile__c uup2 = [SELECT Id, Name, Bridge_Error__c FROM User_Profile__c WHERE Id = :up2.id];
        system.debug('---------triggerSuppressCorrectAnswer2: uup2.Bridge_Error__c: ' + uup2.Bridge_Error__c);
		system.assert(!string.isEmpty(uup2.Bridge_Error__c), 'Some bridge errors occured during suppression, but not shown!');
	} //triggerSuppressCorrectAnswer2
    
    public static testMethod void triggerSuppressCorrectAnswer3()
	{
		Init();
		system.debug('---------triggerSuppressCorrectAnswer3: Bridge_Profile_Settings__c: ' + Bridge_Profile_Settings__c.getAll());
		Test.setMock(HttpCalloutMock.class, new BridgeWSMock_suppress_ok());
		
		User_Profile__c up3 = CreateUserProfiles(1, 'Nolis')[0];
		
		Test.startTest();
		// 3. correct suppression
		up3.WKTS_Profiles__c = '';
		update up3;
		Test.stopTest();
		
		User_Profile__c uup3 = [SELECT Id, Name, Bridge_Error__c FROM User_Profile__c WHERE Id = :up3.id];
		system.assert(string.isEmpty(uup3.Bridge_Error__c), 'Some bridge errors occured during suppression, but should not!');
	} //triggerSuppressCorrectAnswer3
}