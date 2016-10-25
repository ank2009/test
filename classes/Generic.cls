global public with sharing class Generic
{
	/* =============================================================================================
	// Enumerators
	============================================================================================= */
	global public enum Action
	{
		Create,
		Search
	}

	global public enum ApplicationCode
	{
		FTFR,
		WEB3,
		WEB30,
		WEB3S,
		O3E,
		O3EN,
		UNKNOWN
	}

	global public enum PaymentMode
	{
		CC,
		PP,
		IPLUS,
		DKV,
		DD
	}

	global public enum SubscriptionType
	{
		Flash,
		TelerouteExpress,
		Standard
	}

	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 August 2
	* @description	enum with batch process statuses
	*/
	global public enum BatchStatus
	{
		Queued,
		Processing,
		Aborted,
		Completed,
		Failed,
		Preparing,
		Error			// initial state of variable, means unknown state
	}
	/* =============================================================================================
	// Exceptions
	============================================================================================= */
	public class StandardException extends Exception
	{
		public String Error = '';
		public Integer ReturnCode = 0;
	}
	
	public virtual  class SObjectValidationException extends Exception
	{
		public SObjectValidationException(string message, SObject obj)
		{
			this.setMessage(message);
			WrongObject = obj;
		}
		public SObject WrongObject { get; set; }
	}
	
	public class BridgeInternalException extends Exception { }
	public class BridgeExternalException extends Exception { }
	public class TCDException extends Exception { }
	public class ESBInternalException extends Exception { }
	public class ESBExternalException extends Exception { }
	/* =============================================================================================
	// Constructor
	============================================================================================= */
	public Generic()
	{
	}

	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 August 12
	* @description	simple wrapper for ID-String sets (Maps)
	*/
	global class IdStringWrapper
    {
        public ID id {get;set;}
        public String str {get;set;}

        public IdStringWrapper(ID i, String s) { str = s; id = i; }
    }
    /* =============================================================================================
    // Input object definition
    ============================================================================================= */
    global public class packageInput
    {
        public String Login;
        public String PackName;
        public String Product;
        public Generic.Action Action;
        public String CodeAppli;
        public String UserProfileId;

        global public packageInput(String login, String packName, String product, String codeAppli, Generic.Action toDo)
        {
            this.Login = login;
            this.PackName = packName;
            this.Product = product;
            this.Action = toDo;
            this.CodeAppli = codeAppli;
        }
    }

    global public class FeeInput {
       public Id ContactId;
       public String CodeAppli;
       public String FeeName;
       public String SubLineItem;
       public Decimal FeeAmount;
       public String FeeFrequency;
       public Date StartDate;
       public Date EndDate;
       global public FeeInput(Id ContactId, String CodeAppli, String FeeName, String SubLineItem, Decimal FeeAmount, Date StartDate, Date EndDate)
        {
            this.ContactId = ContactId;
            this.CodeAppli = CodeAppli;
            this.FeeName= FeeName;
            this.SubLineItem = SubLineItem;
            this.FeeAmount = FeeAmount;
            this.FeeFrequency = FeeFrequency;
            this.StartDate = StartDate;
            this.EndDate = EndDate;
        }
    }


    /* =============================================================================================
    // Output object definition
    ============================================================================================= */
    global public class StandardOutput
    {
        webservice public String Error = '';
        webservice public Integer ReturnCode = 0;
    }

    global public class ConfigurationParameterOutput
    {
        webservice public String Error = '';
        webservice public Integer ReturnCode = 0;
        webservice public String Value = '';
        webservice public String ParameterType = '';
    }

    public interface iOutput {
        String getError();
        Integer getReturnCode();
    }
    /* =============================================================================================
    // Public methods
    ============================================================================================= */
    global static String getLanguageLabel(String code)
    {
        String label='';
        try{
            label = [select Name from pw_cc__CountryObject__c where IRU_Country_Code__c=:code].Name;
        }
        catch(Exception e)
        {
            system.debug('## Error in loading of the Country Code : '+code+' '+e.getMessage());
            label = code;
        }
        return label;
    }

    global static String getUserProfileId(String login,String codeAppli)
    {
        Contact contactLoaded;
        List<Offer_template__c> oTs;
        String upLoadedId;
        Generic.StandardException ex=new Generic.StandardException();
        try
        {
            contactLoaded = [select Id from Contact where Username__c =:login or Id =: login limit 1];
        }catch(Exception e)
        {
            ex.ReturnCode=11;
            ex.setMessage('getUserProfileId: Error in load of the contact : '+e.getMessage());
            ex.Error='getUserProfileId: Error in load of the contact : '+login+' '+e.getMessage();
            throw ex;
        }
        /*try
        {
            oTs=[select Id from Offer_template__c where Base_Product__r.Access_Kind__c=:codeAppli];
        }catch(Exception e)
        {
            ex.ReturnCode=12;
            ex.setMessage('getUserProfileId: Error in load of the Offer_template__c : '+e.getMessage());
            ex.Error='getUserProfileId: Error in load of the Offer_template__c : '+codeAppli+' '+e.getMessage();
            throw ex;
        }*/
        try
        {
            upLoadedId = [select up.Id from User_Profile__c up
            where /* up.Status__c=:'Activated' and */ up.Contact__c =:contactLoaded.Id
             and up.Provisioning__r.Subscription__r.Access_Kind__c = :codeAppli limit 1].Id;
        }catch(Exception e)
        {
            ex.ReturnCode=13;
            ex.setMessage('getUserProfileId: Error in load of the User_Profile__c : '+e.getMessage());
            ex.Error='getUserProfileId: Error in load of the User_Profile__c : '+ codeAppli +' '+e.getMessage();
            throw ex;
        }
        return upLoadedId;
    }

    global static User_Profile_Service__c getUserProfileService(PackageInput input)
    {
        User_Profile__c upLoaded;
        Service__c service;
        Provisioning_Service__c provServ;
        User_Profile_Service__c userProfileService;
        Generic.StandardException ex=new Generic.StandardException();
        input.UserProfileId =getUserProfileId(input.Login,input.CodeAppli);
        System.debug('Input: '+input);
        System.debug('User Profile Id: '+input.UserProfileId);
        upLoaded=[select up.Id , up.Provisioning__c from User_Profile__c up where Id=:input.UserProfileId];

        try
        {
            service = [select Id from Service__c where Access_Roles__c=:input.Product limit 1];
        }catch(Exception e)
        {
            ex.ReturnCode=14;
            ex.setMessage('getUserProfileService: Error in load of the Service__c : '+e.getMessage());
            ex.Error='getUserProfileService: Error in load of the Service__c : '+input.Product+' '+e.getMessage();
            throw ex;
        }

        System.debug('Service: '+Service.Id);
        try
        {
            provServ = [select Id,Name from Provisioning_Service__c where Provisioning__c=:upLoaded.Provisioning__c and Service__c=:service.Id limit 1];
        }catch(Exception e)
        {
            ex.ReturnCode=15;
            ex.setMessage('getUserProfileService: Error in load of the Provisioning_Service__c : '+e.getMessage());
            ex.Error='getUserProfileService: Error in load of the Provisioning_Service__c : Provisioning='+upLoaded.Provisioning__c+' Service='+service.Id+' '+e.getMessage();
            system.debug('getUserProfileService: Error in load of the Provisioning_Service__c : Provisioning='+upLoaded.Provisioning__c+' Service='+service.Id+' '+e.getMessage());
            throw ex;
        }

        System.debug('Provisioning Service: '+provServ.Id);
        if(input.Action == Generic.Action.Create)
        {
            //We check before if the  User Profile Service has existed in the past for user.
            try
            {
                userProfileService = [select Id,Start_Date__c, End_Date__c, Suspension_End_Date__c,Suspension_Start_Date__c,Suspension_Reason__c,Provisioning_Service__r.Service__r.Name,Provisioning_Service__r.Service__r.Access_Roles__c,User_Profile__r.Provisioning__r.Subscription__c from User_Profile_Service__c
                where Provisioning_Service__c =:provServ.Id and User_Profile__c =: upLoaded.Id
                and RecordTypeId =: Schema.getGlobalDescribe().get('User_Profile_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service').getRecordTypeId()
                limit 1];
            }catch(Exception e)
            {
                ex.ReturnCode=16;
                ex.setMessage('getUserProfileService: Error in load of the User_Profile_Service__c : '+e.getMessage());
                ex.Error='getUserProfileService: Error in load of the User_Profile_Service__c : Provisioning_Service__c='+provServ.Id+' User_Profile__c='+upLoaded.Id+' '+e.getMessage();
            }

            System.debug('Usre Profile Service: '+userProfileService.Id);
            if(userProfileService==null)
            {
                userProfileService= new User_Profile_Service__c();
                userProfileService.Provisioning_Service__c = provServ.Id;
                userProfileService.Name = provServ.Name;
                userProfileService.User_Profile__c = upLoaded.Id;
                userProfileService.Start_Date__c = Date.today();
                userProfileService.RecordTypeId = Schema.getGlobalDescribe().get('User_Profile_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service').getRecordTypeId();
            }
            else
            {
                userProfileService.Start_Date__c = Date.today();
            }
        }
        else
        {
            if(input.Action == Generic.Action.Search)
            {
                try
                {
                    System.debug('User Profile Id : '+upLoaded.Id );
                    System.debug('Provisioning Id: '+provServ.Id);
                    System.debug('Record Type Id: '+Schema.getGlobalDescribe().get('User_Profile_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service').getRecordTypeId());
                    userProfileService = [select Id,Suspension_End_Date__c,End_Date__c,Start_Date__c,Suspension_Start_Date__c,Suspension_Reason__c,Provisioning_Service__r.Service__r.Name,Provisioning_Service__r.Service__r.Access_Roles__c,User_Profile__r.Provisioning__r.Subscription__c from User_Profile_Service__c
                    where Provisioning_Service__c =:provServ.Id and User_Profile__c =: upLoaded.Id
                    and RecordTypeId =: Schema.getGlobalDescribe().get('User_Profile_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service').getRecordTypeId()
                    limit 1];
                }catch(Exception e)
                {
                    ex.ReturnCode=17;
                    ex.setMessage('getUserProfileService: Error in load of the User_Profile_Service__c : '+e.getMessage());
                    ex.Error='getUserProfileService: Error in load of the User_Profile_Service__c : Provisioning_Service__c='+provServ.Id+' User_Profile__c='+upLoaded.Id+' '+e.getMessage();
                    throw ex;
                }
            }
            else
            {
                userProfileService = null;
            }
        }
        return userProfileService;
    }

    global static User_Profile_Service__c getUserProfileServiceForFlash(PackageInput input,String serviceName)
    {
        User_Profile__c upLoaded;
        Service__c service;
        Provisioning_Service__c provServ;
        User_Profile_Service__c userProfileService;
        Generic.StandardException ex=new Generic.StandardException();
        input.UserProfileId =getUserProfileId(input.Login,input.CodeAppli);
        upLoaded=[select up.Id , up.Provisioning__c from User_Profile__c up where Id=:input.UserProfileId];

        try
        {
            if(input.Product == 'FlashSubscription')
            {
                service = [select Id from Service__c where Access_Roles__c=:input.Product and Name=:serviceName limit 1];
            }
            else
            {
                service = [select Id from Service__c where Access_Roles__c=:input.Product limit 1];
            }
        }catch(Exception e)
        {
            ex.ReturnCode=14;
            ex.setMessage('getUserProfileService: Error in load of the Service__c : '+e.getMessage());
            ex.Error='getUserProfileService: Error in load of the Service__c : '+input.Product+' '+e.getMessage();
            throw ex;
        }
        try
        {
            provServ = [select Id,Name from Provisioning_Service__c where Provisioning__c=:upLoaded.Provisioning__c and Service__c=:service.Id limit 1];
        }catch(Exception e)
        {
            ex.ReturnCode=15;
            ex.setMessage('getUserProfileService: Error in load of the Provisioning_Service__c : '+e.getMessage());
            ex.Error='getUserProfileService: Error in load of the Provisioning_Service__c : Provisioning='+upLoaded.Provisioning__c+' Service='+service.Id+' '+e.getMessage();
            system.debug('getUserProfileService: Error in load of the Provisioning_Service__c : Provisioning='+upLoaded.Provisioning__c+' Service='+service.Id+' '+e.getMessage());
            throw ex;
        }

        if(input.Action == Generic.Action.Create)
        {
            //We check before if the  User Profile Service has existed in the past for user.
            try
            {
                userProfileService = [select Id,Suspension_End_Date__c,Suspension_Start_Date__c,Suspension_Reason__c,Provisioning_Service__r.Service__r.Name,Provisioning_Service__r.Service__r.Access_Roles__c from User_Profile_Service__c
                where Provisioning_Service__c =:provServ.Id and User_Profile__c =: upLoaded.Id
                and RecordTypeId =: Schema.getGlobalDescribe().get('User_Profile_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service').getRecordTypeId()
                limit 1];
            }catch(Exception e)
            {
                ex.ReturnCode=16;
                ex.setMessage('getUserProfileService: Error in load of the User_Profile_Service__c : '+e.getMessage());
                ex.Error='getUserProfileService: Error in load of the User_Profile_Service__c : Provisioning_Service__c='+provServ.Id+' User_Profile__c='+upLoaded.Id+' '+e.getMessage();
            }
            if(userProfileService==null)
            {
                userProfileService= new User_Profile_Service__c();
                userProfileService.Provisioning_Service__c = provServ.Id;
                userProfileService.Name = provServ.Name;
                userProfileService.User_Profile__c = upLoaded.Id;
                userProfileService.Start_Date__c = Date.today();
                userProfileService.RecordTypeId = Schema.getGlobalDescribe().get('User_Profile_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service').getRecordTypeId();
                insert userProfileService;
            }
            else
            {
                userProfileService.Start_Date__c = Date.today();
            }
        }
        else
        {
            if(input.Action == Generic.Action.Search)
            {
                try
                {
                    userProfileService = [select Id,Suspension_End_Date__c,Suspension_Start_Date__c,Suspension_Reason__c,Provisioning_Service__r.Service__r.Name,Provisioning_Service__r.Service__r.Access_Roles__c from User_Profile_Service__c
                    where Provisioning_Service__c =:provServ.Id and User_Profile__c =: upLoaded.Id
                    and RecordTypeId =: Schema.getGlobalDescribe().get('User_Profile_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service').getRecordTypeId()
                    limit 1];
                }catch(Exception e)
                {
                    ex.ReturnCode=17;
                    ex.setMessage('getUserProfileService: Error in load of the User_Profile_Service__c : '+e.getMessage());
                    ex.Error='getUserProfileService: Error in load of the User_Profile_Service__c : Provisioning_Service__c='+provServ.Id+' User_Profile__c='+upLoaded.Id+' '+e.getMessage();
                    throw ex;
                }
            }
            else
            {
                userProfileService = null;
            }
        }
        return userProfileService;
    }

    global static Map<Id,User_Profile_Service__c> getUserProfileServices(PackageInput input)
    {
        //Method used for the Flash Transport
        User_Profile__c upLoaded;
        Map<Id,Service__c> services;
        Map<Id,Provisioning_Service__c> provServices;
        Map<Id,User_Profile_Service__c> userProfileServices;
        Generic.StandardException ex=new Generic.StandardException();
        input.UserProfileId =getUserProfileId(input.Login,input.CodeAppli);
        upLoaded=[select up.Id , up.Provisioning__c from User_Profile__c up where Id=:input.UserProfileId];

        try
        {
            services = new Map<ID, Service__c>([select Id from Service__c where Access_Roles__c=:input.Product]);
        }catch(Exception e)
        {
            ex.ReturnCode=14;
            ex.setMessage('getUserProfileService: Error in load of the Service__c : '+e.getMessage());
            ex.Error='getUserProfileService: Error in load of the Service__c : '+input.Product+' '+e.getMessage();
            throw ex;
        }
        try
        {
            provServices = new Map<ID, Provisioning_Service__c>([select Id,Name from Provisioning_Service__c where Provisioning__c=:upLoaded.Provisioning__c and Service__c in :services.keySet()]);
        }catch(Exception e)
        {
            ex.ReturnCode=15;
            ex.setMessage('getUserProfileService: Error in load of the Provisioning_Service__c : '+e.getMessage());
            ex.Error='getUserProfileService: Error in load of the Provisioning_Service__c : '+e.getMessage();
            throw ex;
        }

        if(input.Action == Generic.Action.Create)
        {
            //We check before if the  User Profile Service has existed in the past for user.
            try
            {
                userProfileServices = new Map<ID, User_Profile_Service__c>([select Id,Suspension_End_Date__c,Suspension_Start_Date__c,Suspension_Reason__c,Provisioning_Service__r.Service__r.Name,Provisioning_Service__r.Service__r.Access_Roles__c from User_Profile_Service__c
                where Provisioning_Service__c in :provServices.keySet() and User_Profile__c =: upLoaded.Id
                and RecordTypeId =: Schema.getGlobalDescribe().get('User_Profile_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service').getRecordTypeId()
                ]);
            }catch(Exception e)
            {
                ex.ReturnCode=16;
                ex.setMessage('getUserProfileService: Error in load of the User_Profile_Service__c : '+e.getMessage());
                ex.Error='getUserProfileService: Error in load of the User_Profile_Service__c : '+e.getMessage();
                throw ex;
            }
            if(userProfileServices.size()==0)
            {
                User_Profile_Service__c userProfileService;
                for(Id provServId : provServices.keySet())
                {
                    userProfileService= new User_Profile_Service__c();
                    userProfileService.Provisioning_Service__c = provServId;
                    userProfileService.Name = provServices.get(provServId).Name;
                    userProfileService.User_Profile__c = upLoaded.Id;
                    userProfileService.Start_Date__c = Date.today();
                    userProfileService.RecordTypeId = Schema.getGlobalDescribe().get('User_Profile_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service').getRecordTypeId();
                    userProfileServices.put(userProfileService.id,userProfileService);
                    insert userProfileService;
                }
            }
            else
            {
                for(Id userProfileServiceId : userProfileServices.keySet())
                {
                    userProfileServices.get(userProfileServiceId).Start_Date__c = Date.today();
                }
            }
        }
        else
        {
            if(input.Action == Generic.Action.Search)
            {
                try
                {
                    System.debug('Prov Id: '+provServices.keySet());
                    System.debug('Profile Id: '+upLoaded.Id);
                    System.debug('User Profile Service: '+userProfileServices);
                    Datetime sToday = date.today();
                    userProfileServices = new Map<ID, User_Profile_Service__c>([select Id,Suspension_End_Date__c,Suspension_Start_Date__c,Suspension_Reason__c,Provisioning_Service__r.Service__r.Name,Provisioning_Service__r.Service__r.Access_Roles__c from User_Profile_Service__c
                    where Provisioning_Service__c in :provServices.keySet() and User_Profile__c =: upLoaded.Id
                    and RecordTypeId =: Schema.getGlobalDescribe().get('User_Profile_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service').getRecordTypeId()
                    and (Suspension_Start_Date__c = null
                    OR Suspension_Start_Date__c > TODAY)
                    ]);
                }catch(Exception e)
                {
                    ex.ReturnCode=17;
                    ex.setMessage('getUserProfileService: Error in load of the User_Profile_Service__c : '+e.getMessage());
                    ex.Error='getUserProfileService: Error in load of the User_Profile_Service__c : '+e.getMessage();
                    throw ex;
                }
            }
            else
            {
                userProfileServices = null;
            }
        }
        System.debug('User profile Service'+ userProfileServices);
        return userProfileServices;
    }

    global static Boolean StringNotEmpty(String stringToTest)
    {
        if(stringToTest!=null && stringToTest!='')
        {
            return true;
        }
        return false;
    }

    global static void RemoveRight(String login,String rightCode)
    {
        UserRepositoryParser.UserRepositoryStandardResponse stResponse;
        try
        {
            Dom.XMLNode response = UserRepositoryStub.removeRight(login, rightCode);
            stResponse = UserRepositoryParser.parseStandardResult(response);

            if(stResponse.Code!='0')
                throw new UserRepositoryParser.UserRepositoryParserException('Response Code : '+stResponse.Code+' '+stResponse.Detail);
        }
        catch(Exception ex)
        {
            Generic.StandardException stex=new Generic.StandardException();
            stex.ReturnCode=1001;
            stex.setMessage('Generic RemoveRight fails : '+ex.getMessage());
            stex.Error='Generic RemoveRight fails : '+ex.getMessage();
            system.debug('Generic RemoveRight fails : '+ex.getMessage());
            throw stex;
        }
    }

    global static void AddRight(String login,String rightCode)
    {
        UserRepositoryParser.UserRepositoryStandardResponse stResponse;
        try
        {
            Dom.XMLNode response = UserRepositoryStub.addRight(login, rightCode);
            stResponse = UserRepositoryParser.parseStandardResult(response);

            if(stResponse.Code!='0')
                throw new UserRepositoryParser.UserRepositoryParserException('Response Code : '+stResponse.Code+' '+stResponse.Detail);

        }
        catch(Exception ex)
        {
            Generic.StandardException stex=new Generic.StandardException();
            stex.ReturnCode=1001;
            stex.setMessage('Generic AddRight fails : '+ex.getMessage());
            stex.Error='Generic AddRight fails : '+ex.getMessage();
            system.debug('Generic AddRight fails : '+ex.getMessage());
            throw stex;
        }
    }
    /* =============================================================================================
    // Webservice methods
    ============================================================================================= */
    webservice static ConfigurationParameterOutput GetConfigurationParameter(String key)
    {
        ConfigurationParameterOutput cpo = new ConfigurationParameterOutput();
        try
        {
            Configuration_Parameter__c cp = [SELECT Value__c,Type__c FROM Configuration_Parameter__c WHERE Key__c =:key];
            cpo.Value = cp.Value__c;
            cpo.ParameterType = cp.Type__c;
        }
        catch(Exception ex)
        {
            cpo.ReturnCode=1;
            System.debug('GetConfigurationParameter: Error in load of the Configuration_Parameter__c : '+ex.getMessage()+' for key : '+key);
            cpo.Error='GetConfigurationParameter: Error in load of the Configuration_Parameter__c : '+ex.getMessage()+' for key : '+key;
        }
        return  cpo;
    }

    webservice static UserRepositoryParser.UserRepositoryStandardResponse RemoveRightForUser(String login,String rightCode)
    {
        UserRepositoryParser.UserRepositoryStandardResponse stResponse;
        try
        {
            Dom.XMLNode response = UserRepositoryStub.removeRight(login, rightCode);
            stResponse = UserRepositoryParser.parseStandardResult(response);
        }
        catch(Exception ex)
        {
            stResponse = new UserRepositoryParser.UserRepositoryStandardResponse();
            stResponse.Code = '1001';
            stResponse.Detail = 'Generic RemoveRight fails : '+ex.getMessage();
            system.debug('Generic RemoveRight fails : '+ex.getMessage());
        }
        return stResponse;
    }

    webservice static UserRepositoryParser.UserRepositoryStandardResponse AddRightForUser(String login,String rightCode)
    {
        UserRepositoryParser.UserRepositoryStandardResponse stResponse;
        try
        {
            Dom.XMLNode response = UserRepositoryStub.addRight(login, rightCode);
            stResponse = UserRepositoryParser.parseStandardResult(response);
        }
        catch(Exception ex)
        {
            stResponse = new UserRepositoryParser.UserRepositoryStandardResponse();
            stResponse.Code = '1001';
            stResponse.Detail = 'Generic AddRight fails : '+ex.getMessage();
            system.debug('Generic AddRight fails : '+ex.getMessage());
        }
        return stResponse;
    }

    global static void createNewFee(FeeInput Input){

     //FeeOutput Fee = new  FeeOutput();
        Contact sContact = new Contact();
        User_Profile__c UserProfile = new User_Profile__c();
        Subscription_Line_Item__c SubLiItem = new Subscription_Line_Item__c();
        Subs_Current_Fee__c NewFee = new  Subs_Current_Fee__c();


        SavePoint sp = Database.setSavepoint();
        Database.Saveresult DMSFeeResult;

        System.debug('ContactId:'+Input.ContactId);
        System.debug('CodeAppli:'+Input.CodeAppli);
        System.debug('FeeName:'+Input.FeeName);
        System.debug('SubscriptionLineItem:'+Input.SubLineItem);

        try {
        sContact = [Select Id, AccountId, Account.AccountNumber, Username__c from Contact where Id=: Input.ContactId limit 1];

        }catch(Exception ex){
           Generic.StandardException stex = new Generic.StandardException();
           stex.ReturnCode=1;
           stex.setMessage('Error during the Account search : '+ex.getMessage());
           stex.Error='Error during the Account search : '+ex.getMessage();
           throw stex;
        }

        System.debug('ComplContact:'+sContact.Id);
        System.debug('AccountId:'+sContact.AccountId);

        try {
         /*ComplContract =  [Select Id from Contract where AccountId=:ComplContact.AccountId and Status__c ='Active' and RecordTypeId=:Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName().get('TLR Contract').getRecordTypeId()];*/
        UserProfile =[Select Id, Provisioning__r.Subscription__c, Provisioning__r.Subscription__r.CurrencyIsoCode  from User_Profile__c where Contact__c =:sContact.Id and Provisioning__r.Subscription__r.Access_Kind__c =: input.CodeAppli limit 1];

        }catch(Exception ex){
               Generic.StandardException stex = new Generic.StandardException();
               stex.ReturnCode=2;
               stex.setMessage('Error during thethe UserProfile Search : '+ex.getMessage());
               stex.Error='Error during thethe UserProfile Search : '+ex.getMessage();
               throw stex;
        }



       System.debug('Subscription Id:'+UserProfile.Provisioning__r.Subscription__c);
       System.debug('Subscription Line Item:'+Input.SubLineItem);

       try {

       SubLiItem = [Select Id,  Sales_Price__c  from Subscription_Line_Item__c where  Subscription__r.Id =: UserProfile.Provisioning__r.Subscription__c and  Subscription_Line_Item__c.Name =:Input.SubLineItem limit 1]  ;

        }catch(Exception ex){
           Generic.StandardException stex=new Generic.StandardException();
           stex.ReturnCode=3;
           stex.setMessage('Error during the service name search : '+ex.getMessage());
           stex.Error='Error during the service name search : '+ex.getMessage();
           throw stex;
        }

        System.debug('Subs Line Item:'+SubLiItem.Id);


        try {

        NewFee.Name = Input.FeeName;
        NewFee.Subscription__c = UserProfile.Provisioning__r.Subscription__c;
        NewFee.Subscription_Line_Item__c =SubLiItem.Id;
        NewFee.CurrencyIsoCode = UserProfile.Provisioning__r.Subscription__r.CurrencyIsoCode;
        NewFee.Account__c = sContact.AccountId;
        NewFee.User_Profile__c = UserProfile.Id;

        if (input.StartDate != null){
            NewFee.Start_Date__c = input.StartDate;
        } else {
            NewFee.Start_Date__c = Date.today();
        }

        if (input.EndDate != null){
            NewFee.End_Date__c = input.EndDate;
        }
        DMSFeeResult = Database.insert(NewFee);
        System.debug('Fee Amount'+input.FeeAmount);
        System.debug('Fee Start Date'+input.StartDate);
        System.debug('Fee End Date'+input.EndDate);


        if (input.FeeAmount != null){
            NewFee.Price__c = input.FeeAmount;
            System.debug('Fee Amount'+input.FeeAmount);
            System.debug('Sales Price'+NewFee.Price__c);
        } else {
          NewFee.Price__c = SubLiItem.Sales_Price__c;
        }
        DMSFeeResult = Database.update(NewFee);
        //DMSFeeResult = Database.update(NewFee);


        }catch(Exception ex){
           Generic.StandardException stex = new Generic.StandardException();
           stex.ReturnCode=4;
           stex.setMessage('Error during fee creation : '+ex.getMessage());
           stex.Error='Error during fee creation : '+ex.getMessage();
           Database.rollback(sp);
        }
        System.debug('FeeId: '+DMSFeeResult.getId() );
     }

     global static void UpdateEndDateOfCurrentFee (Id UserProfileId,  String FeeName, Date EndDate)
     {
     	Subs_Current_Fee__c sCurrentFee;
     	SavePoint sp = Database.setSavepoint();
        Database.Saveresult CurrentFeeResult;
     	try
     	{
     	sCurrentFee = [Select Id, End_Date__c from Subs_Current_Fee__c where User_Profile__c =:UserProfileId and Name =:FeeName and  End_Date__c != null];
     	sCurrentFee.End_Date__c = EndDate;

        CurrentFeeResult = Database.update (sCurrentFee);
     	}catch(Exception ex){
           Generic.StandardException stex = new Generic.StandardException();
           stex.ReturnCode=1;
           stex.setMessage('Error durring update the current fee : '+ex.getMessage());
           stex.Error='Error durring update the current fee : '+ex.getMessage();
           Database.rollback(sp);
        }
        System.debug('FeeId: '+CurrentFeeResult.getId() );


     }


	global static Double getProratAmount (Decimal Amount)
	{
		Decimal ProrataAmount;
		Date CurrentDate = Date.today();
		Decimal AmountOfNextMonth = Amount;

		Double NumberDayCurrentMonth = date.daysInMonth(CurrentDate.year() , CurrentDate.month());
		integer DaysBetweenCDateEnMonth = CurrentDate.daysBetween(Date.newInstance(CurrentDate.year(), CurrentDate.month(), date.daysInMonth(CurrentDate.year() , CurrentDate.month())));

		Double Prorata = DaysBetweenCDateEnMonth / NumberDayCurrentMonth;
		Double AmountOfCurrentMonth = Amount *= Prorata;

		ProrataAmount = AmountOfCurrentMonth + AmountOfNextMonth;

		return ProrataAmount;
	}
	
	/** 
	* @author		Andrey Gordienko (andrey_gordienko@epam.com)
	* @date			2013 September 30
	* @description	Create SOQL query for object with field is creatable
	*/
	global static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;    
    }
	
    	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 August 8
	* @description	convert set of strings to plain string, separated by given delimiter
	*/
	global static string getStringFromSet(Set<string> mySet, string delimiter)
	{
		string val = '';
		for(string s : mySet)
			val += ', ' + s;
		val = val.substring(1);
		return val;
	}

}