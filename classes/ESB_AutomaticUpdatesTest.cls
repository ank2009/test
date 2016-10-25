/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2014 December 4
* @description  unit tests to check automatic updates of accounts, contacts and subscriptions are sent to ESB
*/
@isTest
public class ESB_AutomaticUpdatesTest
{
    public class EsbMock_trackCalls implements HttpCalloutMock 
	{
        public boolean callExecuted = false;
		public HTTPResponse respond(HTTPRequest req) 
		{
			Httpresponse resp = new Httpresponse();
			resp.SetStatusCode(200);
            callExecuted = true;
			return resp;
		}
	}
    
    public class TestData
    {
        public Account acc;
        public Contact cont;
        public EsbMock_trackCalls wsMock;
    }
    
    private static TestData CreateTestData()
    {
        TestData retval = new TestData();
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		retval.acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
        retVal.cont = TST_ContactTestHelper.createDummyContact(retVal.acc, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        retval.wsMock = new EsbMock_trackCalls();
        
        return retVal;
    } //CreateTestData
    
	public static testMethod void UpdateAccountTest1()
    {
		TestData data = CreateTestData();        
        // case 1: no call, because of empty status
        data.acc.Name += '1';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, data.wsMock);
		update data.acc;
        Test.stopTest();
        
		system.assertEquals(false, data.wsMock.callExecuted, 'ESB Called when no need!');
    } //UpdateAccountTest1
    
    public static testMethod void UpdateAccountTest2()
    {
        TestData data = CreateTestData();
        // case 2: call, because of status is APPROVED and changed tracked field
        data.acc.ESB_Company_status__c = 'APPROVED';
        update data.acc;
        
        data.acc.Name += '1';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, data.wsMock);
		update data.acc;
        Test.stopTest();
        
		system.assertEquals(true, data.wsMock.callExecuted, 'ESB not called when need!');
    }// UpdateAccountTest2
    
    public static testMethod void UpdateAccountTest3()
    {
        TestData data = CreateTestData();
        // case 3: no call, because of status is APPROVED and changed non-tracked field
        data.acc.ESB_Company_status__c = 'APPROVED';
        update data.acc;
        
        data.acc.Migration_Address_ID__c += '1';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, data.wsMock);
		update data.acc;
        Test.stopTest();
        
		system.assertEquals(false, data.wsMock.callExecuted, 'ESB not called when need!');
    }// UpdateAccountTest3
    
    public static testMethod void UpdateAccountTest4()
    {
        TestData data = CreateTestData();
        // case 3: no call, because of status is CREATED
        data.acc.ESB_Company_status__c = 'CREATED';
        update data.acc;
        
        data.acc.Name += '1';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, data.wsMock);
		update data.acc;
        Test.stopTest();
        
		system.assertEquals(false, data.wsMock.callExecuted, 'ESB not called when need!');
    }// UpdateAccountTest4
    
    public static testMethod void UpdateContactTest1()
    {
        TestData data = CreateTestData();
        // case 1: no call, because contact isnot tracked
        //data.cont.ESB_BuisnessID__c = 'U-123qwe';
        //update data.cont;
        
        data.cont.Username__c += '1';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, data.wsMock);
		update data.cont;
        Test.stopTest();
        
		system.assertEquals(false, data.wsMock.callExecuted, 'ESB not called when need!');
    }// UpdateContactTest1
    
    public static testMethod void UpdateContactTest2()
    {
        TestData data = CreateTestData();
        // case 2: call, because contact is tracked and tracked field is updated
        data.cont.ESB_BuisnessID__c = 'U-123qwe';
        update data.cont;
        
        data.cont.Username__c += '1';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, data.wsMock);
		update data.cont;
        Test.stopTest();
        
		system.assertEquals(true, data.wsMock.callExecuted, 'ESB not called when need!');
    }// UpdateContactTest2
    
    public static testMethod void UpdateContactTest3()
    {
        TestData data = CreateTestData();
        // case 3: no call, because contact is tracked and non-tracked field is updated
        data.cont.ESB_BuisnessID__c = 'U-123qwe';
        update data.cont;
        
        data.cont.Description += '1';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, data.wsMock);
		update data.cont;
        Test.stopTest();
        
		system.assertEquals(false, data.wsMock.callExecuted, 'ESB called when not need!');
    }// UpdateContactTest3
}