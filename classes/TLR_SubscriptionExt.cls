/**
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2013 September 2
* @description  Controller extension for Subscription
**/
public with sharing class TLR_SubscriptionExt
{
    public Subscription__c subscription { get; set; }
    public Boolean error { get; set; }
    //------------------------------------------------------------------------------------------------------
    // upload document page variables
    //------------------------------------------------------------------------------------------------------
    public Document myDocument { get; set; }
    //------------------------------------------------------------------------------------------------------
    // edit subscription page variables
    //------------------------------------------------------------------------------------------------------
    public Boolean startDateEditable { get; set; }
    public Boolean endDateEditable { get; set; }
    public Boolean statusEditable { get; set; }
    //------------------------------------------------------------------------------------------------------
    // Contract PDF page variables
    //------------------------------------------------------------------------------------------------------
    public List<Subs_Package_And_Fee__c> subsPackFeesForContract { get; set; }
    public List<Subs_Package_And_Fee__c> subsPackFeesPM { get; set; }
    public List<Subs_Package_And_Fee__c> subsPackFeesHosting { get; set; }
    public Account client { get; set; }
    public string clientAddress { get; set; }
    public decimal modulesTotal { get; set; }
    public decimal maintenanceTotal { get; set; }
    public decimal consultingTotal { get; set; }
    public decimal consultingPMTotal { get; set; }
    //------------------------------------------------------------------------------------------------------
    // constructors
    //------------------------------------------------------------------------------------------------------
    public TLR_SubscriptionExt(ApexPages.StandardController stdController)
    {
        this(stdController.getId());
    }

    public TLR_SubscriptionExt(Id subsId)
    {
        subscription = [
            SELECT 
                Id, Name, Account__c, Contact__c, Contract__c, Status__c, Terms_Conditions__c,
                Offer_Template__c, Product__c, Siebel_agreement_id__c,
                History__c, Price_List_Code__c, Notes__c, Purchase_Order__c,
                Payment_date__c, Start_Date__c, Start_Usage_Payment__c,
                End_Date__c, CUG_allowed__c, Opportunity__c, Consolidation_Level__c,
                Contract__r.Account.Name, Contract__r.Name, Account__r.ESB_Created_By_WKTSAdmin__c, Account__r.VAT__c,
                Contract__r.AccountId, Opportunity__r.Name,
                Data_Quality__c, Required_Documents__c, Payment_information__c,
                CreditRatingScore_OK__c,Lrisk_OK__c, Referrals_OK__c,
                InsuranceDocuments_OK__c,PassportContractSigner_OK__c,Letterhead_OK__c,OtherChecks_OK__c,
                CreatedDate,LastModifiedDate,Remarks__c,
                Contract__r.Account.BillingCountry,Contract__r.Account.BillingCity, Contract__r.Account.BillingPostalCode,
                Contract__r.Account.BillingStreet, Contract__r.Account.Phone, Contract__r.Account.Fax, Contract__r.Account.VAT__c,
                Contract__r.Account.Email__c, Contract__r.Status, Contract__r.Account.ESB_Company_status__c, Contract__r.Skip_Bank_information_validation__c,
            	Contract__r.Account.Direct_Debit__c, Contract__r.Invoice_Level__c, Contract__r.Account.Account_Level__c, Contract__r.Account.Bank_Number__c,
            	Contract__r.Account.BIC_Code__c, Contract__r.Account.Organization_Country__c, Contract__r.Account.Bank_Code_FR__c,
            	Contract__r.Account.Cashier_Code_FR__c, Contract__r.Account.RIB_Key_FR__c, Contract__r.Account.Payment_Terms__c,
                Opportunity__r.Product_Interest__c, Offer_Template__r.Name, Offer_Template__r.Use_new_Provisioning__c, Contact__r.FirstName,Waiting_For_Payment__c,
            	Has_Active_Verification_Page__c, Opportunity__r.RecordTypeId, Contact__r.Language__c,Product__r.Name
            FROM Subscription__c
            WHERE Id = :subsId
        ];

        startDateEditable = (subscription.Status__c != 'Active'
            && subscription.Status__c != 'On Notice'
            && subscription.Status__c != 'Cancelled');
        endDateEditable = ( subscription.Status__c != 'On Notice' && subscription.Status__c != 'Cancelled');
        statusEditable = subscription.Status__c != 'Cancelled';
    } // TLR_SubscriptionExt
    //------------------------------------------------------------------------------------------------------
    // edit subscription page methods
    //------------------------------------------------------------------------------------------------------
    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 2
    * @description  Saves subscription and updates related lists
    **/
    public PageReference SaveSubscription()
    {
        try
        {
            update subscription;
            // Update Subs Promo Line Items
            SubsPromoLineItemsUtils.updatePromoLineItemsDates(subscription.Id, subscription.Start_Date__c, subscription.End_Date__c);
            return RedirectToSubscription();
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
            return null;
        }
    } // SaveSubscription

    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 2
    * @description  Redirect to subscription
    **/
    public PageReference RedirectToSubscription()
    {
        return Utilities.Redirect(subscription.Id);
    }
    //------------------------------------------------------------------------------------------------------
    // CreateContractPDF page methods
    //------------------------------------------------------------------------------------------------------
    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 10
    * @description  Initialiaztion for Contract PDF page: get list of PackFees, and updaets subscription status to 'sent'
    **/
    public PageReference InitCreateContractPDF()
    {
        if(subscription.Status__c == 'Draft')
        {
            subscription.Status__c = 'Sent';
            update subscription;
        }

        /*subsPackFeesForContract = [
            SELECT
                Id, Name, Sales_Price__c,
            FROM Subs_Package_And_Fee__c
            WHERE Subscription__c = :subscription.Id AND (NOT (Name LIKE 'Maintenance %'))
        ];*/

        List<Subs_Package_And_Fee_Line_Item__c> subsPFLineItems = [
            SELECT
                Id,
                Subs_Package_And_Fee__r.Id, Subs_Package_And_Fee__r.Name, Subs_Package_And_Fee__r.Sales_Price__c,
                Subs_Package_And_Fee__r.Real_Quantity__c, Subs_Package_And_Fee__r.Min_Price__c,
                Service__r.RecordTypeId
            FROM Subs_Package_And_Fee_Line_Item__c
            WHERE Subs_Package_And_Fee__r.Subscription__c = :subscription.Id
                AND (NOT (Subs_Package_And_Fee__r.Name LIKE 'Maintenance %'))
        ];
        subsPackFeesForContract = new List<Subs_Package_And_Fee__c>();
        subsPackFeesPM = new List<Subs_Package_And_Fee__c>();
        subsPackFeesHosting = new List<Subs_Package_And_Fee__c>();
        for(Subs_Package_And_Fee_Line_Item__c item : subsPFLineItems)
            subsPackFeesForContract.add(item.Subs_Package_And_Fee__r);

        //Map<Id, Subs_Package_And_Fee__c> subsPFMap = new Map<Id, Subs_Package_And_Fee__c>(subsPackFeesForContract);

        double sumModules = 0;
        double sumConsulting = 0;
        double sumPM = 0;
        double sumMaintenance = [SELECT Sales_Price__c FROM Subs_Package_And_Fee__c WHERE Subscription__c = :subscription.Id AND Name='Total Maintenance'][0].Sales_Price__c;
        Id tasModuleRTId = TLR_RecordTypeHelper.getId('Service__c', 'TAS Module');
        Id tasConsultingRTId = TLR_RecordTypeHelper.getId('Service__c', 'TAS Consulting');
        for(Subs_Package_And_Fee_Line_Item__c pfli : subsPFLineItems)
        {
            if(pfli.Subs_Package_And_Fee__r.Name.indexOf('Hosting ') == 0)
                subsPackFeesHosting.add(pfli.Subs_Package_And_Fee__r);
            else if(pfli.Service__r.RecordTypeId == tasModuleRTId)
                sumModules += pfli.Subs_Package_And_Fee__r.Sales_Price__c;
            else if(pfli.Service__r.RecordTypeId == tasConsultingRTId)
            {
                if(pfli.Subs_Package_And_Fee__r.Name != 'Consulting')
                {
                    subsPackFeesPM.add(pfli.Subs_Package_And_Fee__r);
                    sumPM += pfli.Subs_Package_And_Fee__r.Sales_Price__c;
                }
                sumConsulting += pfli.Subs_Package_And_Fee__r.Sales_Price__c;
            }
        }
        modulesTotal = sumModules;
        maintenanceTotal = sumMaintenance;
        consultingTotal = sumConsulting;
        consultingPMTotal = sumPM;

        client = subscription.Contract__r.Account;
        return null;
    }

    //------------------------------------------------------------------------------------------------------
    // UploadDocument page methods
    //------------------------------------------------------------------------------------------------------
    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 10
    * @description  Initialiaztion for Upload document page: simlpe check
    **/
    public PageReference InitUploadDocument()
    {
        error = false;

        if (subscription.Status__c != 'Sent')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Documents can be uploaded only under \'Sent\' status!'));
            error = true;
        }
        myDocument = new Document();
        return null;
    }

    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 10
    * @description  Saves document to subscription as attachment. Also updates subscription status
    **/
    public PageReference SaveDocument()
    {
        if (myDocument.Name == null || myDocument.Body == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select a document before saving!'));
            return null;
        }

        try
        {
            Attachment attach = new Attachment();
            attach.Body = myDocument.Body;
            attach.ContentType = myDocument.ContentType;
            attach.Name = myDocument.Name;
            attach.OwnerId = UserInfo.getUserId();
            attach.ParentId = subscription.Id;
            insert attach;

            subscription.Status__c = 'Waiting For Verification';
            update subscription;
        }
        catch (Exception e)
        {
            Generic.StandardException ex = new Generic.StandardException();
            ex.SetMessage('Error during upload! ' + e.getMessage());
            throw ex;
        }

        return RedirectToSubscription();
    }
    //------------------------------------------------------------------------------------------------------
    // VerifyTASSubscription page methods
    //------------------------------------------------------------------------------------------------------
    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 10
    * @description  Initialization for Activate Subscription page (Tas contracts only):
    *               update subscription status and populate CurrentFees with proper values
    **/
    public PageReference InitVerifyTasSybscription()
    {
        Savepoint sp = Database.setSavepoint();
        try
        {
            if(subscription.Status__c != 'Waiting For Verification')
                throw new Generic.StandardException('Subscription is not ready for verification, or already verified.');

            // we need this 3-step status change to keep existing validation in place
            subscription.Status__c = 'Waiting For Provisioning';
            update subscription;
            subscription.Status__c = 'Provisioning initiated';
            update subscription;
            subscription.Status__c = 'Active';
            update subscription;

            TLR_SubscriptionHelper.CreateSubscriptionCurrentFeesFromPF(subscription.Id, null);

            // update Total Maintenance CurrentFee sales price to 0
            List<Subs_Current_Fee__c> subsCurentFees = [
                SELECT
                    Id, Name, Price__c
                FROM Subs_Current_Fee__c
                WHERE Subscription__c = :subscription.Id AND Name = 'Total Maintenance'
            ];
            for(Subs_Current_Fee__c fee : subsCurentFees)
                fee.Price__c = 0;
            update subsCurentFees;

            subscription.Contract__r.Status__c = 'Active';
            subscription.Contract__r.Status = 'Activated';
            update subscription.Contract__r;
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
            return null;
        }
        return RedirectToSubscription();
    }
    //------------------------------------------------------------------------------------------------------
    // VerifySubscription page methods
    //------------------------------------------------------------------------------------------------------
    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 September 10
    * @description  Initialization forVerify Subscription page
    **/
    public PageReference InitVerifyTlrSybscription()
    {
        error = false;

        if (subscription.Status__c != 'Waiting For Verification' && subscription.Status__c != 'Verification incomplete')
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Subscriptions can be verified only under \'Waiting For Verification\' or \'Verification incomplete\' statuses'));
        }
		
        List<Subscription__c> subsWithActiveFXContract = [Select Id From Subscription__c Where Account__c =: subscription.Account__c and 
                                           										(Product__r.Name = 'T-PRO' or Product__r.Name = 'TFX'or Product__r.Name = 'T-ACTIVE') and
                                          										Contract__r.Status__c = 'Active'];
        if(subscription.Has_Active_Verification_Page__c 
           || (subscription.Product__r.Name != 'TFX' && subscription.Product__r.Name != 'T-PRO' && subscription.Product__r.Name != 'T-ACTIVE') 
           || subscription.Opportunity__r.RecordTypeId == TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Admin Opportunity') 
           || subsWithActiveFXContract.size() > 0) 
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
            return RedirectToSubscription();
        }   
        else
        {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Account does not have active Verification Page with limited or full access'));
        }
        return null;
    }
   
    //------------------------------------------------------------------------------------------------------
    // CreateProvisioning page methods
    //------------------------------------------------------------------------------------------------------
    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 April 22
    * @description  performs checks of a subscription
    **/
    public PageReference InitCreateProvisioning()
    {
        System.Savepoint sp = Database.setSavepoint();
        try
        {
        	System.debug('TLR_SubscriptionExt: InitCreateProvisioning: entry.');
            if ([SELECT count() FROM Provisioning__c WHERE Subscription__c = :this.subscription.Id] > 0)
                throw new Generic.StandardException('Provisioning already initiated, check the corresponding related list in subscription'); 
            if (this.subscription.Status__c != 'Waiting For Provisioning' && this.subscription.Status__c != 'Waiting For Payment')
                throw new Generic.StandardException('Provisioning can be started only on subscriptions under \'Waiting for Provisioning\' or \'Waiting For Payment\' status'); 
            if (this.subscription.Product__c == null)
                throw new Generic.StandardException('Product field should not be empty');
            
            //validation rules on Contract level
            boolean validateOnContractLevel = !this.subscription.Contract__r.Skip_Bank_information_validation__c                
               && this.subscription.Contract__r.Account.Direct_Debit__c 
               && this.subscription.Contract__r.Invoice_Level__c == subscription.Contract__r.Account.Account_Level__c;
            
            if(validateOnContractLevel
               && (String.isEmpty(this.subscription.Contract__r.Account.Bank_Number__c) || String.isEmpty(this.subscription.Contract__r.Account.BIC_Code__c)))
                throw new Generic.StandardException('Bank Number and BIC Code on Account should not be blank');
            if(validateOnContractLevel
               && (this.subscription.Contract__r.Account.Organization_Country__c).toLowerCase() == 'france'
               && (String.isEmpty(this.subscription.Contract__r.Account.Bank_Code_FR__c) 
                   || String.isEmpty(this.subscription.Contract__r.Account.Cashier_Code_FR__c ) 
                   || String.isEmpty(this.subscription.Contract__r.Account.RIB_Key_FR__c )))
                throw new Generic.StandardException('Bank Code,Cashier Code, and RIB Key on Account should not be blank');
            if(validateOnContractLevel
               && (this.subscription.Contract__r.Account.Organization_Country__c).toLowerCase() == 'france'
               && this.subscription.Contract__r.Account.Payment_Terms__c != 45)
                throw new Generic.StandardException('Payment Terms on Account Should be 45');
            
            System.debug('TLR_SubscriptionExt: InitCreateProvisioning: subscription: ' + subscription);
            // we need to provision only 2 products in new way
            if(this.subscription.Offer_Template__r.Use_new_Provisioning__c)
            {        	
            	if(subscription.Account__r.VAT__c == null)
                    throw new Generic.StandardException('VAT is required to start provisioning.');
                if(subscription.Contact__c == null)
                    throw new Generic.StandardException('You need to attach contact to provision TFX or TWD or CD product.');
                if(subscription.Contact__r.FirstName == null)
                    throw new Generic.StandardException('You need to set contact first name to provision TFX or TWD or CD product.');
                if(!utilities.ValidateLanguage(subscription.Contact__r.Language__c))
                    throw new Generic.StandardException('Language is incorrect on the Contact level.');
                Id AccId = subscription.Account__c;
                Id ContId = subscription.Contact__c;
                
                subscription.Status__c = 'Provisioning initiated';
                update subscription;
                
                System.debug('TLR_SubscriptionExt: InitCreateProvisioning: ESB_Company_status__c: ' + subscription.Contract__r.Account.ESB_Company_status__c);
                
                // 1) ESB call to notify about created company
                if(subscription.Contract__r.Account.ESB_Company_status__c == 'CREATED') // created on WKTSA side - we need to approve it
                {
                	ESB_Proxy.ApproveCompany(subscription.Account__c, subscription.Contact__c, subscription.Id);
                	//subscription.Status__c = 'Active';
                	//update subscription;
                }
                else if(String.isEmpty(subscription.Contract__r.Account.ESB_Company_status__c)) // Created on our side
                {
                	ESB_Proxy.CreateCompany(AccId, ContId, true, subscription.Id);
                }
                else
                {
                	ESB_Proxy.UpdateCompany(AccId, true, subscription.Id);
                	//subscription.Status__c = 'Active';
                	//update subscription;
                }
                return RedirectToSubscription();
            }
            else // old-fashioned provisioning
            {
                Provisioning__c prov = CreateOldProvisioning(this.subscription);
                return (Utilities.Redirect(prov.Id));
            }
        }
        catch (Exception ex)
        {
        	System.debug('TLR_SubscriptionExt: InitCreateProvisioning: exception: ' + ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
            Database.rollback(sp);
        }
        return null;
    } // InitCreateProvisioning
    
    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 April 22
    * @description  creates provisioning-related records
    **/
    private Provisioning__c CreateOldProvisioning(Subscription__c subs)
    {
        Provisioning__c prov = null;
        
        Map<Id, Id> mappingProvServ = new Map<Id, Id>();
        Map<Id, Id> mappingRTServ = new Map<Id, Id>();
        
        // Provisioning creation
        try
        {
            prov                   = new Provisioning__c();
            prov.Name              = 'Provisioning - '+subs.Opportunity__r.Name;
            prov.OwnerId           = UserInfo.getUserId();
            prov.Account__c        = subs.Contract__r.AccountId;
            prov.Contract__c       = subs.Contract__c;
            prov.Offer_Template__c = subs.Offer_Template__c;
            prov.Subscription__c   = subs.Id;
            
            insert prov;
        }
        catch (Exception e)
        {
            throw new Generic.StandardException('Cannott create provisioning: ' + e.getMessage()); 
        }
        
        // Provisioning Services
        ID productId = subscription.Product__c;
        List<Offer_Line_Item__c> offerLIs = [
            SELECT 
                Id, Service__c, Service__r.Name, Service_Attribute_Template__c
            FROM Offer_Line_Item__c
            WHERE Offer_Template__c = :subs.Offer_Template__c
            ORDER BY Service__r.Name ASC
            ];
        
        List<Product_Line_Item__c> productLineItems = [
            SELECT Service__c 
            FROM Product_Line_Item__c 
            WHERE Parent__c = :productId
        ];
        Set<ID> serviceIDs = new Set<ID>();
        for (Product_Line_Item__c pli : productLineItems)
            serviceIDs.add(pli.Service__c);
        
        try
        {
            // Provisioning Services
            List<Provisioning_Service__c> lstProvServ = new List<Provisioning_Service__c>();            
            // Services first
            for (Offer_Line_Item__c offerLI : offerLIs)
            {
                if (serviceIDs.contains(offerLI.Service__c))
                {
                    Provisioning_Service__c ps  = new Provisioning_Service__c();
                    ps.Name                     = offerLI.Service__r.Name;
                    ps.Provisioning__c          = prov.Id;
                    ps.Service__c               = offerLI.Service__c;
                    lstProvServ.add(ps);
                }
            } // for each offer line item
            
            //Then add-ons
            for (Offer_Line_Item__c offerLI : offerLIs)
            {
                if (!serviceIDs.contains(offerLI.Service__c))
                {
                    Provisioning_Service__c ps  = new Provisioning_Service__c();
                    ps.Name                     = offerLI.Service__r.Name;
                    ps.Provisioning__c          = prov.Id;
                    ps.Service__c               = offerLI.Service__c;
                    
                    lstProvServ.add(ps);
                }
            } // for each offer line item
            
            if (lstProvServ.size() > 0)
                insert lstProvServ;
            
            for (Provisioning_Service__c ps : lstProvServ)
                mappingProvServ.put(ps.Service__c, ps.Id);
        }
        catch (Exception e)
        {
            throw new Generic.StandardException('Cannot create provisioning services: ' + e.getMessage()); 
        }
        // Provisioning Service Attributes & Rights Template Service Attributes creation
        List<Id> servAttrTempls = new List<Id>();
        for (Offer_Line_Item__c offerLI : offerLIs)
        {
            if (offerLI.Service_Attribute_Template__c != null)
                servAttrTempls.add(offerLI.Service_Attribute_Template__c);
        }
        
        List<Service_Attribute_Template_Line_Item__c> servAttrTplLIs = [
            SELECT Service_Attribute__c 
            FROM Service_Attribute_Template_Line_Item__c 
            WHERE Service_Attribute_Template__c IN :servAttrTempls
        ];
        List<Id> servAttrs = new List<Id>();
        for (Service_Attribute_Template_Line_Item__c servAttrTplLI : servAttrTplLIs)
            servAttrs.add(servAttrTplLI.Service_Attribute__c);
        
        List<Service_Attribute__c> serviceAttributes = [
            SELECT Id, Name, Parent__c 
            FROM Service_Attribute__c 
            WHERE Id IN :servAttrs 
            ORDER BY Name ASC
        ];
        try
        {
            List<Provisioning_Service_Attribute__c>     lstPsa  = new List<Provisioning_Service_Attribute__c>();                
            for (Service_Attribute__c serviceAttribute : serviceAttributes)
            {
                Provisioning_Service_Attribute__c psa = new Provisioning_Service_Attribute__c();
                psa.Name                              = serviceAttribute.Name;
                psa.Provisioning_Service__c           = mappingProvServ.get(serviceAttribute.Parent__c);
                psa.Service_Attribute__c              = serviceAttribute.Id;
                
                lstPsa.add(psa);
            }
            if (lstPsa.size() > 0)
                insert lstPsa;
        }
        catch (Exception e)
        {
            throw new Generic.StandardException('Cannot create provisioning service attributes: ' + e.getMessage());
        }
        //Sart HCL ***Copy Right Template from Offer Template****
        List<Rights_Template_Default__c> listOfRTDefault = new List<Rights_Template_Default__c>(); 
        List<Rights_Template__c> listOfRT = new List<Rights_Template__c>();                
        Map<Id, Rights_Template__c> mapRTDnRT = new Map<Id, Rights_Template__c>();
        
        List<Rights_Template_Default__c> lisstOFRTD = [
            Select 
                r.Status__c,r.Default__c, r.Private_Exchange_ID__c,
                r.PUG_Name__c, r.PIA_Interface__c, r.Offer_Template__c, r.Name, r.Id
            From Rights_Template_Default__c r
            WHERE r.Offer_Template__c = :prov.Offer_Template__c
        ];
        if(! lisstOFRTD.isEmpty())
        {
            for(Rights_Template_Default__c objRTD: lisstOFRTD)
            {
                Rights_Template__c objRT = new Rights_Template__c(); 
                objRT.Name                   = objRTD.Name;
                objRT.Provisioning__c        = prov.Id;
                objRT.Status__c              = objRTD.Status__c;
                objRT.Default__c             = objRTD.Default__c;
                objRT.Private_Exchange_ID__c = objRTD.Private_Exchange_ID__c;
                objRT.PUG_Name__c            = objRTD.PUG_Name__c;
                objRT.PIA_Interface__c       = objRTD.PIA_Interface__c;
                listOfRT.add(objRT);
                listOfRTDefault.add(objRTD);
                mapRTDnRT.put(objRTD.Id, objRT);
            }
        }
        if(! listOfRT.isEmpty())
        {
            try
            {
                System.debug('---------- TLR_SubscriptionExt: CreateOldProvisioning: listOfRT: ' + listOfRT);
                insert listOfRT;
            }
            catch (Exception e)
            {
                throw new Generic.StandardException('Cannot create Default Rights Template: ' + e.getMessage());
            }
        }
        // **********   
        List<Rights_Template_Service__c> listOfRTS = new List<Rights_Template_Service__c>(); 
        List<Rights_Template_Service_Default__c> listOfRTSDefault = new List<Rights_Template_Service_Default__c>(); 
        Map<Id, Rights_Template_Service__c> mapRTSDnRTS = new Map<Id, Rights_Template_Service__c>();
        if(! listOfRTDefault.isEmpty() && !listOfRT.isEmpty())
        {
            List<Rights_Template_Service_Default__c> lisstOFRTSD = [
                Select r.Service__c, r.Rights_Template__c, r.Name, r.Id
                From Rights_Template_Service_Default__c r
                WHERE r.Rights_Template__c IN :listOfRTDefault
            ];
            if(! lisstOFRTSD.isEmpty())
            {
                for(Rights_Template_Service_Default__c objRTSD : lisstOFRTSD)
                {
                    Rights_Template_Service__c objRTS = new Rights_Template_Service__c();
                    System.debug('---------- TLR_SubscriptionExt: CreateOldProvisioning: mapRTDnRT.get(objRTSD.Rights_Template__c): ' + mapRTDnRT.get(objRTSD.Rights_Template__c)); 
                    objRTS.Name = objRTSD.Name; 
                    objRTS.Rights_Template__c = mapRTDnRT.get(objRTSD.Rights_Template__c).Id;
                    objRTS.Service__c = objRTSD.Service__c;
                    listOfRTS.add(objRTS);
                    listOfRTSDefault.add(objRTSD);
                    mapRTSDnRTS.put(objRTSD.Id,objRTS);
                }
            }
            if(! listOfRTS.isEmpty())
            {
                try
                {
                    insert listOfRTS;
                }
                catch (Exception e)
                {
                    throw new Generic.StandardException('Cannot create Rights Template Services: ' + e.getMessage());
                }
            }
            // *********Rights Template Service Attributes insertion**********
            List<Rights_Template_Service_Attribute__c>  lstRTSA = new List<Rights_Template_Service_Attribute__c>();
            if(!listOfRTSDefault.isEmpty() && !listOfRTS.isEmpty())
            {
                List<Rights_Template_Service_Attribute_Def__c> lisstOFRTSAD = [
                    Select r.Service_Attribute__c, r.Rights_Template_Service__c, r.Name, r.Id
                    From Rights_Template_Service_Attribute_Def__c r
                    WHERE r.Rights_Template_Service__c IN :listOfRTSDefault
                ];
                if(! lisstOFRTSAD.isEmpty())
                {
                    for(Rights_Template_Service_Attribute_Def__c objRTSADeafult : lisstOFRTSAD)
                    {
                        Rights_Template_Service_Attribute__c objRTSA = new Rights_Template_Service_Attribute__c();
                        objRTSA.Name                              = objRTSADeafult.Name; 
                        objRTSA.Rights_Template_Service__c        = mapRTSDnRTS.get(objRTSADeafult.Rights_Template_Service__c).Id;
                        objRTSA.Service_Attribute__c              = objRTSADeafult.Service_Attribute__c;
                        lstRTSA.add(objRTSA);
                    }
                }
            }
            if(!lstRTSA.isEmpty())
            {
                try
                {
                    insert lstRTSA;
                }
                catch (Exception e)
                {
                    throw new Generic.StandardException('Cannot create Rights Template Service Attributes: ' + e.getMessage());
                }
            }
        } // if we have default rights templates
        //End HCL
        try
        {
            subs.Status__c = 'Provisioning initiated';
            update subs;
        }
        catch (DmlException e)
        {
            throw new Generic.StandardException('Insufficient privileges.');
        }
        catch (Exception e)
        {
            throw new Generic.StandardException('Cannot update subscription: ' + e.getMessage());
        }
        return prov;
    } //CreateOldProvisioning
    
    //------------------------------------------------------------------------------------------------------
    // CancelSubscription page methods
    //------------------------------------------------------------------------------------------------------
    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2015 March 30
    * @description  performs page initialization, error checks
    **/
    public PageReference InitCancelSubscription()
    {
    	error = false;
        
        // for new provisioning we don't have to do anything actually
        if(this.subscription.Offer_Template__r.Use_new_Provisioning__c)
        {
        	subscription.End_Date__c = Date.Today();
        	return null;
        }
        
        // but for old one - we need to be sure user
        List<Provisioning__c> prov = [SELECT Id FROM Provisioning__c WHERE Subscription__c = :subscription.Id];
        
        if (prov.size() == 0)
        {
            error = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient Privileges! (cannot access old provisioning)'));
            return null;
        }
        
        subscription.End_Date__c = Date.Today();
        return null;
    } //InitCancelSubscription
    
    public PageReference CancelSubscription()
    {
    	error = false; // just in case
    	try
    	{
    		TLR_SubscriptionHelper.CancelSubscription(subscription);
    		return RedirectToSubscription();
    	}
    	catch(Exception ex)
    	{
    		error = true;
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Error: ' + ex.getMessage()));
    	}
    	return null;
    } //CancelSubscription
}