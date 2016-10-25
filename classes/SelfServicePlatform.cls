global public with sharing class SelfServicePlatform {

    public SelfServicePlatform(){}
    
    public enum TypeAbo{
        Free_basic,
        Flash_volume,
        Flash_subscription
    }
    
    /* =============================================================================================
    // Input object definition
    ============================================================================================= */
    global public class CreateUserInput
    {   
        webservice public String AccountName;
        webservice public String AddressNumber;
        webservice public String AddressLine1;
        webservice public String AddressLine2;
        webservice public String AddressLine3;
        /*public String Street{
            get{return AddressNumber+'\n'+AddressLine1+'\n'+AddressLine2+'\n'+AddressLine3;}
        }*/
        
        public String Street{
            get{return AddressLine1;}
        }
        webservice public String Zipcode;
        webservice public String City;
        webservice public String Country;
        webservice public String VAT;
        webservice public String Siret;
        webservice public Date CompanyCreationDate;
        webservice public String TransportLicense;        
        public Id accountId;
        //Contact informations  
        webservice public String LastName;
        webservice public String FirstName;
        webservice public String Gender;
        webservice public String PreferredLanguage;
        webservice public String Mobile;
        webservice public String Phone;
        webservice public String Fax;
        webservice public String Email;
        public Id contactId;
        //Contract informations
        webservice public String Term;
        webservice public String PaymentMode;//(CC / PP / DD / IPLUS)
        webservice public String BankName;
        webservice public String IBAN;
        webservice public String BIC_Code;
        webservice public String BankAddress;
        webservice public String BankPostCode;
        webservice public String BankCity;
        webservice public String BankCountry;
        webservice public String DKV_CardNumber;
        webservice public String DKV_Validity;        
        webservice public String SipsId;        
        webservice public String CC_Number;
        webservice public String CC_Type;
        webservice public String CC_Holder;        
        webservice public Date CC_ExpirationDate;
        webservice public Boolean NoCommercial;        
        webservice public Date TransactionDate;
        webservice public String TransactionId;
        
        //Subscription informations
        webservice public Decimal Amount;
        webservice public Integer Credits;     
        webservice public String CurrencyUsed;
        //Opportunity informations
        public Id opportunityId;

        //Offer template
        webservice public String Appli;
        webservice public String TypeAbo;
        webservice public String Trial;
        webservice public String Frequency;
        webservice public String OfferTemplate; 
        
        //User Profile informations
        webservice public String ServicesLinksTemplate;
        webservice public Boolean TLR_Express;
        webservice public String AW_SessionId;
        webservice public String TLR_InternalFlag;
        webservice public String AW_UserTestFlag;
        
        //Lead Information
        webservice public String ProspectId;
    }

    global public class SwitchPaymentModeInput
    {
        webservice public String Login;
        webservice public String Term;
        webservice public String PaymentMode;//(CC / PP / DD / IPLUS)
        webservice public String IBAN;
        webservice public String BankName;
        webservice public String BIC_Code;
        webservice public String BankAddress;
        webservice public String BankPostCode;
        webservice public String BankCity;
        webservice public String BankCountry;
        webservice public String DKV_CardNumber;
        webservice public String DKV_Validity;
        //webservice public String SipsId; //Doublon de Transaction Id
        webservice public String CC_Number;
        webservice public String CC_Type;
        webservice public String CC_Holder;
        webservice public Date CC_ExpirationDate; //(mm/dd/yyyy)        
        webservice public Date TransactionDate;
        webservice public String TransactionId;
        webservice public Boolean FlagPaymentModeChangedOnly=false;
        webservice public Decimal TransactionAmount;
        webservice public Integer Credits;
        //webservice public String SipsId;
    }
    
    global public class CanSubscribeInput
    {   
        webservice public String Siret;
        webservice public String VAT;
        webservice public Boolean NoCommercial;     
    }
    
    global public class UpdateProfileInput
    {
        webservice public String Login;
        webservice public String Appli;
        webservice public String FirstName;
        webservice public String LastName;
        webservice public String Phone;
        webservice public String Fax;
        webservice public String Mobile;
        webservice public String Language;
        webservice public String Email;
        //webservice public String RegFlag02;
    }
    
    global public class GetCompanyVATInfosInput
    {
        webservice public String Login;

    }
    
    global public class MigrateFlashInput
    {
        webservice public String Login;
        webservice public Decimal Amount;
        webservice public String Frequency;
        webservice public String Trial;
        webservice public String PaymentMode;
        webservice public String SipsId;
        webservice public String CC_Number;
        webservice public Date CC_ExpirationDate;
        webservice public String DKV_CardNumber;
        webservice public String DKV_Validity; 
        webservice public TypeAbo FlashSubscription;
    }
    
    global public class MigrateFrequencyInput
    {
        webservice public String Login;
        webservice public Decimal Amount;
        webservice public String Frequency;
    }
    
    global public class CreatePaymentInput
    {
        webservice public String Login;
        webservice public Decimal Amount;
        webservice public String PaymentMode;
        webservice public String SipsId;
        webservice public String CurrencyUsed;
        webservice public String Credits;
        webservice public String DKV_CardNumber;
        webservice public String DKV_Validity;        
        webservice public String CC_Number;
        webservice public String CC_Type;
        webservice public String CC_Holder;        
        webservice public Date CC_ExpirationDate;
    }
    /* =============================================================================================
    // Output object definition    
    ============================================================================================= */
    global public class CreateUserOutput
    {
        webservice public String Error = '';
        webservice public Integer ReturnCode = 0;
        webservice public  String Login = '';
    }
    
    global public class CreateLeadOutput
    {
        webservice public String Error = '';
        webservice public Integer ReturnCode = 0;
        webservice public  String ProspectId = '';
        webservice public  String CampaignId = '';
    }
    
    global public class GetLeadOutput
    {
        webservice public String Error = '';
        webservice public Integer ReturnCode = 0;
       //Ids        
        webservice public   String AW_SessionId;
        webservice public   Boolean TLR_ExpressFlag = false;
        webservice public   String TLR_InternalFlag = 'N';
        webservice public   String AW_UserTestFlag = 'N';
        webservice public   String RegCounter;
        webservice public   Double AW_MaxStep = 0;
        
        //Company Informations
        webservice public   String AccountName;
        webservice public   String VAT;
        webservice public   String Siret;
        webservice public   Date CompanyCreationDate;
        webservice public   String TransportLicense;
        webservice public   Boolean NoCommercial;
        
        //Coordonates
        webservice public   String AddressNumber;
        webservice public   String AddressLine1;
        webservice public   String AddressLine2;
        webservice public   String AddressLine3;
        public String Street{
            get{return AddressNumber+AddressLine1+AddressLine2+AddressLine3;}
        }
        webservice public   String Zipcode;
        webservice public   String City;
        webservice public   String Country;

        //Contact Informations
        webservice public String LastName;
        webservice public String FirstName;
        webservice public String Gender;
        webservice public String PreferredLanguage;
        webservice public String Mobile;
        webservice public String Phone;
        webservice public String Fax;
        webservice public String Email;       
        
        //Contract Informations
        webservice public String TypeAbo;
        webservice public String Frequency;        
    }
    
    global public class CanSubscribeOutput
    {
        webservice public String Error = '';
        webservice public Integer ReturnCode = 0;
        webservice public Boolean Result = false;       
    } 
    
    global public class GetProductOutput
    {
        webservice public String Error = '';
        webservice public Integer ReturnCode = 0;
        webservice public String Frequency = '';
        webservice public Date EndDate;
        webservice public String PriceList = '';
        webservice public String FreeTrial = '';
    } 
    
    global public class GetCompanyVATInfosOutput
    {
        webservice public String Error = '';
        webservice public Integer ReturnCode = 0;
        webservice public  String VAT = '';
        webservice public  String Siret;
        webservice public  String CompanyName = '';
        webservice public  Boolean NoCommercial = false;
    } 
    
    global public class ReadFlashTransportCompanyOutput
    {
        webservice public String Error = '';
        webservice public Integer ReturnCode = 0;
        webservice public  String PaymentMethod = '';
        webservice public  String CcNumber = '';
        webservice public  Date CcExpirationDate;
        webservice public  String PriceList = '';
        webservice public  String TransactionDate = '';
        webservice public  Date EntitlementStartDate;
        webservice public  String SubscriptionFrequency = '';
        webservice public  Date NextSubscriptionPayDate;
        webservice public  Date EntitlementEndDate;
    } 
    
    /* =============================================================================================
    // Internals methods    
    ============================================================================================= */
    private static void createAccount(CreateUserInput input)
    {
        Id accountId = null;
        try{
            Account newAccount = new Account();
           
            newAccount.Name = input.AccountName;
            newAccount.Company_Name__c = input.AccountName;
            newAccount.ShippingStreet = input.Street;
            newAccount.BillingStreet = newAccount.ShippingStreet;
            newAccount.ShippingPostalCode = input.Zipcode;
            newAccount.BillingPostalCode = newAccount.ShippingPostalCode;
            newAccount.ShippingCity = input.City;
            newAccount.BillingCity = newAccount.ShippingCity;
            newAccount.ShippingCountry = input.Country;
            newAccount.BillingCountry = newAccount.ShippingCountry;
            newAccount.Company_Creation_Date__c = input.CompanyCreationDate;
            //newAccount.Company_Registration_Number__c = input.TransportLicense;
            if(Generic.StringNotEmpty(input.VAT))
            {
                newAccount.VAT__c = input.VAT.replace(' ','');
            }
            newAccount.SIRET__c = input.Siret;
            newAccount.Company_Registration_Number__c = input.Siret;            
            
            newAccount.BIC_Code__c = input.BIC_Code;
            if(Generic.StringNotEmpty(input.IBAN) && (input.IBAN.length()==27))
            {
                newAccount.Iban_Number__c = input.IBAN;            
                newAccount.Bank_Number__c = input.IBAN.substring(14,25);
                newAccount.Cashier_Code_FR__c = input.IBAN.substring(9,14);
                newAccount.Bank_Code_FR__c = input.IBAN.substring(4,9);
                newAccount.RIB_Key_FR__c = input.IBAN.substring(25,27);
            }
            
            newAccount.Bank_Name__c = input.BankName;
            newAccount.Bank_Street_Address__c = input.BankAddress;
            newAccount.Bank_Postal_Code__c = input.BankPostCode;
            newAccount.Bank_City__c = input.BankCity;
            newAccount.Bank_Country__c = input.BankCountry;            
            newAccount.Type = (input.TLR_InternalFlag == 'Y')?'TLR internal':'Customer';
            insert newAccount;
            input.accountId = newAccount.Id;
        }catch(Exception ex){
            Generic.StandardException stex=new Generic.StandardException();
            stex.ReturnCode=2;
            stex.setMessage('Error in Account creation : '+ex.getMessage());
            stex.Error='Error in Account creation : '+ex.getMessage();
            throw stex;   
        }   
    }
    
    private static void createContact(CreateUserInput input,Id accountId)
    {
        try{
            Contact newContact = new Contact();
            newContact.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('TLR Contact').getRecordTypeId();
            newContact.AccountId = accountId;
            newContact.LastName = input.LastName;
            newContact.FirstName = input.FirstName;
            
            if(Generic.StringNotEmpty(input.Gender)){
            newContact.Gender__c = input.Gender;	
            } else {
            newContact.Gender__c = 'Male';	
            }
            newContact.Language__c = Language_Code__c.getValues(input.PreferredLanguage).Label__c;
            newContact.MobilePhone = input.Mobile;
            newContact.Phone = input.Phone;
            newContact.Fax = input.Fax;
            newContact.Email = input.Email;
            newContact.MailingStreet = input.Street;
            newContact.MailingPostalCode = input.Zipcode;
            newContact.MailingCity = input.City;
            newContact.MailingCountry = input.Country;
            insert newContact;
            input.contactId = newContact.Id;
        }catch(Exception ex){
            Generic.StandardException stex=new Generic.StandardException();
            stex.ReturnCode=3;
            stex.setMessage('Error in Contact creation : '+ex.getMessage());
            stex.Error='Error in Contact creation : '+ex.getMessage();
            throw stex;    
        }       
    }
    
    private static void createOpportunity(CreateUserInput input,Id accountId)
    {
        try{
            Opportunity newOpportunity = new Opportunity();
            newOpportunity.AccountId = accountId;           
            newOpportunity.Name = input.OfferTemplate + ' - '+ input.AccountName;
            newOpportunity.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('TLR Opportunity').getRecordTypeId();
            newOpportunity.StageName = 'Closed Won';
            newOpportunity.Reason_Won__c = 'Create by Self Service Platform';
            newOpportunity.CloseDate = Date.today();
            insert newOpportunity;     
            input.opportunityId = newOpportunity.Id;
        }catch(Exception ex){
            Generic.StandardException stex=new Generic.StandardException();
            stex.ReturnCode=4;
            stex.setMessage('Error in Opportunity creation : '+ex.getMessage());
            stex.Error='Error in Opportunity creation : '+ex.getMessage();
            throw stex; 
        }       
    }
    
    private static void updateAndConvertLead(CreateUserInput input)
    {
        try{
            Lead lead = [select Id,Name,Company,Street,PostalCode,City,Country,LastName,FirstName,Gender__c,Language__c,MobilePhone,Phone,Fax,Email from lead where Id =:input.ProspectId limit 1];
            //Account
            lead.Company = input.AccountName;
            lead.Street = input.Street;
            lead.PostalCode = input.Zipcode;
            lead.City = input.City;
            lead.Country = input.Country;
            lead.Company_Creation_Date__c = input.CompanyCreationDate;
            
            lead.VAT__c = input.VAT;
            lead.SIRET__c = input.Siret;
            
            //Contact
            lead.LastName = input.LastName;
            lead.FirstName = input.FirstName;
            lead.Gender__c = input.Gender;
            lead.Language__c = Language_Code__c.getValues(input.PreferredLanguage).Label__c;
            lead.MobilePhone = input.Mobile;
            lead.Phone = input.Phone;
            lead.Fax = input.Fax;
            lead.Email = input.Email;   
            update lead;
            
            //Convert the lead
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(lead.Id);
            lc.setOwnerId(lead.OwnerId);
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            
            input.accountId = lcr.getAccountId();
            input.contactId = lcr.getContactId();
            input.opportunityId = lcr.getOpportunityId();
        }
        catch(Exception e)
        {
            Generic.StandardException ex=new Generic.StandardException();
            ex.ReturnCode=13;
            ex.setMessage('Error in Lead Conversion (updateAndConvertLead) : '+e.getMessage());
            ex.Error='Error in Lead Conversion (updateAndConvertLead) : '+e.getMessage();
            throw ex;   
        }   
    }
    
    private static String getMatchingAccessRoleForTypeAbo(TypeAbo abo)
    {
        if(abo==TypeAbo.Free_basic)
            return 'FlashFree'; 
        if(abo==TypeAbo.Flash_volume)
            return 'FlashAct'; 
        if(abo==TypeAbo.Flash_subscription)
            return 'FlashSubscription'; 
            
        return '';
    }
    
    private static String getMatchingServiceNameForFrequency(String frequency)
    {
        if(frequency == '1 Month')
            return 'Flash Subscription Monthly'; 
        if(frequency == '12 Months')
            return 'Flash Subscription Yearly'; 
            
        return '';
    }

    
    private static void createPaymentActivity(String contractId,String transactionId,Date transactionDate,Integer credits,Decimal amount,String paymentMode,Generic.ApplicationCode appliCode,Id contactId)
    {                               
        
        System.debug('Contract ID'+contractId);
        System.debug('Transaction Id'+transactionId);
        System.debug('Trans'+transactionDate);
        System.debug('Transaction Id'+transactionId);
        System.debug('Transaction Id'+transactionId);
        System.debug('Transaction Id'+transactionId);
        System.debug('Transaction Id'+transactionId);
        
        
        FinancialTransaction__c fTransaction = new FinancialTransaction__c();
        
        try
        {           
            if(appliCode!=Generic.ApplicationCode.UNKNOWN)
            {
                Subscription__c subsc=[select Id from Subscription__c where Contract__c=:contractId limit 1];
                fTransaction.Subscription__c=subsc.Id;
            }
            if(Generic.StringNotEmpty(contractId))
                fTransaction.Contract__c = contractId;
            fTransaction.Contact__c = contactId;
            fTransaction.TransactionId__c = transactionId;
            fTransaction.TransactionDate__c = transactionDate;
            if(credits!=0)
                fTransaction.Credits__c = credits;
            fTransaction.TransactionAmount__c = amount;
            fTransaction.PaymentMode__c = paymentMode;    
            insert fTransaction;        
        }
        catch(Exception e)
        {
            Generic.StandardException ex=new Generic.StandardException();
            ex.ReturnCode=12;
            ex.setMessage('Error, createPaymentActivity : '+e.getMessage());
            ex.Error='Error, createPaymentActivity : '+e.getMessage();
            throw ex;   
        }   
        
    }
    /* =============================================================================================
    // Webservices methods    
    ============================================================================================= */
    //Used in TGO and Flash SSP
    webservice static CreateUserOutput CreateUser(CreateUserInput input)
    {
        CreateUserOutput output = new CreateUserOutput();
        Savepoint sp = Database.setSavepoint();
        system.debug('## >>> CreateUser : Input : '+input);
        try{
            //If we receive a ProspectId, it is because a lead have already been created. In this case we update and convert this lead.             
            if(input.ProspectId !=null && input.ProspectId != ''){
                //update and convert the Lead
                updateAndConvertLead(input);
            }else{
                //create Account
                createAccount(input);
                //create Contact
                createContact(input,input.accountId);   
                //create Opportunity
                createOpportunity(input,input.accountId);
            }
            output.Login=input.contactId;
            System.debug('Contact Id'+input.contactId);
            
            try{
                ChooseOfferTemplateExt cotExt = new ChooseOfferTemplateExt(input.opportunityId);
                System.debug('######## input.OfferTemplate = ' + input.OfferTemplate);
                Configuration_Parameter__c cp = [SELECT Value__c FROM Configuration_Parameter__c WHERE Key__c =:input.OfferTemplate];
                cotExt.selectedOT = cp.Value__c;
                cotExt.Save();
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=5;
                stex.setMessage('Error in Configuration_Parameter__c search for : '+input.Appli+' '+ex.getMessage());
                stex.Error='Error in Configuration_Parameter__c search for : '+input.Appli+' '+ex.getMessage();
                throw stex;   
            }   
            Id contractId;
            Id subscriptionId;
            try{
                //CreateContractExt ccExt = new CreateContractExt(input.opportunityId);
                contractId = TLR_ContractHelper.CreateNewContract(input.opportunityId);
                subscriptionId = (new TLR_SubscriptionHelper()).CreateNewSubscription(contractId, input.opportunityId);
                
                Subscription__c sub = [select Start_Date__c from Subscription__c where Id=:subscriptionId]; 
                sub.Start_Date__c = Date.today();
                update sub;
                
                Contract newContract = [select StartDate,Payment_Method__c,Payment_Term__c,Credit_Card_Name__c,Credit_Card_Holder__c,Credit_Card_Expiration_Date__c,Credit_Card_Number__c from Contract where Id =:contractId];
                newContract.StartDate = Date.today();
                newContract.Payment_Method__c = input.PaymentMode;
                newContract.Payment_Term__c = input.Term;
                newContract.Credit_Card_Name__c = input.CC_Type;
                newContract.Credit_Card_Holder__c = input.CC_Holder;
                newContract.Credit_Card_Expiration_Date__c = input.CC_ExpirationDate;
                newContract.Credit_Card_Number__c = input.CC_Number;
                newContract.Status__c='Active';
                update newContract;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=6;
                stex.setMessage('Error in Contract creation : '+ex.getMessage());
                stex.Error='Error in Contract creation : '+ex.getMessage();
                throw stex;   
            }   
            CreateProvisioningExt cpe;
            try{                
                cpe = new CreateProvisioningExt(subscriptionId);                
                cpe.init();
                //cpe.initExternal('TGO Provisioning object for '+input.AccountName,Date.today());
                //cpe.Save();   
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=7;
                stex.setMessage('Error in Provisioning creation : '+ex.getMessage());
                stex.Error='Error in Provisioning creation : '+ex.getMessage();
                throw stex;   
            }  
            
            provisioningUserMgt pum;
            try{
                Provisioning__c prov = [select RecordTypeId from Provisioning__c where Id=:cpe.getProv().Id];
                prov.RecordTypeId = Schema.getGlobalDescribe().get('Provisioning__c').getDescribe().getRecordTypeInfosByName().get('TLR Provisioning TGO').getRecordTypeId();
                update prov;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=10;
                stex.setMessage('Error updating provisioning : '+ex.getMessage());
                stex.Error='Error updating provisioning : '+ex.getMessage();
                throw stex;   
            }
            
            Id upId;
            try{
                pum = new provisioningUserMgt(cpe.getProv().Id);
                upId = pum.CreateUserProfile(input.contactId);
                if(input.AW_UserTestFlag == 'Y')
                {
                    User_Profile__c up = [select User_Profile__c.Test_login__c from User_Profile__c where Id=:upId];
                    up.Test_login__c = true;
                    update up;
                }
                if(input.Appli == 'FTFR')
                {
                    System.debug('input FTFR:'+ input);
                    pum.AddFlashRights(upId,input.TypeAbo,input.Frequency);
                    
                    if (input.TypeAbo =='Flash_subscription' && input.Frequency =='12 Months'){
                    	
                    /*Retrieve the User Profile Service "Flash Subscription Yearly"  created before and  update the suspension start date
                    */	
                    Generic.packageInput packageInputToCreate=new Generic.packageInput(input.contactId, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_subscription), Generic.ApplicationCode.FTFR.name(), Generic.Action.Search);
                    User_Profile_Service__c ups = Generic.getUserProfileServiceForFlash(packageInputToCreate,getMatchingServiceNameForFrequency(input.Frequency)); 
                        //We update the suspension start date
                        Date suspensionDate = Date.today();
                        Date trialEndDate = Date.today();
                        if(input.Trial == 'Y')
                        {
                            //We add one month to current date
                            suspensionDate = suspensionDate.addMonths(1);
                            trialEndDate = date.newinstance(suspensionDate.year(), suspensionDate.month(), Date.daysInMonth(suspensionDate.year(), suspensionDate.month()));
                        }
                        suspensionDate = date.newinstance(suspensionDate.addYears(1).year(), suspensionDate.month(), Date.daysInMonth(suspensionDate.addYears(1).year(), suspensionDate.month())); 
                        ups.Suspension_Start_Date__c = suspensionDate;
                        ups.Suspension_End_Date__c = null;
                    
                        update ups;
                        
                        /*
                        Create New Fee
                        */
                        Generic.FeeInput SubsFee = New Generic.FeeInput(input.contactId, Generic.ApplicationCode.FTFR.name(), 'Flash Subscription Yearly', 'Flash Subscription Yearly', null, Date.today(), suspensionDate);
                        Generic.createNewFee(SubsFee);
                        
                        /*
                        Create Payment Activity
                        */
                        if (input.PaymentMode != null && input.PaymentMode !='')
            			createPaymentActivity(contractId,/*input.TransactionId*/input.SipsId,/*input.TransactionDate*/Date.today(),input.Credits,0,input.PaymentMode,Generic.ApplicationCode.FTFR,input.contactId);
            			System.Debug ('Payment activity created'); 
                           	
                    } else if (input.TypeAbo =='Flash_subscription' && input.Frequency =='1 Month') {
                    
                    Decimal CalculatedProrataAmount = Generic.getProratAmount(input.Amount);
                    System.Debug('Calculate Amount'+CalculatedProrataAmount);
                    Date sEndDate = Date.today().addMonths(1);
                    Date OneOffEndDate = Date.newInstance(sEndDate.year(), sEndDate.month(), date.daysInMonth(sEndDate.year() , sEndDate.month())); 
                    
                    /*Create OneOff Fee
                    */
                    Generic.FeeInput OneOffFee = New Generic.FeeInput(input.contactId, Generic.ApplicationCode.FTFR.name(), 'Flash Subscription Monthly', 'Flash Subscription Monthly', CalculatedProrataAmount, Date.today(), OneOffEndDate);
                    System.Debug ('Fee input OneOffFee'+OneOffFee);
                    Generic.createNewFee(OneOffFee);
                    
                     /*Create Recurrent Fee
                    */
                    Date StartDate = Date.Today().addMonths(2);
                    Date RecurrenbtStartDay = StartDate.toStartOfMonth();
                    System.Debug('Start Date'+RecurrenbtStartDay);
                    Date RecurrentStartDate = date.newInstance(RecurrenbtStartDay.year(), RecurrenbtStartDay.month(), RecurrenbtStartDay.day());
                    Generic.FeeInput ReccurentFee = New Generic.FeeInput(input.contactId, Generic.ApplicationCode.FTFR.name(), 'Flash Subscription Monthly', 'Flash Subscription Monthly', null,RecurrentStartDate , null);
                    System.Debug ('Fee input OneOffFee'+ReccurentFee);
                    Generic.createNewFee(ReccurentFee);
                    
                    /*
                    Create Payment Activity
                    */
                    if (input.PaymentMode != null && input.PaymentMode !='')
            		createPaymentActivity(contractId,/*input.TransactionId*/input.SipsId,/*input.TransactionDate*/Date.today(),input.Credits,CalculatedProrataAmount,input.PaymentMode,Generic.ApplicationCode.FTFR,input.contactId);
            		System.Debug ('Payment activity created'); 
                      
                    }
                }
                else
                {
                    pum.AddProductRights(upId);
                }                                       
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=8;
                stex.setMessage('Error in User Profile creation : '+ex.getMessage());
                stex.Error='Error in User Profile creation : '+ex.getMessage();
                throw stex;   
            }
            
            
            //For Flash-Transport the user profile is directly provisioned
            if(input.Appli == 'FTFR')
            {
                List<Id> userProfileIds = new List<Id>();
                userProfileIds.add(upId);                   
                ProvisioningMessagesAsync.SendInitialProvisioningRequests(userProfileIds);
                
                  
            }
            else
            {
                try{
                    // create the new approval request to submit
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Submitted for approval. Please approve.');
                    //req.setObjectId(upId);
                    req.setObjectId(cpe.getProv().Id);
                    // submit the approval request for processing
                    Approval.ProcessResult result = Approval.process(req);
                    // display if the reqeust was successful
                    System.debug('Submitted for approval successfully: '+result.isSuccess());
                }catch(Exception ex){
                    Generic.StandardException stex=new Generic.StandardException();
                    stex.ReturnCode=9;
                    stex.setMessage('Error in submition for approval : '+ex.getMessage());
                    stex.Error='Error in submition for approval : '+ex.getMessage();
                    throw stex;   
                }
            }
            /* Create payment activity 
            */

            if (input.PaymentMode != null && input.PaymentMode !='' && input.TypeAbo == 'Flash_volume')
            createPaymentActivity(contractId,/*input.TransactionId*/input.SipsId,/*input.TransactionDate*/Date.today(),input.Credits,input.Amount,input.PaymentMode,Generic.ApplicationCode.FTFR,input.contactId);
            System.Debug ('Payment activity created'); 
            
        }
        catch(Generic.StandardException sex)
        {
            output.returnCode = sex.ReturnCode;
            output.error = sex.Error;
            System.debug('## Return Code '+output.error+' : '+output.returnCode);
            Database.rollback(sp);
        }
        catch(Exception ex)
        {
            output.returnCode = 1;
            output.error = ex.getMessage();
            Database.rollback(sp);
        }
        system.debug('## >>> CreateUser : Output : '+output);
        return output;
    }
    
    //Used in TGO and Flash SSP
    webservice static CreateLeadOutput CreateLead(Lead lead,String prospectId)
    {
        CreateLeadOutput clOutput = new CreateLeadOutput();
        Lead newLead;  
        try{
            if(prospectId !=null && prospectId != ''){
                newLead = [select Id,Name,Company,Street,PostalCode,City,Country,LastName,FirstName,Gender__c,Language__c,MobilePhone,Phone,Fax,Email from lead where id = : prospectId];
            }else{
                newLead = new Lead();   
            }
             
            newLead.Express_Flag__c = lead.Express_Flag__c;
            newLead.Session_Id__c = lead.Session_Id__c;
            newLead.Max_Step_Registration__c = lead.Max_Step_Registration__c;
            newLead.Abo_Frequency__c = lead.Abo_Frequency__c;
            newLead.Type_Abo__c = lead.Type_Abo__c;
            newLead.LeadSource = lead.LeadSource;
            newLead.No_Commercial__c = lead.No_Commercial__c; 

            newLead.RecordTypeId=Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('TLR Lead').getRecordTypeId();
            
            //Company Informations
            if(Generic.StringNotEmpty(lead.Company))
            {
                newLead.Company = lead.Company;
            }
            else
            {
                //newLead.Company = lead.LastName +' '+ lead.FirstName;
                newLead.Company = 'None';
            }
            newLead.Company_Creation_Date__c = lead.Company_Creation_Date__c;
            if(Generic.StringNotEmpty(lead.VAT__c))
            {
                newLead.VAT__c = lead.VAT__c.replace(' ','');
            }
            newLead.Siret__c = lead.Siret__c;
            if(Generic.StringNotEmpty(lead.Siret__c))
            {
                newLead.Company_Reg__c = lead.Siret__c;
            }           
            newLead.Transport_Licence__c = lead.Transport_Licence__c;
            
            //Coordonates
            newLead.Street = lead.Street;
            newLead.PostalCode = lead.PostalCode;
            newLead.City = lead.City;
            newLead.Country = lead.Country;         
    
            //Contact Informations
            newLead.LastName = lead.LastName;
            newLead.FirstName = lead.FirstName;
            newLead.Gender__c = lead.Gender__c;
            try
            {
                newLead.Language__c = Language_Code__c.getValues(lead.Language__c).Label__c;
            }catch(Exception e){
                newLead.Language__c = 'English';
            }
            newLead.MobilePhone = lead.MobilePhone;
            newLead.Phone = lead.Phone;
            newLead.Fax = lead.Fax;
            newLead.Email = lead.Email;   

            System.debug('>>> Created Lead : ' + newLead);
            upsert newLead;
            clOutput.prospectId = newLead.Id;
            System.debug('## Return Code 0 ');
        }catch(Exception ex){
            clOutput.ReturnCode = 1;
            clOutput.Error = ex.getMessage();
            System.debug('## Return Code 1 : '+ex.getMessage());
        }
        return clOutput;
    }

    //Used in TGO and Flash SSP
    webservice static GetLeadOutput GetLead(String prospectId)
    {
        GetLeadOutput output = new GetLeadOutput();
        try{
            //Lead lead = [select Id,Name,Company,Street,PostalCode,City,Country,LastName,FirstName,Gender__c,Language__c,MobilePhone,Phone,Fax,Email from lead where id =:prospectId];
            Lead lead = [select Id,Test_User_Flag__c,Teleroute_Internal_Flag__c,No_Commercial__c,Type_Abo__c,Abo_Frequency__c,Express_Flag__c,Session_Id__c,Max_Step_Registration__c,Company,VAT__c,Siret__c,Company_Creation_Date__c,Transport_Licence__c,Street,PostalCode,City,Country,LastName,FirstName,Gender__c,Language__c,MobilePhone,Phone,Fax,Email from lead where id =:prospectId];    
            output.TLR_ExpressFlag = lead.Express_Flag__c;
            output.AW_SessionId = lead.Session_Id__c;
            output.AW_MaxStep = lead.Max_Step_Registration__c;
            output.TypeAbo = lead.Type_Abo__c;
            output.Frequency = lead.Abo_Frequency__c;
            output.NoCommercial = lead.No_Commercial__c;
            output.AW_UserTestFlag = (lead.Test_User_Flag__c)?'Y':'N';
            output.TLR_InternalFlag = (lead.Teleroute_Internal_Flag__c)?'Y':'N';
            
            //Company Informations
            /*if(lead.Max_Step_Registration__c>1)
                output.AccountName = lead.Company;
            */
            
            if(lead.Company =='None') {
                output.AccountName ='';
            } else {
                output.AccountName = lead.Company;
            } 
            output.VAT = lead.VAT__c;
            output.Siret = lead.Siret__c;
            output.CompanyCreationDate = lead.Company_Creation_Date__c;
            output.TransportLicense = lead.Transport_Licence__c;

            //Coordinates
            List<String> streetLines = new List<String>();
            if(Generic.StringNotEmpty(lead.Street))
            {
                streetLines = lead.Street.split('\n');
                System.debug('## street line size : '+streetLines.size());
                output.AddressLine1 = streetLines[0];
                if(streetLines.size()>1)
                    output.AddressLine2 = streetLines[1];
                if(streetLines.size()>2)
                    output.AddressLine3 = streetLines[2];   
                if(streetLines.size()>3)
                    output.AddressLine3 = output.AddressLine3+' '+streetLines[3];    
            }
            output.Zipcode = lead.PostalCode;
            output.City = lead.City;
            output.Country = lead.Country;
    
            //Contact Informations
            output.LastName = lead.LastName;
            output.FirstName = lead.FirstName;
            output.Gender = lead.Gender__c;
            List<Language_Code__c> cfgLanguageList=[select Name from Language_Code__c where Label__c=:lead.Language__c limit 1];
            output.PreferredLanguage =(cfgLanguageList.size()>0)? cfgLanguageList[0].Name:'EN';
            output.Mobile = lead.MobilePhone;
            output.Phone = lead.Phone;
            output.Fax = lead.Fax;
            output.Email = lead.Email; 
        }
        catch(Exception ex)
        {
            output.ReturnCode = 1;
            output.Error = ex.getMessage();
            System.debug('## Return Code 1 : '+output.Error);
        }
        return output;
    }    
    
    webservice static Generic.StandardOutput SwitchPaymentMode(SwitchPaymentModeInput input){
        Generic.StandardOutput spmOutput = new Generic.StandardOutput();
        Generic.StandardException sex=new Generic.StandardException();
        Savepoint sp = Database.setSavepoint();
        //User_Profile__c up;
        Contact contact;
        Account account;
        Contract contract;
        try{
            
            try
            {
                contact = [select Id,AccountId from contact where Username__c=:input.Login];
            }catch(Exception ex){
                    sex.Error='Contact not found : '+ex.getMessage();
                    sex.ReturnCode=1;
                    throw sex;
            }
            
            try
            {
                account = [select Id from account where id = : contact.AccountId];
            }catch(Exception ex){
                    sex.Error='Account not found : '+ex.getMessage();
                    sex.ReturnCode=2;
                    throw sex;
            }
            if(Generic.StringNotEmpty(input.BIC_Code))
                account.BIC_Code__c = input.BIC_Code;
            if(Generic.StringNotEmpty(input.IBAN))  
            {
                account.Iban_Number__c = input.IBAN;
                account.Bank_Number__c = input.IBAN.substring(14,25);
                account.Cashier_Code_FR__c = input.IBAN.substring(9,14);
                account.Bank_Code_FR__c = input.IBAN.substring(4,9);
                account.RIB_Key_FR__c = input.IBAN.substring(25,27);
            }
            if(Generic.StringNotEmpty(input.BankName))  
                account.Bank_Name__c = input.BankName;   
            if(Generic.StringNotEmpty(input.BankAddress))       
                account.Bank_Street_Address__c = input.BankAddress;
            if(Generic.StringNotEmpty(input.BankPostCode))              
                account.Bank_Postal_Code__c = input.BankPostCode;
            if(Generic.StringNotEmpty(input.BankCity))              
                account.Bank_City__c = input.BankCity;
            if(Generic.StringNotEmpty(input.BankCountry))               
                account.Bank_Country__c = input.BankCountry;
                
            if(Generic.StringNotEmpty(input.DKV_CardNumber))    
                account.DKV_Card_Number__c = input.DKV_CardNumber;
            if(Generic.StringNotEmpty(input.DKV_Validity))              
                account.DKV_Validity__c = input.DKV_Validity;
            update account; 
            
            try
            {
                contract = [select Id,Payment_Method__c,Payment_Term__c,Credit_Card_Name__c,Credit_Card_Holder__c,Credit_Card_Expiration_Date__c,Credit_Card_Number__c, SIPS_ID__c from contract where AccountId = : contact.AccountId /* and offer_template.name=:'TGO' where subscription.offerTemplateId=offer_template.Id*/ limit 1];
            }catch(Exception ex){
                    sex.Error='Contract not found : '+ex.getMessage();
                    sex.ReturnCode=3;
                    throw sex;
            }       

            if(Generic.StringNotEmpty(input.CC_Number))
            {               
                contract.Payment_Method__c = input.PaymentMode;
                contract.Payment_Term__c = input.Term;
                contract.Credit_Card_Name__c = input.CC_Type;
                contract.Credit_Card_Holder__c = input.CC_Holder;
                contract.Credit_Card_Expiration_Date__c = input.CC_ExpirationDate;
                contract.Credit_Card_Number__c = input.CC_Number;
                //contract.SIPS_ID__c = input.SipsId;
                update contract;
            }
            if(!input.FlagPaymentModeChangedOnly)
                createPaymentActivity(contract.Id,input.TransactionId,input.TransactionDate,input.Credits,input.TransactionAmount,input.PaymentMode,Generic.ApplicationCode.UNKNOWN,contact.Id);
            
        }
        catch(Generic.StandardException stex)
        {
            spmOutput.ReturnCode = stex.ReturnCode;
            spmOutput.Error = stex.Error;
            Database.rollback(sp);
        }
        catch(Exception ex)
        {
            spmOutput.ReturnCode = 1;
            spmOutput.Error = ex.getMessage();
            Database.rollback(sp);
        }
        
        return spmOutput;
    }
    
    
    //Flash Methods
    webservice static CanSubscribeOutput CanSubscribeToProduct(CanSubscribeInput input){
        /*
        Check if the user can subscribe to Flash (prevent multiple accounts)        
        */
        System.debug('Input can subscribr to product method: '+input);
        CanSubscribeOutput csOutput = new CanSubscribeOutput();
        try{
        /*
        Before all, we check if the customer works in a non commercial agence
        */
        if(input.NoCommercial == true)
        {
            csOutput.Result =true;
            return csOutput;
        }
        
        /*
        VAT
        */
        if(Generic.StringNotEmpty(input.VAT))
        {
            Integer nbSub = [select count() from Subscription__c where Subscription__c.Contract__r.Account.VAT__c=:input.VAT and Offer_Template__r.Base_Product__r.Name='Flash - Catalog'];
            if(nbSub == 0)
            {
                csOutput.Result = true;
            }   
            else
            {
                csOutput.ReturnCode = 901;
                csOutput.Error = 'This VAT Number is already used by a Flash User';
                return csOutput;
            }    
        }
        
        /*
        Siret
        */  
        if(input.Siret.length() > 0)
        {
            Integer nbSubSiret = [select count() from Subscription__c where Subscription__c.Contract__r.Account.Siret__c=:input.Siret and Offer_Template__r.Base_Product__r.Name='Flash - Catalog'];
            if(nbSubSiret == 0)
            {
                csOutput.Result = true;
            }   
            else
            {
                csOutput.ReturnCode = 902;
                csOutput.Error = 'This Siret is already used by a Flash User';
                return csOutput;
            }
        }
            
        }catch(Exception ex){
            csOutput.ReturnCode = 1;
            csOutput.Error = ex.getMessage();
        }
        System.debug('Output can subscribe to product: '+csOutput);
        return csOutput;
        
    }
    
    webservice static GetProductOutput GetProduct(String login)
    {
        /*
        Retrieve the product        
        */
        GetProductOutput gpOutput = new GetProductOutput();
        try{
            //We are looking for the concerned contact
            Map<Id,User_Profile_Service__c> userProfileServices;
            //We load the User profile services for Flash
            //We check before if the flash have flash subscription
            Generic.packageInput packageInputFlashSubs = new Generic.packageInput(login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_subscription), Generic.ApplicationCode.FTFR.name(), Generic.Action.Search);
            System.debug('Input: '+packageInputFlashSubs);
            Map<Id,User_Profile_Service__c> upsFlashSubs = Generic.getUserProfileServices(packageInputFlashSubs);
            
            System.debug('Flash Subscription: '+upsFlashSubs);
            
            //Flash Act
            Generic.packageInput packageInputFlashAct = new Generic.packageInput(login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_volume), Generic.ApplicationCode.FTFR.name(), Generic.Action.Search);
            Map<Id,User_Profile_Service__c> upsFlashAct = Generic.getUserProfileServices(packageInputFlashAct);
            
            System.debug('Flash Act: '+upsFlashAct);
            
            // Flash Free
            Generic.packageInput packageInputFreeBasic=new Generic.packageInput(login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Free_basic), Generic.ApplicationCode.FTFR.name(), Generic.Action.Search);
            Map<Id,User_Profile_Service__c> upsFreeBasic = Generic.getUserProfileServices(packageInputFreeBasic);


            System.debug('Flash Free: '+upsFreeBasic);
            
            if (!upsFlashSubs.isEmpty())
            userProfileServices = upsFlashSubs;
            if (!upsFlashAct.isEmpty())
            userProfileServices = upsFlashAct;
            if (!upsFreeBasic.isEmpty())
            userProfileServices = upsFreeBasic;
            
            System.debug('User Profile Services: '+userProfileServices);
             
            for(User_Profile_Service__c ups : userProfileServices.values())
            {
                if(
                    ups.Suspension_Start_Date__c == null
                    ||
                    ups.Suspension_Start_Date__c > Date.today()
                    ||
                    (ups.Suspension_End_Date__c != null && ups.Suspension_End_Date__c<Date.today())
                    )
                {
                    if(ups.Provisioning_Service__r.Service__r.Name == 'Flash Subscription Yearly')
                        gpOutput.Frequency = '12 Months';
                        gpOutput.PriceList ='EU_FLASH_SUBS';
                    if (ups.Provisioning_Service__r.Service__r.Name == 'Flash Subscription Monthly')
                        gpOutput.Frequency = '1 Month';
                        gpOutput.PriceList ='EU_FLASH_SUBS';  
                    if (ups.Provisioning_Service__r.Service__r.Name == 'Flash Act')
                        gpOutput.PriceList ='EU_FLASH_CREDITS';     
                    if (ups.Provisioning_Service__r.Service__r.Name == 'Flash Free')
                        gpOutput.PriceList ='EU_FLASH_SUBS';    
                                                            
                    if(ups.Suspension_Start_Date__c > Date.today()) 
                        gpOutput.EndDate = ups.Suspension_Start_Date__c;
                        
                    //gpOutput.PriceList = ups.Provisioning_Service__r.Service__r.Access_Roles__c;
                }
            }
            
        }catch(Exception ex){
            gpOutput.ReturnCode = 1;
            gpOutput.Error = ex.getMessage();
        }
        System.debug(gpOutput);
        return gpOutput;
    }
    
    webservice static Generic.StandardOutput UpdateProfile(UpdateProfileInput input){
        /*
        Update user information     
        */
        Generic.StandardOutput sOutput = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
            try{
            if(input.Appli=='' || (input.Appli!='O3E' && input.Appli!='O3EN' && input.Appli!='WEB3N' && input.Appli!='WEB3' && input.Appli!='WEB30' && input.Appli!='WEB3S' && input.Appli!='TPRO' && input.Appli!='FTFR'))
            {
                sOutput.ReturnCode = 4;
                sOutput.Error = 'This application is not defined or not authorized.';
                return sOutput;
            }
            
            //We are looking for the concerned contact
            Contact contactConcerned = [select Id from Contact where Username__c =:input.Login limit 1];
            
            if(input.Appli!='WEB3S' && input.Appli!='FTFR')
            {
                if (Generic.StringNotEmpty(input.FirstName))
                    contactConcerned.FirstName = input.FirstName;
                if (Generic.StringNotEmpty(input.LastName))
                    contactConcerned.LastName = input.LastName;
                if (Generic.StringNotEmpty(input.Phone))
                    contactConcerned.Phone = input.Phone;
                if (Generic.StringNotEmpty(input.Fax))
                    contactConcerned.Fax = input.Fax;
                if (Generic.StringNotEmpty(input.Mobile))
                    contactConcerned.MobilePhone = input.Mobile;
                if (Generic.StringNotEmpty(input.Language))
                    contactConcerned.Language__c = input.Language;
                
            }
            
            if (Generic.StringNotEmpty(input.Email))
                contactConcerned.Email = input.Email;
            
            update contactConcerned;
        }catch(Exception ex){
            sOutput.ReturnCode = 3;
            sOutput.Error = ex.getMessage();
            Database.rollback(sp);
        }
        return sOutput;
    }
    
    webservice static GetCompanyVATInfosOutput GetCompanyVATInfos(String login)
    {
        /*
        Get information about the company       
        */
        GetCompanyVATInfosOutput gcvatiOutput = new GetCompanyVATInfosOutput();
        try{
            Contact contact = [select Id,AccountId from Contact c where c.Username__c =:login limit 1];
            Account account = [select Id, Name,VAT__c,SIRET__c,Company_Name__c,Legal_Status__c from Account a where a.Id=:contact.AccountId];
            gcvatiOutput.VAT = account.VAT__c;
            gcvatiOutput.Siret = account.SIRET__c;
            gcvatiOutput.CompanyName = account.Name;
            if(account.Legal_Status__c == 'No Commercial')
                gcvatiOutput.NoCommercial = true;
        }catch(Exception ex){
            gcvatiOutput.ReturnCode = 1;
            gcvatiOutput.Error = ex.getMessage();
        }
        return gcvatiOutput;
    }
    
    webservice static Generic.StandardOutput MigrateFromActToSubscription(MigrateFlashInput input){
        /*
        Migrate from act to subscription    
        */ 
        System.debug('MigrateFlasfInput From Act to Subscription: '+input);
        
        Generic.StandardOutput sOutput = new Generic.StandardOutput();
        
        try{
            Contact contactLoaded = [select c.Id,c.AccountId from Contact c where c.Username__c =:input.Login limit 1];
            
            try
            {
                //We close the Service flash Act
                Generic.packageInput packageInputToRemove=new Generic.packageInput(input.Login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_volume), Generic.ApplicationCode.FTFR.name(), Generic.Action.Search);
                User_Profile_Service__c upsToRemove = Generic.getUserProfileService(packageInputToRemove); 
                upsToRemove.Suspension_Start_Date__c = Date.today();//date.newinstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));
                upsToRemove.Suspension_Reason__c = 'Managed by MyProducts';
                upsToRemove.Suspension_End_Date__c = null;
                
                update upsToRemove;           
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=2;
                stex.setMessage('Error closing flash Act service : '+ex.getMessage());
                stex.Error='Error closing flash Act service : '+ex.getMessage();
                throw stex;   
            }  
                        
            try
            {
                //We open the Service flash subscription
                Generic.packageInput packageInputToCreate=new Generic.packageInput(input.Login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_subscription), Generic.ApplicationCode.FTFR.name(), Generic.Action.Create);
                User_Profile_Service__c upsToCreate = Generic.getUserProfileServiceForFlash(packageInputToCreate,getMatchingServiceNameForFrequency(input.Frequency)); 

                //We store only the user profile service having corresponding at the good frequency
                if(input.Frequency == '12 Months')
                {
                    //We calculate the last day of the current month
                    Date suspensionDate = Date.today();
                    Date trialEndDate = Date.today();
                    if(input.Trial == 'Y')
                    {
                        //We add one month to current date
                        suspensionDate = suspensionDate.addMonths(1);
                        trialEndDate = date.newinstance(suspensionDate.year(), suspensionDate.month(), Date.daysInMonth(suspensionDate.year(), suspensionDate.month()));
                    }
                    suspensionDate = date.newinstance(suspensionDate.addYears(1).year(), suspensionDate.month(), Date.daysInMonth(suspensionDate.addYears(1).year(), suspensionDate.month())); 
                    upsToCreate.Suspension_Start_Date__c = suspensionDate;
                    upsToCreate.Suspension_Reason__c = 'Managed by MyProducts';
                    upsToCreate.Suspension_End_Date__c = null;
                    
                    /*
                    Create Fee
                    */
                    Generic.FeeInput SubsFee = New Generic.FeeInput(contactLoaded.Id, Generic.ApplicationCode.FTFR.name(), 'Flash Subscription Yearly', 'Flash Subscription Yearly', null, null, suspensionDate);
                    Generic.createNewFee(SubsFee); 
                    
                     /*
                    Create Payment Activity
                    */
                    Id userProfId = Generic.getUserProfileId(input.login,Generic.ApplicationCode.FTFR.name());
            		String contractId = [select Provisioning__r.Contract__c from User_Profile__c where Id=:userProfId].Provisioning__r.Contract__c;
            		createPaymentActivity(contractId,input.SipsId,Date.today(),0,0,input.PaymentMode,Generic.ApplicationCode.FTFR,contactLoaded.Id);
            
                }
                else
                {
                    //input.Frequency == '1 Month'
                    upsToCreate.Suspension_Start_Date__c = null;
                    upsToCreate.Suspension_Reason__c = '';    
                    upsToCreate.Suspension_End_Date__c = null; 
                    
                    
                    Decimal CalculatedProrataAmount = Generic.getProratAmount(input.Amount);
                    System.Debug('Calculate Amount'+CalculatedProrataAmount);
                    Date sEndDate = Date.today().addMonths(1);
                    Date OneOffEndDate = Date.newInstance(sEndDate.year(), sEndDate.month(), date.daysInMonth(sEndDate.year() , sEndDate.month())); 
                    
                    /*Create OneOff Fee
                    */
                    Generic.FeeInput OneOffFee = New Generic.FeeInput(contactLoaded.Id, Generic.ApplicationCode.FTFR.name(), 'Flash Subscription Monthly', 'Flash Subscription Monthly', CalculatedProrataAmount, Date.today(), OneOffEndDate);
                    System.Debug ('Fee input OneOffFee'+OneOffFee);
                    Generic.createNewFee(OneOffFee);
                    
                     /*Create Recurrent Fee
                    */
                    Date StartDate = Date.Today().addMonths(2);
                    Date RecurrenbtStartDay = StartDate.toStartOfMonth();
                    System.Debug('Start Date'+RecurrenbtStartDay);
                    Date RecurrentStartDate = date.newInstance(RecurrenbtStartDay.year(), RecurrenbtStartDay.month(), RecurrenbtStartDay.day());
                    
                    Generic.FeeInput ReccurentFee = New Generic.FeeInput(contactLoaded.Id, Generic.ApplicationCode.FTFR.name(), 'Flash Subscription Monthly', 'Flash Subscription Monthly', null,RecurrentStartDate , null);
                    System.Debug ('Fee input OneOffFee'+ReccurentFee);
                    Generic.createNewFee(ReccurentFee);
                    
                    /*
                    Create Payment Activity
                    */
                    Id userProfId = Generic.getUserProfileId(input.login,Generic.ApplicationCode.FTFR.name());
                    String contractId = [select Provisioning__r.Contract__c from User_Profile__c where Id=:userProfId].Provisioning__r.Contract__c;
                    createPaymentActivity(contractId,input.SipsId,Date.today(),0,CalculatedProrataAmount,input.PaymentMode,Generic.ApplicationCode.FTFR,contactLoaded.Id);	
                               
                }

                upsert upsToCreate;
                
                
                // Sysncronise  the User Profile
                List<Id> userProfileIds = new List<Id>();
                userProfileIds.add(packageInputToCreate.UserProfileId);
                if (!Test.isRunningTest())
                	ProvisioningMessagesAsync.SendReProvisioning(userProfileIds); 
   
            
            }catch(Exception ex){
            	
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=3;
                stex.setMessage('Error Opening flash subscription service : '+ex.getMessage());
                stex.Error='Error Opening flash subscription service : '+ex.getMessage();
                throw stex;   
            }
            
            
        }catch(Exception ex){
            sOutput.ReturnCode = 1;
            sOutput.Error = ex.getMessage();
        }
        return sOutput;
    }
    
    webservice static Generic.StandardOutput MigrateFromSubscriptionToAct(String login){
        /*
        Migrate from subscription to act    
        */
        Generic.StandardOutput sOutput = new Generic.StandardOutput();
        try{
            Contact contactLoaded = [select c.Id,c.AccountId from Contact c where c.Username__c =:login limit 1];
            Date suspendedDate;
            try
            {
                //We close the Service flash subscription
                Generic.packageInput packageInputToRemove=new Generic.packageInput(login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_subscription), Generic.ApplicationCode.FTFR.name(), Generic.Action.Search);
                Map<Id,User_Profile_Service__c> upsToRemoves = Generic.getUserProfileServices(packageInputToRemove); 
                                
                //We have to determine if the current subscription is monthly or yearly
                for(Id upsToRemoveId : upsToRemoves.keySet())
                {
                    //Suspension Date is already configured for frenquency yearly at creation if itr is null, it is monthly
                    //If we have already a Suspension Start Date in the future we must take this date
                    //Update DS
                    if(upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c == null || upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c > Date.today())
                    {
                        //upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c = date.newinstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));
                        upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c = Date.today();
                        upsToRemoves.get(upsToRemoveId).Suspension_Reason__c = 'Managed by MyProducts';
                        upsToRemoves.get(upsToRemoveId).Suspension_End_Date__c = null;
                    }
                    suspendedDate = upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c;
                }       
                update upsToRemoves.values();
                
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=2;
                stex.setMessage('Error closing flash subscription service : '+ex.getMessage());
                stex.Error='Error closing flash subscription service : '+ex.getMessage();
                throw stex;   
            }  
                        
            try
            {
                //We open the Service flash Act
                Generic.packageInput packageInputToCreate=new Generic.packageInput(login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_volume), Generic.ApplicationCode.FTFR.name(), Generic.Action.Create);
                Map<Id,User_Profile_Service__c> upsToCreates = Generic.getUserProfileServices(packageInputToCreate);
                
                for(User_Profile_Service__c ups: upsToCreates.values()){
                //ups.Suspension_Start_Date__c = Date.today();
                ups.Suspension_Start_Date__c = null;
                ups.Suspension_Reason__c = 'Managed by MyProducts';
                update ups;
                }
                
                // Synchronise the User Profil
                
                List<Id> userProfileIds = new List<Id>();
                userProfileIds.add(packageInputToCreate.UserProfileId);
                if (!Test.isRunningTest())
                	ProvisioningMessagesAsync.SendReProvisioning(userProfileIds); 
                
                       
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=3;
                stex.setMessage('Error Opening flash Act service : '+ex.getMessage());
                stex.Error='Error Opening flash Act service : '+ex.getMessage();
                throw stex;   
            }
            
            /*
            closeCurrentSubscription(contactLoaded.AccountId,Generic.ApplicationCode.FTFR);
            MigrateFlashInput input=new MigrateFlashInput();
            input.FlashSubscription=TypeAbo.Flash_volume;
            createSubscriptionServicesAndUpdateAccount(input);
            */            
        }catch(Exception ex){
            sOutput.ReturnCode = 1;
            sOutput.Error = ex.getMessage();
        }
        return sOutput;
    }
   
    
   
    
    webservice static Generic.StandardOutput MigrateFrequency(MigrateFrequencyInput input){
        /*
        Change the subscription frequency   
        */
        System.debug('MigrateFrequencyInput: '+input);
        Generic.StandardOutput sOutput = new Generic.StandardOutput();
        try{
            //TODO
            Contact contactLoaded = [select c.Id,c.AccountId from Contact c where c.Username__c =:input.Login limit 1];
            
            Date suspendedDate;
            try
            {
                //We close the Service flash subscription
                Generic.packageInput packageInputToRemove=new Generic.packageInput(input.Login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_subscription), Generic.ApplicationCode.FTFR.name(), Generic.Action.Search);
                Map<Id,User_Profile_Service__c> upsToRemoves = Generic.getUserProfileServices(packageInputToRemove); 
                                
                //We have to determine if the current subscription is monthly or yearly
                for(Id upsToRemoveId : upsToRemoves.keySet())
                {
                    //Suspension Date is already configured for frenquency yearly at creation
                    //If we have already a Suspension Start Date in the future we must take this date
                    if(upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c == null || upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c > Date.today())
                    {
                        //upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c = date.newinstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));
                        upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c = Date.today();
                        upsToRemoves.get(upsToRemoveId).Suspension_Reason__c = 'Managed by MyProducts';
                        upsToRemoves.get(upsToRemoveId).Suspension_End_Date__c = null;
                    }
                    suspendedDate = upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c;
                    
                }       
                update upsToRemoves.values();
                
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=2;
                stex.setMessage('Error closing flash subscription service : '+ex.getMessage());
                stex.Error='Error closing flash subscription service : '+ex.getMessage();
                throw stex;   
            }  
            
            try
            {
                //We open the Service flash subscription
                Generic.packageInput packageInputToCreate=new Generic.packageInput(input.Login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_subscription), Generic.ApplicationCode.FTFR.name(), Generic.Action.Create);
                User_Profile_Service__c upsToCreate = Generic.getUserProfileServiceForFlash(packageInputToCreate,getMatchingServiceNameForFrequency(input.Frequency)); 

                //We store only the user profile service having corresponding at the good frequency
                if(input.Frequency == '12 Months')
                {
                    //We calculate the last day of the current month
                    Date suspensionDate = Date.today();
                    Date trialEndDate = Date.today();
                   /* if(input. == 'Y')
                    {
                        //We add one month to current date
                        suspensionDate = suspensionDate.addMonths(1);
                        trialEndDate = date.newinstance(suspensionDate.year(), suspensionDate.month(), Date.daysInMonth(suspensionDate.year(), suspensionDate.month()));
                     }*/
                    suspensionDate = date.newinstance(suspensionDate.addYears(1).year(), suspensionDate.month(), Date.daysInMonth(suspensionDate.addYears(1).year(), suspensionDate.month())); 
                    upsToCreate.Suspension_Start_Date__c = suspensionDate;
                    upsToCreate.Suspension_Reason__c = 'Managed by MyProducts';
                    upsToCreate.Suspension_End_Date__c = null;
                    
                    // Create a new  Fee
                    Generic.FeeInput SubsFee = New Generic.FeeInput(contactLoaded.Id, Generic.ApplicationCode.FTFR.name(), 'Flash Subscription Yearly', 'Flash Subscription Yearly', null, null, suspensionDate);
                    Generic.createNewFee(SubsFee);
                     
                }
                else
                {
                    //input.Frequency == '1 Month'
                    upsToCreate.Suspension_Start_Date__c = null;
                    upsToCreate.Suspension_Reason__c = '';    
                    upsToCreate.Suspension_End_Date__c = null;
                    
                    Decimal CalculatedProrataAmount = Generic.getProratAmount(input.Amount);
                    System.Debug('Calculate Amount'+CalculatedProrataAmount);
                    Date sEndDate = Date.today().addMonths(1);
                    Date OneOffEndDate = Date.newInstance(sEndDate.year(), sEndDate.month(), date.daysInMonth(sEndDate.year() , sEndDate.month())); 
                    
                    /*Create OneOff Fee
                    */
                    Generic.FeeInput OneOffFee = New Generic.FeeInput(contactLoaded.Id, Generic.ApplicationCode.FTFR.name(), 'Flash Subscription Monthly', 'Flash Subscription Monthly', CalculatedProrataAmount, Date.today(), OneOffEndDate);
                    System.Debug ('Fee input OneOffFee'+OneOffFee);
                    Generic.createNewFee(OneOffFee);
                    
                     /*Create Recurrent Fee
                    */
                    Date StartDate = Date.Today().addMonths(2);
                    Date RecurrenbtStartDay = StartDate.toStartOfMonth();
                    System.Debug('Start Date'+RecurrenbtStartDay);
                    Date RecurrentStartDate = date.newInstance(RecurrenbtStartDay.year(), RecurrenbtStartDay.month(), RecurrenbtStartDay.day());
                    
                    Generic.FeeInput ReccurentFee = New Generic.FeeInput(contactLoaded.Id, Generic.ApplicationCode.FTFR.name(), 'Flash Subscription Monthly', 'Flash Subscription Monthly', null,RecurrentStartDate , null);
                    System.Debug ('Fee input OneOffFee'+ReccurentFee);
                    Generic.createNewFee(ReccurentFee);
                                          
                }
                upsert upsToCreate;
                
                
                // Syncronise the User profile
                List<Id> userProfileIds = new List<Id>();
                userProfileIds.add(packageInputToCreate.UserProfileId);
                if (!Test.isRunningTest())
                	ProvisioningMessagesAsync.SendReProvisioning(userProfileIds); 
                
                
                
                //TODO
                //Subs_Current_Fee__c 
                
                //We cancel the credits 
                //updateWallet

            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=3;
                stex.setMessage('Error Opening flash subscription service : '+ex.getMessage());
                stex.Error='Error Opening flash subscription service : '+ex.getMessage();
                throw stex;   
            }
            //createPaymentActivity(contractId, transactionId, transactionDate, credits, amount, paymentMode);
        
        }catch(Exception ex){
            sOutput.ReturnCode = 1;
            sOutput.Error = ex.getMessage();
        }
        return sOutput;
    }
    
    webservice static Generic.StandardOutput MigrateFromFreeBasicToOthers(MigrateFlashInput input){
        /*
        Migrate from free basic to others   
        */
        
        System.Debug('MigrateFlashInput'+input); 
        Generic.StandardOutput sOutput = new Generic.StandardOutput();
        try{
            //TODO
            Contact contactLoaded = [select c.Id,c.AccountId from Contact c where c.Username__c =:input.Login limit 1];
            try
            {
                //We close the Service flash Free Basic
                Generic.packageInput packageInputToRemove=new Generic.packageInput(input.Login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Free_basic), Generic.ApplicationCode.FTFR.name(), Generic.Action.Search);
                User_Profile_Service__c upsToRemove = Generic.getUserProfileService(packageInputToRemove); 
                upsToRemove.Suspension_Start_Date__c = Date.today();//date.newinstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));
                upsToRemove.Suspension_Reason__c = 'Managed by MyProducts';
                upsToRemove.Suspension_End_Date__c = null;
                
                update upsToRemove;           
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=2;
                stex.setMessage('Error closing flash Free Basic service : '+ex.getMessage());
                stex.Error='Error closing flash Free Basic service : '+ex.getMessage();
                throw stex;   
            }  
                
            if(input.FlashSubscription == TypeAbo.Flash_subscription)
            {        
                try
                {           
                    //We open the Service flash subscription
                    Generic.packageInput packageInputToCreate=new Generic.packageInput(input.Login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_subscription), Generic.ApplicationCode.FTFR.name(), Generic.Action.Create);
                    User_Profile_Service__c upsToCreate = Generic.getUserProfileServiceForFlash(packageInputToCreate,getMatchingServiceNameForFrequency(input.Frequency)); 
    
                    //We store only the user profile service having corresponding at the good frequency
                    if(input.Frequency == '12 Months')
                    {
                        //We calculate the last day of the current month
                        Date suspensionDate = Date.today();
                        Date trialEndDate = Date.today();
                        if(input.Trial == 'Y')
                        {
                            //We add one month to current date
                            suspensionDate = suspensionDate.addMonths(1);
                            trialEndDate = date.newinstance(suspensionDate.year(), suspensionDate.month(), Date.daysInMonth(suspensionDate.year(), suspensionDate.month()));
                        }
                        suspensionDate = date.newinstance(suspensionDate.addYears(1).year(), suspensionDate.month(), Date.daysInMonth(suspensionDate.addYears(1).year(), suspensionDate.month())); 
                        upsToCreate.Suspension_Start_Date__c = suspensionDate;
                        upsToCreate.Suspension_Reason__c = 'Managed by MyProducts';
                        upsToCreate.Suspension_End_Date__c = null;
                        Generic.FeeInput SubsFee = New Generic.FeeInput(contactLoaded.Id, Generic.ApplicationCode.FTFR.name(), 'Flash Subscription Yearly', 'Flash Subscription Yearly', null, Date.today(), suspensionDate);
                        Generic.createNewFee(SubsFee);
                        
	                    Id userProfId = Generic.getUserProfileId(input.login,Generic.ApplicationCode.FTFR.name());
	                    String contractId = [select Provisioning__r.Contract__c from User_Profile__c where Id=:userProfId].Provisioning__r.Contract__c;
	                    createPaymentActivity(contractId,input.SipsId,Date.today(),0,0,input.PaymentMode,Generic.ApplicationCode.FTFR,contactLoaded.Id);
                 
                    }
                    else
                    {
                        //input.Frequency == '1 Month'
                        upsToCreate.Suspension_Start_Date__c = null;
                        upsToCreate.Suspension_Reason__c = '';    
                        upsToCreate.Suspension_End_Date__c = null;
                        
	                    Decimal CalculatedProrataAmount = Generic.getProratAmount(input.Amount);
	                    System.Debug('Calculate Amount'+CalculatedProrataAmount);
	                    Date sEndDate = Date.today().addMonths(1);
	                    Date OneOffEndDate = Date.newInstance(sEndDate.year(), sEndDate.month(), date.daysInMonth(sEndDate.year() , sEndDate.month())); 
	                    
	                    /*Create OneOff Fee
	                    */
	                    Generic.FeeInput OneOffFee = New Generic.FeeInput(contactLoaded.Id, Generic.ApplicationCode.FTFR.name(), 'Flash Subscription Monthly', 'Flash Subscription Monthly', CalculatedProrataAmount, Date.today(), OneOffEndDate);
	                    System.Debug ('Fee input OneOffFee'+OneOffFee);
	                    Generic.createNewFee(OneOffFee);
	                    
	                     /*Create Recurrent Fee
	                    */
	                    Date StartDate = Date.Today().addMonths(2);
	                    Date RecurrenbtStartDay = StartDate.toStartOfMonth();
	                    System.Debug('Start Date'+RecurrenbtStartDay);
	                    Date RecurrentStartDate = date.newInstance(RecurrenbtStartDay.year(), RecurrenbtStartDay.month(), RecurrenbtStartDay.day());
	                    
	                    Generic.FeeInput ReccurentFee = New Generic.FeeInput(contactLoaded.Id, Generic.ApplicationCode.FTFR.name(), 'Flash Subscription Monthly', 'Flash Subscription Monthly', null, RecurrentStartDate , null);
	                    System.Debug ('Fee input OneOffFee'+ReccurentFee);
	                    Generic.createNewFee(ReccurentFee); 
	                    
	                    
	                    /*
	                    Create Payment Activity
	                    */                  
	                    
	                                        
	                    Id userProfId = Generic.getUserProfileId(input.login,Generic.ApplicationCode.FTFR.name());
	                    String contractId = [select Provisioning__r.Contract__c from User_Profile__c where Id=:userProfId].Provisioning__r.Contract__c;
	                    createPaymentActivity(contractId,input.SipsId,Date.today(),0,CalculatedProrataAmount,input.PaymentMode,Generic.ApplicationCode.FTFR,contactLoaded.Id);
                 
	                }
    
                    upsert upsToCreate;

                    // Syncronise the User profile
                    List<Id> userProfileIds = new List<Id>();
                    userProfileIds.add(packageInputToCreate.UserProfileId);
                    if (!Test.isRunningTest())
                    	ProvisioningMessagesAsync.SendReProvisioning(userProfileIds); 
                
                                
                }catch(Exception ex){
                    Generic.StandardException stex=new Generic.StandardException();
                    stex.ReturnCode=3;
                    stex.setMessage('Error Opening flash subscription service : '+ex.getMessage());
                    stex.Error='Error Opening flash subscription service : '+ex.getMessage();
                    throw stex;   
                }
            }   
            else //input.FlashSubscription == TypeAbo.Flash_volume
            {
                try
                {
                    //We open the Service flash Act
                    Generic.packageInput packageInputToCreate=new Generic.packageInput(input.Login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_volume), Generic.ApplicationCode.FTFR.name(), Generic.Action.Create);
                    MAP<Id,User_Profile_Service__c> upsToCreates = Generic.getUserProfileServices(packageInputToCreate);
                    
                    
                    /*upsToCreate.Suspension_Start_Date__c = null;
                    upsToCreate.Suspension_Reason__c = 'Managed by MyProducts';
                    upsToCreate.Suspension_End_Date__c = null;
    
                    upsert upsToCreate;*/
                    
                    for (User_Profile_Service__c ups: upsToCreates.values()){
                    ups.Suspension_Start_Date__c = null;
                    ups.Suspension_Reason__c = 'Managed by MyProducts';
                    ups.Suspension_End_Date__c = null;
                    }
                    
                    // Syncronise the User profile
                    List<Id> userProfileIds = new List<Id>();
                    userProfileIds.add(packageInputToCreate.UserProfileId);
                    ProvisioningMessagesAsync.SendReProvisioning(userProfileIds); 
                
                    
                            
                }catch(Exception ex){
                    Generic.StandardException stex=new Generic.StandardException();
                    stex.ReturnCode=4;
                    stex.setMessage('Error Opening flash Act service : '+ex.getMessage());
                    stex.Error='Error Opening flash Act service : '+ex.getMessage();
                    throw stex;   
                }
            }      
        }catch(Exception ex){
            sOutput.ReturnCode = 1;
            sOutput.Error = ex.getMessage();
        }
        return sOutput;
    }    
    
     webservice static Generic.StandardOutput Unsubscribe(String login){
        /*
        Unsubscribe to Flash product (returns to Flash Free), the cancellation is valid only for flas subscription.    
        */
        Generic.StandardOutput sOutput = new Generic.StandardOutput();
        try{
            //We have to deactivate fees
            
            Contact contactLoaded = [select c.Id,c.AccountId from Contact c where c.Username__c =:login limit 1];
           
            try
            {
                //We close the Service flash subscription
                Generic.packageInput packageInputToRemove=new Generic.packageInput(login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_subscription), Generic.ApplicationCode.FTFR.name(), Generic.Action.Search);
                Map<Id,User_Profile_Service__c> upsToRemoves = Generic.getUserProfileServices(packageInputToRemove); 
                              
                if(upsToRemoves.size()>0)  
                {
                    //We have to determine if the current subscription is monthly or yearly
                    for(Id upsToRemoveId : upsToRemoves.keySet())
                    {
                        //Suspension Date is already configured for frenquency yearly at creation
                        //If we have already a Suspension Start Date in the future we must take this date
                        if(upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c == null || upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c > Date.today())
                        {
                            //upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c = date.newinstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));
                            upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c = Date.Today(); 
                            upsToRemoves.get(upsToRemoveId).Suspension_Reason__c = 'Managed by MyProducts';
                            upsToRemoves.get(upsToRemoveId).Suspension_End_Date__c = null;
                        }
                        Date suspendedDate = upsToRemoves.get(upsToRemoveId).Suspension_Start_Date__c;
                    }       
                    update upsToRemoves.values();
                }
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=3;
                stex.setMessage('Error closing flash subscription service : '+ex.getMessage());
                stex.Error='Error closing flash subscription service : '+ex.getMessage();
                throw stex;   
            }
            
            try
            {   
            	
            	Generic.packageInput packageInputToCreate=new Generic.packageInput(login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Free_basic), Generic.ApplicationCode.FTFR.name(), Generic.Action.Create);
                Map<Id,User_Profile_Service__c> upsToCreate = Generic.getUserProfileServices(packageInputToCreate);
                
           
                if (upsToCreate.size()>0)
                {
                	for (Id upsId : upsToCreate.keySet())
                	{
                    	upsToCreate.get(upsId).Suspension_Reason__c = 'Managed by MyProducts';
                    	upsToCreate.get(upsId).Suspension_Start_Date__c = null;
                    	upsToCreate.get(upsId).Suspension_End_Date__c = null;	
                	}
                update upsToCreate.values();
                }
                List<Id> userProfileIds = new List<Id>();
                userProfileIds.add(packageInputToCreate.UserProfileId);
                if (!Test.isRunningTest())
                	ProvisioningMessagesAsync.SendReProvisioning(userProfileIds);  
            	    
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=4;
                stex.setMessage('Error Opening flash Free Basic service : '+ex.getMessage());
                stex.Error='Error Opening flash Free Basic service : '+ex.getMessage();
                throw stex;   
            }
        }catch(Exception ex){
            sOutput.ReturnCode = 1;
            sOutput.Error = ex.getMessage();
        }
        return sOutput;
    }
    
    webservice static Generic.StandardOutput CreatePayment(CreatePaymentInput input){
        /*
        Creates an activity for the payment (when the user buy credits) 
        */
        
        
        Generic.StandardOutput sOutput = new Generic.StandardOutput();
        try
        {
            Contact contact   = [SELECT Id FROM Contact WHERE Username__c = :input.Login];
        	Id userProfId 	  = Generic.getUserProfileId(input.Login, Generic.ApplicationCode.FTFR.name());
            String contractId = [SELECT Provisioning__r.Contract__c FROM User_Profile__c WHERE Id = :userProfId].Provisioning__r.Contract__c;
            createPaymentActivity(contractId, input.SipsId, Date.today(), Integer.valueOf(input.Credits), input.Amount, input.PaymentMode, Generic.ApplicationCode.FTFR, contact.Id);
        }
        catch(Exception ex)
        {
            sOutput.ReturnCode = 1;
            sOutput.Error = ex.getMessage();
        }
        System.debug('Output Create Payment activity'+sOutput);
        return sOutput;
    }
    
    webservice static ReadFlashTransportCompanyOutput ReadFlashTransportCompany(String login){
        /*
        Get information about the company   
        */
        ReadFlashTransportCompanyOutput rftcOutput = new ReadFlashTransportCompanyOutput();
        try{
            
            Contact currentContact=[select Id,AccountId from Contact where Username__c =:login limit 1];
            
            Id userProfId = Generic.getUserProfileId(login,Generic.ApplicationCode.FTFR.name());
            String contractId = [select Provisioning__r.Contract__c from User_Profile__c where Id=:userProfId].Provisioning__r.Contract__c;

            Account currentAccount=[select Id from Account where Id=:currentContact.AccountId limit 1];
            
            //rftcOutput.
            Contract currentContract=[select Id, Credit_Card_Number__c, Credit_Card_Expiration_Date__c, Payment_Method__c from Contract where Id=:contractId];
            Subscription__c currentSub=[select Id from Subscription__c where Contract__c=:currentContract.Id];
            
            
            //We load the User profile services for Flash
            //We check before if the flash have flash subscription
            Generic.packageInput packageInputFlashSubs = new Generic.packageInput(login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_subscription), Generic.ApplicationCode.FTFR.name(), Generic.Action.Search);
            Map<Id,User_Profile_Service__c> userProfileServices = Generic.getUserProfileServices(packageInputFlashSubs);
            //We check if the flash have flash Act
            Generic.packageInput packageInputFlashAct = new Generic.packageInput(login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Flash_volume), Generic.ApplicationCode.FTFR.name(), Generic.Action.Search);
            User_Profile_Service__c upsFlashAct = Generic.getUserProfileService(packageInputFlashAct);
            if(upsFlashAct != null)
                userProfileServices.put(upsFlashAct.id,upsFlashAct);
            //We check if the flash have flash Free Basic
            Generic.packageInput packageInputFreeBasic=new Generic.packageInput(login, '',getMatchingAccessRoleForTypeAbo(TypeAbo.Free_basic), Generic.ApplicationCode.FTFR.name(), Generic.Action.Search);
            User_Profile_Service__c upsFreeBasic = Generic.getUserProfileService(packageInputFreeBasic);
            if(upsFreeBasic != null)
                userProfileServices.put(upsFreeBasic.id,upsFreeBasic);
                
            for(User_Profile_Service__c ups : userProfileServices.values())
            {
                if(
                    ups.Suspension_Start_Date__c == null
                    ||
                    ups.Suspension_Start_Date__c > Date.today()
                    ||
                    (ups.Suspension_End_Date__c != null && ups.Suspension_End_Date__c<Date.today())
                    )
                {
                    if(ups.Provisioning_Service__r.Service__r.Name == 'Flash Subscription Yearly')
                        rftcOutput.SubscriptionFrequency = '12 Month';
                    else
                        rftcOutput.SubscriptionFrequency = '1 Month';
                        
                    if(ups.Suspension_Start_Date__c > Date.today()) 
                        rftcOutput.EntitlementEndDate = ups.Suspension_Start_Date__c;
                }
            }
            
            rftcOutput.CcNumber=currentContract.Credit_Card_Number__c;
            rftcOutput.CcExpirationDate=currentContract.Credit_Card_Expiration_Date__c;
            rftcOutput.PaymentMethod=currentContract.Payment_Method__c;
        }catch(Exception ex){
            rftcOutput.ReturnCode = 1;
            rftcOutput.Error = ex.getMessage();
        }
        return rftcOutput;
    }
    
    
}