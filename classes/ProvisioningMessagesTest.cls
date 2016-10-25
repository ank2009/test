@isTest
public class ProvisioningMessagesTest
{
	private static void Init()
	{
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
	}  
	public class ProvisioningMock_assign_ok implements WebServiceMock 
	{
		public Void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType)
		{
			LibSFDCToESBV2.ProvisionningV2Response_element request_x = new LibSFDCToESBV2.ProvisionningV2Response_element();
			request_x.output = new LibWKTSComCrmProvisioningV2.CRMProvisionningResponseTypev2();
			request_x.output.status = 'Success';
			response.put('response_x', request_x);
		}
	}
 	 	
 	public static testMethod void testSendInitialProvisioningRequests()
    {
    	 Init();
        // -------------
        // Data creation
        // -------------
        
        // Services
        List<ID> services = TestData.createTestServices(10);
            
        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
        
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        
        // Product
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        
        // Account
        Account a = TST_AccountTestHelper.createDummyAccount('France',true);
        Id accountId = a.Id;
        Account accnt = [SELECT Id, About_Specialization__c, BIC_Code__c, Description, Company_Creation_Date__c,
                                Completion_Level__c, Customer_Since__c, Total_employees__c,
                                Iban_Number__c, ISO_Certification__c, Company_Registration_Number__c,
                                Number_of_trucks_owned__c FROM Account WHERE Id = :accountId];
        accnt.About_Specialization__c = 'ADR/dangerous goods';
        accnt.BIC_Code__c = 'AAAAAA12123';
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
        
        // Contacts
        List<Contact> contacts = TST_ContactTestHelper.createDummyContactList(accnt ,10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        List<ID> contactsId = new List<ID>();
        
        for(Contact con: contacts)
        {
            contactsId.add(con.Id);
        }
            
        // Contract
        Id contractId = TestData.createTestContract(accountId).Id;
        
        // Subscription
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;
        
        // Provisioning
        Id provisioningId = TestData.createTestProvisioningAndServices(subsId, contractId, accountId).Id;
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioningId, servWithServAttributes); 
    
        // User Profiles
        List<ID> userProfiles = TestData.createTestUserProfiles(contactsId , provisioningId, provServices);
            
        // ----------
        // Start Test
        // ----------
        // Init();
        Test.setMock(WebServiceMock.class, new ProvisioningMock_assign_ok());
        Test.startTest();
        
        ProvisioningMessages.SendInitialProvisioningRequests(userProfiles);
        
        Test.stopTest();
    }
    public static testMethod void testSendReProvisioning()
    {
    	Init();
        // -------------
        // Data creation
        // -------------
        
        // Services
        List<ID> services = TestData.createTestServices(10);
            
        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
        
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        
        // Product
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        
        // Account
        Account a = TST_AccountTestHelper.createDummyAccount('France', true);
        Id accountId = a.Id;
        Account accnt = [SELECT Id, About_Specialization__c, BIC_Code__c, Description, Company_Creation_Date__c,
                                Completion_Level__c, Customer_Since__c, Total_employees__c,
                                Iban_Number__c, ISO_Certification__c, Company_Registration_Number__c,
                                Number_of_trucks_owned__c FROM Account WHERE Id = :accountId];
        accnt.About_Specialization__c = 'ADR/dangerous goods';
        accnt.BIC_Code__c = 'AAAAAA12123';
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
        
        // Contacts
        List<Contact> contacts = TST_ContactTestHelper.createDummyContactList(accnt ,10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        List<ID> contactsId = new List<ID>();
        
        for(Contact con: contacts)
        {
            contactsId.add(con.Id);
        }
            
        // Contract
        Id contractId = TestData.createTestContract(accountId).Id;
        
        // Subscription
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;
        
        // Provisioning
        Id provisioningId = TestData.createTestProvisioningAndServices(subsId, contractId, accountId).Id;
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioningId, servWithServAttributes); 
    
        // User Profiles
        List<ID> userProfiles = TestData.createTestUserProfiles(contactsId , provisioningId, provServices);
            
        // ----------
        // Start Test
        // ----------
        //Init();
        Test.setMock(WebServiceMock.class, new ProvisioningMock_assign_ok());
        
        Test.startTest();
        
        ProvisioningMessages.SendReProvisioning(userProfiles);
        
        Test.stopTest();
    }
    
    public static testMethod void testCancelSubscription()
    {
    	Init();
        // -------------
        // Data creation
        // -------------
        
        // Services
        List<ID> services = TestData.createTestServices(10);
            
        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
        
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        
        // Product
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        
        // Account
        Account a = TST_AccountTestHelper.createDummyAccount('France', true);
        Id accountId = a.Id;
        Account accnt = [SELECT Id, About_Specialization__c, BIC_Code__c, Description, Company_Creation_Date__c,
                                Completion_Level__c, Customer_Since__c, Total_employees__c,
                                Iban_Number__c, ISO_Certification__c, Company_Registration_Number__c,
                                Number_of_trucks_owned__c FROM Account WHERE Id = :accountId];
        accnt.About_Specialization__c = 'ADR/dangerous goods';
        accnt.BIC_Code__c = 'AAAAAA12123';
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
        
        // Contacts
        List<Contact> contacts = TST_ContactTestHelper.createDummyContactList(accnt ,10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        List<ID> contactsId = new List<ID>();
        
        for(Contact con: contacts)
        {
            contactsId.add(con.Id);
        }
            
        // Contract
        Id contractId = TestData.createTestContract(accountId).Id;
        
        // Subscription
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;
        
        // Provisioning
        Id provisioningId = TestData.createTestProvisioningAndServices(subsId, contractId, accountId).Id;
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioningId, servWithServAttributes); 
    
        // User Profiles
        List<ID> userProfiles = TestData.createTestUserProfiles(contactsId , provisioningId, provServices);
        
        //createCustomSettings();    
  		Test.setMock(WebServiceMock.class, new ProvisioningMock_assign_ok());
        // ----------
        // Start Test
        // ----------
        Test.startTest();
        
        ProvisioningMessages.CancelSubscription(subsId, Date.Today());
        
        Test.stopTest();
    }
    
    public static testMethod void testCancelSubscriptionMassProvisioning()
    {
    	Init();
        // -------------
        // Data creation
        // -------------
        
        // Services
        List<ID> services = TestData.createTestServices(10);
            
        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
        
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        
        // Product
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        
        // Account
        Account a = TST_AccountTestHelper.createDummyAccount('France',true);
        Id accountId = a.Id;
        Account accnt = [SELECT Id, About_Specialization__c, BIC_Code__c, Description, Company_Creation_Date__c,
                                Completion_Level__c, Customer_Since__c, Total_employees__c,
                                Iban_Number__c, ISO_Certification__c, Company_Registration_Number__c,
                                Number_of_trucks_owned__c FROM Account WHERE Id = :accountId];
        accnt.About_Specialization__c = 'ADR/dangerous goods';
        accnt.BIC_Code__c = 'AAAAAA12123';
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
        
        // Contacts
        List<Contact> contacts = TST_ContactTestHelper.createDummyContactList(accnt ,10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        List<ID> contactsId = new List<ID>();
        
        for(Contact con: contacts)
        {
            contactsId.add(con.Id);
        }
            
        // Contract
        Id contractId = TestData.createTestContract(accountId).Id;
        
        // Subscription
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;
        
        // Provisioning
        Id provisioningId = TestData.createTestProvisioningAndServices(subsId, contractId, accountId).Id;
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioningId, servWithServAttributes); 
    
        // User Profiles
        List<ID> userProfiles = TestData.createTestUserProfiles(contactsId , provisioningId, provServices);
           
        // ----------
        // Start Test
        // ----------

  		Test.setMock(WebServiceMock.class, new ProvisioningMock_assign_ok());
        Test.startTest();
        
        ProvisioningMessages.CancelSubscriptionMassProvisioning(subsId, Date.Today(),userProfiles);
        
        Test.stopTest();
    }
     public static testMethod void testUpdateAccount()
    {
    	Init();
        // -------------
        // Data creation
        // -------------
        
        // Services
        List<ID> services = TestData.createTestServices(10);
            
        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
        
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        
        // Product
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        
        // Account
        Account a = TST_AccountTestHelper.createDummyAccount('France',true);
        Id accountId = a.Id;
        Account accnt = [SELECT Id, About_Specialization__c, BIC_Code__c, Description, Company_Creation_Date__c,
                                Completion_Level__c, Customer_Since__c, Total_employees__c,
                                Iban_Number__c, ISO_Certification__c, Company_Registration_Number__c,
                                Number_of_trucks_owned__c FROM Account WHERE Id = :accountId];
        accnt.About_Specialization__c = 'ADR/dangerous goods';
        accnt.BIC_Code__c = 'AAAAAA12123';
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
        
        // Contacts
        List<Contact> contacts = TST_ContactTestHelper.createDummyContactList(accnt ,10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        List<ID> contactsId = new List<ID>();
        
        for(Contact con: contacts)
        {
            contactsId.add(con.Id);
        }
            
        // Contract
        Id contractId = TestData.createTestContract(accountId).Id;
        
        // Subscription
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;
        
        // Provisioning
        Id provisioningId = TestData.createTestProvisioningAndServices(subsId, contractId, accountId).Id;
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioningId, servWithServAttributes); 
    
        // User Profiles
        List<ID> userProfiles = TestData.createTestUserProfiles(contactsId , provisioningId, provServices);
           
        // ----------
        // Start Test
        // ----------

  		Test.setMock(WebServiceMock.class, new ProvisioningMock_assign_ok());
        Test.startTest();
        
        ProvisioningMessages.UpdateAccount(subsId);
        
        Test.stopTest();
    }
    public static testMethod void testUpdateContact()
    {
    	Init();
        // -------------
        // Data creation
        // -------------
        
        // Services
        List<ID> services = TestData.createTestServices(10);
            
        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
        
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        
        // Product
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        
        // Account
        Account a = TST_AccountTestHelper.createDummyAccount('France',true);
        Id accountId = a.Id;
        Account accnt = [SELECT Id, About_Specialization__c, BIC_Code__c, Description, Company_Creation_Date__c,
                                Completion_Level__c, Customer_Since__c, Total_employees__c,
                                Iban_Number__c, ISO_Certification__c, Company_Registration_Number__c,
                                Number_of_trucks_owned__c FROM Account WHERE Id = :accountId];
        accnt.About_Specialization__c = 'ADR/dangerous goods';
        accnt.BIC_Code__c = 'AAAAAA12123';
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
        
        // Contacts
        List<Contact> contacts = TST_ContactTestHelper.createDummyContactList(accnt ,10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        List<ID> contactsId = new List<ID>();
        
        for(Contact con: contacts)
        {
            contactsId.add(con.Id);
        }
            
        // Contract
        Id contractId = TestData.createTestContract(accountId).Id;
        
        // Subscription
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;
        
        // Provisioning
        Id provisioningId = TestData.createTestProvisioningAndServices(subsId, contractId, accountId).Id;
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioningId, servWithServAttributes); 
    
        // User Profiles
        List<ID> userProfiles = TestData.createTestUserProfiles(contactsId , provisioningId, provServices);
           
        // ----------
        // Start Test
        // ----------

  		Test.setMock(WebServiceMock.class, new ProvisioningMock_assign_ok());
        Test.startTest();
        
        ProvisioningMessages.UpdateContact(userProfiles);
        
        Test.stopTest();
    }
     public static testMethod void testSuspendAndUnsuspendUsersInSubscription()
    {
    	Init();
        // -------------
        // Data creation
        // -------------
        
        // Services
        List<ID> services = TestData.createTestServices(10);
            
        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
        
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        
        // Product
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        
        // Account
        Account a = TST_AccountTestHelper.createDummyAccount('France', true);
        Id accountId = a.Id;
        Account accnt = [SELECT Id, About_Specialization__c, BIC_Code__c, Description, Company_Creation_Date__c,
                                Completion_Level__c, Customer_Since__c, Total_employees__c,
                                Iban_Number__c, ISO_Certification__c, Company_Registration_Number__c,
                                Number_of_trucks_owned__c FROM Account WHERE Id = :accountId];
        accnt.About_Specialization__c = 'ADR/dangerous goods';
        accnt.BIC_Code__c = 'AAAAAA12123';
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
        
        // Contacts
        List<Contact> contacts = TST_ContactTestHelper.createDummyContactList(accnt ,10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        List<ID> contactsId = new List<ID>();
        
        for(Contact con: contacts)
        {
            contactsId.add(con.Id);
        }
            
        // Contract
        Id contractId = TestData.createTestContract(accountId).Id;
        
        // Subscription
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;
        
        // Provisioning
        Id provisioningId = TestData.createTestProvisioningAndServices(subsId, contractId, accountId).Id;
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioningId, servWithServAttributes); 
    
        // User Profiles
        List<ID> userProfiles = TestData.createTestUserProfiles(contactsId , provisioningId, provServices);
        Map<ID, List<ID>> mapSubUps = new Map<ID, List<ID>>();   
        
        for (User_Profile__c up : [Select Provisioning__r.Subscription__c FROM User_Profile__c Where Id =:userProfiles])
        {
           if (mapSubUps.get(up.Provisioning__r.Subscription__c) == null)
               mapSubUps.put(up.Provisioning__r.Subscription__c, new List<ID>());
               
           mapSubUps.get(up.Provisioning__r.Subscription__c).add(up.Id);
        }   
          
        // ----------
        // Start Test
        // ----------

  		Test.setMock(WebServiceMock.class, new ProvisioningMock_assign_ok());
        Test.startTest();
        
        ProvisioningMessages.SuspendUsersInSubscription(mapSubUps,'SuspendAll');
        ProvisioningMessages.UnsuspendUsersInSubscription(mapSubUps);
              
        Test.stopTest();
    }
}