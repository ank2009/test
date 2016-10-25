/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2014
* @description  class contains webservices to be called from WKTSA through ESB
*/
global class ESB_CompanyOperations
{
    // specific exceptions to filter and send proper responses
    public class AccountNotFoundException extends Exception { }
    public class ContactNotFoundException extends Exception { }
    public class CorrelationIDMissingException extends Exception { }
    public class CorrelationIDDuplicatedException extends Exception { }
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 July
    * @description  process cm.company.create message - creates company
    */
    webservice static ESB_DataClasses.response NotifyCompanyCreated(ESB_DataClasses.company company, string correlationId)
    {
        ESB_DataClasses.response response = new ESB_DataClasses.response();
        response.applicationId = ESB_DataClasses.wktsApplicationsEnum.OBSS;
        
        string errorMessage = null;
        Id accountId = NULL;
        
        response.infos.info.add(CreateResponseMessage('SF-0001', 'NotifyCompanyCreated called.'));
        
        system.savepoint sp;
        
        system.debug('---------- ESB_CompanyOperations: NotifyCompanyCreated: received data: ' + company + ', correlationID: ' + correlationId);
        
        try
        {
            VerifyCorrelationId(correlationId);
            
            sp = database.setSavepoint();
            
            Account acc = ESB_ConvertHelper.extractAccount(company);
            Contact cont = ESB_ConvertHelper.extractContact(company);
            
            // TODO checks here
            
            acc.ESB_Created_By_WKTSAdmin__c = true;
            
            system.debug('---------- ESB_CompanyOperations: NotifyCompanyCreated: account: ' + acc);
            system.debug('---------- ESB_CompanyOperations: NotifyCompanyCreated: contact: ' + cont);
            
            insert acc;
            TLR_AccountMembershipLifeCycleController con = new TLR_AccountMembershipLifeCycleController(acc.Id); 
            response.infos.info.add(CreateResponseMessageFormat('SF-1001', 'Account "{0}" created.', new string[] { acc.Name }));
            
            cont.AccountId = acc.Id;
            accountId = acc.Id;
            
            insert cont;
            
            response.infos.info.add(CreateResponseMessageFormat('SF-1002', 'Contact "{0} {1} {2}" created.', new string[] { cont.Salutation, cont.FirstName, cont.LastName }));
            
            boolean isGuest = false;
            // create case to approve guest company (TWD only)
            Case twdCase = new Case();
            twdCase.RecordTypeId = TLR_RecordTypeHelper.getId('Case', 'TWD Case');
            twdCase.AccountId = acc.Id;
            twdCase.ContactId = cont.Id;
            //twdCase.Shipper__c - company, who invited 
            twdCase.Subject = 'To be approved guest';
            twdCase.Description = 'Please create subscription';
            if(company.invitedBy != null)
            {
                twdCase.Description += '\nInviter BusinessID: ' + company.invitedBy.byCompany.id;
                FillInvitedByField(twdCase,company.invitedBy.byCompany.id);
                   
                if(company.invitedBy.forProducts != null)
                {
                    twdCase.Description += '\nProducts invited to:';
                    for(ESB_DataClasses.wktsBusinessProductEnum product : company.invitedBy.forProducts.wktsBusinessProduct)
                        twdCase.Description += '\n' + string.valueOf(product);
                    
                    if(company.invitedBy.forProducts.wktsBusinessProduct.size() == 1)
                        if(company.invitedBy.forProducts.wktsBusinessProduct.get(0) == ESB_DataClasses.wktsBusinessProductEnum.WKTSAdmin )
                            isGuest = true;
                            
                }
            }
            //twdCase.OwnerId = customer care for TWD
            if(isGuest)
                CreateGuestCompanyAutomated(acc.Id, cont.Id);
            else
            {
                insert twdCase;
                response.infos.info.add(CreateResponseMessage('SF-1003', 'Case created.'));
            }
        }
        catch (DMLException dex)
        {
            errorMessage = 'DML error';
            Database.rollback(sp);
            system.debug('---------- ESB_CompanyOperations: NotifyCompanyCreated: DML exception: ' + dex);
            Integer dmlCount = dex.getNumDml();
            for(integer i = 0; i < dmlCount; i++)
            {
                string message = string.valueOf(dex.getDmlType(i)) + ' ' + dex.getDmlMessage(i);
                response.errors.error.add(CreateResponseMessage('SF-E002', message));
            }
        }
        catch(CorrelationIDMissingException ex)
        {
            errorMessage = 'missing correlationID';
            response.errors.error.add(CreateResponseMessage('SF-E006', 'Correlation ID is missing in message!'));
        }
        catch(CorrelationIDDuplicatedException ex)
        {
            errorMessage = 'duplicated correlationID';
            response.errors.error.add(CreateResponseMessage('SF-E007', 'Correlation ID duplicated: ' + correlationId));
        }
        catch(Exception ex)
        {
            errorMessage = 'General error';
            Database.rollback(sp);
            system.debug('---------- ESB_CompanyOperations: NotifyCompanyCreated: exception: ' + ex);
            response.errors.error.add(CreateExceptionMessage('SF-E001', ex));
        }
        
        system.debug('---------- ESB_CompanyOperations: NotifyCompanyCreated: response: ' + response);
        ESB_LogUtility.WriteLog('NotifyCompanyCreated', company, response, correlationId, errorMessage, accountId, NULL);
        return response;
    } //NotifyCompanyCreated
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 July
    * @description  process cm.user.create message - creates contact
    */
    webservice static ESB_DataClasses.response NotifyUserCreated(ESB_DataClasses.user user, string correlationId)
    {
        ESB_DataClasses.response response = new ESB_DataClasses.response();
        response.applicationId = ESB_DataClasses.wktsApplicationsEnum.OBSS;
        
        response.infos.info.add(CreateResponseMessage('SF-0001', 'NotifyUserCreated called.'));
        
        string errorMessage = null;
        Id contactId = null;
        
        system.debug('---------- ESB_CompanyOperations: NotifyUserCreated: received user: ' + user);
        
        try
        {
            VerifyCorrelationId(correlationId);
            
            List<Contact> cList = [SELECT Id FROM Contact WHERE ESB_BuisnessID__c = :user.businessId.id];
            if(cList.size() > 0)
            {
                response.errors.error.add(CreateResponseMessageFormat('SF-E005', 'There is already contact with businessId "{0}" in salesforce.', new string[] { user.businessId.id }));
            }
            else
            {
                Contact newCont = ESB_ConvertHelper.extractContact(user, null);
                //newCont.ESB_WKTSADMIN_user__c = true;
                system.debug('---------- ESB_CompanyOperations: NotifyUserCreated: contact: ' + newCont);
                insert newCont;
                contactId = newCont.Id;
                response.infos.info.add(
                    CreateResponseMessageFormat(
                        'SF-1002', 
                        'Contact "{0} {1} {2}" created.', 
                        new string[] { newCont.Salutation, newCont.FirstName, newCont.LastName })
                );
            }
        }
        catch(AccountNotFoundException ex)
        {
            errorMessage = 'Account is missnig';
            response.errors.error.add(CreateResponseMessageFormat('SF-E003', 'Account with businessId "{0}" not found.', new string[] { user.companyBusinessAccount.id }));
        }
        catch(CorrelationIDMissingException ex)
        {
            errorMessage = 'missing correlationID';
            response.errors.error.add(CreateResponseMessage('SF-E006', 'Correlation ID is missing in message!'));
        }
        catch(CorrelationIDDuplicatedException ex)
        {
            errorMessage = 'duplicated correlationID';
            response.errors.error.add(CreateResponseMessage('SF-E007', 'Correlation ID duplicated: ' + correlationId));
        }
        catch(DMLException dex)
        {
            errorMessage = 'DML exception';
            Integer dmlCount = dex.getNumDml();
            for(integer i = 0; i < dmlCount; i++)
            {
                string message = string.valueOf(dex.getDmlType(i)) + ' ' + dex.getDmlMessage(i);
                response.errors.error.add(CreateResponseMessage('SF-E002', message));
            }
        }
        catch(Exception ex)
        {
            errorMessage = 'General error';
            response.errors.error.add(CreateExceptionMessage('SF-E001', ex));
        }
        
        system.debug('---------- ESB_CompanyOperations: NotifyUserCreated: response: ' + response);
        
        ESB_LogUtility.WriteLog('NotifyUserCreated', user, response, correlationId, errorMessage, NULL, contactId);
        return response;
    } //NotifyUserCreated
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 July
    * @description  process cm.company.update message - updates account
    */
    webservice static ESB_DataClasses.response NotifyCompanyUpdated(ESB_DataClasses.company company, string correlationId)
    {
        ESB_DataClasses.response response = new ESB_DataClasses.response();
        response.applicationId = ESB_DataClasses.wktsApplicationsEnum.OBSS;
        
        response.infos.info.add(CreateResponseMessage('SF-0001', 'NotifyCompanyUpdated called.'));
        
        string errorMessage = null;
        Id accountId = NULL;
        
        system.debug('---------- ESB_CompanyOperations: NotifyCompanyUpdated: received data: ' + company);
        
        try
        {
            VerifyCorrelationId(correlationId);
            List<Account> accs = [SELECT Id FROM Account WHERE AccountNumber = :company.businessId.id];
            
            system.debug('---------- ESB_CompanyOperations: NotifyCompanyUpdated: found accounts: ' + accs);
            
            if(accs == null || accs.size() == 0)
                throw new AccountNotFoundException();
            
            Account newAcc = ESB_ConvertHelper.extractAccount(company, accs.get(0).Id);
            
            system.debug('---------- ESB_CompanyOperations: NotifyCompanyUpdated: account to update: ' + newAcc);
            update newAcc; //may
            accountId = newAcc.Id;
            
            // case needs to be created if products are changed
            // or invitedBy field is not empty
            if(areProductsChanged(company, newAcc.Id) || (company.invitedBy != null)) 
            {
                // create case to align products
                Case twdCase = new Case();
                twdCase.RecordTypeId = TLR_RecordTypeHelper.getId('Case', 'TWD Case');
                twdCase.AccountId = newAcc.Id;
                //twdCase.ContactId = cont.Id;
                twdCase.Subject = 'Company update';
                
                twdCase.Description = 'Please adjust subscription for company ' + company.businessId.id;
                twdCase.Description += '\nRenewed products list:\n';
                if(company.productsAccesses != null)
                    for(String pa : company.productsAccesses.wktsCompanyProductAccess)
                        twdCase.Description += string.valueOf(pa) + '\n';
                else
                    for(ESB_DataClasses.wktsBusinessProductEnum p : company.invitedBy.forProducts.wktsBusinessProduct)
                        twdCase.Description += string.valueOf(p) + '\n';
                if(company.invitedBy != null)
                {
                    twdCase.Description += '\n\nInviter company BusinessID: ' + company.invitedBy.byCompany.id;
                    FillInvitedByField(twdCase,company.invitedBy.byCompany.id);
                }
                
                insert twdCase;
                
                response.infos.info.add(CreateResponseMessage('SF-1003', 'Case created.'));
            }
            
            TLR_AccountMembershipLifeCycleController con = new TLR_AccountMembershipLifeCycleController(newAcc.Id);
            
            response.infos.info.add(CreateResponseMessageFormat('SF-1004', 'Account "{0}" updated.', new string[] { newAcc.Name }));
        }
        catch(AccountNotFoundException ex)
        {
            errorMessage = 'Account not found';
            response.errors.error.add(CreateResponseMessageFormat('SF-E003', 'Account with businessId "{0}" not found.', new string[] { company.businessId.id }));
        }
        catch(CorrelationIDMissingException ex)
        {
            errorMessage = 'missing correlationID';
            response.errors.error.add(CreateResponseMessage('SF-E006', 'Correlation ID is missing in message!'));
        }
        catch(CorrelationIDDuplicatedException ex)
        {
            errorMessage = 'duplicated correlationID';
            response.errors.error.add(CreateResponseMessage('SF-E007', 'Correlation ID duplicated: ' + correlationId));
        }
        catch(DMLException dex)
        {
            errorMessage = 'DML error';
            Integer dmlCount = dex.getNumDml();
            for(integer i = 0; i < dmlCount; i++)
            {
                string message = string.valueOf(dex.getDmlType(i)) + ' ' + dex.getDmlMessage(i);
                response.errors.error.add(CreateResponseMessage('SF-E002', message));
            }
        }
        catch(Exception ex)
        {
            errorMessage = 'General error';
            response.errors.error.add(CreateExceptionMessage('SF-E001', ex));
        }
        
        system.debug('---------- ESB_CompanyOperations: NotifyCompanyUpdated: response: ' + response);
        ESB_LogUtility.WriteLog('NotifyCompanyUpdated', company, response, correlationId, errorMessage, accountId, NULL);
        return response;
    } //NotifyCompanyUpdated
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 July
    * @description  process cm.user.update message - updates contact
    */
    webservice static ESB_DataClasses.response NotifySuperUserUpdated(ESB_DataClasses.user user, string correlationId)
    {
        system.debug('---------- ESB_CompanyOperations: NotifySuperUserUpdated: received data: ' + user);
        
        ESB_DataClasses.response response = new ESB_DataClasses.response();
        response.applicationId = ESB_DataClasses.wktsApplicationsEnum.OBSS;
        
        response.infos.info.add(CreateResponseMessage('SF-0001', 'NotifySuperUserUpdated called.'));
        
        string errorMessage = null;
        Id contactId = NULL;
        
        system.savepoint sp;
        
        try
        {
            VerifyCorrelationId(correlationId);
            
            sp = Database.setSavepoint();
            List<Contact> cList = [SELECT Id FROM Contact WHERE ESB_BuisnessID__c = :user.businessId.id];
            Contact cont = cList.size() > 0 ? cList.get(0) : null;
            system.debug('---------- ESB_CompanyOperations: NotifySuperUserUpdated: contact found by businessID: ' + cont);
            List<Subscription__c> subsList = new List<Subscription__c>();
            Subscription__c subs = null;
            
            if(cont == null && user.companyBusinessAccount == null)
                throw new ContactNotFoundException();
            if(cont == null && user.companyBusinessAccount != null)
            {
                // contact can have empty businessId and we need to check account to find subscription with initiated provisioning
                subsList = [
                    SELECT Id, Name, Contact__r.Id, Status__c
                    FROM Subscription__c 
                    WHERE Account__r.AccountNumber = :user.companyBusinessAccount.id 
                        AND Contact__r.ESB_BuisnessID__c = null
                        AND Contact__c != null
                        AND Status__c = 'Provisioning initiated'
                    LIMIT 1
                ];
                
                system.debug('---------- ESB_CompanyOperations: NotifySuperUserUpdated: subscriptions found: ' + subsList);
                if(subsList.size() != 0)
                {
                    subs = subsList.get(0);
                    cont = subs.Contact__r;
                }
                else
                // possible case for dual provisioning: contact is not attached to a subscription with 'provisioning initiated' status
                // we need to find Contact attached to our account withoud businessID but with FX username (should be given by CM)
                {
                    cList = [
                        SELECT Id, Username__c
                        FROM Contact
                        WHERE
                            Account.AccountNumber = :user.companyBusinessAccount.id
                            AND Username__c = :user.login
                            AND ESB_BuisnessID__c = null
                    ];
                    system.debug('---------- ESB_CompanyOperations: NotifySuperUserUpdated: contacts found (case 2): ' + cList);
                    if(cList.size() > 0)
                        cont = cList.get(0);
                }
            }
            if(cont == null) // here we need to create contact
            {
                Contact newCont = ESB_ConvertHelper.extractContact(user, null);
                //newCont.ESB_WKTSADMIN_user__c = true;
                system.debug('---------- ESB_CompanyOperations: NotifySuperUserUpdated: contact not found. About to create contact: ' + newCont);
                insert newCont;
                
                response.infos.info.add(CreateResponseMessageFormat('SF-1005', 'Contact "{0}" created.', new string[] { newCont.Name }));
            }
            else // here contact is found and we need to update it
            {
                contactId = cont.Id;
                Contact newCont = ESB_ConvertHelper.extractContact(user, cont.Id);
                //newCont.ESB_WKTSADMIN_user__c = true;
                system.debug('---------- ESB_CompanyOperations: NotifySuperUserUpdated: extracted contact: ' + newCont);
                update newCont;
                
                ESB_DataClasses.responseTracking msg1 = new ESB_DataClasses.responseTracking();
                msg1.messageDate = datetime.now();
                msg1.message.key = 'SF-1005';
                msg1.message.content = string.format('Contact "{0}" updated.', new string[] { newCont.Name });
                response.infos.info.add(msg1);
                
                // now we need to activate subscription.
                if(subs != null)
                    if(subs.Status__c == 'Provisioning initiated')
                    {
                        subs.Status__c = 'Active';
                        update subs;
                    }
            }
        }
        catch(ContactNotFoundException ex)
        {
            errorMessage = 'Contact not found';
            Database.rollback(sp);
            string message = string.format('User with businessId "{0}" not found.', new string[] { user.businessId.id });
            if(user.companyBusinessAccount != null)
            {
                if(user.companyBusinessAccount.id != null)
                    message = string.format('User for company with businessId "{0}" not found.', new string[] { user.companyBusinessAccount.id });
            }
            response.errors.error.add(CreateResponseMessage('SF-E004', message));
        }
        catch(CorrelationIDMissingException ex)
        {
            errorMessage = 'missing correlationID';
            response.errors.error.add(CreateResponseMessage('SF-E006', 'Correlation ID is missing in message!'));
        }
        catch(CorrelationIDDuplicatedException ex)
        {
            errorMessage = 'duplicated correlationID';
            response.errors.error.add(CreateResponseMessage('SF-E007', 'Correlation ID duplicated: ' + correlationId));
        }
        catch(DMLException dex)
        {
            errorMessage = 'DML error';
            Database.rollback(sp);
            Integer dmlCount = dex.getNumDml();
            for(integer i = 0; i < dmlCount; i++)
            {
                string message = string.valueOf(dex.getDmlType(i)) + ' ' + dex.getDmlMessage(i);
                response.errors.error.add(CreateResponseMessage('SF-E002', message));
            }
        }
        catch(Exception ex)
        {
            errorMessage = 'General error';
            Database.rollback(sp);
            response.errors.error.add(CreateExceptionMessage('SF-E001', ex));
        }
        
        system.debug('---------- ESB_CompanyOperations: NotifySuperUserUpdated: response: ' + response);
        ESB_LogUtility.WriteLog('NotifySuperUserUpdated', user, response, correlationId, errorMessage, NULL, contactId);
        return response;
    } //NotifySuperUserUpdated
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 July
    * @description  process cm.company.publish message - creates case for account to be published
    */
    webservice static ESB_DataClasses.response NotifyCompanyPublished(ESB_DataClasses.company company, string correlationId)
    {
        system.debug('---------- ESB_CompanyOperations: NotifyCompanyPublished: call. ');
        ESB_DataClasses.response response = new ESB_DataClasses.response();
        response.applicationId = ESB_DataClasses.wktsApplicationsEnum.OBSS;
        
        response.infos.info.add(CreateResponseMessage('SF-0001', 'NotifyCompanyPublished called.'));
        
        string errorMessage = null;
        Id accountId = NULL;
        
        try
        {
            VerifyCorrelationId(correlationId);
            List<Account> accs = [SELECT Id, Name FROM Account WHERE AccountNumber = :company.businessId.id];
            
            system.debug('---------- ESB_CompanyOperations: NotifyCompanyPublished: found accounts: ' + accs);
            
            if(accs == null || accs.size() == 0)
                throw new AccountNotFoundException();
                
            Account acc = accs.get(0);
            accountId = acc.Id;
            
            // create case to approve guest company (TWD only)
            Case twdCase = new Case();
            twdCase.RecordTypeId = TLR_RecordTypeHelper.getId('Case', 'TWD Case');
            twdCase.AccountId = acc.Id;
            twdCase.Subject = 'Publish company';
            twdCase.Description = 'Please validate and approve company. When done please add CD_Approved to account\'s subscription.';
            twdCase.Description += '\nAccount: ' + acc.Name + ' (businessId: ' + company.businessId.id + ')';
			twdCase.Origin = 'Community Manager';
            //twdCase.OwnerId = customer care for TWD
            
            insert twdCase;
            
            response.infos.info.add(CreateResponseMessage('SF-1003', 'Case created.'));
        }
        catch(AccountNotFoundException ex)
        {
            errorMessage = 'Account not found';
            response.errors.error.add(CreateResponseMessageFormat('SF-E003', 'Account with businessId "{0}" not found.', new string[] { company.businessId.id }));
        }
        catch(CorrelationIDMissingException ex)
        {
            errorMessage = 'missing correlationID';
            response.errors.error.add(CreateResponseMessage('SF-E006', 'Correlation ID is missing in message!'));
        }
        catch(CorrelationIDDuplicatedException ex)
        {
            errorMessage = 'duplicated correlationID';
            response.errors.error.add(CreateResponseMessage('SF-E007', 'Correlation ID duplicated: ' + correlationId));
        }
        catch(DMLException dex)
        {
            errorMessage = 'DML error';
            Integer dmlCount = dex.getNumDml();
            for(integer i = 0; i < dmlCount; i++)
            {
                string message = string.valueOf(dex.getDmlType(i)) + ' ' + dex.getDmlMessage(i);
                response.errors.error.add(CreateResponseMessage('SF-E002', message));
            }
        }
        catch(Exception ex)
        {
            errorMessage = 'General error';
            response.errors.error.add(CreateExceptionMessage('SF-E001', ex));
        }
        
        system.debug('---------- ESB_CompanyOperations: NotifyCompanyPublished: response: ' + response);
        ESB_LogUtility.WriteLog('NotifyCompanyPublished', company, response, correlationId, errorMessage, accountId, NULL);
        return response;
    } //NotifyCompanyPublished
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 July
    * @description  private method to create subscription automatically
    */
    private static void CreateGuestCompanyAutomated(Id accountId, Id contactId)
    {
        // here we need to create oppty, attach offer template to it and accept offer to create subscription.
        // then we need to attach superUser and send subscription for provisioning
        system.debug('---------- ESB_CompanyOperations: CreateGuestCompanyAutomated: entry');
        // 1) create oppty
        Opportunity oppty = new Opportunity();
        oppty.Name = 'CD opportunity for invited guest';
        oppty.Product_Interest__c = 'CD';
        oppty.StageName = 'New not worked';
        oppty.Probability = 10;
        oppty.CloseDate = date.today();
        oppty.AccountId = accountId;
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
        Subscription__c subs = [SELECT Id, Name, Contact__c, Status__c, Flag_IntegrityChecks__c,Waiting_For_Payment__c FROM Subscription__c WHERE Id=:subsId];
        system.debug('---------- ESB_CompanyOperations: CreateGuestCompanyAutomated: subscription found: ' + subs);
        subs.Contact__c = contactId;
        subs.Flag_IntegrityChecks__c = true;
        //subs.Status__c = 'Sent';
        //update subs;
        //subs.Status__c = 'Waiting For Verification';
        //update subs;
        if(subs.Waiting_For_Payment__c)
        {
            subs.Status__c = 'Waiting For Payment';
        }
        else
        {
            subs.Status__c = 'Waiting For Provisioning';
        }
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
        // initiate provisioning
        //TLR_SubscriptionExt subsExt = new TLR_SubscriptionExt(subs.Id);
        //subsExt.InitCreateProvisioning();
        
        // subscription should be active now, because it i already active in WKTSAdmin
        /*subs.Status__c = 'Provisioning initiated';
        update subs;*/
        subs.Status__c = 'Active';
        update subs; //may
        TLR_AccountMembershipLifeCycleController con = new TLR_AccountMembershipLifeCycleController(accountId);
        // now we need to send confirmation to everyone
        ESB_Proxy.ApproveCompany(accountId, contactId, subs.Id);
    } //CreateGuestCompanyAutomated
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 July
    * @description   returns true if new products are added, or old ones are removed
    */
    private static boolean areProductsChanged(ESB_DataClasses.company company, Id accId)
    {
        Map<string, ESB_PA_to_ProductsMapping__c> paMapping = ESB_PA_to_ProductsMapping__c.getAll();
        boolean productAccess = false, invitedProducts = false;
        if(company.productsAccesses != null)
            productAccess = true;
        if(company.invitedBy != null)
            invitedProducts = true;
            
        if(!productAccess && !invitedProducts) // no changes
            return false;
            
        Set<string> validOffers = Utilities.getNewProvisioningOfferTemplatesLowerCase();
        Set<string> newProducts = new Set<String>();
        Set<string> oldProducts = new Set<String>();
        boolean retVal = false;
        
        // list of new products
        if(productAccess)
            for(String pa : company.productsAccesses.wktsCompanyProductAccess)
                if(paMapping.containsKey(pa))
                    newProducts.add(paMapping.get(string.valueOf(pa)).ESB_BusinessProduct__c);
        
        if(invitedProducts)
            for(ESB_DataClasses.wktsBusinessProductEnum p : company.invitedBy.forProducts.wktsBusinessProduct)
                newProducts.add(string.valueOf(p));
        
        // get list of old products
        List<Subs_Current_Fee__c> scfList = [
            SELECT
                Id, Name, Subscription__r.Offer_Template__r.Name
            FROM Subs_Current_Fee__c
            WHERE Subscription__r.Account__c = :accId
                AND Subscription__r.Status__c = 'Active'
        ];
        for(Subs_Current_Fee__c scf : scfList)
            if(validOffers.contains(scf.Subscription__r.Offer_Template__r.Name.toLowerCase())) // if offer template is ours
                if(paMapping.containsKey(scf.Name)) // if our mapping contains this key
                {
                    string productName = paMapping.get(scf.Name).ESB_BusinessProduct__c;
                    if(!oldProducts.contains(productName))  // if our list isn't contain current value
                        oldProducts.add(productName);
                }
        system.debug('---------- ESB_CompanyOperations: areProductsChanged: oldProducts: ' + oldProducts);
        system.debug('---------- ESB_CompanyOperations: areProductsChanged: newProducts: ' + newProducts);
        // lets compare our lists
        for(string s : oldProducts)
            if(!newProducts.contains(s))
                retVal = true;
        for(string s : newProducts)
            if(!oldProducts.contains(s))
                retVal = true;
        
        return retVal;
    } //areProductsChanged
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 January 20
    * @description  process asynchronous response from WKTSA
                    main task is to save status and error message (if any)
    */
    webservice static ESB_DataClasses.response ProcessResponse(ESB_DataClasses.response response)
    {
        ESB_DataClasses.response retVal = new ESB_DataClasses.response();
        retVal.applicationId = ESB_DataClasses.wktsApplicationsEnum.OBSS;
        
        retVal.infos.info.add(CreateResponseMessage('SF-0001', 'ProcessResponse called.'));
        
        try
        {
            List<ESB_Interaction_Logs__c> logs = [
                SELECT Id, Message_correlationId__c
                FROM ESB_Interaction_Logs__c
                WHERE Message_correlationId__c = :response.correlationId
            ];
            
            if(logs.size() < 1)
                throw new CorrelationIDMissingException();
            
            if(logs.size() > 1)
                throw new CorrelationIDDuplicatedException();
            
            ESB_Interaction_Logs__c requestLog = logs.get(0);
            
            requestLog.Remote_response__c = string.valueOf(response);
            string responseContent = requestLog.Remote_response__c.substringAfter('[content=').substringBefore(', key=');                
            if(responseContent == 'success')
            {
                requestLog.CM_Successful_Response_Checkbox__c = true;
            }
            update requestLog;
        }
        catch(CorrelationIDMissingException ex)
        {
            string message = 'Correlation ID not found: ' + response.correlationId;
            retVal.errors.error.add(CreateResponseMessage('SF-E006', message));
        }
        catch(CorrelationIDDuplicatedException ex)
        {
            string message = 'Correlation ID duplicated: ' + response.correlationId;
            retVal.errors.error.add(CreateResponseMessage('SF-E007', message));
        }
        catch(Exception ex)
        {
            retVal.errors.error.add(CreateExceptionMessage('SF-E001', ex));
        }
        
        return retVal;
    } //ProcessResponse
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 January 20
    * @description  marks SF Contact as removed (WKTSCRM-1725)
    */
    webservice static ESB_DataClasses.response RemoveUser(ESB_DataClasses.user user, string correlationId)
    {
        system.debug('---------- ESB_CompanyOperations: RemoveUser: received data: ' + user);
        
        ESB_DataClasses.response retVal = new ESB_DataClasses.response();
        retVal.applicationId = ESB_DataClasses.wktsApplicationsEnum.OBSS;
        
        retVal.infos.info.add(CreateResponseMessage('SF-0001', 'RemoveUser called.'));
        
        string errorMessage = null;
        Id contactId = NULL;
        
        try
        {
            VerifyCorrelationId(correlationId);
            
            List<Contact> cList = [SELECT Id, FirstName, LastName, ESB_User_status__c FROM Contact WHERE ESB_BuisnessID__c = :user.businessId.id];
            Contact exCont = cList.size() > 0 ? cList.get(0) : null;
            system.debug('---------- ESB_CompanyOperations: RemoveUser: contact found by businessID: ' + exCont);
            
            if(exCont == null)
                throw new ContactNotFoundException();
            
            Contact cont = cList.get(0);
            cont.ESB_User_status__c = 'SUSPENDED';
            
            update cont;
            contactId = cont.Id;
            
            retVal.infos.info.add(
                CreateResponseMessageFormat(
                    'SF-1006', 
                    'Contact "{0} {1}" with businessID "{2}" marked as suspended.', 
                    new string[] { cont.FirstName, cont.LastName, user.businessId.id })
            );
        }
        catch(ContactNotFoundException ex)
        {
            errorMessage = 'Contact not found';
            retVal.errors.error.add(CreateResponseMessageFormat('SF-E004', 'User with businessId "{0}" not found.', new string[] { user.businessId.id }));
        }
        catch(CorrelationIDMissingException ex)
        {
            errorMessage = 'missing correlationID';
            retVal.errors.error.add(CreateResponseMessage('SF-E006', 'Correlation ID is missing in message!'));
        }
        catch(CorrelationIDDuplicatedException ex)
        {
            errorMessage = 'duplicated correlationID';
            retVal.errors.error.add(CreateResponseMessage('SF-E007', 'Correlation ID duplicated: ' + correlationId));
        }
        catch(Exception ex)
        {
            errorMessage = 'General error';
            retVal.errors.error.add(CreateExceptionMessage('SF-E001', ex));
        }
        
        system.debug('---------- ESB_CompanyOperations: RemoveUser: response: ' + retVal);
        ESB_LogUtility.WriteLog('RemoveUser', user, retVal, correlationId, errorMessage, NULL, contactId);
        
        return retVal;
    } //RemoveUser
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 March 23
    * @description  Creates response message to be added to response infos, warnings or errors
    */
    public static ESB_DataClasses.responseTracking CreateResponseMessage(string key, string content)
    {
        ESB_DataClasses.responseTracking msg = new ESB_DataClasses.responseTracking();
        msg.messageDate = datetime.now();
        msg.message.key = key;
        msg.message.content = content;
        return msg;
    } // CreateResponseMessage
    public static ESB_DataClasses.responseTracking CreateResponseMessageFormat(string key, string format, List<string> arguments)
    {
        return CreateResponseMessage(key, string.format(format, arguments));
    } // CreateResponseMessage
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 March 23
    * @description  Creates error response message. To keep message formatting in one place
    */
    public static ESB_DataClasses.responseTracking CreateExceptionMessage(string key, Exception ex)
    {
        string content = ex.getMessage();
        return CreateResponseMessage(key, content);
    } // CreateResponseMessage
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 July 15
    * @description  verifies correlationID
    */
    private static void VerifyCorrelationId(string corrId)
    {
        if(corrId == null)
            throw new CorrelationIDMissingException();
        if(string.isBlank(corrId))
            throw new CorrelationIDMissingException();
        
        List<ESB_Interaction_Logs__c> logs = [SELECT Id, Name, Message_CorrelationId__c FROM ESB_Interaction_Logs__c WHERE Message_CorrelationId__c = :corrId and Message__c = null];
        if(logs.size() > 0)
            throw new CorrelationIDDuplicatedException();
        
    } //VerifyCorrelationId
    
    private static void FillInvitedByField(Case twdCase,string invitedByAccNum)
    {
        List<Account> acc = [Select Id from Account where AccountNumber =: invitedByAccNum];
        if(acc != null && acc.size() > 0)
        {
            twdCase.Invited_By__c=acc[0].Id;
        }
    }
}