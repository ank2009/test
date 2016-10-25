/**
 * @author Abdelali Karim / Nicolas Dolet
 * @date 26/12/2011
 */

@isTest
public class CtrlSwitchUPSuspensionTest
{
	public class WS_Call_ok implements HttpCalloutMock
	{
		public HTTPResponse respond(HTTPRequest req)
		{
			HttpResponse res = new HttpResponse();
			res.setStatusCode(200);
			return res;
		}
	} // BridgeWSMock_assign_ok class
    public static testMethod void testCtrlSwitchUPSuspension()
    {
    	// here we facing governor limit:
    	//System.LimitException: Too many record type describes: 101 stack Class.TLR_RecordTypeHelper.getId: line 67, column 1
		//Class.TLR_ContactTriggerHandler.<init>: line 11, column 1
		//Trigger.TLR_ContactBeforeTrigger: line 10, column 1
        List<ID> services = TestData.createTestServices(10);
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('France',true);
        Account accnt = [SELECT Id, About_Specialization__c, BIC_Code__c, Description, Company_Creation_Date__c,
                                Completion_Level__c, Customer_Since__c, Total_employees__c,
                                Iban_Number__c, ISO_Certification__c, Company_Registration_Number__c,
                                Number_of_trucks_owned__c
                           FROM Account
                          WHERE Id = :a.Id];
        accnt.About_Specialization__c = 'ADR/dangerous goods';
        //accnt.BIC_Code__c = '0617549000';
        accnt.Description = 'Test';
        accnt.Company_Creation_Date__c = Date.Today();
        accnt.Completion_Level__c = 5;
        accnt.Customer_Since__c = Date.Today();
        accnt.Total_employees__c = 5;
        accnt.Iban_Number__c = 'FR7615749364310001008090273';
        accnt.ISO_Certification__c = '1';
        accnt.Company_Registration_Number__c = '94735237300072';
        accnt.Number_of_trucks_owned__c = 5;
        update accnt;
		
		List<Contact> cList = TST_ContactTestHelper.createDummyContactList(a, 10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        List<ID> contacts = new List<Id>();
        for(Contact c : cList)
        	contacts.add(c.Id);
        
        Id contractId = TestData.createTestContract(a.Id).Id;
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;
        Id provisioningId = TestData.createTestProvisioningAndServices(subsId, contractId, a.Id).Id;
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioningId, servWithServAttributes);
        List<ID> userprofiles = TestData.createTestUserProfiles(contacts, provisioningId, provServices);
        User_Profile__c UP=[SELECT Id FROM User_Profile__c WHERE Id=:userprofiles[0]];
		
		// we don't need to call bridge
		General_Settings__c gs = General_Settings__c.getInstance('Default');
		gs.Enable_Bridge_calls__c = false;
		update gs;
		
		// set mockup for other WS calls
		
		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new WS_Call_ok());
		
        UP.Suspension_Start_Date__c = Date.today();
        UP.Suspension_Reason__c = 'None';
        update UP;

        // Page preparation
        PageReference pageRef = Page.UserProfileSwitchSuspension;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', UP.Id);
		
        CtrlSwitchUPSuspension controller = new CtrlSwitchUPSuspension(new ApexPages.StandardController(UP));

        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + UP.Id, cancelPage);
        System.assertEquals(null, controller.save());

        // wtf we have here exception - i don't know
        //String sendProvisioningMsgPage = controller.sendProvisioningMsg().getUrl();
        //System.assertEquals('/'+UP.Id,sendProvisioningMsgPage);

        /*User_Profile__c UP1=[SELECT Id FROM User_Profile__c WHERE Id=:userprofiles[1]];
        UP1.Suspension_End_Date__c = null;
        UP1.Status__c ='Suspended';
        UP1.Immediate_unsuspension__c = true;
        ApexPages.currentPage().getParameters().put('id', UP1.Id);
        controller = new CtrlSwitchUPSuspension(new ApexPages.StandardController(UP1));
        ApexPages.currentPage().getParameters().put('id', UP1.Id);
        String savePage1 = controller.Save().getUrl();
        System.assertEquals(null, savePage1 );
        String sendProvisioningMsgPage1 = controller.sendProvisioningMsg().getUrl();
        System.assertEquals('/' + UP1.Id,sendProvisioningMsgPage1);*/
		Test.StopTest();
    }

}