/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2014 April 10
* @description  contains methods to call ESB methods
*/
public class ESB_Proxy
{
    private static string xmlDateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss';
    private static string esbNamespacePrefix = 'v1';
    private static string esbNamespaceURI = 'http://www.wktransportservices.com/schema/communitymanager/mbs/v1_1';
    private static string crmNamespacePrefix = 'wktscm';
    private static string crmNamespaceURI = 'http://www.wktransportservices.com/schema/mbs/obss/companyuseraddress/v1_6';
    private static string envelopeNamespaceURI = 'http://schemas.xmlsoap.org/soap/envelope/';
    
    @future(callout = true)
    public static void CreateGuestCompany(Id accountId, Id contactId)
    {
        // check, if we allowed to do ESB calls
        User u = [SELECT Id, Name, Disable_ESB_calls__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(u.Disable_ESB_calls__c)
        {
            system.debug('--------ESB_Proxy: CreateGuestCompany: ESB calls are disabled for user ' + u.Name);
            return;
        }
        XmlStreamWriter bodyWriter = writeCompany(accountId, contactId, true, null, true);
        string requestBody = bodyWriter.getXmlString();
        
        system.debug('--------ESB_Proxy: CreateGuestCompany: request body: ' + requestBody);
        
        SendRequestToESB('cm', 'company', 'provision', requestBody, accountId, contactId);
    } //CreateGuestCompany
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 April 10
    * @description  call WKTSAdmin through OSB to notify about company creatino
    */
    @future(callout = true)
    public static void CreateCompany(Id accountId, Id contactId, Boolean writeUser, Id SubscriptionId)
    {
        // check, if we allowed to do ESB calls
        User u = [SELECT Id, Name, Disable_ESB_calls__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(u.Disable_ESB_calls__c)
        {
            system.debug('--------ESB_Proxy: CreateCompany: ESB calls are disabled for user ' + u.Name);
            return;
        }
        // get needed fields from Account
        Account acc = [
            SELECT
                Id, Name, CreatedDate, LastModifiedDate, Company_Type__c, VAT__c, Email__c, Fax, Phone, Website,
                BillingCountry, BillingState, BillingCity, BillingPostalCode, BillingStreet,
                ShippingCountry, ShippingState, ShippingCity, ShippingPostalCode, ShippingStreet,
                Time_Zone__c, Customer_Since__c, Company_Registration_Number__c, Transport_Licence__c, ParentID,
                ESB_Company_Type__c, ESB_Company_Status__c, AccountNumber, Parent_TWA__c, Parent_TWA__r.AccountNumber
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
        
        // to reset status in case of failure
        Subscription__c subscription = [SELECT Id, Name, Status__c, Waiting_For_Payment__c FROM Subscription__c WHERE Id = :SubscriptionId];
        
        //system.savepoint sp;
        try
        {
            //sp = Database.setSavepoint();
            
            acc.ESB_Company_status__c = 'APPROVED';
            
            List<Id> subsIdList = new List<Id>();
            subsIdList.add(SubscriptionId);
            XmlStreamWriter bodyWriter = writeCompany(acc, contactId, writeUser, subsIdList, true);
            
            string requestBody = bodyWriter.getXmlString();
            
            system.debug('--------ESB_Proxy: CreateCompany: request body: ' + requestBody);
            
            if(SendRequestToESB('cm', 'company', 'provision', requestBody, accountId, contactId))
                update acc;
            else
            {
                if(subscription.Waiting_For_Payment__c)
                {
                    subscription.Status__c = 'Waiting For Payment';
                }
                else
                {
                    subscription.Status__c = 'Waiting For Provisioning';
                }
                update subscription;
            }
        }
        catch(Exception ex)
        {
            //Database.rollback(sp);
            if(subscription.Waiting_For_Payment__c)
            {
                subscription.Status__c = 'Waiting For Payment';
            }
            else
            {
                subscription.Status__c = 'Waiting For Provisioning';
            }
            update subscription;
        }
    } //CreateCompany
    
    @future(callout = true)
    public static void ApproveCompany(Id accountId, Id contactId, Id subscriptionId)
    {
        ApproveCompanySync(accountId, contactId, subscriptionId);
    }
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 May 15
    * @description  call WKTSAdmin through OSB to notify about company creatino
    */
    
    public static void ApproveCompanySync(Id accountId, Id contactId, Id subscriptionId)
    {
        // check, if we allowed to do ESB calls
        User u = [SELECT Id, Name, Disable_ESB_calls__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(u.Disable_ESB_calls__c)
        {
            system.debug('--------ESB_Proxy: ApproveCompany: ESB calls are disabled for user ' + u.Name);
            return;
        }
        
        // get needed fields from Account
        Account acc = [
            SELECT
                Id, Name, CreatedDate, ESB_Company_Type__c, LastModifiedDate, AccountNumber, ESB_Company_status__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
        // get needed fields from Contact
        Contact superUser = [
            SELECT
                Id, Name, CreatedDate, LastModifiedDate, ESB_BuisnessID__c, ESB_User_status__c
            FROM Contact
            WHERE Id = :contactId
        ];
        
        List<Subs_Current_Fee__c> subsCurrentFeeList = null;
        Subscription__c subscription = null;
        
        if(subscriptionId != null)
        {
            subscription = [SELECT Id, Name, Status__c, Waiting_For_Payment__c FROM Subscription__c WHERE Id = :subscriptionId];
            subsCurrentFeeList = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Subs_Current_Fee__c WHERE Subscription__c = :subscriptionId];
        }
        
        system.debug('--------ESB_Proxy: ApproveCompany: account: ' + acc);
        system.debug('--------ESB_Proxy: ApproveCompany: contact: ' + superUser);
        
        //system.savepoint sp;
        try
        {
            //sp = Database.setSavepoint();
            
            acc.ESB_Company_status__c = 'APPROVED';
            
            XmlStreamWriter bodyWriter = new XmlStreamWriter();
            
            bodyWriter.writeStartElement(crmNamespacePrefix, 'company', crmNamespaceURI);
            bodyWriter.writeAttribute('', '', 'xmlns:' + crmNamespacePrefix, crmNamespaceURI);
            
            // XSD abstractData fields START 
            bodyWriter.writeStartElement('', 'creationDate', ''); // required
            bodyWriter.writeAttribute('', '', 'xmlns', '');
            bodyWriter.writeCharacters(acc.CreatedDate.format(xmlDateFormat));
            bodyWriter.writeEndElement(); //creationDate
            
            bodyWriter.writeStartElement('', 'modificationDate', ''); // required
            bodyWriter.writeAttribute('', '', 'xmlns', '');
            bodyWriter.writeCharacters(acc.LastModifiedDate.format(xmlDateFormat));
            bodyWriter.writeEndElement(); //creationDate
            // modificationDate and deletionDate are not marked as required
            
            // XSD abstractData fields END
            
            // XSD companyAbstract fields START 
            writeBussinessId(bodyWriter,acc.AccountNumber);
            
            if(String.isNotEmpty(acc.ESB_Company_Type__c))
            {
                bodyWriter.writeStartElement('', 'companyType', ''); // not required
                bodyWriter.writeAttribute('', '', 'xmlns', '');
                bodyWriter.writeCharacters(acc.ESB_Company_Type__c);
                bodyWriter.writeEndElement(); //companyType
            }
            
            bodyWriter.writeStartElement('', 'users', '');
            bodyWriter.writeStartElement('', 'user', '');
            bodyWriter.writeStartElement('', 'creationDate', '');
            bodyWriter.writeCharacters(superUser.CreatedDate.format(xmlDateFormat));
            bodyWriter.writeEndElement();//creationDate
            writeBussinessId(bodyWriter, superUser.ESB_BuisnessID__c);
            bodyWriter.writeStartElement('', 'status', '');
            bodyWriter.writeCharacters(superUser.ESB_User_status__c/*'READY'*/);
            bodyWriter.writeEndElement();//status
            bodyWriter.writeEndElement();//user
            bodyWriter.writeEndElement();//users
            
            if(subsCurrentFeeList != null)
                writeProductAccess(bodyWriter, subsCurrentFeeList);
            
            bodyWriter.writeStartElement('', 'companyState', ''); //  not required
            bodyWriter.writeCharacters(acc.ESB_Company_status__c/*'APPROVED'*/);
            bodyWriter.writeEndElement(); //companyState
            
            bodyWriter.writeEndElement(); // company
            
            
            string requestBody = bodyWriter.getXmlString();
            
            system.debug('--------ESB_Proxy: ApproveCompany: request: ' + requestBody);
            
            if(SendRequestToESB('cm', 'company', 'approve', requestBody, accountId, contactId))
            {
                update acc;
                if(subscription != null)
                { 
                    subscription.Status__c = 'Active';
                    update subscription;
                }
                
            }
            else if(subscription != null)
            { 
                if(subscription.Waiting_For_Payment__c)
                {
                    subscription.Status__c = 'Waiting For Payment';
                }
                else
                {
                    subscription.Status__c = 'Waiting For Provisioning';
                }
                update subscription;
            }
        }
        catch(Exception ex)
        {
            //Database.rollback(sp);
            if(subscription != null)
            { 
                if(subscription.Waiting_For_Payment__c)
                {
                    subscription.Status__c = 'Waiting For Payment';
                }
                else
                {
                    subscription.Status__c = 'Waiting For Provisioning';
                }
                update subscription;
            }
            //throw ex;
        }
    } //ApproveCompany
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2014 May 21
    * @description  call WKTSAdmin through OSB to notify about company update
    */
    @future(callout = true)
    public static void UpdateCompany(Id accountId, Boolean sendCurrentFees)
    {
        UpdateCompanySynch(accountId, sendCurrentFees, true, null);
    }
    
    /** 
    * @author       Andrei Lobkis (andrei_lobkis@epam.com)
    * @date         2016 July 21
    * @description  this version of UpdateCompany  method should be used for the case of subscription provisioning
    */
    @future(callout = true)
    public static void UpdateCompany(Id accountId, Boolean sendCurrentFees, Id subscriptionId)
    {
        UpdateCompanySynch(accountId, sendCurrentFees, true, subscriptionId);
    }
    
    /** 
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2015 July 22
    * @description  call WKTSAdmin through OSB to notify about company and related users update
    */
    @future(callout = true)
    public static void SerialUpdateCompany(Id accountId, List<ID> contactsId)
    {
        Account processAcc = New Account(Id = accountId, TFX_Migration_Status__c = '');
        List<ESB_Interaction_Logs__c> transactionLogs = New List<ESB_Interaction_Logs__c>();        
        Account acc = SelectAccount(accountId); 
        String requestBody = '';       
        try
        {
            requestBody = UpdateCompanySynch(acc, true, false, null);
        }   
        catch(Exception ex)
        {
            processAcc.TFX_Migration_Status__c = 'error:' + ex;
        }
        
        if(processAcc.TFX_Migration_Status__c == '')
        {        
            ESB_Interaction_Logs__c accESBlog = SendRequestToESB_NODML('cm', 'company', 'update', requestBody, acc.AccountNumber); 
            accESBlog.Account__c = acc.Id;       
            if(accESBlog != NULL)
            {
                transactionLogs.Add(accESBlog);
                if(accESBlog.ESB_response_status__c == 200)
                {
                    List <Contact> processContacts = [SELECT Id, ESB_BuisnessID__c, Admin_Products__c, CreatedDate FROM Contact WHERE Id IN: contactsId ];
                    for(Contact currCon : processContacts)
                    {
                        XmlStreamWriter bodyWriter = new XmlStreamWriter();
                        bodyWriter.writeStartElement(crmNamespacePrefix, 'user', crmNamespaceURI);
                        bodyWriter.writeAttribute('', '', 'xmlns:' + crmNamespacePrefix, crmNamespaceURI);
                        bodyWriter.writeStartElement('', 'creationDate', ''); // required as part of abstractData
                        bodyWriter.writeCharacters(currCon.createdDate.format(xmlDateFormat));
                        bodyWriter.writeEndElement(); //creationDate
                        writeBussinessId(bodyWriter, currCon.ESB_BuisnessID__c);
                        bodyWriter.writeEndElement();//user        
                        requestBody = bodyWriter.getXmlString();
                        ESB_Interaction_Logs__c contactESBlog = SendRequestToESB_NODML('cm', 'user', 'activate', requestBody, acc.AccountNumber);
                        contactESBlog.Contact__c = currCon.Id;
                        transactionLogs.Add(contactESBlog);
                        if(String.isBlank(currCon.Admin_Products__c))
                        {
                            currCon.Admin_Products__c = 'TFX';
                        }
                        else if(!currCon.Admin_Products__c.contains('TFX'))
                        {
                            currCon.Admin_Products__c += ', TFX';
                        }
                    }
                    if(processContacts.size() > 0)
                    {
                        update processContacts;
                    }
                    processAcc.TFX_Migration_Status__c = 'TFX migration request was send';
                }
                else
                {
                    processAcc.TFX_Migration_Status__c = 'ESB Proxy Error during request send';        
                }
                insert(transactionLogs);
            }
        }
        update processAcc; 
        TFXMigrationHelper.addTFXMigrationLog(processAcc,processAcc.TFX_Migration_Status__c);       
    }
    
    public static String UpdateCompanySynch(Id accountId, Boolean sendCurrentFees, Boolean needSend, Id subscriptionId)
    {
        Account acc = SelectAccount(accountId);
        return UpdateCompanySynch(acc, sendCurrentFees, needSend, subscriptionId);
    }
     /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2014 May 21
    * @description  call WKTSAdmin through OSB to notify about company update. Synchronous method
    */
    public static String UpdateCompanySynch(Account acc, Boolean sendCurrentFees, Boolean needSend, Id subscriptionId)
    {
        Boolean resultHttp = true;
        // check, if we allowed to do ESB calls
        User u = [SELECT Id, Name, Disable_ESB_calls__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(u.Disable_ESB_calls__c)
        {
            system.debug('--------ESB_Proxy: UpdateCompanySynch: ESB calls are disabled for user ' + u.Name);
            return NULL;
        }
        
       
        Subscription__c subscriptionToActivate;
        if(SubscriptionId != null)
        subscriptionToActivate = [SELECT Id, Name, Status__c, Waiting_For_Payment__c FROM Subscription__c WHERE Id = :SubscriptionId];
        
        // we need to get list of subscriptions IDs
        List<Id> subsIdList = new List<Id>();
        
        if(sendCurrentFees) // add all the subscriptions for account
        {
            List<Subscription__c> subs = [
                SELECT Id, Name 
                FROM Subscription__c 
                WHERE
                    Offer_Template__r.Use_new_Provisioning__c = true
					and Status__c in ('Active', 'On Notice', 'Cancelled')
                    AND Account__c = :acc.Id];
                        
            for(Subscription__c s : subs)
                subsIdList.add(s.Id);
            if(SubscriptionId != null)
            	subsIdList.add(SubscriptionId);
            System.debug('-subs--' + subsIdList);            
        }
        try
        {
            XmlStreamWriter bodyWriter = writeCompany(acc, null, false, subsIdList, sendCurrentFees);
            
            String requestBody = bodyWriter.getXmlString();
            if(needSend) 
            {
                resultHTTP = SendRequestToESB('cm', 'company', 'update', requestBody, acc.Id, NULL);
            }
            system.debug('--------ESB_Proxy: UpdateCompany: request body: ' + requestBody);
            if(resultHTTP)
            {
                if(subscriptionToActivate != null)
                { 
                    subscriptionToActivate.Status__c = 'Active';
                    update subscriptionToActivate;
                }
                return requestBody;
            }
            else
            {
                if(subscriptionToActivate != null)
                {
                    if(subscriptionToActivate.Waiting_For_Payment__c)
                    {
                        subscriptionToActivate.Status__c = 'Waiting For Payment';
                    }
                    else
                    {
                        subscriptionToActivate.Status__c = 'Waiting For Provisioning';
                    }
                    update subscriptionToActivate;
                }
                return null;
            }    
        }
        catch(Exception e)
        {
            if(subscriptionToActivate != null)
            {
                if(subscriptionToActivate.Waiting_For_Payment__c)
                {
                    subscriptionToActivate.Status__c = 'Waiting For Payment';
                }
                else
                {
                    subscriptionToActivate.Status__c = 'Waiting For Provisioning';
                }
                update subscriptionToActivate;
                return null;
            }
            else
                throw e;
        }
        
    } //UpdateCompanySynch
    
      /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2014 May 21
    * @description  call WKTSAdmin through OSB to notify about supe user update
    */
    @future(callout = true)
    public static void UpdateSuperUser(Id contactId)
    {
        // check, if we allowed to do ESB calls
        User u = [SELECT Id, Name, Disable_ESB_calls__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(u.Disable_ESB_calls__c)
        {
            system.debug('--------ESB_Proxy: UpdateSuperUser: ESB calls are disabled for user ' + u.Name);
            return;
        }
        
        
        XmlStreamWriter bodyWriter = new XmlStreamWriter();
        bodyWriter.writeStartElement(crmNamespacePrefix, 'user', crmNamespaceURI);
        bodyWriter.writeAttribute('', '', 'xmlns:' + crmNamespacePrefix, crmNamespaceURI);
        bodyWriter = writeUser(bodyWriter, contactId, null);
        bodyWriter.writeEndElement();//user
        
        
        string requestBody = bodyWriter.getXmlString();
        system.debug('--------ESB_Proxy: UpdateUser: request body: ' + requestBody);
        SendRequestToESB('cm', 'user', 'update', requestBody, NULL, ContactId);
    } //UpdateSuperUser
    
    /** 
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2014 Nov 7
    * @description  call WKTSAdmin through OSB to notify about user create (for dual provisioning issue)
    */
    @future(callout = true)
    public static void CreateUser(Id contactId, boolean sendRoles)
    {
        // check, if we allowed to do ESB calls
        User u = [SELECT Id, Name, Disable_ESB_calls__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(u.Disable_ESB_calls__c)
        {
            system.debug('--------ESB_Proxy: UpdateSuperUser: ESB calls are disabled for user ' + u.Name);
            return;
        }
        
        List<ESB_DataClasses.userRole> roles = new List<ESB_DataClasses.userRole>();
        if(sendRoles)
            roles = GetActiveRoles(contactId);
        
        XmlStreamWriter bodyWriter = new XmlStreamWriter();
        bodyWriter.writeStartElement(crmNamespacePrefix, 'user', crmNamespaceURI);
        bodyWriter.writeAttribute('', '', 'xmlns:' + crmNamespacePrefix, crmNamespaceURI);
        bodyWriter = writeUser(bodyWriter, contactId, roles, ESB_DataClasses.userType.USER);
        bodyWriter.writeEndElement();//user
        
        
        string requestBody = bodyWriter.getXmlString();
        system.debug('--------ESB_Proxy: CreateUser: request body: ' + requestBody);
        SendRequestToESB('cm', 'user', 'create', requestBody, NULL, contactId);
    } //CreateUser
    
    /** 
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2015 March 16
    * @description  activate user
    */
    @future(callout = true)
    public static void ActivateUser(string businessID, dateTime createdDate)
    {
        // check, if we allowed to do ESB calls
        User u = [SELECT Id, Name, Disable_ESB_calls__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(u.Disable_ESB_calls__c)
        {
            system.debug('--------ESB_Proxy: ActivateUser: ESB calls are disabled for user ' + u.Name);
            return;
        }
        
        XmlStreamWriter bodyWriter = new XmlStreamWriter();
        bodyWriter.writeStartElement(crmNamespacePrefix, 'user', crmNamespaceURI);
        bodyWriter.writeAttribute('', '', 'xmlns:' + crmNamespacePrefix, crmNamespaceURI);
        bodyWriter.writeStartElement('', 'creationDate', ''); // required as part of abstractData
        bodyWriter.writeCharacters(createdDate.format(xmlDateFormat));
        bodyWriter.writeEndElement(); //creationDate
        writeBussinessId(bodyWriter, businessID);
        bodyWriter.writeEndElement();//user
        
        string requestBody = bodyWriter.getXmlString();
        system.debug('--------ESB_Proxy: ActivateUser: request body: ' + requestBody);
        SendRequestToESB('cm', 'user', 'activate', requestBody, NULL,  NULL);
    } // ActivateUser
    
    /** 
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2014 Nov 10
    * @description  extract active roles from old-fashioned provisioning
    */
    private static List<ESB_DataClasses.userRole> GetActiveRoles(Id contactId)
    {
        List<ESB_DataClasses.userRole> retVal = new List<ESB_DataClasses.userRole>();
        
        Set<string> rolesRawSet = new Set<string>();
        
        List<User_Profile__c> upList = [SELECT Id, Name FROM User_Profile__c WHERE Contact__c = :contactId];
        
        if(upList.size() > 0)
        {
            User_Profile__c up = upList.get(0);
            
            // services
            List<User_Profile_Service__c> upsList = [
                SELECT Id, Name, Provisioning_Service__r.Service__r.Access_Roles__c
                FROM User_Profile_Service__c
                WHERE User_Profile__c = :up.Id
            ];
            for(User_Profile_Service__c ups : upsList)
                rolesRawSet.add(ups.Provisioning_Service__r.Service__r.Access_Roles__c);
            
            // service attributes
            List<User_Profile_Service_Attribute__c> upsaList = [
                SELECT Id, Name, Provisioning_Service_Attribute__r.Service_Attribute__r.Access_Role__c
                FROM User_Profile_Service_Attribute__c
                WHERE User_Profile_Service__r.User_Profile__c = :up.Id
            ];
            system.debug('--- attributes ---');
            for(User_Profile_Service_Attribute__c upsa : upsaList)
                rolesRawSet.add(upsa.Provisioning_Service_Attribute__r.Service_Attribute__r.Access_Role__c);
            
            Map<string, FXRolesMapping__c> mapping = FXRolesMapping__c.getAll();
            for(string role : rolesRawSet)
            {
                if(mapping.containsKey(role))
                    retVal.add(ESB_ConvertHelper.stringToUserRole(mapping.get(role).TFX_userRole__c));
            }
        }
        return retVal;
    } //GetActiveRoles
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 April 10
    * @description  returns header for all requests. we have to pass XmlStreamWriter here to avoid
    *               complex transformations to inject header tags in exiwting XMLStreamWriter
    */
    private static void writeHeader(XmlStreamWriter writer, string namespacePrefix, string namespaceURI, string docType, string domain, string item, string event)
    {
        writer.writeStartElement(namespacePrefix, 'Header', namespaceURI);
        
        writer.writeStartElement(namespacePrefix, 'issuer', namespaceURI);
        writer.writeAttribute('', '', 'type', 'ADMIN'); 
        writer.writeStartElement(namespacePrefix, 'time', namespaceURI);
        writer.writeCharacters(datetime.now().format(xmlDateFormat));
        writer.writeEndElement(); // time
        writer.writeEndElement(); // issuer
        
        writer.writeStartElement(namespacePrefix, 'exchangeType', namespaceURI);
        writer.writeStartElement(namespacePrefix, 'documentType', namespaceURI);
        writer.writeCharacters(docType);
        writer.writeEndElement(); // documentType
        writer.writeStartElement(namespacePrefix, 'domain', namespaceURI);
        writer.writeCharacters(domain);
        writer.writeEndElement(); // domain
        writer.writeStartElement(namespacePrefix, 'item', namespaceURI);
        writer.writeCharacters(item);
        writer.writeEndElement(); // item
        writer.writeStartElement(namespacePrefix, 'action', namespaceURI);
        writer.writeCharacters(event);
        writer.writeEndElement(); // action
        writer.writeEndElement(); // exchangeType
        
        writer.writeStartElement(namespacePrefix, 'origin', namespaceURI);
        writer.writeCharacters('OBSS');
        writer.writeEndElement(); // origin
        
        // this is not our problem anymore
        //writer.writeStartElement(namespacePrefix, 'destination', namespaceURI);
        //writer.writeCharacters('NA');
        //writer.writeEndElement(); // destination
        
        writer.writeEndElement(); // Header
    } //createHeader
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2014 May 6
    * @description  returns Xml Stream Writer with recorded bussiness id
    */
    private static void writeBussinessId(XmlStreamWriter writer, string bussinessId)
    {
        writer.writeStartElement('', 'businessId', ''); // required
        writer.writeAttribute('', '', 'xmlns', '');
        writer.writeStartElement('', 'id', '');
        writer.writeCharacters(bussinessId);
        writer.writeEndElement(); //id
        writer.writeEndElement(); //businessId
    } //bussinessId
    
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 November 10
    * @description  returns Xml Stream Writer with recorded user. Wrapper for function below
    */
    private static XmlStreamWriter writeUser(XmlStreamWriter writer, Id contactId, List<ESB_DataClasses.userRole> roles, ESB_DataClasses.userType userType)
    {
        Contact cont = [
            SELECT
                Id, Name, CreatedDate, LastModifiedDate, Email, MobilePhone, Phone, Fax,
                /*Status__c,*/ Is_Visible__c, Language__c, Time_Zone__c, Username__c, ESB_BuisnessID__c,
                Gender__c, FirstName, LastName, AccountID, Account.AccountNumber, ESB_User_status__c
            FROM Contact
            WHERE Id = :contactId
        ];
        return writeUser(writer, cont, roles, userType);
    } //writeUser
    
    private static XmlStreamWriter writeUser(XmlStreamWriter writer, Id contactId, List<ESB_DataClasses.userRole> roles)
    {
        return writeUser(writer, contactId, roles, ESB_DataClasses.userType.SUPERUSER);
    }
    // for compatibility
    private static XmlStreamWriter  writeUser(XmlStreamWriter writer, Contact superUser, List<ESB_DataClasses.userRole> roles)
    {
        return writeUser(writer, superUser, roles, ESB_DataClasses.userType.SUPERUSER);
    }
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2014 May 6
    * @description  returns Xml Stream Writer with recorded user
    */
    private static XmlStreamWriter  writeUser(XmlStreamWriter writer, Contact superUser, List<ESB_DataClasses.userRole> roles, ESB_DataClasses.userType userType)
    {
        writer.writeStartElement('', 'creationDate', ''); // required as part of abstractData
        writer.writeCharacters(superUser.CreatedDate.format(xmlDateFormat));
        writer.writeEndElement(); //creationDate
        if(String.isNotEmpty(superUser.FirstName))
        {
            writer.writeStartElement('', 'firstName', ''); // not required as part of userShortInfo
            writer.writeCharacters(superUser.FirstName);
            writer.writeEndElement(); //firstName
        }
        if(String.isNotEmpty(superUser.LastName))
        {
            writer.writeStartElement('', 'lastName', '');// not required as part of userShortInfo
            writer.writeCharacters(superUser.LastName);
            writer.writeEndElement(); //lastName
        }
        if(String.isNotEmpty(superUser.Username__c))
        {
            writer.writeStartElement('', 'login', '');
            writer.writeCharacters(superUser.Username__c);
            writer.writeEndElement(); //login
        }
        if(roles != null && roles.size() > 0)
        {
            writer.writeStartElement('', 'userRoles', '');
            for(ESB_DataClasses.userRole r : roles)
            {
                writer.writeStartElement('', 'userRole', '');
                writer.writeCharacters(string.valueOf(r)); 
                writer.writeEndElement(); //userRole
            }
            writer.writeEndElement(); //userRoles
        }
        if(superUser.ESB_BuisnessID__c != null)
            writeBussinessId(writer, superUser.ESB_BuisnessID__c);
        else
            writeBussinessId(writer, 'FAKE');
        writer.writeStartElement('', 'companyBusinessAccount', '');
        writer.writeStartElement('', 'id', '');
        writer.writeCharacters(superUser.Account.AccountNumber); 
        writer.writeEndElement();//id
        writer.writeEndElement(); //companyBusinessAccount
        
        if(String.isNotEmpty(superUser.Email))
        {
            writer.writeStartElement('', 'email', ''); // not required
            writer.writeCharacters(superUser.Email); 
            writer.writeEndElement(); //email
        }
        
        if(String.isNotEmpty(superUser.MobilePhone))
        {
            writer.writeStartElement('', 'mobile', ''); // not required
            writePhone(writer, superUser.MobilePhone);
            writer.writeEndElement(); //mobile
        }
        
        if(String.isNotEmpty(superUser.Fax))
        {
            writer.writeStartElement('', 'fax', ''); // not required
            writePhone(writer, superUser.Fax);
            writer.writeEndElement(); //fax
        }
        
        if(String.isNotEmpty(superUser.Phone))
        {
            writer.writeStartElement('', 'phone', ''); // not required
            writePhone(writer, superUser.Phone);
            writer.writeEndElement(); //phone
        }
        
        writer.writeStartElement('', 'status', ''); // not required
        // following values are allowed: CREATED, APPROVED, READY, REJECTED, SUSPENDED, BLOCKED, BLOCKED_BY_ADMIN
        writer.writeCharacters(superUser.ESB_User_status__c == null ? 'CREATED' : superUser.ESB_User_status__c); //------?
        writer.writeEndElement(); //status      
        writer.writeStartElement('', 'userType', '');
        writer.writeCharacters(string.valueOf(userType));
        writer.writeEndElement(); //userType    
        if(String.isNotEmpty(superUser.Gender__c))
        { 
            writer.writeStartElement('', 'userTitle', ''); // not required
            writer.writeStartElement('', 'value', '');
            writer.writeCharacters(superUser.Gender__c == 'Female' ? 'Ms' : 'Mr');
            writer.writeEndElement(); //value
            writer.writeEndElement(); //userTitle  
        } 
        writer.writeStartElement('', 'visible', ''); // not required
        writer.writeCharacters(string.ValueOf(superUser.Is_Visible__c));
        writer.writeEndElement(); //visible 
        if(String.isNotEmpty(superUser.Language__c))
        {    
            string lang = Language_parameters__c.getValues(superUser.Language__c).Locale__c;
            writer.writeStartElement('', 'preferredLanguage', ''); // not required
            //writer.writeStartElement('', 'language', '');
            writer.writeCharacters(lang);
            //writer.writeEndElement(); //language
            writer.writeEndElement(); //preferredLanguage 
        }   
        if(superUser.Time_Zone__c != null)
        {
            writer.writeStartElement('', 'preferredTimezone', ''); // not required
            writer.writeCharacters(superUser.Time_Zone__c); 
            writer.writeEndElement(); //preferredTimezone
        }       
        // socialNetworks and spokenLanguages are not required
        return writer;
    } //writeUser
    
    
    /** 
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2014 May 21
    * @description  returns Xml Stream Writer with recorded productAccess list.
    */
    private static XmlStreamWriter writeProductAccess(XmlStreamWriter writer, List<Subs_Current_Fee__c> subsCurrentFeeList)
    {
        system.debug('--------ESB_Proxy: writeProductAccess: subsCurrentFeeList: ' + subsCurrentFeeList);
        
        writer.writeStartElement('', 'productsAccesses', '');
        writer.writeAttribute('', '', 'xmlns', '');
        
        // we can't have cd_guest and cd_approved for one company.
        Boolean hasCdGuest = false, hasCdApproved = false;
        
        if(subsCurrentFeeList != null)
            if(subsCurrentFeeList.size() > 0)
                for(Subs_Current_Fee__c cf : subsCurrentFeeList)
                {
                    if(cf.Start_Date__c <= date.today() && (cf.End_Date__c > date.today() || cf.End_Date__c == null))
                    {
                        writer.writeStartElement('', 'wktsCompanyProductAccess', '');
                        writer.writeCharacters(cf.Name);
                        writer.writeEndElement(); //wktsCompanyProductAccess
                        
                        if(cf.Name.equalsIgnoreCase('cd_guest'))
                            hasCdGuest = true;
                        if(cf.Name.equalsIgnoreCase('cd_approved'))
                            hasCdApproved = true;
                    }
                }
        
        writer.writeEndElement(); //productsAccesses
        
        if(hasCdGuest && hasCdApproved)
        {
            Generic.ESBInternalException ex = new Generic.ESBInternalException('Account cannot have cd_guest and cd_approved currentFees at the same time!');
            //ex.Message = ;
            throw ex;
        }
        
        return writer;
    } //bussinessId
    
    private static XmlStreamWriter writeCompany(Id accountId, Id contactId, Boolean writeUser, List<Id> subsIdList, Boolean writeProductAccess)
    {
        Account acc = SelectAccount(accountId);
        return writeCompany(acc,contactId, writeUser, subsIdList, writeProductAccess);
    }//writeCompany
    
    private static Account SelectAccount(Id accountId)
    {
        Account acc = [
            SELECT
                Id, Name, CreatedDate, LastModifiedDate, Company_Type__c, VAT__c, Email__c, Fax, Phone, Website, 
                BillingCountry, BillingState, BillingCity, BillingPostalCode, BillingStreet,
                ShippingCountry, ShippingState, ShippingCity, ShippingPostalCode, ShippingStreet,
                Time_Zone__c, AccountNumber, Customer_Since__c, Company_Registration_Number__c, Transport_Licence__c, ParentID,
                ESB_Company_Type__c, ESB_Company_status__c,
                ESB_Billing_Address_ID__c, ESB_ShippingAddress_ID__c, Parent_TWA__c, Parent_TWA__r.AccountNumber
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
        
        return acc;
    } // SelectAccount
    
    private static XmlStreamWriter writeCompany(Account acc, Id contactId, Boolean writeUser, List<Id> subsIdList, Boolean writeProductAccess)
    {
        system.debug('--------ESB_Proxy: writeCompany: params: acc: ' + acc + ', contactId: ' + contactId + ', writeUser: ' + writeUser + ', subsIdList: ' + subsIdList);
        
        Account parentAccount = null;
        if(acc.ParentId != null)
            parentAccount = [Select AccountNumber From Account Where id =: acc.ParentId];
        
        Contact superUser = new Contact();
        if(contactId != null)
        {
            // get needed fields from Contact
            superUser = [
                SELECT
                    Id, Name, CreatedDate, LastModifiedDate, Email, MobilePhone, Phone, Fax,
                    /*Status__c,*/ Is_Visible__c, Language__c, Time_Zone__c, Username__c, ESB_BuisnessID__c,
                    Gender__c, FirstName, LastName, AccountID, Account.AccountNumber, ESB_User_status__c
                FROM Contact
                WHERE Id = :contactId
            ];
        }
        
        
        List<Subs_Current_Fee__c> subsCurrentFeeList = null;
        if((subsIdList != null) && writeProductAccess)
            subsCurrentFeeList = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Subs_Current_Fee__c WHERE Subs_Package_And_Fee__c!=null and Subs_Package_And_Fee__r.Package_and_Fee__r.Not_Use_new_Provisioning__c != true And Subscription__c IN :subsIdList];
        
        system.debug('--------ESB_Proxy: writeCompany: subsCurrentFeeList: ' + subsCurrentFeeList);
        
        XmlStreamWriter bodyWriter = new XmlStreamWriter();
        
        bodyWriter.writeStartElement(crmNamespacePrefix, 'company', crmNamespaceURI);
        bodyWriter.writeAttribute('', '', 'xmlns:' + crmNamespacePrefix, crmNamespaceURI);
        
        // XSD abstractData fields START 
        bodyWriter.writeStartElement('', 'creationDate', ''); // required
        bodyWriter.writeAttribute('', '', 'xmlns', '');
        bodyWriter.writeCharacters(acc.CreatedDate.format(xmlDateFormat));
        bodyWriter.writeEndElement(); //creationDate
        
        bodyWriter.writeStartElement('', 'modificationDate', ''); // required
        bodyWriter.writeAttribute('', '', 'xmlns', '');
        bodyWriter.writeCharacters(acc.LastModifiedDate.format(xmlDateFormat));
        bodyWriter.writeEndElement(); //creationDate
        // modificationDate and deletionDate are not marked as required
        
        // XSD abstractData fields END
        
        // XSD companyAbstract fields START 
        writeBussinessId(bodyWriter,acc.AccountNumber);
        
        writeAddresses(bodyWriter, acc);
        
        if(String.isNotEmpty(acc.ESB_Company_Type__c))
        {
            bodyWriter.writeStartElement('', 'companyType', ''); // not required
            bodyWriter.writeAttribute('', '', 'xmlns', '');
            bodyWriter.writeCharacters(acc.ESB_Company_Type__c);
            bodyWriter.writeEndElement(); //companyType
        }
        
        if(String.isNotEmpty(acc.Name))
        {
            bodyWriter.writeStartElement('', 'name', ''); // not required
            bodyWriter.writeCharacters(acc.Name); 
            bodyWriter.writeEndElement(); //name
        }
        
        bodyWriter.writeStartElement('', 'parentCompanyBusinessAccount', '');
        bodyWriter.writeStartElement('', 'id', '');
        if(acc.parentID != null)
        {
            bodyWriter.writeCharacters(parentAccount.AccountNumber);
        }
        bodyWriter.writeEndElement(); // id
        bodyWriter.writeEndElement(); //parentCompanyBusinessAccount
        
        bodyWriter.writeStartElement('', 'operationalParentCompanyBusinessAccount', '');
        bodyWriter.writeStartElement('', 'id', '');
        if(acc.Parent_TWA__c != null)
        {
            bodyWriter.writeCharacters(acc.Parent_TWA__r.AccountNumber);
        }
        bodyWriter.writeEndElement(); // id
        bodyWriter.writeEndElement(); //operationalParentCompanyBusinessAccount
        
        if(String.isNotEmpty(acc.Company_Registration_Number__c))
        {
            bodyWriter.writeStartElement('', 'tradeRegistrationNumber', ''); // not required
            bodyWriter.writeCharacters(acc.Company_Registration_Number__c);
            bodyWriter.writeEndElement();//tradeRegistrationNumber
        }
        if(String.isNotEmpty(acc.Transport_Licence__c))
        {
            bodyWriter.writeStartElement('', 'transportLicenseNumber', ''); // not required
            bodyWriter.writeCharacters(acc.Transport_Licence__c);
            bodyWriter.writeEndElement();//transportLicenseNumber
        }
        if(String.isNotEmpty(acc.VAT__c))
        {
            bodyWriter.writeStartElement('', 'vat', ''); // required by WKTS Admin`
            bodyWriter.writeCharacters(acc.VAT__c); 
            bodyWriter.writeEndElement(); //vat
        }
        if(String.isNotEmpty(acc.Email__c))
        {
            bodyWriter.writeStartElement('', 'email', ''); // not required
            bodyWriter.writeCharacters(acc.Email__c); 
            bodyWriter.writeEndElement(); //email
        }
        if(String.isNotEmpty(acc.Fax))
        {
            bodyWriter.writeStartElement('', 'fax', ''); // not required
            writePhone(bodyWriter, acc.Fax);
            bodyWriter.writeEndElement(); //fax
        }
        
        if(String.isNotEmpty(acc.Phone))
        {
            bodyWriter.writeStartElement('', 'phone', ''); // not required
            writePhone(bodyWriter, acc.Phone);
            bodyWriter.writeEndElement(); //phone
        }
        
        if(String.isNotEmpty(acc.Website))
        {
            bodyWriter.writeStartElement('', 'website', ''); // not required
            bodyWriter.writeCharacters(acc.Website);
            bodyWriter.writeEndElement(); //website
        }
        if(acc.Customer_Since__c!=null)
        {
            bodyWriter.writeStartElement('', 'customerSince', ''); // not required
            bodyWriter.writeCharacters( // special trick to handle date -> datetime conversion
                dateTime.newInstance(
                    acc.Customer_Since__c.year(),
                    acc.Customer_Since__c.month(),
                    acc.Customer_Since__c.day()
                ).format(xmlDateFormat));
            bodyWriter.writeEndElement(); //customerSince
        }
        
        // not will the end of function we will see company XSD 
        // super user
        if(writeUser)
        {
            bodyWriter.writeStartElement('', 'users', '');
            bodyWriter.writeStartElement('', 'user', ''); // not required
            bodyWriter.writeAttribute('', '', 'xmlns', '');
            bodyWriter = writeUser(bodyWriter, superUser, null);
            bodyWriter.writeEndElement();//user      
            bodyWriter.writeEndElement();//users
        }
        
        if(writeProductAccess)
        {
            if(subsCurrentFeeList != null)
                writeProductAccess(bodyWriter, subsCurrentFeeList);
            else
            {
                bodyWriter.writeStartElement('', 'productsAccesses', '');
                bodyWriter.writeAttribute('', '', 'xmlns', '');
                bodyWriter.writeStartElement('', 'wktsCompanyProductAccess', '');
                bodyWriter.writeCharacters('CD_guest');
                bodyWriter.writeEndElement(); //wktsCompanyProductAccess
                bodyWriter.writeEndElement(); //productsAccesses
            }
        }
        
        bodyWriter.writeStartElement('', 'companyState', ''); //  not required
        bodyWriter.writeCharacters(acc.ESB_Company_status__c/*'APPROVED'*/);
        bodyWriter.writeEndElement(); //companyState
        
        //bodyWriter.writeStartElement('', 'companyDocuments', ''); //  not required
        // there is a list of allowed values
        //bodyWriter.writeEndElement(); //companyDocuments
            
        bodyWriter.writeEndElement(); //company
        return bodyWriter;
    } //writeCompany
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 May 26
    * @description  Writes phone number in format specified in cm.xsd, without 'phone' tag itself, only internals
    */
    private static void writePhone(XmlStreamWriter writer, string phone)
    {
        // if starts with '+' - skip it
        string phn = phone.startsWith('+') ? phone.substring(1) : phone;
        
        string[] parts = phn.split(' ');
        
        system.debug('----------ESB_Proxy.writePhone: phn: ' + phn + ', parts: ' + parts);
        
        if(parts.size() == 2)
        {
            writer.writeStartElement('', 'localNumber', '');
            writer.writeCharacters(parts.get(1)); 
            writer.writeEndElement(); //localNumber
            writer.writeStartElement('', 'prefixNumber', '');
            //writer.writeCharacters('');
            writer.writeEndElement(); //prefixNumber
            writer.writeStartElement('', 'countryNumber', '');
            writer.writeCharacters(parts.get(0)); 
            writer.writeEndElement(); //countryNumber
        }
        else if(parts.size() == 3)
        {
            writer.writeStartElement('', 'localNumber', '');
            writer.writeCharacters(parts.get(2)); 
            writer.writeEndElement(); //localNumber
            writer.writeStartElement('', 'prefixNumber', '');
            writer.writeCharacters(parts.get(1));
            writer.writeEndElement(); //prefixNumber
            writer.writeStartElement('', 'countryNumber', '');
            writer.writeCharacters(parts.get(0)); 
            writer.writeEndElement(); //countryNumber
        }
    } //writePhone
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 June 9
    * @description  Writes addresses tag for both shipping and bililng addresses
                            2014-08-14 update - we will use only shipping address
    */
    private static void writeAddresses(XmlStreamWriter writer, Account acc)
    {
        /*boolean isBillingAddressThere = 
            (acc.BillingStreet != null) ||
            (acc.BillingState != null) ||
            (acc.BillingCity != null) ||
            (acc.BillingPostalCode != null) ||
            (acc.BillingCountry != null);
        */
        boolean isShippingAddressThere = 
            (acc.ShippingStreet != null) ||
            (acc.ShippingState != null) ||
            (acc.ShippingCity != null) ||
            (acc.ShippingPostalCode != null) ||
            (acc.ShippingCountry != null);
            
        /*boolean addressesTheSame = 
            (acc.BillingStreet == acc.ShippingStreet) &&
            (acc.BillingState == acc.ShippingState) &&
            (acc.BillingCity == acc.ShippingCity) &&
            (acc.BillingPostalCode == acc.ShippingPostalCode) &&
            (acc.BillingCountry == acc.ShippingCountry);
        */
        // if both addresses are empty
        if(/*!isBillingAddressThere &&*/ !isShippingAddressThere)
            return;
        
        // now we need to find countryISO codes for billing and shipping countries
        string /*billingCountryCode = '',*/ shippingCountryCode = '';
        /*if(acc.BillingCountry != null)
        {
            List<pw_cc__CountryObject__c> countries = [
                SELECT Name, pw_cc__IsoCode_2__c
                FROM pw_cc__CountryObject__c
                WHERE Name = :acc.BillingCountry
            ];
            billingCountryCode = countries.get(0).pw_cc__IsoCode_2__c;
        }*/
        if(acc.ShippingCountry != null)
        {
            shippingCountryCode = Country_Parameters__c.getValues(acc.ShippingCountry).ISO2_code__c;
        }
        
        writer.writeStartElement('', 'addresses', '');
        writer.writeAttribute('', '', 'xmlns', '');
        
        /*
        if(addressesTheSame)
        {
            writeAddress(writer, acc.ESB_Billing_Address_ID__c, acc.BillingStreet, '', acc.BillingState, acc.BillingPostalCode, acc.BillingCity, billingCountryCode, 
                acc.Time_Zone__c, new string[] {'postal', 'billing'});
        }
        else
        {
            // here we have different addresses, and we will write both of them
            if(isBillingAddressThere)
                writeAddress(writer, acc.ESB_Billing_Address_ID__c, acc.BillingStreet, '', acc.BillingState, acc.BillingPostalCode, acc.BillingCity, billingCountryCode, 
                    acc.Time_Zone__c, new string[] {'billing'});
            
            if(isShippingAddressThere)*/
                writeAddress(writer, acc.ESB_ShippingAddress_ID__c, acc.ShippingStreet, '', acc.ShippingState, acc.ShippingPostalCode, acc.ShippingCity, shippingCountryCode, 
                    acc.Time_Zone__c, new string[] {'postal'});
        /*}*/
        writer.writeEndElement(); //addresses
    } //writeAddresses
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 June 9
    * @description  Writes address
    */
    private static void writeAddress(XmlStreamWriter writer, string bID,
        string street, string num, string state, string postCode, string city, string country, 
        string timeZone, string[] locationTypes) //// billing, pickup, delivery, postal
    {
        writer.writeStartElement('', 'address', '');
        
        writer.writeStartElement('', 'creationDate', '');
        writer.writeCharacters(DateTime.now().format(xmlDateFormat));
        writer.writeEndElement();//creationDate
        
        if(bID == null) bID = 'FAKE';
        writeBussinessId(writer, bID);
        
        if(string.isNotEmpty(num))
        {
            writer.writeStartElement('', 'number', ''); // not required
            writer.writeCharacters(num); 
            writer.writeEndElement(); //number
        }
        if(string.isNotEmpty(street))
        {
            writer.writeStartElement('', 'streetName', ''); // not required
            writer.writeCharacters(street);
            writer.writeEndElement(); //streetName
        }
        if(String.isNotEmpty(state))
        {
            writer.writeStartElement('', 'district', ''); // not required
            writer.writeCharacters(state);
            writer.writeEndElement(); //district
        }
        if(String.isNotEmpty(city))
        {
            writer.writeStartElement('', 'city', ''); // not required
            writer.writeCharacters(city);
            writer.writeEndElement(); //city
        }
        if(String.isNotEmpty(state))
        {
            writer.writeStartElement('', 'state_province', ''); // not required
            writer.writeCharacters(state);
            writer.writeEndElement(); //state-province
        }
        if(String.isNotEmpty(postCode))
        {
            writer.writeStartElement('', 'postCode', ''); // not required
            writer.writeCharacters(postCode);
            writer.writeEndElement(); //postCode
        }
        if(String.isNotEmpty(country))
        {
            writer.writeStartElement('', 'country', ''); // not required
            writer.writeCharacters(country);
            writer.writeEndElement(); //country
        }
        
        //bodyWriter.writeStartElement('', 'addressLines', ''); // not required
        //bodyWriter.writeStartElement('', 'addressLine', ''); // required as part of wktscm:addressLine
        //bodyWriter.writeStartElement('', 'line', '');
        //bodyWriter.writeCharacters(acc.BillingStreet); not exist
        //bodyWriter.writeEndElement(); //line
        //bodyWriter.writeEndElement(); //addressLine
        //bodyWriter.writeEndElement(); //addressLines
        
        writer.writeStartElement('', 'locationTypes', '');
        for(string s : locationTypes)
        {
            writer.writeStartElement('', 'addressLocationType', '');
            writer.writeCharacters(s);
            writer.writeEndElement(); //addressLocationType
        }
        writer.writeEndElement(); //locationTypes
        
        if(timeZone != null)
        {
            writer.writeStartElement('', 'timezone', ''); // not required
            writer.writeCharacters(timeZone);
            writer.writeEndElement(); //timezone
        }
        
        writer.writeEndElement(); //address
    } //writeAddress
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2014 September 23
    * @description  Request To ESB
    */
    private static boolean SendRequestToESB(string domain, string item, string event, string requestBody, Id accountId, Id contactId)
    {
        boolean retVal = false;
        
        ESB_Interaction_Logs__c log = new ESB_Interaction_Logs__c();
            
        log = SendRequestToESB_NODML(domain, item, event, requestBody);
        if(log.ESB_response_status__c == 200)
            retVal = true;
        if(accountId != NULL)
        {
            log.Account__c = accountId;
        }
        if(contactId != NULL)
        {
            log.Contact__c = contactId;
        }
        insert log;
        if(item == 'company')
            TLR_ContactHelper.CreateDMSUsersForAccount(accountId, requestBody.contains('DMS_approved'));
        return retVal;
    } //SendRequestToESB
    
    private static ESB_Interaction_Logs__c SendRequestToESB_NODML(string domain, string item, string event, string requestBody)
    {
        return SendRequestToESB_NODML(domain, item, event, requestBody, null);
    }
    
    /** 
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2015 June 23
    * @description  Call To ESB without DML
    */
    private static ESB_Interaction_Logs__c SendRequestToESB_NODML(string domain, string item, string event, string requestBody, string unitOfOrder)
    {
        ESB_Interaction_Logs__c retVal = new ESB_Interaction_Logs__c();
        
        string correlationId = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaSmallAndCaps, 10);
        
        XmlStreamWriter requestWriter = new XmlStreamWriter();
        requestWriter.setDefaultNamespace(esbNamespaceURI);
        // envelope start
        requestWriter.writeStartElement('soapenv', 'Envelope', envelopeNamespaceURI);
        // namespaces
        requestWriter.writeAttribute('xmlns', envelopeNamespaceURI, 'soapenv', envelopeNamespaceURI);
        requestWriter.writeAttribute('xmlns', envelopeNamespaceURI, esbNamespacePrefix, esbNamespaceURI);
        
        requestWriter.writeEmptyElement('soapenv', 'Header', envelopeNamespaceURI);
        requestWriter.writeStartElement('soapenv', 'Body', envelopeNamespaceURI);
        
        requestWriter.writeStartElement(esbNamespacePrefix, 'message', esbNamespaceURI);
        requestWriter.writeAttribute('', '', 'type', 'document');
        requestWriter.writeAttribute('', '', 'correlationId', correlationId);
        if(!string.isBlank(unitOfOrder))
            requestWriter.writeAttribute('', '', 'unitOfOrder', unitOfOrder);
        writeHeader(requestWriter, '', '', 'request', domain, item, event);
        requestWriter.writeStartElement('', 'Body', '');
        requestWriter.writeCData(requestBody);
        requestWriter.writeEndElement(); //Body
        requestWriter.writeEndElement(); //message        
        requestWriter.writeEndElement(); // soap envelope Body
        requestWriter.writeEndElement(); // soap envelope  
        
        FXSettings__c settings = FXSettings__c.getValues('FXSettings');
        HttpResponse response;
        string reqBody = requestWriter.getXmlString();        
        string msgType = string.Format('{0}.{1}.{2}', new string[] {domain, item, event});
        
        try
        {
            response = SoapHttp.sendSOAPRequest(reqBody, settings.ESB_Url__c, 10000, settings.ESB_Certificate_name__c); 
            
            retVal = ESB_LogUtility.CreateLog(ESB_LogUtility.MessageDirection.Outgoing, msgType, reqBody, response.getBody(), correlationId, response.getStatusCode(), null);            
        }
        catch(System.CalloutException ex)
        {
            System.Debug('--------ESB_Proxy.SendRequestToESB_NODML: exception: ' + ex);
            retVal = ESB_LogUtility.CreateLog(ESB_LogUtility.MessageDirection.Outgoing, msgType, reqBody, ex.getMessage(), correlationId, -1, 'callout error');
        }
        return retVal;
    } //SendRequestToESB_NODML
}