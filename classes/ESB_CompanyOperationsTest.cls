/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2014 December 4
* @description  unit tests for ESB CompanyOperations class (incoming ESB Calls)
*/
@isTest
public with sharing class ESB_CompanyOperationsTest
{
    private class myTestData
    {
        public ESB_DataClasses.company company;
        public ESB_DataClasses.user user;
        
        public Account account;
        public Account parentAccount;
        public Account operationalParentAccount;
        
        public Contact contact;
    }
    public class EsbMock_ok implements HttpCalloutMock 
	{
		public HTTPResponse respond(HTTPRequest req) 
		{
			Httpresponse resp = new Httpresponse();
			resp.SetStatusCode(200);
			return resp;
		}
	}
	private static myTestData InitData()
	{
        myTestData retVal = new myTestData();
        retVal.user = new ESB_DataClasses.user();
        retVal.user.businessId = new ESB_DataClasses.businessIdentifier();
        retVal.user.businessId.id = 'U-123abc';
        retVal.user.creationDate = DateTime.now().addHours(-9);
        retVal.user.companyBusinessAccount = new ESB_DataClasses.businessIdentifier();
        retVal.user.companyBusinessAccount.id = 'FAKE';
        retVal.user.email = 'user@company.com';
        retVal.user.login = 'U-LOGIN123';
        retVal.user.userTitle = new ESB_DataClasses.dictionary();
        retVal.user.userTitle.value.add('Mr.');
        retVal.user.firstName = 'Test';
        retVal.user.lastName = 'Tetest';
        retVal.user.phone = new ESB_DataClasses.communicationDetails();
        retVal.user.phone.countryNumber = '32';
        retVal.user.phone.prefixNumber = '12';
        retVal.user.phone.localNumber = '22456789';
        retVal.user.mobile = new ESB_DataClasses.communicationDetails();
        retVal.user.mobile.countryNumber = '32';
        retVal.user.mobile.prefixNumber = '3';
        retVal.user.mobile.localNumber = '45316789';
        retVal.user.fax = new ESB_DataClasses.communicationDetails();
        retVal.user.fax.countryNumber = '32';
        retVal.user.fax.prefixNumber = '33';
        retVal.user.fax.localNumber = '456333789';
        retVal.user.preferredLanguage = 'en_GB';
        retVal.user.preferredTimezone = 'Europe/Minsk';
        retVal.user.status = ESB_DataClasses.userStatus.CREATED;
        retVal.user.userType = ESB_DataClasses.userType.SUPERUSER;
        
        retVal.company = new ESB_DataClasses.company();
        retVal.company.creationDate = DateTime.now().addHours(-5);
        retVal.company.businessId = new ESB_DataClasses.businessIdentifier();
        retVal.company.businessId.id = 'FAKE';
        retVal.company.companyState = ESB_DataClasses.companyState.CREATED;
        retVal.company.companyType = ESB_DataClasses.companyObjectsTypeEnum.SHIPPER;
        retVal.company.name = 'test company';
        retVal.company.vat = 'FR123';
        retVal.company.tradeRegistrationNumber = '1234576';
        retVal.company.transportLicenseNumber = 'LIC-4321';
        retVal.company.email = 'company@company.com';
        retVal.company.website = 'http://company.com';
        retVal.company.phone = new ESB_DataClasses.communicationDetails();
        retVal.company.phone.countryNumber = '32';
        retVal.company.phone.prefixNumber = '2';
        retVal.company.phone.localNumber = '1234533';
        retVal.company.fax = new ESB_DataClasses.communicationDetails();
        retVal.company.fax.countryNumber = '32';
        retVal.company.fax.prefixNumber = '21';
        retVal.company.fax.localNumber = '65422211';
        
        retVal.company.users = new ESB_DataClasses.users();
        retVal.company.users.user.add(retVal.user);
        
        ESB_DataClasses.address addr = new ESB_DataClasses.address();
        addr.businessId = new ESB_DataClasses.businessIdentifier();
        addr.businessId.id = 'A-123abc';
        addr.country = 'BE';
        addr.city = 'Brussels';
        addr.postCode = '1234';
        addr.streetName = 'Lenina';
        addr.timezone = 'Europe/Sarajevo';
        addr.creationDate =  DateTime.now().addHours(-9);
        addr.homeNumber = '123';
        addr.locationTypes = new ESB_DataClasses.locationTypes();
        addr.locationTypes.addressLocationType.add(ESB_DataClasses.addressLocationTypeEnum.postal);
        
        retVal.company.addresses = new ESB_DataClasses.addresses();
        retVal.company.addresses.address.add(addr);
        
        List<ESB_PA_to_ProductsMapping__c> mappings = new List<ESB_PA_to_ProductsMapping__c>();
        mappings.add(new ESB_PA_to_ProductsMapping__c(Name = 'CD_approved', ESB_BusinessProduct__c = 'WKTSAdmin'));
        mappings.add(new ESB_PA_to_ProductsMapping__c(Name = 'CD_guest', ESB_BusinessProduct__c = 'WKTSAdmin'));
        mappings.add(new ESB_PA_to_ProductsMapping__c(Name = 'FX_Start_UK', ESB_BusinessProduct__c = 'FX'));
        
        insert mappings;
        
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        
        retVal.account = TST_AccountTestHelper.createDummyAccount(false);
        retVal.parentAccount = TST_AccountTestHelper.createDummyAccount(true);
        retVal.operationalParentAccount = TST_AccountTestHelper.createDummyAccount(true);
        
        retVal.parentAccount = [SELECT Id, Name, AccountNumber FROM Account WHERE Id = :retVal.parentAccount.Id];
        retVal.operationalParentAccount = [SELECT Id, Name, AccountNumber FROM Account WHERE Id = :retVal.operationalParentAccount.Id];
            
        retVal.account.ParentId = retVal.parentAccount.Id;
        retVal.account.TWA_Parent_ID__c = retVal.operationalParentAccount.Id;
        retVal.account.ESB_Company_Type__c = 'SHIPPER';
        insert retVal.account;
        retVal.account = [SELECT Id, Name, AccountNumber FROM Account WHERE Id = :retVal.account.Id];
        
        retVal.company.parentCompanyBusinessAccount = new ESB_DataClasses.businessIdentifier();
        retVal.company.parentCompanyBusinessAccount.id = retVal.parentAccount.AccountNumber;
        retVal.company.operationalParentCompanyBusinessAccount = new ESB_DataClasses.businessIdentifier();
        retVal.company.operationalParentCompanyBusinessAccount.id = retVal.operationalParentAccount.AccountNumber;
        
        retVal.contact = TST_ContactTestHelper.createDummyContact(retVal.account, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), false);
        retVal.contact.ESB_BuisnessID__c = retVal.user.businessId.id;
        insert retVal.contact;
        
        retVal.company.businessId.id = retVal.account.AccountNumber;
            
        // we need offer tempalte called CD_Offer
        
        
        return retVal;
	}
    
    private static myTestData InitDataWithSubscription()
	{
        myTestData retVal = InitData();
        
        // 1) create oppty
        Opportunity oppty = new Opportunity();
        oppty.Name = 'CD opportunity for invited guest';
        oppty.Product_Interest__c = 'CD';
        oppty.StageName = 'New not worked';
        oppty.Probability = 10;
        oppty.CloseDate = date.today();
        oppty.AccountId = retVal.account.Id;
        insert oppty;                   // 2 soql queries
        
        system.debug('---------- ESB_CompanyOperations: CreateGuestCompanyAutomated: oppty created: ' + oppty);
        
        // 2) attach offer template
        Offer_Template__c ot = [
            SELECT Id, Name, Default_Value__c, CUG_allowed__c, CurrencyIsoCode 
            FROM Offer_Template__c 
            WHERE Name = 'CD offer'
        ];                              // 1 soql query
        oppty.Offer_Template__c = ot.Id;
        oppty.CurrencyIsoCode = ot.CurrencyIsoCode;             // from ChooseOfferTemplateExt
        oppty.Maximum_Invoice_Amount__c = ot.Default_Value__c;  // from ChooseOfferTemplateExt
        oppty.CUG_allowed__c = ot.CUG_allowed__c;               // from ChooseOfferTemplateExt
        
        oppty.StageName = 'Contract request';
        update oppty;               // here we will attach line items, packFees, create quote, because of trigger
                                    // 17 queries
        
        system.debug('---------- ESB_CompanyOperations: CreateGuestCompanyAutomated: oppty updated: ' + oppty);
        
        // 3) accept offer: create contract & subscription
        // first we need to extract allneeded fields from Oppty
        oppty = [
            SELECT 
                Id, Name, AccountId, Maximum_Invoice_Amount__c, Start_Usage_Payment_Date__c, CloseDate,
                StageName, RecordTypeId, Offer_Template__c, Offer_Template__r.Name, Offer_Template__r.Access_Kind__c,
                Offer_Template__r.Base_Product__c, Offer_Template__r.Contract_Term__c, Offer_Template__r.Default_Invoice_Level__c,
                Offer_Template__r.Default_Invoice_Media__c, Offer_Template__r.Default_Payment_Method__c,
                Offer_Template__r.Skip_Bank_information_validation__c,
                CUG_allowed__c, CurrencyIsoCode, 
                Type, Product_Interest__c, Reason_Lost__c, Reason_Won__c, Competitors__c, Probability,
                CampaignId, Additonal_comments__c,
                Expected_revenue__c,
                Contact__c, Development_Taylor_Made__c, Expected_Revenue_Date__c, License_Fee__c, Maintenance__c,
                Professional_Services__c, Rental_Monthly_Fee__c
            FROM Opportunity 
            WHERE Id = :oppty.Id
        ];
        TLR_SubscriptionHelper subsHelper = new TLR_SubscriptionHelper();
        Id contractId = TLR_ContractHelper.CreateNewContract(oppty, oppty.Offer_Template__r);
        Id subsId = subsHelper.CreateNewSubscription(contractId, oppty, oppty.Offer_Template__r);
        system.debug('---------- ESB_CompanyOperations: CreateGuestCompanyAutomated: Subscription created. subsId: ' + subsId);
        
        
        // 4) attach contact as superUser to subscription and initiate provisioning
        Subscription__c subs = [SELECT Id, Name, Contact__c, Status__c, Flag_IntegrityChecks__c FROM Subscription__c WHERE Id=:subsId];
        system.debug('---------- ESB_CompanyOperations: CreateGuestCompanyAutomated: subscription found: ' + subs);
        subs.Contact__c = retVal.contact.Id;
        subs.Flag_IntegrityChecks__c = true;
        //subs.Status__c = 'Sent';
        //update subs;
        //subs.Status__c = 'Waiting For Verification';
        //update subs;
        subs.Status__c = 'Waiting For Provisioning';
        update subs;
        
        system.debug('---------- ESB_CompanyOperations: CreateGuestCompanyAutomated: subscription updated: ' + subs);
        // insert currentFees
        // first we need to select one
        List<Subs_Package_And_Fee__c> subsPFList = [
            SELECT
                Id, Name, Comments__c, 
                Subscription__r.Account__r.Id, Subscription__r.Account__r.AccountNumber, Subscription__r.Account__r.Account_Level__c
            FROM Subs_Package_And_Fee__c
            WHERE Subscription__c = :subs.Id
        ];
        system.debug('---------- ESB_CompanyOperations: CreateGuestCompanyAutomated: subsPFList: ' + subsPFList);
        Subs_Package_And_Fee__c cdGuestPF = null;
        for(Subs_Package_And_Fee__c spf : subsPFList)
        {
            if(spf.Name == 'CD_guest')
                cdGuestPF = spf;
        }
        if(cdGuestPF != null)
        {
            system.debug('---------- ESB_CompanyOperations: CreateGuestCompanyAutomated: starting currentFee creation. subsPF: ' + cdGuestPF);
            TLR_SubscriptionHelper.CreateSingleSubscriptionCurrentFee(
                cdGuestPF.Name,                 // name
                date.today(),                   // startdate
                cdGuestPF.Subscription__r.Account__r.Id,
                cdGuestPF.Subscription__r.Account__r.AccountNumber,
                cdGuestPF.Subscription__r.Account__r.Account_Level__c,
                subs.Id,
                cdGuestPF.Id,
                cdGuestPF.Comments__c,          // notes
                true                            // inservNow
            );
        }
        
        return retVal;
    }
    
    private static void validateUserContact(ESB_DataClasses.user user, Contact cont)
    {
        system.AssertEquals(user.email, cont.Email, 'Contact email is not saved!');
        system.AssertEquals(user.userTitle.value[0], cont.Salutation, 'Contact salutation is not saved!');
        system.AssertEquals(user.firstName, cont.FirstName, 'Contact email is not saved!');
        system.AssertEquals(user.lastName, cont.LastName, 'Contact email is not saved!');
        system.AssertEquals(string.valueOf(user.status), cont.ESB_User_Status__c, 'Contact ESB user status is not saved!');
        system.AssertEquals(user.businessId.id, cont.ESB_BuisnessID__c, 'Contact BuisnessID is not saved!');
        system.AssertEquals(user.login, cont.Username__c, 'Contact username is not saved!');
        system.AssertEquals(/*user.preferredLanguage*/'English', cont.Language__c, 'Contact language is not saved!');
        system.AssertEquals(user.preferredTimezone, cont.Time_Zone__c, 'Contact timezone is not saved!');
        
        string phone = ESB_ConvertHelper.composePhoneNumber(user.phone);
	    system.assertEquals(phone, cont.Phone, 'Contact phone is not saved!');
        string mobile = ESB_ConvertHelper.composePhoneNumber(user.mobile);
	    system.assertEquals(mobile, cont.MobilePhone, 'Contact phone is not saved!');
	    
	    // as of now (27.01.2015) WKTSA does not store fax for users, so we will not accept fax updates
        //string fax = ESB_ConvertHelper.composePhoneNumber(user.fax);
	    //system.assertEquals(fax, cont.Fax, 'Contact phone is not saved!');
    } //validateUserContact
    
    private static void validateCompanyAccount(ESB_DataClasses.company company, Account acc)
    {
        system.AssertEquals(string.valueOf(company.companyState), acc.ESB_Company_Status__c, 'Company status is not saved!');
        system.AssertEquals(string.valueOf(company.companyType), acc.ESB_Company_Type__c, 'Company type is not saved!');
        system.AssertEquals(company.addresses.address[0].businessId.id, acc.ESB_ShippingAddress_ID__c, 'Company address ID is not saved!');
        system.AssertEquals('Belgium', acc.ShippingCountry, 'Company Country is not saved!');
        system.AssertEquals(company.addresses.address[0].city, acc.ShippingCity, 'Company city is not saved!');
        system.AssertEquals(company.addresses.address[0].postCode, acc.ShippingPostalCode, 'Company postCode is not saved!');
        system.AssertEquals(string.Format('{0} {1}',  new string[] {
            company.addresses.address[0].streetName,
            company.addresses.address[0].homeNumber })
               , acc.ShippingStreet, 'Company street and home number are not saved!');
        system.AssertEquals(company.addresses.address[0].timeZone, acc.Time_Zone__c, 'Company timezone is not saved!');
        system.AssertEquals(company.email, acc.Email__c, 'Company email is not saved!');
        system.AssertEquals(company.tradeRegistrationNumber, acc.Company_Registration_Number__c, 'Company Company Registration Number__c is not saved!');
        system.AssertEquals(company.vat, acc.VAT__c, 'Company VAT is not saved!');
        system.AssertEquals(company.transportLicenseNumber, acc.Transport_Licence__c, 'Company transport license is not saved!');
        system.AssertEquals(company.website, acc.Website, 'Company Website license is not saved!');
        
        string phone = ESB_ConvertHelper.composePhoneNumber(company.phone);
	    system.assertEquals(phone, acc.Phone, 'Company phone is not saved!');        
        string fax = ESB_ConvertHelper.composePhoneNumber(company.fax);
	    system.assertEquals(fax, acc.Fax, 'Company Fax is not saved!');
        
        // hierarchy
        // parent synchronization is not used in this direction, WKTSA acnnot change parent (usual, not TWA) of an account
        //system.AssertEquals(company.parentCompanyBusinessAccount.id, acc.Parent.AccountNumber, 'Company parent is not saved!');
        system.AssertEquals(company.operationalParentCompanyBusinessAccount.id, acc.Parent_TWA__r.AccountNumber, 'Company TWA parent is not saved!');
        
    } //validateConmapyAccount
    
    
    private static void validateAccountsTheSame(Account acc1, Account acc2)
    {
        system.AssertEquals(acc1.ESB_Company_Status__c, acc2.ESB_Company_Status__c, 'Company status is different!');
        system.AssertEquals(acc1.ESB_Company_Type__c, acc2.ESB_Company_Type__c, 'Company type is different!');
        system.AssertEquals(acc1.ESB_ShippingAddress_ID__c, acc2.ESB_ShippingAddress_ID__c, 'Company address ID is different!');
        system.AssertEquals(acc1.ShippingCountry, acc2.ShippingCountry, 'Company Country is different!');
        system.AssertEquals(acc1.ShippingCity, acc2.ShippingCity, 'Company city is different!');
        system.AssertEquals(acc1.ShippingPostalCode, acc2.ShippingPostalCode, 'Company postCode is different!');
        system.AssertEquals(acc1.ShippingStreet, acc2.ShippingStreet, 'Company street and home number are different!');
        system.AssertEquals(acc1.Time_Zone__c, acc2.Time_Zone__c, 'Company timezone is different!');
        system.AssertEquals(acc1.Email__c, acc2.Email__c, 'Company email is different!');
        system.AssertEquals(acc1.Company_Registration_Number__c, acc2.Company_Registration_Number__c, 'Company Company Registration Number__c is different!');
        system.AssertEquals(acc1.VAT__c, acc2.VAT__c, 'Company VAT is not saved!');
        system.AssertEquals(acc1.Transport_Licence__c, acc2.Transport_Licence__c, 'Company transport license is different!');
        system.AssertEquals(acc1.Website, acc2.Website, 'Company Website license is different!');
	    system.assertEquals(acc1.Phone, acc2.Phone, 'Company phone is different!');        
	    system.assertEquals(acc1.Fax, acc2.Fax, 'Company Fax is different!');
        
        system.AssertEquals(acc1.Parent_TWA__r.AccountNumber, acc2.Parent_TWA__r.AccountNumber, 'Company TWA parent is different!');
        
    } //validateAccountsTheSame
    
    private static void validateContactsTheSame(Contact cont1, Contact cont2)
    {
        system.AssertEquals(cont1.Email, cont2.Email, 'Contact email is different!');
        system.AssertEquals(cont1.Salutation, cont2.Salutation, 'Contact salutation is different!');
        system.AssertEquals(cont1.FirstName, cont2.FirstName, 'Contact email is different!');
        system.AssertEquals(cont1.LastName, cont2.LastName, 'Contact email is different!');
        system.AssertEquals(cont1.ESB_User_Status__c, cont2.ESB_User_Status__c, 'Contact ESB user status is different!');
        system.AssertEquals(cont1.ESB_BuisnessID__c, cont2.ESB_BuisnessID__c, 'Contact BuisnessID is different!');
        system.AssertEquals(cont1.Username__c, cont2.Username__c, 'Contact username is different!');
        system.AssertEquals(cont1.Language__c, cont2.Language__c, 'Contact language is different!');
        system.AssertEquals(cont1.Time_Zone__c, cont2.Time_Zone__c, 'Contact timezone is different!');
	    system.assertEquals(cont1.Phone, cont2.Phone, 'Contact phone is different!');
	    system.assertEquals(cont1.MobilePhone, cont2.MobilePhone, 'Contact phone is different!');
	    
	    // as of now (27.01.2015) WKTSA does not store fax for users, so we will not accept fax updates
    } //validateContactsTheSame
    
    
    public static testMethod void NotifyCompanyCreatedTestPositive()
    {
        myTestData data = initData();
        data.account.AccountNumber = '';
        update data.account;
        data.contact.ESB_BuisnessID__c = '';
        data.contact.AccountId = null;
        update data.contact;
        
        Account invAcc  = TST_AccountTestHelper.createDummyAccount(true);
        data.company.invitedBy = new ESB_DataClasses.invitedBy();
        data.company.invitedBy.byCompany = new ESB_DataClasses.businessIdentifier();
        data.company.invitedBy.byCompany.id = [select AccountNumber from Account where Id =: invAcc.Id].AccountNumber;
        data.company.invitedBy.forProducts = new ESB_DataClasses.wktsBusinessProducts();
        
        Test.startTest();
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        ESB_DataClasses.response resp = ESB_CompanyOperations.NotifyCompanyCreated(data.company, correlationId);
        Test.stopTest();
        
        system.assert([select Id, Invited_By__c from Case].Invited_By__c == invAcc.Id,'Invited_By__c field wasn\'t filled correctly');
        
        system.assert(resp.errors.error.size() == 0, 'ESB Error: ' + string.valueOf(resp.errors.error));
        
        List<Contact> contacts = [
        	SELECT 
            	Id, Name, AccountId, ESB_User_status__c, Email, Salutation, FirstName, LastName,
            	Phone, MobilePhone, Fax, ESB_BuisnessID__c, Language__c, Time_Zone__c, Username__c
        	FROM Contact 
        	WHERE ESB_BuisnessID__c = :data.user.businessId.id
        ];
        
        system.assertEquals(1, contacts.size(), 'Too many or none of contacts are saved!');
        
        if(contacts.size() > 0)
        {
        	Contact cont = contacts[0];
            
            List<Account> accounts = [
                SELECT 
                	Id, Name, AccountNumber, Time_Zone__c, Phone, Fax, Website, VAT__c, Transport_Licence__c, Email__c,
                	ShippingCountry, ShippingCity, ShippingPostalCode, ShippingStreet,
                	ESB_Company_Status__c, ESB_Company_Type__c, ESB_ShippingAddress_ID__c,
                	Parent_TWA__r.AccountNumber, Parent.AccountNumber, Company_Registration_Number__c
                FROM Account 
                WHERE Id = :cont.AccountId
            ];
            
            system.assertEquals(1, accounts.size(), 'Too many or none of accounts are saved!');
            
            Account acc = accounts[0];
            
            system.debug('----------account (data)' + data.account);
            system.debug('----------account (select)' + acc);
            system.debug('----------parent account (data)' + data.parentAccount);
            system.debug('----------parent account (select)' + acc.Parent);
            
            validateUserContact(data.user, cont);
	        validateCompanyAccount(data.company, acc);
            
	        system.AssertEquals(acc.Id, cont.AccountId, 'Contact is not attached to an account! (by SalesForce ID)');
        }
        TestLogPageRedirect();
    } //NotifyCompanyCreatedTestPositive
  
    public static testMethod void NotifyCompanyCreatedTestNegative1()
    {
        myTestData data = initData();
        data.account.AccountNumber = '';
        update data.account;
        data.contact.ESB_BuisnessID__c = '';
        data.contact.AccountId = null;
        update data.contact;
        
        data.company.phone.localNumber = '1 23 4';
        Test.startTest();
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        ESB_DataClasses.response resp = ESB_CompanyOperations.NotifyCompanyCreated(data.company, correlationId);
        Test.stopTest();
        
        system.assert(resp.errors.error.size() > 0, 'Error should be sent!');
        
        List<Contact> contacts = [
        	SELECT 
            	Id, Name
        	FROM Contact 
        	WHERE ESB_BuisnessID__c = :data.user.businessId.id
        ];
        
        List<Account> accounts = [
            SELECT 
            Id, Name, AccountNumber
            FROM Account 
            WHERE Name = :data.company.Name
        ];
        
        system.assertEquals(0, contacts.size(), 'Contact should not be saved!');
        system.assertEquals(0, accounts.size(), 'Account should not be saved!');
    } //NotifyCompanyCreatedTestNegative1
    
    public static testMethod void NotifyUserCreatedTestPositive()
    {
        myTestData data = initData();
        data.account.AccountNumber = '';
        update data.account;
        data.contact.ESB_BuisnessID__c = '';
        update data.contact;
        
        Test.startTest();
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        ESB_DataClasses.response resp = ESB_CompanyOperations.NotifyUserCreated(data.user, correlationId);
        Test.stopTest();
        
        system.assert(resp.errors.error.size() == 0, 'ESB Error: ' + string.valueOf(resp.errors.error));
        
        List<Contact> contacts = [
        	SELECT 
            	Id, Name, AccountId, ESB_User_status__c, Email, Salutation, FirstName, LastName,
            	Phone, MobilePhone, Fax, ESB_BuisnessID__c, Language__c, Time_Zone__c, Username__c
        	FROM Contact 
        	WHERE ESB_BuisnessID__c = :data.user.businessId.id
        ];
        
        system.assertEquals(1, contacts.size(), 'Too many or none of contacts are saved!');
        
        if(contacts.size() > 0)
        {
            Contact cont = contacts[0];
            validateUserContact(data.user, cont);
        }
    } //NotifyUserCreatedTestPositive
    
    public static testMethod void NotifyUserCreatedTestNegative1()
    {
        myTestData data = initData();
        
        // case 1 - try to create existing contact
        data.account.AccountNumber = '';
        update data.account; // new account number will be generated inside trigger
		string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        ESB_DataClasses.response resp = ESB_CompanyOperations.NotifyUserCreated(data.user, correlationId);
        system.assert(resp.errors.error.size() > 0, 'Error should be sent! (case 1 - existing contact)');
        
        // case 2 - contact for missing account
        data.contact.ESB_BuisnessID__c = '';
        update data.contact;
        data.user.companyBusinessAccount.id = 'SOME_MISSING_ID';
        correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        resp = ESB_CompanyOperations.NotifyUserCreated(data.user, correlationId);
        system.assert(resp.errors.error.size() > 0, 'Error should be sent! (case 2 - missing account)');
    } //NotifyUserCreatedTestNegative1
    
    public static testMethod void NotifyUserCreatedTestNegative2()
    {
        myTestData data = initData();
        data.contact.ESB_BuisnessID__c = '';
        update data.contact;
        
        // case 3 - validation error
        data.user.phone.localNumber = '+92 92 92';
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        ESB_DataClasses.response resp = ESB_CompanyOperations.NotifyUserCreated(data.user, correlationId);
        system.assert(resp.errors.error.size() > 0, 'Error should be sent! (case 3 - validation)');
    } //NotifyUserCreatedTestNegative2
    
    public static testMethod void NotifyCompanyUpdatedTestPositive1()
    {
        myTestData data = initData();
        data.company.users = null;
        data.company.productsAccesses = new ESB_DataClasses.productsAccesses();
        data.company.productsAccesses.wktsCompanyProductAccess.add('CD_approved');
        data.company.productsAccesses.wktsCompanyProductAccess.add('FX_Start_UK');
        
        Account acc  = TST_AccountTestHelper.createDummyAccount(true);
        data.company.invitedBy = new ESB_DataClasses.invitedBy();
        data.company.invitedBy.byCompany = new ESB_DataClasses.businessIdentifier();
        data.company.invitedBy.byCompany.id = [select AccountNumber from Account where Id =: acc.Id].AccountNumber;
       	data.company.invitedBy.forProducts = new ESB_DataClasses.wktsBusinessProducts();
     
        
        Test.startTest();
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        ESB_DataClasses.response resp = ESB_CompanyOperations.NotifyCompanyUpdated(data.company, correlationId);
        Test.StopTest();
        
		system.assert([select Id, Invited_By__c from Case].Invited_By__c == acc.Id,'Invited_By__c field wasn\'t filled correctly');
        system.assert(resp.errors.error.size() == 0, 'ESB Error: ' + string.valueOf(resp.errors.error));
        
        data.account = [
            SELECT 
                Id, Name, AccountNumber, Time_Zone__c, Phone, Fax, Website, VAT__c, Transport_Licence__c, Email__c,
                ShippingCountry, ShippingCity, ShippingPostalCode, ShippingStreet,
                ESB_Company_Status__c, ESB_Company_Type__c, ESB_ShippingAddress_ID__c,
                Parent_TWA__r.AccountNumber, Parent.AccountNumber, Company_Registration_Number__c
            FROM Account 
            WHERE Id = :data.account.Id
        ];
        
        validateCompanyAccount(data.company, data.account);
        
        // check created case
		List<Case> cases = [SELECT Id, Subject, Description, RecordTypeId FROM Case WHERE AccountId = :data.account.Id];
        system.assertNotEquals(0, cases.size(), 'No Case created!');
        system.assertEquals(1, cases.size(), 'Too Many Cases created!');
        if(cases.size() > 0)
        {
            Case c = cases.get(0);
            system.debug('---------- case: ' + c);
            //system.assertEquals('TWD Case', TLR_RecordTypeHelper.getName(c.RecordTypeId), 'Wrong case record type!');
            system.assertEquals(TLR_RecordTypeHelper.getId('Case', 'TWD Case'), c.RecordTypeId, 'Wrong case record type!');
            system.assertEquals('Company update', c.Subject, 'Wrong case subject!');
            system.assert(c.Description.indexOf(data.account.AccountNumber) > -1, 'Account number should be in case description!');
        } // if cases > 0
        
    } //NotifyCompanyUpdatedTestPositive
    
    public static testMethod void NotifyCompanyUpdatedTestNegative()
    {
        myTestData data = initData();
        data.company.users = null;
        data.company.productsAccesses = new ESB_DataClasses.productsAccesses();
        data.company.productsAccesses.wktsCompanyProductAccess.add('CD_approved');
        data.company.productsAccesses.wktsCompanyProductAccess.add('FX_Start_UK');
        
        data.account = [
            SELECT 
                Id, Name, AccountNumber, Time_Zone__c, Phone, Fax, Website, VAT__c, Transport_Licence__c, Email__c,
                ShippingCountry, ShippingCity, ShippingPostalCode, ShippingStreet,
                ESB_Company_Status__c, ESB_Company_Type__c, ESB_ShippingAddress_ID__c,
                Parent_TWA__r.AccountNumber, Parent.AccountNumber, Company_Registration_Number__c
            FROM Account 
            WHERE Id = :data.account.Id
        ];
        
        // 1) - test validation error
        data.company.phone.localNumber = '1 23 4 5';
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        ESB_DataClasses.response resp = ESB_CompanyOperations.NotifyCompanyUpdated(data.company, correlationId);
        system.assert(resp.errors.error.size() > 0, 'Error should be sent! (case 1)');
        
        Account acc = [
            SELECT 
                Id, Name, AccountNumber, Time_Zone__c, Phone, Fax, Website, VAT__c, Transport_Licence__c, Email__c,
                ShippingCountry, ShippingCity, ShippingPostalCode, ShippingStreet,
                ESB_Company_Status__c, ESB_Company_Type__c, ESB_ShippingAddress_ID__c,
                Parent_TWA__r.AccountNumber, Parent.AccountNumber, Company_Registration_Number__c
            FROM Account 
            WHERE Id = :data.account.Id
        ];
        validateAccountsTheSame(data.account, acc);
        
        // 2) test missing account
        data.company.phone.localNumber = '12345'; // restore broken value to something correct
        data.company.businessId.id += '111';
        correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        resp = ESB_CompanyOperations.NotifyCompanyUpdated(data.company, correlationId);
        system.assert(resp.errors.error.size() > 0, 'Error should be sent! (case 2)');
        acc = [
            SELECT 
                Id, Name, AccountNumber, Time_Zone__c, Phone, Fax, Website, VAT__c, Transport_Licence__c, Email__c,
                ShippingCountry, ShippingCity, ShippingPostalCode, ShippingStreet,
                ESB_Company_Status__c, ESB_Company_Type__c, ESB_ShippingAddress_ID__c,
                Parent_TWA__r.AccountNumber, Parent.AccountNumber, Company_Registration_Number__c
            FROM Account 
            WHERE Id = :data.account.Id
        ];
        validateAccountsTheSame(data.account, acc);
        
    } //NotifyCompanyUpdatedTestNegative
    
    public static testMethod void NotifySuperUserUpdatedTestPositive()
    {
        myTestData data = initData();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_ok());
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
		data.user.status = ESB_DataClasses.userStatus.APPROVED;
        ESB_DataClasses.response resp = ESB_CompanyOperations.NotifySuperUserUpdated(data.user, correlationId);
        Test.StopTest();
        
        system.assert(resp.errors.error.size() == 0, 'ESB Error: ' + string.valueOf(resp.errors.error));
        
        data.contact = [
        	SELECT 
            	Id, Name, AccountId, ESB_User_status__c, Email, Salutation, FirstName, LastName,
            	Phone, MobilePhone, Fax, ESB_BuisnessID__c, Language__c, Time_Zone__c, Username__c
        	FROM Contact 
        	WHERE Id = :data.contact.Id
        ];
        
        validateUserContact(data.user, data.contact);
        
    } //NotifySuperUserUpdatedTestPositive
    
    public static testMethod void NotifySuperUserUpdatedTestNegative()
    {
        myTestData data = initData();
        
        data.contact = [
        	SELECT 
            	Id, Name, AccountId, ESB_User_status__c, Email, Salutation, FirstName, LastName,
            	Phone, MobilePhone, Fax, ESB_BuisnessID__c, Language__c, Time_Zone__c, Username__c
        	FROM Contact 
        	WHERE Id = :data.contact.Id
        ];
        
        // 1) no contact ID and no company ID
        data.user.companyBusinessAccount = null;
        data.user.businessId.id = '';
        //Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new EsbMock_ok());
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        ESB_DataClasses.response resp = ESB_CompanyOperations.NotifySuperUserUpdated(data.user, correlationId);
        //Test.StopTest();
        
        system.assert(resp.errors.error.size() > 0, 'Error should be sent! (case 1)');
        Contact cont = [
        	SELECT 
            	Id, Name, AccountId, ESB_User_status__c, Email, Salutation, FirstName, LastName,
            	Phone, MobilePhone, Fax, ESB_BuisnessID__c, Language__c, Time_Zone__c, Username__c
        	FROM Contact 
        	WHERE Id = :data.contact.Id
        ];
        
        validateContactsTheSame(data.contact, cont);
        
        // 2) validation error
        data.user.businessId.id = data.contact.ESB_BuisnessID__c;
        data.user.phone.localNumber = '1 2 3 4 rw';
        
        correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        resp = ESB_CompanyOperations.NotifySuperUserUpdated(data.user, correlationId);
        system.assert(resp.errors.error.size() > 0, 'Error should be sent! (case 1)');
        cont = [
        	SELECT 
            	Id, Name, AccountId, ESB_User_status__c, Email, Salutation, FirstName, LastName,
            	Phone, MobilePhone, Fax, ESB_BuisnessID__c, Language__c, Time_Zone__c, Username__c
        	FROM Contact 
        	WHERE Id = :data.contact.Id
        ];
        
        validateContactsTheSame(data.contact, cont);
    } //NotifySuperUserUpdatedTestNegative
    
    
    public static testMethod void ProcessResponseTestPositive()
    {
    	string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
    	
        ESB_LogUtility.WriteLog(ESB_LogUtility.MessageDirection.Outgoing, 'cm.test.test', 'request body', 'response body', correlationId, 200, null, null, null);
		
		ESB_DataClasses.response resp = new ESB_DataClasses.response();
		resp.correlationId = correlationId;
		ESB_DataClasses.responseTracking msg2 = new ESB_DataClasses.responseTracking();
		msg2.messageDate = datetime.now();
		msg2.message.key = '123123';
		msg2.message.content = 'error';
		resp.errors.error.add(msg2);
		
		ESB_CompanyOperations.ProcessResponse(resp);
		
		ESB_Interaction_Logs__c logRecord = [
			SELECT Id, Remote_response__c, CM_Successful_Response_Checkbox__c
			FROM ESB_Interaction_Logs__c
			WHERE Message_correlationId__c = :correlationId
		];
		
		System.assertEquals(string.valueOf(resp), logRecord.Remote_response__c, 'Response message is not saved!');
        System.assertEquals(logRecord.CM_Successful_Response_Checkbox__c, false, 'CM Successful Response value is not correct!');
        TestLogPageResponse('123123','error' );
        
        resp = new ESB_DataClasses.response();
		resp.correlationId = correlationId;
		msg2.message.content = 'success';
		resp.errors.error.add(msg2);
        
        ESB_CompanyOperations.ProcessResponse(resp);
		
		logRecord = [
			SELECT Id, Remote_response__c, CM_Successful_Response_Checkbox__c
			FROM ESB_Interaction_Logs__c
			WHERE Message_correlationId__c = :correlationId
		];
		
		System.assertEquals(string.valueOf(resp), logRecord.Remote_response__c, 'Response message is not saved!');
        System.assertEquals(logRecord.CM_Successful_Response_Checkbox__c, true, 'CM Successful Response value is not correct!');
        TestLogPageResponse('123123','success' );
    } //ProcessResponseTestPositive
    
    public static testMethod void ProcessResponseTestNegative()
    {
        // case 1 - no correlation ID
    	string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
    	
		ESB_DataClasses.response resp = new ESB_DataClasses.response();
		resp.correlationId = correlationId;
		ESB_DataClasses.responseTracking msg2 = new ESB_DataClasses.responseTracking();
		msg2.messageDate = datetime.now();
		msg2.message.key = '123123';
		msg2.message.content = 'blah-blah';
		resp.errors.error.add(msg2);
		
		ESB_DataClasses.response resp2 = ESB_CompanyOperations.ProcessResponse(resp);
		system.assert(resp2.errors.error.size() > 0, 'Error should be sent! (case 1)');
        
        // case 2 - many correlationID
        ESB_LogUtility.WriteLog(ESB_LogUtility.MessageDirection.Outgoing, 'cm.test.test', 'request1 body', 'response1 body', correlationId, 200, null, null, null);
        ESB_LogUtility.WriteLog(ESB_LogUtility.MessageDirection.Outgoing, 'cm.test.test', 'request2 body', 'response2 body', correlationId, 200, null, null, null);
        
        resp2 = ESB_CompanyOperations.ProcessResponse(resp);
		system.assert(resp2.errors.error.size() > 0, 'Error should be sent! (case 2)');
    } //ProcessResponseTestNegative
    
    
    public static testMethod void CreateGuestAutomatedTestPositive()
    {
		TST_OfferTemplateTestHelper.createFullOfferTemplate('CD', 'CD offer', new String[] {'CD_guest', 'CD_approved'});
        myTestData data = initData();
        
        data.account.AccountNumber = '';
        update data.account;
        data.contact.ESB_BuisnessID__c = '';
        update data.contact;
        
        Test.setMock(HttpCalloutMock.class, new EsbMock_ok());
        
        data.company.invitedBy = new ESB_DataClasses.invitedBy();
        data.company.invitedBy.forProducts = new ESB_DataClasses.wktsBusinessProducts();
        data.company.invitedBy.byCompany = new ESB_DataClasses.businessIdentifier();
        data.company.invitedBy.byCompany.id = data.parentAccount.AccountNumber;
        data.company.invitedBy.forProducts.wktsBusinessProduct.add(ESB_DataClasses.wktsBusinessProductEnum.WKTSAdmin);
        
        
            
        
        // to disable outgoing ESB calls
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'st111', Email='standarduse1r@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1111', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Disable_ESB_calls__c = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduse111@testorg.com');

        ESB_DataClasses.response resp;
        System.runAs(u) 	
        {
            Test.startTest();
            string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        	resp = ESB_CompanyOperations.NotifyCompanyCreated(data.company, correlationId);
            Test.stopTest();
        }
        
        system.assert(resp.errors.error.size() == 0, 'ESB Error: ' + string.valueOf(resp.errors.error));
        
        List<Contact> contacts = [
        	SELECT 
            	Id, Name, AccountId, ESB_User_status__c, Email, Salutation, FirstName, LastName,
            	Phone, MobilePhone, Fax, ESB_BuisnessID__c, Language__c, Time_Zone__c, Username__c
        	FROM Contact 
        	WHERE ESB_BuisnessID__c = :data.user.businessId.id
        ];
        
        system.assertEquals(1, contacts.size(), 'Too many or none of contacts are saved!');
        
        if(contacts.size() > 0)
        {
        	Contact cont = contacts[0];
            
            
            List<Account> accounts = [
                SELECT 
                	Id, Name, AccountNumber, Time_Zone__c, Phone, Fax, Website, VAT__c, Transport_Licence__c, Email__c,
                	ShippingCountry, ShippingCity, ShippingPostalCode, ShippingStreet,
                	ESB_Company_Status__c, ESB_Company_Type__c, ESB_ShippingAddress_ID__c,
                	Parent_TWA__r.AccountNumber, Parent.AccountNumber, Company_Registration_Number__c
                FROM Account 
                WHERE Id = :cont.AccountId
            ];
            
            system.assertEquals(1, accounts.size(), 'Too many or none of accounts are saved!');
            
            Account acc = accounts[0];
            
            validateUserContact(data.user, cont);
	        validateCompanyAccount(data.company, acc);
            
	        system.AssertEquals(acc.Id, cont.AccountId, 'Contact is not attached to an account! (by SalesForce ID)');
            
            // check subscription
            List<Subscription__c> subsList = [
                SELECT 
                	Id, Name, Status__c, Offer_Template__r.Name
                FROM Subscription__c 
                WHERE Account__c = :acc.Id
            ];
            system.assertNotEquals(0, subsList.size(), 'No Subscriptions created!');
            system.assertEquals(1, subsList.size(), 'Too Many Subscriptions created!');
            if(subsList.size() > 0)
            {
                Subscription__c subs = subsList.get(0);
                
                system.assertEquals('CD offer', subs.Offer_Template__r.Name, 'Wrong offer tempalte attached to subscription!');
                system.assertEquals('Active', subs.Status__c, 'Subscription is not activated!');
                
                // we need to have 1 subs current fee - cd_guest
                List<Subs_Current_Fee__c> scfList = [SELECT Id, Name, Start_Date__c FROM Subs_Current_Fee__c WHERE Subscription__c = :subs.Id];
                system.assertNotEquals(0, scfList.size(), 'No curerntFees created!');
            	system.assertEquals(1, scfList.size(), 'Too Many curerntFees created!');
                if(scfList.size() > 0)
                {
                    Subs_Current_Fee__c scf = scfList.get(0);
                    system.assertEquals('CD_guest', scf.Name, 'Wrong curerntFee attached!');
                    //system.assertEquals(date.today(), scf.Start_Date__c, 'Wrong curerntFee start date!'); //strange SF behavior
                } // if current fees size > 0
            } // if subscriptions size > 0
        } // if contacts size > 0
    } //CreateGuestAutomatedTestPositive
	
    
    public static testMethod void RemoveUserTestPositive()
    {
        myTestData data = initData();
        
        System.assertNotEquals('SUSPENDED', data.contact.ESB_User_status__c, 'Wrong ESB User status before removal!');
        
        Test.startTest();
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        ESB_DataClasses.response resp = ESB_CompanyOperations.RemoveUser(data.user, correlationId);
        Test.stopTest();
        
        system.assert(resp.errors.error.size() == 0, 'ESB Error: ' + string.valueOf(resp.errors.error));
        
        data.contact = [SELECT Id, ESB_User_status__c FROM Contact WHERE ESB_BuisnessID__c = :data.user.businessId.id];
        
        System.assertEquals('SUSPENDED', data.contact.ESB_User_status__c, 'ESB User status is not updated!');
    } //RemoveUserTestPositive
    
    public static testMethod void RemoveUserTestNegative()
    {
        myTestData data = initData();
        data.user.businessId.id += '123';
        
        System.assertNotEquals('SUSPENDED', data.contact.ESB_User_status__c, 'Wrong ESB User status before removal!');
        
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        ESB_DataClasses.response resp = ESB_CompanyOperations.RemoveUser(data.user, correlationId);
        system.assert(resp.errors.error.size() > 0, 'Error should be sent!');
        
        Contact contact = [SELECT Id, ESB_User_status__c FROM Contact WHERE Id = :data.contact.id];
        
        System.assertEquals(data.contact.ESB_User_status__c, contact.ESB_User_status__c, 'ESB User status is updated!');
    } //RemoveUserTestNegative
    
	
    public static testMethod void NotifyCompanyPublishedTestPositive()
    {
        TST_OfferTemplateTestHelper.createFullOfferTemplate('CD', 'CD offer', new String[] {'CD_guest', 'CD_approved'});
        Test.startTest();
        myTestData data = InitDataWithSubscription();
        data.company.businessId.id = data.account.AccountNumber;
        data.company.users = null;
        Test.StopTest();
        
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        ESB_DataClasses.response resp = ESB_CompanyOperations.NotifyCompanyPublished(data.company, correlationId);
        
        
        system.assert(resp.errors.error.size() == 0, 'ESB Error: ' + string.valueOf(resp.errors.error));
		// check created case
		List<Case> cases = [SELECT Id, Subject, Description, RecordTypeId FROM Case WHERE AccountId = :data.account.Id];
        system.assertNotEquals(0, cases.size(), 'No Case created!');
        system.assertEquals(1, cases.size(), 'Too Many Cases created!');
        if(cases.size() > 0)
        {
            Case c = cases.get(0);
            system.debug('---------- case: ' + c);
            //system.assertEquals('TWD Case', TLR_RecordTypeHelper.getName(c.RecordTypeId), 'Wrong case record type!');
            system.assertEquals(TLR_RecordTypeHelper.getId('Case', 'TWD Case'), c.RecordTypeId, 'Wrong case record type!');
            system.assertEquals('Publish company', c.Subject, 'Wrong case subject!');
            system.assert(c.Description.indexOf(data.account.AccountNumber) > -1, 'Account number should be in case description!');
            system.assert(c.Description.indexOf(data.account.Name) > -1, 'Account name should be in case description!');
        } // if cases > 0
    } //NotifyCompanyPublishedTestPositive
    
    public static testMethod void NotifyCompanyPublishedTestNegative()
    {
        TST_OfferTemplateTestHelper.createFullOfferTemplate('CD', 'CD offer', new String[] {'CD_guest', 'CD_approved'});
        Test.startTest();
        myTestData data = InitDataWithSubscription();
        Test.StopTest();
        
        data.company.users = null;
        
        // case 1 - missig account
        data.company.businessId.id = 'MISSING_ID';
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        ESB_DataClasses.response resp = ESB_CompanyOperations.NotifyCompanyPublished(data.company, correlationId);        
        system.assert(resp.errors.error.size() > 0, 'Error should be sent!');
        
    } //NotifyCompanyPublishedTestNegative
    
    public static testMethod void CorrelationIdTests_NotifyCompanyCreated()
    {
        myTestData data = initData();
        data.account.AccountNumber = '';
        update data.account;
        data.contact.ESB_BuisnessID__c = '';
        data.contact.AccountId = null;
        update data.contact;
        
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        
        Test.startTest();
        // case 1: positive
        ESB_DataClasses.response resp1 = ESB_CompanyOperations.NotifyCompanyCreated(data.company, correlationId);
        
        // case 2: missing correlationId
        ESB_DataClasses.response resp2 = ESB_CompanyOperations.NotifyCompanyCreated(data.company, '');
        
        // case 3: duplicated correlationId
        ESB_DataClasses.response resp3 = ESB_CompanyOperations.NotifyCompanyCreated(data.company, correlationId);
        Test.stopTest();
        
        List<ESB_Interaction_Logs__c> logs = [
            SELECT 
            	Id, Name, Message_CorrelationId__c, Message__c 
            FROM ESB_Interaction_Logs__c 
            WHERE Message_CorrelationId__c = :correlationId
            	AND Message__c = null // correct message, without errors, case 1
        ];
        system.assertEquals(1, logs.size(), 'Something is wrong with ESB logs!');
        logs = [
            SELECT 
            	Id, Name, Message_CorrelationId__c, Message__c 
            FROM ESB_Interaction_Logs__c 
            WHERE Message_CorrelationId__c = :correlationId
            	AND Message__c != null // message with errors: case 3
        ];
        system.assertEquals(1, logs.size(), 'Something is wrong with ESB logs!');
        
        system.assert(resp1.errors.error.size() == 0, 'Error should not be sent!');
        system.assert(resp2.errors.error.size() > 0, 'Error should be sent! (missing correlationID)');
        system.assert(resp3.errors.error.size() > 0, 'Error should be sent! (duplicated correlationID)');
    } // CorrelationIdTests_NotifyCompanyCreated
    
    public static testMethod void CorrelationIdTests_NotifyUserCreated()
    {
        myTestData data = initData();
        data.account.AccountNumber = '';
        update data.account;
        data.contact.ESB_BuisnessID__c = '';
        update data.contact;
        
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        
        Test.startTest();
        // case 1: positive        
        ESB_DataClasses.response resp1 = ESB_CompanyOperations.NotifyUserCreated(data.user, correlationId);
        
        // case 2: missing correlationId        
        ESB_DataClasses.response resp2 = ESB_CompanyOperations.NotifyUserCreated(data.user, '');
        
        // case 3: duplicated correlationId        
        ESB_DataClasses.response resp3 = ESB_CompanyOperations.NotifyUserCreated(data.user, correlationId);
        Test.stopTest();
        
        List<ESB_Interaction_Logs__c> logs = [
            SELECT 
            	Id, Name, Message_CorrelationId__c, Message__c 
            FROM ESB_Interaction_Logs__c 
            WHERE Message_CorrelationId__c = :correlationId
            	AND Message__c = null // correct message, without errors, case 1
        ];
        system.assertEquals(1, logs.size(), 'Something is wrong with ESB logs!');
        logs = [
            SELECT 
            	Id, Name, Message_CorrelationId__c, Message__c 
            FROM ESB_Interaction_Logs__c 
            WHERE Message_CorrelationId__c = :correlationId
            	AND Message__c != null // message with errors: case 3
        ];
        system.assertEquals(1, logs.size(), 'Something is wrong with ESB logs!');
        
        system.assert(resp1.errors.error.size() == 0, 'Error should not be sent!');
        system.assert(resp2.errors.error.size() > 0, 'Error should be sent! (missing correlationID)');
        system.assert(resp3.errors.error.size() > 0, 'Error should be sent! (duplicated correlationID)');        
    } //CorrelationIdTests_NotifyUserCreated
    
    public static testMethod void CorrelationIdTests_NotifyCompanyUpdated()
    {
        myTestData data = initData();
        data.company.users = null;
        data.company.productsAccesses = new ESB_DataClasses.productsAccesses();
        data.company.productsAccesses.wktsCompanyProductAccess.add('CD_approved');
        data.company.productsAccesses.wktsCompanyProductAccess.add('FX_Start_UK');
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        
        Test.startTest();
        // case 1: positive 
        ESB_DataClasses.response resp1 = ESB_CompanyOperations.NotifyCompanyUpdated(data.company, correlationId);
        
        // case 2: missing correlationId  
        ESB_DataClasses.response resp2 = ESB_CompanyOperations.NotifyCompanyUpdated(data.company, '');
        
        // case 3: duplicated correlationId  
        ESB_DataClasses.response resp3 = ESB_CompanyOperations.NotifyCompanyUpdated(data.company, correlationId);
        Test.StopTest();
        
        List<ESB_Interaction_Logs__c> logs = [
            SELECT 
            	Id, Name, Message_CorrelationId__c, Message__c 
            FROM ESB_Interaction_Logs__c 
            WHERE Message_CorrelationId__c = :correlationId
            	AND Message__c = null // correct message, without errors, case 1
        ];
        system.assertEquals(1, logs.size(), 'Something is wrong with ESB logs!');
        logs = [
            SELECT 
            	Id, Name, Message_CorrelationId__c, Message__c 
            FROM ESB_Interaction_Logs__c 
            WHERE Message_CorrelationId__c = :correlationId
            	AND Message__c != null // message with errors: case 3
        ];
        system.assertEquals(1, logs.size(), 'Something is wrong with ESB logs!');
        
        system.assert(resp1.errors.error.size() == 0, 'Error should not be sent!');
        system.assert(resp2.errors.error.size() > 0, 'Error should be sent! (missing correlationID)');
        system.assert(resp3.errors.error.size() > 0, 'Error should be sent! (duplicated correlationID)');
    } //CorrelationIdTests_NotifyCompanyUpdated
    
    public static testMethod void CorrelationIdTests_NotifySuperUserUpdated()
    {
        myTestData data = initData();
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EsbMock_ok());
        // case 1: positive 
		data.user.status = ESB_DataClasses.userStatus.APPROVED;
        ESB_DataClasses.response resp1 = ESB_CompanyOperations.NotifySuperUserUpdated(data.user, correlationId);
        
        // case 2: missing correlationId 
        ESB_DataClasses.response resp2 = ESB_CompanyOperations.NotifySuperUserUpdated(data.user, '');
        
        // case 3: duplicate correlationId 
        ESB_DataClasses.response resp3 = ESB_CompanyOperations.NotifySuperUserUpdated(data.user, correlationId);
        Test.StopTest();
        
        List<ESB_Interaction_Logs__c> logs = [
            SELECT 
            	Id, Name, Message_CorrelationId__c, Message__c 
            FROM ESB_Interaction_Logs__c 
            WHERE Message_CorrelationId__c = :correlationId
            	AND Message__c = null // correct message, without errors, case 1
        ];
        system.assertEquals(1, logs.size(), 'Something is wrong with ESB logs!');
        logs = [
            SELECT 
            	Id, Name, Message_CorrelationId__c, Message__c 
            FROM ESB_Interaction_Logs__c 
            WHERE Message_CorrelationId__c = :correlationId
            	AND Message__c != null // message with errors: case 3
        ];
        system.assertEquals(1, logs.size(), 'Something is wrong with ESB logs!');
        
        system.assert(resp1.errors.error.size() == 0, 'Error should not be sent!');
        system.assert(resp2.errors.error.size() > 0, 'Error should be sent! (missing correlationID)');
        system.assert(resp3.errors.error.size() > 0, 'Error should be sent! (duplicated correlationID)');
    } //CorrelationIdTests_NotifySuperUserUpdated
    
    public static testMethod void CorrelationIdTests_NotifyCompanyPublished()
    {
        TST_OfferTemplateTestHelper.createFullOfferTemplate('CD', 'CD offer', new String[] {'CD_guest', 'CD_approved'});
        Test.startTest();
        myTestData data = InitDataWithSubscription();
        data.company.businessId.id = data.account.AccountNumber;
        data.company.users = null;
        Test.StopTest();
        
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        
        // case 1: positive 
        ESB_DataClasses.response resp1 = ESB_CompanyOperations.NotifyCompanyPublished(data.company, correlationId);
        
        // case 2: missing correlationId 
        ESB_DataClasses.response resp2 = ESB_CompanyOperations.NotifyCompanyPublished(data.company, '');
        
        // case 3: duplicated correlationId 
        ESB_DataClasses.response resp3 = ESB_CompanyOperations.NotifyCompanyPublished(data.company, correlationId);
        
        List<ESB_Interaction_Logs__c> logs = [
            SELECT 
            	Id, Name, Message_CorrelationId__c, Message__c 
            FROM ESB_Interaction_Logs__c 
            WHERE Message_CorrelationId__c = :correlationId
            	AND Message__c = null // correct message, without errors, case 1
        ];
        system.assertEquals(1, logs.size(), 'Something is wrong with ESB logs!');
        logs = [
            SELECT 
            	Id, Name, Message_CorrelationId__c, Message__c 
            FROM ESB_Interaction_Logs__c 
            WHERE Message_CorrelationId__c = :correlationId
            	AND Message__c != null // message with errors: case 3
        ];
        system.assertEquals(1, logs.size(), 'Something is wrong with ESB logs!');
        
        system.assert(resp1.errors.error.size() == 0, 'Error should not be sent!');
        system.assert(resp2.errors.error.size() > 0, 'Error should be sent! (missing correlationID)');
        system.assert(resp3.errors.error.size() > 0, 'Error should be sent! (duplicated correlationID)');
    } //CorrelationIdTests_NotifyCompanyPublished
    
    public static testMethod void CorrelationIdTests_RemoveUser()
    {
    	myTestData data = initData();
        System.assertNotEquals('SUSPENDED', data.contact.ESB_User_status__c, 'Wrong ESB User status before removal!');
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        
        Test.startTest();
        // case 1: positive
        ESB_DataClasses.response resp1 = ESB_CompanyOperations.RemoveUser(data.user, correlationId);
        
        // case 2: missing correlationId 
        ESB_DataClasses.response resp2 = ESB_CompanyOperations.RemoveUser(data.user, null);
        
        // case 3: duplicated correlationId 
        ESB_DataClasses.response resp3 = ESB_CompanyOperations.RemoveUser(data.user, correlationId);
        Test.stopTest();
        
        List<ESB_Interaction_Logs__c> logs = [
            SELECT 
            	Id, Name, Message_CorrelationId__c, Message__c 
            FROM ESB_Interaction_Logs__c 
            WHERE Message_CorrelationId__c = :correlationId
            	AND Message__c = null // correct message, without errors, case 1
        ];
        system.assertEquals(1, logs.size(), 'Something is wrong with ESB logs!');
        logs = [
            SELECT 
            	Id, Name, Message_CorrelationId__c, Message__c 
            FROM ESB_Interaction_Logs__c 
            WHERE Message_CorrelationId__c = :correlationId
            	AND Message__c != null // message with errors: case 3
        ];
        system.assertEquals(1, logs.size(), 'Something is wrong with ESB logs!');
        
        system.assert(resp1.errors.error.size() == 0, 'Error should not be sent!');
        system.assert(resp2.errors.error.size() > 0, 'Error should be sent! (missing correlationID)');
        system.assert(resp3.errors.error.size() > 0, 'Error should be sent! (duplicated correlationID)');
    } //CorrelationIdTests_RemoveUser
    
    private static void TestLogPageRedirect()
    {
        ESB_Interaction_Logs__c log = [select Id, Remote_response__c from ESB_Interaction_Logs__c];        
        ApexPages.StandardController scontroller = new ApexPages.StandardController(log);
        CtrlESBInteractionLogs controller = new CtrlESBInteractionLogs(scontroller);
        PageReference redirectAddress = controller.checkForRedirect();  
        system.assert(redirectAddress.getUrl() == ('/'+log.Id+'?nooverride=1'),'wrong redirect address');
    }
    
    private static void TestLogPageResponse(string responseKey, string responseContent)
    {
        ApexPages.StandardController scontroller;
        CtrlESBInteractionLogs controller;
        List<ESB_Interaction_Logs__c> logs = [select Id, Remote_response__c from ESB_Interaction_Logs__c];  
        for(integer i=0; i<logs.size(); i++)
        {
            scontroller = new ApexPages.StandardController(logs[i]);
            controller = new CtrlESBInteractionLogs(scontroller);
            system.assert(CtrlESBInteractionLogs.responseKey == responseKey,logs+ 'responseKey is wrong'+CtrlESBInteractionLogs.responseKey);
            system.assert(CtrlESBInteractionLogs.responseContent == responseContent,logs+ 'responseContent is wrong'+CtrlESBInteractionLogs.responseContent);
        }
    }
}