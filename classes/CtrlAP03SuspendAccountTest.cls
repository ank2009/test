/**
* @author Nicolas Dolet
* @date 23/12/2011
* @description Test CtrlAP03SuspendAccount
*/

@isTest
public class CtrlAP03SuspendAccountTest 
{
    public class SuspendAccountMock_ok implements WebServiceMock 
    {
        public Void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType)
        {
            LibSFDCToESBV2.ProvisionningV2Response_element request_x = new LibSFDCToESBV2.ProvisionningV2Response_element();
            request_x.output = new LibWKTSComCrmProvisioningV2.CRMProvisionningResponseTypev2();
            request_x.output.status = 'Success';
            response.put('response_x', request_x);
        }
    }
   public static testMethod void testCtrl1() {
// somewhere below we faced governor limit of SOQL queries
        //System.LimitException: Too many SOQL queries: 101 stack Class.TLR_ContactTriggerHandler.UpdateContactProvisioningMessage: line 84, column 1

        // Data generation
        List<ID> services = TestData.createTestServices(1);
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 1);

        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount(true);
        List<Contact> cList = TST_ContactTestHelper.createDummyContactList(a, 1, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        List<ID> contacts = new List<Id>();
        for(Contact c : cList)
            contacts.add(c.Id);
       
       Contract testContract = TestData.createTestContract(a.Id);      
       Id contractId = testContract.Id;
       testContract.Direct_Debit__c = TRUE;
       upsert testContract;
       testContract.Direct_Debit__c = FALSE;
       upsert testContract;
       Id subsId = TestData.createTestSubscription(productId, contractId).Id;
                    Provisioning__c provisioning = TestData.createTestProvisioningAndServices(subsId, contractId, a.Id);
                  Map<ID, List<Id>> provServices = TestData.createTestProvisioningHierarchy(provisioning.Id, servWithServAttributes);
                             User_Profile__c up1 = TestData.createTestUserProfile(contacts[0], provisioning.Id, provServices);

        // Page preparation
        PageReference pageRef = Page.SuspendAccount;
        Test.setCurrentPage(pageRef);

        CtrlAP03SuspendAccount controller = new CtrlAP03SuspendAccount(new ApexPages.StandardController(provisioning));
        Test.setMock(WebServiceMock.class, new SuspendAccountMock_ok());
        Test.startTest();
        controller.init();

        controller.cancel();

        // Test all kinds of exceptions
        controller.suspend();
        controller.user.Suspension_Reason__c = 'Bad payer';
        controller.suspend();
        controller.user.Suspension_Start_Date__c = Date.today() - 1;
        controller.suspend();
        controller.user.Suspension_Start_Date__c = Date.today();
        controller.suspend();
        controller.user.Suspension_Start_Date__c = null;
        controller.user.Suspension_End_Date__c = Date.today() - 1;
        controller.suspend();
        controller.user.Suspension_Start_Date__c = Date.today();
        controller.user.Suspension_End_Date__c = Date.today() + 1;
        controller.suspend();

        controller.availableContacts[0].selected = true;
        controller.contacts[0].selected = true;
        controller.suspend();
        controller.selectAll();
        controller.suspend();

        controller.suspendOption = 'Service(s) / Service Attibutes(s)'; // Not equals 'Subscription'
        controller.selectAll();
        controller.suspend();

        Test.stopTest();

    }
/*
    public static testMethod void testCtrl2() {

        // Data generation
        List<ID> services = TestData.createTestServices(10);
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);

        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
                                    Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
                                    Id accountId = TestData.createTestAccounts().Id;
                               List<ID> contacts = TestData.createTestContacts(accountId, 10);
                                   Id contractId = TestData.createTestContract(accountId).Id;
                                       Id subsId = TestData.createTestSubscription(productId, contractId).Id;
                    Provisioning__c provisioning = TestData.createTestProvisioningAndServices(subsId, contractId, accountId);
                  Map<ID, List<Id>> provServices = TestData.createTestProvisioningHierarchy(provisioning.Id, servWithServAttributes);
                             User_Profile__c up1 = TestData.createTestUserProfile(contacts[0], provisioning.Id, provServices);
                             User_Profile__c up2 = TestData.createTestUserProfile(contacts[1], provisioning.Id, provServices);

        // Page preparation
        PageReference pageRef = Page.SuspendAccount;
        Test.setCurrentPage(pageRef);

        CtrlAP03SuspendAccount controller = new CtrlAP03SuspendAccount(new ApexPages.StandardController(provisioning));

        Test.startTest();
        controller.init();

        controller.refreshList();
        controller.getUser();
        controller.getOptionsFilter();
        controller.getContacts();
        controller.getServices();
        controller.selectAllSusp();

        controller.applyFilterAccName();
        controller.applyFilterAccNumber();
        controller.applyFilterTlrNumber();
        controller.applyFilterDebtorNumber();
        controller.applyFilterCountry();
        controller.applyFilterCity();

        controller.suspendOption = 'Service(s) / Service Attibutes(s)'; // Not equals 'Subscription'
        controller.selectAll();
        controller.suspend();

        Test.stopTest();

    }
*/
    public static testMethod void testCtrl3() {
/*
        // Data generation
        List<ID> services = TestData.createTestServices(10);
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);

        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
                                    Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
                                    Id accountId = TestData.createTestAccounts().Id;
                               List<ID> contacts = TestData.createTestContacts(accountId, 10);
                                   Id contractId = TestData.createTestContract(accountId).Id;
                                       Id subsId = TestData.createTestSubscription(productId, contractId).Id;
                    Provisioning__c provisioning = TestData.createTestProvisioningAndServices(subsId, contractId, accountId);
                  Map<ID, List<Id>> provServices = TestData.createTestProvisioningHierarchy(provisioning.Id, servWithServAttributes);
                             User_Profile__c up1 = TestData.createTestUserProfile(contacts[0], provisioning.Id, provServices);
                             User_Profile__c up2 = TestData.createTestUserProfile(contacts[1], provisioning.Id, provServices);

        // Page preparation
        PageReference pageRef = Page.SuspendAccount;
        Test.setCurrentPage(pageRef);

        CtrlAP03SuspendAccount controller = new CtrlAP03SuspendAccount(new ApexPages.StandardController(provisioning));

        Test.startTest();
        controller.init();

        controller.suspendOption = 'Service(s) / Service Attibutes(s)'; // Not equals 'Subscription'
        controller.selAllSusp = true;
        controller.suspend();

        Test.stopTest();
*/
    }
}