@isTest
global class ProvisioningTiviosViaESB {

    // Wrapper for request output
    public class wrapperParam 
    {
        public String error;
        public Id contactId;
    }
    
    
    /**
     * Calls the provisioning web service on ESB.
     *
     * @param[in]    id    Id of the user profile to provision
     * @return    True
     */
    WebService static String Provisioning(String id) 
    {
        wrapperParam wrapper = new wrapperParam();
        wktransportservicesComCrmProvisioning.CRMProvisioningObjectsType req = prepareRequest(id, wrapper);
        
        if (wrapper.error == 'OK')
        {
            crmlibSftoesb.SFToESBExport1_SFToESBHttpPort ws = createWS();
            wktransportservicesComCrmProvisioning.CRMProvisioningResponseType ret = callWS(ws, req);
            String response = handleResponse(ret, wrapper.contactId);
            
            return response;
        }
        else
            return wrapper.error;
    }
    
    public static wktransportservicesComCrmProvisioning.CRMProvisioningObjectsType prepareRequest(String id, wrapperParam wrapper)
    {
        //Current date
        Datetime dateAndTime = Datetime.now();
        String StrDateAndTime = dateAndTime.format('MM/dd/yyyy HH:mm');
        
        // Database query : Contact id
        User_Profile__c userProfile = [SELECT Tivios_Role__c, FX_Login__c, FX_Acces_Kind__c, Contact__c FROM User_Profile__c WHERE Id = :id];

        // Database query : Contact information 
        Contact contactInfo = [SELECT Title, Salutation, Phone, Name, MobilePhone, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, LastName, Language__c, Id, FirstName, Fax, Email, Description, CreatedById, AccountId FROM Contact WHERE Id = :userProfile.Contact__c];
        wrapper.contactId = contactInfo.Id;

        // Database query : Account information + subscription (dans account)
        Account accountInfo = [SELECT Website, VAT__c, Tivios_Subscription__c, Subscription_Status__c, Subscription_ID__c, Phone, ParentId, Name, Id, Fax, Deactivation_Date__c, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity, Activation_Date__c, Account_Level__c FROM Account WHERE Id = :contactInfo.AccountId];
        
        // Data quality check
        List<String> missingInfo = new String[0];
        if (accountInfo.Name == null) missingInfo.add('Account Name');
        if (accountInfo.BillingCountry == null) missingInfo.add('Account Billing Country');
        if (accountInfo.BillingStreet == null) missingInfo.add('Account Billing Street');
        if (accountInfo.BillingState == null) missingInfo.add('Account Billing State');
        if (contactInfo.Name == null) missingInfo.add('Contact Name');
        if (contactInfo.FirstName == null) missingInfo.add('Contact First Name');
        if (contactInfo.Email == null) missingInfo.add('Contact Email');
        if (contactInfo.Salutation == null) missingInfo.add('Contact Salutation');
        if (contactInfo.Language__c == null) missingInfo.add('Contact Language');
        if (contactInfo.MailingStreet == null) missingInfo.add('Contact Mailing Street');
        if (contactInfo.MailingState == null) missingInfo.add('Contact Mailing State');
        if (contactInfo.MailingCountry == null) missingInfo.add('Contact Mailing Country');
        if (accountInfo.Tivios_Subscription__c == null) missingInfo.add('Tivios Subscription');
        if (accountInfo.Subscription_Status__c == null) missingInfo.add('Subscription Status');
        if (accountInfo.Activation_Date__c == null) missingInfo.add('Subscription Activation Date');
        
        if (missingInfo.size() > 0)
        {
            wrapper.error = 'Error: following information are missing\n';
            for (String s : missingInfo)
                wrapper.error += '\t- ' + s + '\n';
                
            return null;
        }
        
        // Request to send
        wktransportservicesComCrmProvisioning.CRMProvisioningObjectsType req = new wktransportservicesComCrmProvisioning.CRMProvisioningObjectsType();
        // Account
        req.account = new wktransportservicesComCrmProvisioning.CRMProvisioningAccountType();
        try 
        {
            req.account.companyId = accountInfo.ID;
        }
        catch (Exception ex) 
        {
            wrapper.error = 'Error : Invalid Account Id';
            return null;
        }
        req.account.id = '';
        req.account.companyName = (accountInfo.Name != null) ? accountInfo.Name : '';
        req.account.country = (accountInfo.BillingCountry != null) ? accountInfo.BillingCountry.toUpperCase() : '';
        req.account.postalCode = (accountInfo.BillingPostalCode != null) ? accountInfo.BillingPostalCode : '';
        req.account.telephoneNumber = (accountInfo.Phone != null) ? accountInfo.Phone : '';
        req.account.adressLine1 = (accountInfo.BillingStreet != null) ? accountInfo.BillingStreet : '';
        req.account.location = ''; 
        req.account.location += ((accountInfo.BillingStreet != null) ? accountInfo.BillingStreet + ' ' : '');
        req.account.location += ((accountInfo.BillingPostalCode != null) ? accountInfo.BillingPostalCode + ' ' : '');
        req.account.location += ((accountInfo.BillingCity != null) ? accountInfo.BillingCity + ' ' : '');
        req.account.location += ((accountInfo.BillingState != null) ? accountInfo.BillingState + ' ' : '');
        req.account.location += ((accountInfo.BillingCountry != null) ? accountInfo.BillingCountry: '');
        req.account.state = (accountInfo.BillingState != null) ? accountInfo.BillingState : '';
        req.account.city = (accountInfo.BillingCity != null) ? accountInfo.BillingCity : '';
        req.account.fax = (accountInfo.Fax != null) ? accountInfo.Fax : '';
        req.account.level = (accountInfo.Account_Level__c != null) ? accountInfo.Account_Level__c : '';
        req.account.vat = (accountInfo.VAT__c != null) ? accountInfo.VAT__c : '';
        try 
        {
            req.account.parentId = accountInfo.ParentId;
        }
        catch (Exception ex) 
        {
            wrapper.error = 'Error : Copy Account Id';
            return null;
        }
        req.account.adressLine2 = '';
        req.account.adressLine3 = '';
        req.account.webSiteUrl = (accountInfo.Website != null) ? accountInfo.Website : '';
        req.account.phoneCountryCode = '';
        req.account.phoneCityCode = '';
        req.account.phoneExtension = '';
        req.account.phoneNumber = (accountInfo.Phone != null) ? accountInfo.Phone : '';
        req.account.faxCountryCode = '';
        req.account.faxCityCode = '';
        req.account.faxExtension = '';
        req.account.faxNumber = (accountInfo.Fax != null) ? accountInfo.Fax : '';
        req.account.mobileCountryCode = '';
        req.account.mobileCityCode = '';
        req.account.mobileExtension = '';
        req.account.mobileNumber = '';
        req.account.timeStamp = StrDateAndTime;
        req.account.sourceSystemID = 'CRM';
        req.account.targetSystemID = new String[1];
        req.account.targetSystemID[0] = 'TOP';
        req.account.action = 'add';
        
        // Contact
        req.contact = new wktransportservicesComCrmProvisioning.CRMProvisioningContactType();
        try 
        {
            req.contact.contactSourceUID = contactInfo.Id;
        }
        catch (Exception ex) 
        {
            wrapper.error = 'Error : Invalid Contact Id';
            return null;
        }
        req.contact.id = '';
        req.contact.description = (contactInfo.Description != null) ? contactInfo.Description : 'No Description';
        req.contact.fullName = (contactInfo.Name != null) ? contactInfo.Name : '';
        req.contact.givenName = (contactInfo.FirstName != null) ? contactInfo.FirstName : '';
        req.contact.fax = (contactInfo.Fax != null) ? contactInfo.Fax : '';
        req.contact.initials = '';
        req.contact.initials += (contactInfo.FirstName != null) ? contactInfo.FirstName.substring(0, 1) : '';
        req.contact.initials += (contactInfo.LastName != null) ? contactInfo.LastName.substring(0, 1) : '';
        req.contact.internetEmailAdress = (contactInfo.Email != null) ? contactInfo.Email : '';
        req.contact.location = '';
        req.contact.location += ((contactInfo.MailingStreet != null) ? contactInfo.MailingStreet + ' ' : '');
        req.contact.location += ((contactInfo.MailingPostalCode != null) ? contactInfo.MailingPostalCode + ' ' : '');
        req.contact.location += ((contactInfo.MailingCity != null) ? contactInfo.MailingCity + ' ' : '');
        req.contact.location += ((contactInfo.MailingState != null) ? contactInfo.MailingState + ' ' : '');
        req.contact.location += ((contactInfo.MailingCountry!= null) ? contactInfo.MailingCountry : '');
        req.contact.surname = (contactInfo.LastName != null) ? contactInfo.LastName : '';
        req.contact.telephoneNumber = (contactInfo.Phone != null) ? contactInfo.Phone : '';
        req.contact.title = (contactInfo.Salutation != null) ? contactInfo.Salutation : '';
        req.contact.jobCode = (contactInfo.Title != null) ? contactInfo.Title : 'Empty';
        req.contact.language = (contactInfo.Language__c != null) ? contactInfo.Language__c.toUpperCase() : '';
        req.contact.streetAddress = (contactInfo.MailingStreet != null) ? contactInfo.MailingStreet : '';
        req.contact.state = (contactInfo.MailingState != null) ? contactInfo.MailingState : '';
        req.contact.postalCode = (contactInfo.MailingPostalCode != null) ? contactInfo.MailingPostalCode : '';
        req.contact.city = (contactInfo.MailingCity != null) ? contactInfo.MailingCity : '';
        req.contact.country = (contactInfo.MailingCountry != null) ? contactInfo.MailingCountry.toUpperCase() : '';
        req.contact.adressLine2 = '';
        req.contact.adressLine3 = '';
        req.contact.otherPhoneNumber = (contactInfo.MobilePhone != null) ? contactInfo.MobilePhone : '';
        req.contact.webSiteUrl = (accountInfo.Website != null) ? accountInfo.Website : '';
        req.contact.phoneCountryCode = '';
        req.contact.phoneCityCode = '';
        req.contact.phoneExtension = '';
        req.contact.phoneNumber = (contactInfo.Phone != null) ? contactInfo.Phone : '';
        req.contact.faxCountryCode = '';
        req.contact.faxCityCode = '';
        req.contact.faxExtension = '';
        req.contact.faxNumber = (contactInfo.Fax != null) ? contactInfo.Fax : '';
        req.contact.mobileCountryCode = '';
        req.contact.mobileCityCode = '';
        req.contact.mobileExtension = '';
        req.contact.mobileNumber = (contactInfo.MobilePhone != null) ? contactInfo.MobilePhone : '';
        req.contact.fxLogin = (userProfile.FX_Login__c != null) ? userProfile.FX_Login__c : '';
        req.contact.fxAccknd = (userProfile.FX_Acces_Kind__c != null) ? userProfile.FX_Acces_Kind__c : '';
        req.contact.activationDate = StrDateAndTime;
        try 
        {
            req.contact.userCreatorId = contactInfo.CreatedById;
        }
        catch (Exception ex) 
        {
            wrapper.error = 'Error : Invalid Creator Id';
            return null;
        }
        req.contact.contactStatus = 'Activated';
        req.contact.groupsMembership = new wktransportservicesComCrmProvisioning.CRMProvisioningGroupsMembershipType();
        // Multi-picklist Tivios_Role__c        
        if (userProfile.Tivios_Role__c != null)
        {
            List<String> roles = userProfile.Tivios_Role__c.split(';');
        
            req.contact.groupsMembership.groupMembership = new String[roles.size()];
                   
            for (Integer i = 0; i < roles.size(); i++)
            {
                req.contact.groupsMembership.groupMembership[i] = roles[i];
            }
        }
        try 
        {
            req.contact.ownerAccountID = accountInfo.Id;
        }
        catch (Exception ex) 
        {
            wrapper.error = 'Error : Invalid owner Account Id';
            return null;
        }
        req.contact.timeStamp = StrDateAndTime;
        req.contact.sourceSystemID = 'CRM';
        req.contact.targetSystemID = new String[1];
        req.contact.targetSystemID[0] = 'TOP';
        req.contact.action = 'add';
        
        // Subscription
        req.subscription = new wktransportservicesComCrmProvisioning.CRMProvisioningSubscriptionType[1];
        req.subscription[0] = new wktransportservicesComCrmProvisioning.CRMProvisioningSubscriptionType();
        req.subscription[0].subscriptionID = (accountInfo.Subscription_ID__c != null) ? accountInfo.Subscription_ID__c : '';
        req.subscription[0].description = 'Tivios' + ((accountInfo.Tivios_Subscription__c != null) ? ' ' + accountInfo.Tivios_Subscription__c : '') + ' Subscription';
        req.subscription[0].fullName = 'Tivios' + ((accountInfo.Tivios_Subscription__c != null) ? '_' + accountInfo.Tivios_Subscription__c : '');
        req.subscription[0].activationDate = (accountInfo.Activation_Date__c != null) ? accountInfo.Activation_Date__c.format('MM/dd/yyyy HH:mm') : '';
        DateTime dateFuture = dateAndTime.addYears(150);
        req.subscription[0].deactivationDate = (accountInfo.Deactivation_Date__c != null) ? accountInfo.Deactivation_Date__c.format('MM/dd/yyyy HH:mm') : dateFuture.format('MM/dd/yyyy HH:mm');
        try 
        {
            req.subscription[0].parentID = accountInfo.Id;
        }
        catch (Exception ex) 
        {
            wrapper.error = 'Error : Invalid parent Account Id';
            return null;
        }
        req.subscription[0].productType = 'TOP' + ((accountInfo.Tivios_Subscription__c != null) ? '_' + accountInfo.Tivios_Subscription__c.toUpperCase() : '');
        req.subscription[0].status = (accountInfo.Subscription_Status__c != null) ? accountInfo.Subscription_Status__c : '';
        req.subscription[0].timeStamp = StrDateAndTime;
        req.subscription[0].sourceSystemID = 'CRM';
        req.subscription[0].targetSystemID = new String[1];
        req.subscription[0].targetSystemID[0] = 'TOP';
        req.subscription[0].action = 'add';
        
        wrapper.error = 'OK';
        return req;
    } 
    
    public static crmlibSftoesb.SFToESBExport1_SFToESBHttpPort createWS()
    {
        // Web Service to call
        crmlibSftoesb.SFToESBExport1_SFToESBHttpPort WS = new crmlibSftoesb.SFToESBExport1_SFToESBHttpPort();
        WS.timeout_x = 20000;
        return WS;
    }
    
    public static wktransportservicesComCrmProvisioning.CRMProvisioningResponseType callWS(crmlibSftoesb.SFToESBExport1_SFToESBHttpPort WS, wktransportservicesComCrmProvisioning.CRMProvisioningObjectsType req)
    {
        System.Debug('Provisioning start');
        wktransportservicesComCrmProvisioning.CRMProvisioningResponseType ret = WS.Provisionning(req);
        System.Debug('Provisioning return status: ' + ret.status + ' login: ' + ret.login);
        return ret;
    }
    
    public static String handleResponse(wktransportservicesComCrmProvisioning.CRMProvisioningResponseType ret, Id contactId)
    {
        if (ret.status == 'OK')
        {
            try
            {
                Contact myContact = [SELECT Id, Username__c FROM Contact WHERE id = :contactId];
                myContact.Username__c = ret.login;
                update myContact;

                return 'Provisioning is complete';
            }
            catch (Exception e)
            {
                return 'Warning: Contact login copy';
            }
        }
        else if (ret.status == 'ERROR')
        {
            try
            {
                Contact myContact = [SELECT Id, Username__c FROM Contact WHERE id = :contactId];
                myContact.Username__c = 'Error During Provisioning';
                update myContact;
            }
            catch (Exception e)
            {
            }
            
            return 'Error During Provisioning';
        }
        else
            return ret.status;
    }
    
    static testMethod void testProvisioning()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
    	
        Account accnt = TST_AccountTestHelper.createDummyAccount(false);
        accnt.Tivios_Subscription__c = 'Enterprise';
        accnt.Subscription_Status__c = 'Active';
        accnt.Activation_Date__c = Datetime.now();
        insert accnt;
        
        Contact contact = TST_ContactTestHelper.createDummyContact(accnt, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), false);
        contact.Key_contact_or_decision_maker__c=true;
        insert contact;
        
        User_Profile__c userP = new User_Profile__c();
        userP.Contact__c = contact.Id;
        userP.Tivios_Role__c = 'COMPANY_MANAGER; PLANNER_SUPERVISOR';
        userP.Contact_Id__c = contact.Id;
        userP.Username__c = contact.Id;
        insert userP;
        
        wrapperParam wrapper = new wrapperParam();
        wktransportservicesComCrmProvisioning.CRMProvisioningObjectsType req = prepareRequest(userP.id, wrapper);
        
        System.AssertEquals('OK', wrapper.error);
        
        crmlibSftoesb.SFToESBExport1_SFToESBHttpPort ws = createWS();
        wktransportservicesComCrmProvisioning.CRMProvisioningResponseType ret = new wktransportservicesComCrmProvisioning.CRMProvisioningResponseType();
        ret.status = 'OK';
        ret.login = 'WFXX016708';
        
        String response = handleResponse(ret, wrapper.contactId);
        
        String userN = [SELECT Username__c FROM Contact WHERE Id = :wrapper.contactId].Username__c;
        
        System.AssertEquals('Provisioning is complete', response);
        System.AssertEquals('WFXX016708', userN);
        
        ret.status = 'ERROR';
        
        response = handleResponse(ret, wrapper.contactId);
        
        userN = [SELECT Username__c FROM Contact WHERE Id = :wrapper.contactId].Username__c;
        
        System.AssertEquals('Error During Provisioning', response);
        System.AssertEquals('Error During Provisioning', userN);
        
        crmlibSftoesb.ProvisionningResponse_element pre = new crmlibSftoesb.ProvisionningResponse_element();
        crmlibSftoesb.Provisionning_element pe = new crmlibSftoesb.Provisionning_element();
    }
}