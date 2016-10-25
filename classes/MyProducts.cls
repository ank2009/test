global public with sharing class MyProducts {
    /* =============================================================================================
    // Input object definition    
    ============================================================================================= */
    global public class AddPackageInput
    { 
        //webservice public String RightTemplate; //Not Used
        //webservice public String RightCode;     //Not Used
        webservice public String Login;
        webservice public String Active;
        webservice public String Product;
        //webservice public String PriceList;   //Not Used
        webservice public String PackName;
        webservice public String ProratePaid;
        webservice public String CodeAppli; 
        webservice public Generic.SubscriptionType SubscriptionType; 
    }
    
    global public class RemovePackageInput
    {
        webservice public String Login;
        //webservice public String RightCode; //Not Used
        webservice public String PackName;
        webservice public String Product;   
        webservice public String CodeAppli;
        webservice public Generic.SubscriptionType SubscriptionType;    
    }
    
    global public class MyProductStandardInput
    {
        webservice public String Login; 
        webservice public String PackName;
        webservice public String Product;  
        webservice public String CodeAppli;
        webservice public Generic.SubscriptionType SubscriptionType; 
    }    
    
    global public class BasicUserInfo
    {
        webservice public String Login;
        webservice public String Country;
        webservice public String AccessKind;
    }
    /* =============================================================================================
    // Output object definition    
    ============================================================================================= */    
    global public class GetProductsResult
    {
        webservice public List<ProductInfo> productList = new List<ProductInfo>();
        webservice public String Error = '';
        webservice public Integer ReturnCode = 0;
        webservice public Integer NumberOfProduct = 0;
    }
    
    global public class ProductInfo
    {
        webservice public String ProductIdentifier;
        webservice public String ProductName;
        webservice public Boolean isAProduct;
        webservice public Boolean isActive;
        webservice public Boolean isCancelled;      
        webservice public Date CancelDate;              
        webservice public Date StartDate;       
    
        /** 
         * This method allows to get a validity of product
         * Y : The product is active this month
         * N : The Product isn't active  
         *  
         */
        webservice public Boolean CurrentMonth;     
        
        /** 
         * This method allows to get the number of hours allows for this package 
         *  
         */
        webservice public Integer PackageDuration;      
        
        /** 
         * This method allows to get the package code
         */
        webservice public Integer PackageCode;      
        
        /** 
         * This method allows to get the connectionType
         */
        webservice public Integer ConnectionType;
    }
    
    /* =============================================================================================
    // Input : CreatePayementActivity 
    ============================================================================================= */
        
    global public class CreatePaymentInput
       {
        webservice public String Login;
        webservice public String CodeAppli;
        webservice public String Amount;
        webservice public String PaymentMode;
        webservice public String TransactionDate;
        webservice public String TransactionId;
        webservice public String Credits;
        webservice public String PaymentCurrency;
       }
       
    
    
    /* =============================================================================================
    // Internals objects definition    
    ============================================================================================= */ 

    /* =============================================================================================
    // Internals methods    
    ============================================================================================= */

    /* =============================================================================================
    // Webservices methods    
    ============================================================================================= */
    webservice static Generic.StandardOutput AddPackage(AddPackageInput input)
    {
        //Add the package (fee) related to the product subscribed + add the right associated

        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();

        /*  Add suspension Start Date
        */
        Date sToday = date.today();  
        Date NewDate = sToday.addYears(1);
        Date SuspensionDate =NewDate.toStartOfMonth(); 

        system.debug('## >>> AddPackage: input :'+input);
        try{
            Generic.PackageInput pInput = new Generic.PackageInput(input.Login,input.PackName,input.Product,input.CodeAppli,Generic.Action.Create); 

            /*User_Profile_Service__c userProfileService = Generic.getUserProfileService(pInput);
            userProfileService.Start_Date__c = Date.today();*/
            
            MAP<Id, User_Profile_Service__c> userProfileServices = Generic.getUserProfileServices(pInput);
            //userProfileService.Start_Date__c = Date.today();
            
            
            for(User_Profile_Service__c ups : userProfileServices.values()) {
            	
               ups.Suspension_Start_Date__c = null;
               ups.Suspension_End_Date__c = null;
               ups.Start_Date__c = 	Date.today();
               ups.Suspension_Reason__c ='';
               
               if(input.Product=='FlashSubscription')
            	{
            	//ups.Suspension_Start_Date__c = date.newinstance (SuspensionDate.Year(),SuspensionDate.month(), date.daysInMonth(SuspensionDate.Year(),SuspensionDate.month()));
            	
            	ups.End_Date__c = date.newinstance (SuspensionDate.Year(),SuspensionDate.month(), date.daysInMonth(SuspensionDate.Year(),SuspensionDate.month()));
            	} else {
                ups.End_Date__c = null;
            	}
            	System.debug('End Date: '+ups.End_Date__c);
            	System.debug('Product Name: '+input.Product);
            	
            	update ups;
               
            }
            
            //For the flash, the user has to wait one year to unsubscribe
            /*if(input.Product=='FlashSubscription')
            {
            	userProfileService.Suspension_Start_Date__c = Date.today().addYears(1);
            }
            else
            {*/
            	//userProfileService.Suspension_Start_Date__c = null;
            //}
            //	userProfileService.End_Date__c = Date.today().addYears(1);
            //userProfileService.Suspension_End_Date__c = null;	
            //userProfileService.Suspension_Reason__c = '';
            
            //We update the userProfile in the FX
            List<Id> userProfileIds = new List<Id>();
    		userProfileIds.add(pInput.UserProfileId);        			
    		ProvisioningMessagesAsync.SendReProvisioning(userProfileIds); 
    		
    		
    		
    		// Retrieve the contact Id 
    		System.Debug('Login'+input.Login);
	        Id ContactId = [Select Id from Contact where Username__c=:input.Login].Id;  
	    	System.Debug('Contact ID'+ContactId);	    	
	    	String subsLineItem = [select Name from Subscription_Line_Item__c where Service__r.Access_Roles__c=:input.Product limit 1].Name;
		    System.debug('Sub Line Item'+subsLineItem);		    
		    
		    // Start date of the new  fee
		    Date sFeeDate =  date.Today().addMonths(1);
		    Date FeeStartDate = sFeeDate.toStartOfMonth();
		    
		   	// Add the new fee	    
		    Generic.FeeInput NewFeeInput = new Generic.FeeInput (ContactId, input.CodeAppli, subsLineItem, subsLineItem, null, FeeStartDate, null); 
		   	Generic.createNewFee(NewFeeInput);
    	

	    		/*Subs_Current_Fee__c newFee = new Subs_Current_Fee__c();
				newFee.User_Profile__c = pInput.UserProfileId;
				newFee.Start_Date__c = Date.today();
				newFee.Subscription__c = userProfileService.User_Profile__r.Provisioning__r.Subscription__c;
	    		newFee.Subscription_Line_Item__c = subsLineItem.Id; 
	    		insert newFee;
            } 
            catch(Exception e)
            {
                Generic.StandardException sex = new Generic.StandardException();
                sex.ReturnCode=2;
                sex.setMessage('AddPackage: Error in creation of the Fee : '+e.getMessage());
                sex.Error='AddPackage: Error in creation of the Fee : '+e.getMessage();
                throw sex;
            } */

        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            Database.rollback(sp);
        }

		              
        system.debug('## >>> AddPackage: output :'+output);
        return output;
    }
    
    webservice static Generic.StandardOutput RemovePackage(RemovePackageInput input)
    {
        //Cancel the package and remove the associated right
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        Date sToday = date.today();  
        Date NewDate = sToday.addMonths(1);
        Date SuspensionDate =NewDate.toStartOfMonth(); 
         
        system.debug('## >>> RemovePackage: input :'+input);
        try{
            Generic.PackageInput pInput = new Generic.PackageInput(input.Login,input.PackName,input.Product,input.CodeAppli,Generic.Action.Search); 

            User_Profile_Service__c userProfileService = Generic.getUserProfileService(pInput);
            //To remove Flash, at least one year has to be past
            
            // A voir avec françois pourquoi ????? 
            //if(input.Product=='FlashSubscription' && (userProfileService.Start_Date__c.addYears(1)<Date.today()))
            if(input.Product=='FlashSubscription')
            {
            	userProfileService.Suspension_Start_Date__c = userProfileService.End_Date__c.AddDays(1);
            	System.debug('Suspension Start Date'+userProfileService.Suspension_Start_Date__c);
            }
            else
            {
            	//userProfileService.Suspension_Start_Date__c = date.newinstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));
        	    userProfileService.Suspension_Start_Date__c = date.newinstance (SuspensionDate.year(),SuspensionDate.month(), SuspensionDate.Day());
                userProfileService.End_Date__c = date.newinstance (SuspensionDate.year(),SuspensionDate.month(), SuspensionDate.Day()); 
        	
        	}
            
            userProfileService.Suspension_Reason__c = 'Managed by MyProducts';
            update userProfileService;
            
            //We update the userProfile in the FX
            /* Already Done by workflow */
 
             
            
            //We update the current fee
            
            //if (input.Product !='FlashSubscription')
            
            try
            {
            	/*
            	Subs_Current_Fee__c currentFee = [select End_Date__c from Subs_Current_Fee__c where Subscription__c=:userProfileService.User_Profile__r.Provisioning__r.Subscription__c and Subs_Current_Fee__c.Subscription_Line_Item__r.Service__r.Access_Roles__c=:input.Product];
            	if(currentFee != null)
            	{
					currentFee.End_Date__c = date.newinstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));
					update currentFee;
            	}
            	*/
            } 
            catch(Exception e)
            {
                Generic.StandardException sex = new Generic.StandardException();
                sex.ReturnCode=2;
                sex.setMessage('RemovePackage: Error in load of the Fee : '+e.getMessage());
                sex.Error='RemovePackage: Error in load of the Fee : '+e.getMessage();
                throw sex;
            } 

        }catch(Generic.StandardException stex){
            output.returnCode = stex.ReturnCode;
            output.error = stex.Error;
            Database.rollback(sp);
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            Database.rollback(sp);
        }
        system.debug('## >>> RemovePackage: output :'+output);
        return output;
    }    
    
    webservice static GetProductsResult GetProducts(BasicUserInfo input)
    {
        GetProductsResult pr = new GetProductsResult();
        String userProfileId;
        List <User_Profile_Service__c> userServiceLinkList;
        system.debug('## >>> GetProducts: input :'+input);
        
        Boolean oneSearchPackage = false;
        ProductInfo piSearch = new ProductInfo();
        ProductInfo pi;
        try
        {
            userProfileId = Generic.getUserProfileId(input.Login,input.AccessKind);
            
            //We check if the user has a package
            try{
            	User_Profile__c up = [select Package_And_Fee__r.Package_Quantity__c,Package_And_Fee__r.Unit__c,Package_And_Fee__r.Name,Package_And_Fee__c from User_Profile__c where Id=:userProfileId];
            	List <Subs_Package_And_Fee_Line_Item__c> subPacAnFeLiItListe=[SELECT Service__r.Access_Roles__c FROM Subs_Package_And_Fee_Line_Item__c where Subs_Package_And_Fee_Line_Item__c.Subs_Package_And_Fee__c=:up.Package_And_Fee__c];

            	//In this first MyProduct version we send only the packagage for the FreightSearch Access 
            	for(Subs_Package_And_Fee_Line_Item__c subPacAnFeLiIt : subPacAnFeLiItListe)
            	{
        			if(subPacAnFeLiIt.Service__r.Access_Roles__c=='FreightSearch')
        			{
        				oneSearchPackage=true;	            		 
	            		//piSearch.ProductIdentifier = subPacAnFeLiIt.Service__r.Access_Roles__c;
	            		piSearch.ProductName = subPacAnFeLiIt.Service__r.Access_Roles__c;
	            		//pi.PackageCode = up.Package_And_Fee__r.Name;
	            		piSearch.isAProduct = false;
	            		//pi.ProductIdentifier  = up.Package_And_Fee__c
	            		if(Generic.StringNotEmpty(up.Package_And_Fee__r.Unit__c))
	            		{
	            			Integer packageDuration = 0;
	            			//At the front level, the value has to be in seconds
	            			if(up.Package_And_Fee__r.Unit__c == 'Hours')
	            			{
	            				packageDuration = Integer.valueOf(up.Package_And_Fee__r.Package_Quantity__c) * 3600;
	            			}
	            			else
	            			{            			
		            			if(up.Package_And_Fee__r.Unit__c == 'Minute')
		            			{
		            				packageDuration = Integer.valueOf(up.Package_And_Fee__r.Package_Quantity__c) * 60;
		            			}
	            				else
	            				{
	            					packageDuration = Integer.valueOf(up.Package_And_Fee__r.Package_Quantity__c);
	            				}	
	            			}	
	            			piSearch.PackageDuration = packageDuration;
	            		}
        			}
            	}
            }
            catch(Exception e)
            {
                Generic.StandardException sex = new Generic.StandardException();
                sex.ReturnCode=3;
                sex.setMessage('GetProductsResult: Error in load of the User_Profile__c : '+e.getMessage());
                sex.Error='GetProductsResult: Error in load of the User_Profile__c : User Profile Id: '+userProfileId+' '+e.getMessage();
                throw sex;
            }      
            
            try
            {
                userServiceLinkList = [select Id,Suspension_Start_Date__c,Provisioning_Service__r.Service__r.Access_Roles__c,End_Date__c,Provisioning_Status__c,Service__c,Name,Start_Date__c from User_Profile_Service__c 
                    where User_Profile__c =: userProfileId
                    and RecordTypeId =: Schema.getGlobalDescribe().get('User_Profile_Service__c').getDescribe().getRecordTypeInfosByName().get('TLR User Profile Service').getRecordTypeId()];
            }catch(Exception e)
            {
                Generic.StandardException sex = new Generic.StandardException();
                sex.ReturnCode=2;
                sex.setMessage('GetProductsResult: Error in load of the User_Profile_Service__c : '+e.getMessage());
                sex.Error='GetProductsResult: Error in load of the User_Profile_Service__c : Number of reccord: '+userServiceLinkList.size()+' User Profile Id: '+userProfileId+' '+e.getMessage();
                throw sex;
            }           
            for(User_Profile_Service__c userServiceLink : userServiceLinkList)
            {
            	if(userServiceLink.Suspension_Start_Date__c==null || userServiceLink.Suspension_Start_Date__c>Date.today())
            	{
	                pi = new ProductInfo();
	                if(oneSearchPackage && userServiceLink.Provisioning_Service__r.Service__r.Access_Roles__c == 'FreightSearch')
	                {
	                	pi = piSearch;
	                }      
	                pi.ProductName = userServiceLink.Provisioning_Service__r.Service__r.Access_Roles__c;
	                //pi.ProductIdentifier = userServiceLink.Provisioning_Service__r.Service__r.Access_Roles__c;       
	                pi.CancelDate = userServiceLink.Suspension_Start_Date__c;
	                
					//We check if the product have been subscribed during the current month
					//TODO:We have to calculate it on the fee
	                pi.CurrentMonth = (date.newinstance(Date.today().year(), Date.today().month(),1).isSameDay(date.newinstance(userServiceLink.Start_Date__c.year(), userServiceLink.Start_Date__c.month(),1)))?true:false;
	                /*pi.isActive = 
	                (
	                	(userServiceLink.Provisioning_Service__r.Service__r.Access_Roles__c=='FlashSubscription')
	                	||
	                	(userServiceLink.Suspension_Start_Date__c==null)
	                	||
	                	(
	                		(userServiceLink.Suspension_Start_Date__c!=null)
	                		&&
	               			(userServiceLink.Suspension_Start_Date__c>Date.today())
	               			&&
	               			(userServiceLink.Suspension_Start_Date__c.month()!=Date.today().month())
	                	)
	                )?true:false;*/
	                
	                pi.isActive = 
	                (
	                	(userServiceLink.Provisioning_Service__r.Service__r.Access_Roles__c=='FlashSubscription')
	                	||
	                	(userServiceLink.Suspension_Start_Date__c==null)
	    
	                )?true:false;
	                
	                pi.isAProduct = true;
	                if(userServiceLink.Provisioning_Service__r.Service__r.Access_Roles__c=='FlashSubscription' && userServiceLink.Suspension_Start_Date__c!=null)
	                {
	                	pi.isCancelled = true;
	                }
					else
	                {
	                	pi.isCancelled = false;
	                }
	                //pi.ProductName = userServiceLink.Name;
	                pi.StartDate =  userServiceLink.Start_Date__c;
	                pi.CancelDate = userServiceLink.End_Date__c;
	                //pi.=userServiceLink.End_Date__c;
	                if(Generic.StringNotEmpty(pi.ProductName))
	                	pr.productList.add(pi);    
	                
	                system.debug('## >>> GetProducts: pi :'+pi); 
            	}
            }
            pr.NumberOfProduct = pr.productList.size();
           
        }catch(Generic.StandardException stex){
            pr.ReturnCode = stex.ReturnCode;
            pr.Error = stex.Error;
        }catch(Exception ex){
            pr.ReturnCode = 1;
            pr.Error = 'Number of reccord: '+userServiceLinkList.size()+' Number of reccord seen:'+pr.NumberOfProduct+' User Profile Id: '+userProfileId+' '+ ex.getMessage();
        }           
        system.debug('## >>> GetProducts: pr :'+pr);
        return pr;
    }

    webservice static Generic.StandardOutput CancelCancellation(MyProductStandardInput input)
    {
        //Subscribe to Teleroute plus (fee + right creation)
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        try{
            //TODO
            Generic.PackageInput pInput = new Generic.PackageInput(input.Login,input.PackName,input.Product,input.CodeAppli,Generic.Action.Search); 

            User_Profile_Service__c userProfileService = Generic.getUserProfileService(pInput);
            userProfileService.Suspension_Start_Date__c = null;
            userProfileService.Suspension_Reason__c = '';
            update userProfileService;
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            Database.rollback(sp);
        }
        return output;
    }     
    /*
    webservice static Generic.StandardOutput CancelSubscription(MyProductStandardInput input)
    {
        //Subscribe to Teleroute plus (fee + right creation)
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        try{
            //TODO
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.Message();
            Database.rollback(sp);
        }
        return output;
    }   
       */
           /*
    webservice static Generic.StandardOutput Subscribe(MyProductStandardInput input)
    {
        //Subscribe to Teleroute plus (fee + right creation)
        //Subscribe to Teleroute Flash (fee + right creation + email)1
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        try{
            //TODO
        }catch(Exception ex){
            output.ReturnCode = 1;
            output.Error = ex.getMessage();
            Database.rollback(sp);
        }
        return output;
    }   
    
    webservice static Generic.StandardOutput EndSubscribe(MyProductStandardInput input)
    {
        //Unsubscribe to Teleroute plus (fee cancellation + right deletion)
        //Unsubscribe to Teleroute Flash (fee cancellation + email)
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        try{
            //TODO
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            Database.rollback(sp);
        }
        return output;
    }  
    */
    
     
    global public class ReadCompanyInput
    {       
        webservice public String ContactLogin;     
    }
    
    global public class ReadCompanyOutput
    {   
    	webservice public Integer ReturnCode=0;
        webservice public String Error='';    
        webservice public String CompanyName;
        //webservice public String StreetAddress;
        webservice public String StreetNumber;
        webservice public String AddressLine1='';
        webservice public String AddressLine2='';
        webservice public String AddressLine3='';
        webservice public String Zipcode;
        webservice public String City;
        webservice public String Country;
        webservice public String VAT;
        webservice public String PhoneNumber;
        webservice public String FaxNumber;
        webservice public String EmailAddress;
		webservice public String SiretNumber;
        webservice public String PaymentMode ='';//(CC / PP / DD / IPLUS)
        webservice public String BankName='';
        webservice public String BankNumber='';
        webservice public String IBAN='';
        webservice public String BIC_Code='';
        webservice public String BankAddress='';
        webservice public String BankPostCode='';
        webservice public String BankCity='';
        webservice public String BankCountry='';
        //webservice public String DKV_CardNumber;
        //webservice public String DKV_Validity;         
        webservice public datetime TransactionDate;
        webservice public String TransactionId='';       
    }
    global public class ReadProfileContactOutput
    {   
    	webservice public Integer ReturnCode=0;
        webservice public String Error;    
        webservice public String LastName;
        webservice public String FirstName;
        webservice public String Gender;
        webservice public String JobTitle;
        webservice public String ContactPhone;
        webservice public String ContactFax;
        webservice public String ContactMobile;
        webservice public String ContactEmail;
        webservice public String LanguageCode;   
    }
    
    global public class getProrataOutput
    {   
    	webservice public Integer ReturnCode=0;
        webservice public String Error;    
        webservice public Integer Prorata; 
    }
    
    private static Integer getMaxDaysMonth (Date InputDate){
    	Integer MOutput;
    	Integer Month = InputDate.month();
    	Integer Year = InputDate.year();   
    	//Month = Month+1;
    	//Date EndMonth = date.newInstance(Year, Month, 0);
        MOutput = date.daysInMonth(Year, Month);
    	return MOutput;
    }
    
    
    webservice static ReadCompanyOutput ReadCompany (ReadCompanyInput Input){
    	
    	
    	ReadCompanyOutput sOutput = new ReadCompanyOutput();
    	//Account CompanyInfo = New Account();
        
    	try {
    	System.debug('Contact Login: '+ input.ContactLogin);
    	Contact ContactInfo =[Select Id, AccountId from Contact where Username__c=:Input.ContactLogin limit 1];
    	
    	if (ContactInfo.Id != null || ContactInfo.Id !='') {
    	Account CompanyInfo = [Select Id, Name, BillingCountry, BillingState, BillingStreet, BillingCity, BillingPostalCode, Email__c, Fax, Phone, SIRET__c, VAT__c, Iban_Number__c,  BIC_Code__c, Bank_Name__c, Bank_Street_Address__c, Bank_Postal_Code__c, Bank_City__c, Bank_Country__c from Account where Id=:ContactInfo.AccountId]; 
	    System.debug('Company Id:'+CompanyInfo.Id);
	    //if (CompanyInfo.Id !=null && CompanyInfo.Id !='') {
	    	
	    	sOutput.CompanyName =CompanyInfo.Name;
	    	System.debug('CompanyName :'+sOutput.CompanyName);
	    	sOutput.Country = CompanyInfo.BillingCountry;
	    	System.debug('Country :'+sOutput.Country);
	    	sOutput.City=CompanyInfo.BillingCity;
	    	System.debug('City :'+sOutput.City);
	    	//sOutput.StreetAddress = CompanyInfo.BillingStreet;
	        sOutput.Zipcode = CompanyInfo.BillingPostalCode;
	        System.debug('Zip Code :'+sOutput.Zipcode);
	        List<String> sBillingStreet = new List<String>();
            sBillingStreet = CompanyInfo.BillingStreet.split('\n');
            System.debug('Billing Street :'+CompanyInfo.BillingStreet);
                System.debug('## street line size : '+sBillingStreet.size());
                sOutput.StreetNumber = sBillingStreet[0];
                if(sBillingStreet.size()>1)
                    sOutput.AddressLine1 = sBillingStreet[1];
                if(sBillingStreet.size()>2)
                    sOutput.AddressLine2 = sBillingStreet[2];   
                if(sBillingStreet.size()>3)
                    sOutput.AddressLine3 = sOutput.AddressLine3+' '+sBillingStreet[3];    
	        if (CompanyInfo.Email__c != null){
	        sOutput.EmailAddress = CompanyInfo.Email__c;
	        } else {
	        sOutput.EmailAddress ='';	
	        }
	        System.debug('Email Address:'+sOutput.EmailAddress);
	        if(CompanyInfo.Fax != null){
	        sOutput.FaxNumber = CompanyInfo.Fax;
	        } else {
	        sOutput.FaxNumber ='';	
	        }
	        System.debug('Fax Number:'+sOutput.FaxNumber);
	        if(CompanyInfo.Phone!=null){
	        sOutput.PhoneNumber =CompanyInfo.Phone;	
	        }else {
	        sOutput.PhoneNumber = '';	
	        }
	        System.debug('Phone Number:'+sOutput.PhoneNumber);
	        if(CompanyInfo.SIRET__c != null){
	        sOutput.SiretNumber = CompanyInfo.SIRET__c;
	        }else {
	        sOutput.SiretNumber ='';	
	        }
	        System.debug('Siret Number:'+sOutput.SiretNumber);
	        if(CompanyInfo.VAT__c !=null){
	        sOutput.VAT = CompanyInfo.VAT__c;
	        }else {
	        sOutput.VAT ='';	
	        }
	        System.debug('VAT:'+sOutput.VAT);
            /* 
            Retrieve info from financial transaction
            */
	        sOutput.IBAN = CompanyInfo.Iban_Number__c; 	
	        sOutput.BIC_Code = CompanyInfo.BIC_Code__c;
	        //sOutput.BankNumber = CompanyInfo.Iban_Number__c.substring(14,25);
	        sOutput.BankName = CompanyInfo.Bank_Name__c;
	        sOutput.BankAddress= CompanyInfo.Bank_Street_Address__c;
            sOutput.BankPostCode = CompanyInfo.Bank_Postal_Code__c;
            sOutput.BankCity = CompanyInfo.Bank_City__c;
            sOutput.BankCountry = CompanyInfo.Bank_Country__c;   
    		} else {
    		sOutput.ReturnCode=2;
	    	sOutput.Error ='Contact not found';	
    		} 
        
    	} catch(Exception ex){
            sOutput.ReturnCode = 2;
            sOutput.Error = ex.getMessage();
        }
        System.debug('Result: '+sOutput);
        return sOutput;
 
    }
    
    webservice static ReadProfileContactOutput ReadProfile (String ContactLogin){
    	ReadProfileContactOutput RpOutput = new  ReadProfileContactOutput();
    	
    	try {
    	Contact ContactInfo =[Select Id, FirstName, LastName, Gender__c, Phone, MobilePhone, Fax, Email, Language__c, Job_Title__c from Contact where Username__c =:ContactLogin];	
        
        if (ContactInfo.Id != null && ContactInfo.Id !='') {
    	RpOutput.FirstName = ContactInfo.FirstName;
    	RpOutput.LastName = ContactInfo.LastName;
    	RpOutput.Gender = ContactInfo.Gender__c;
    	RpOutput.JobTitle = ContactInfo.Job_Title__c;
    	RpOutput.ContactEmail = ContactInfo.Email;
    	RpOutput.ContactFax = ContactInfo.Fax;
    	RpOutput.ContactMobile = ContactInfo.MobilePhone;
    	RpOutput.ContactPhone = ContactInfo.Phone;
    	RpOutput.LanguageCode = Language_Code__c.getValues(ContactInfo.Language__c).Name;
        } else {
        RpOutput.ReturnCode = 1;
        RpOutput.Error ='No Contact found';        		
        	}
    	}catch(Exception ex){ 
            RpOutput.ReturnCode = 2;
            RpOutput.Error ='ERROR !!!'+ ex.getMessage();
        }
    	return RpOutput;
    }
    
    
    webservice static getProrataOutput ProrataCalculation (String PackName){
    
     	getProrataOutput PcOutput= new getProrataOutput();
    	
    	try {
     	
     	PcOutput.Prorata =1;
     	
     	}catch(Exception ex){ 
            PcOutput.ReturnCode = 41;
            PcOutput.Error ='ERROR !!!'+ ex.getMessage();
           
     	}
     
     	return PcOutput;
    }

    webservice static Generic.StandardOutput CreatePaymentActivity(CreatePaymentInput input)
    {                               

        System.debug('CreatePaymentInput'+input);
  
        Generic.StandardOutput sOutput = new Generic.StandardOutput();
        FinancialTransaction__c fTransaction = new FinancialTransaction__c(); 
        
        try
        {    

            Id contactId   = [SELECT Id FROM Contact WHERE Username__c = :input.Login].Id;
            System.debug('Contact Id: '+contactId);
            
            Id userProfId = Generic.getUserProfileId(input.Login, input.CodeAppli);                       
            System.debug('User Profile Id: '+userProfId);
            
            Id contractId = [SELECT Provisioning__r.Contract__c FROM User_Profile__c WHERE Id = :userProfId].Provisioning__r.Contract__c;
            System.debug('Contract Id: '+contractId);
            
            if(Generic.StringNotEmpty(contractId))
                fTransaction.Contract__c = contractId;
            fTransaction.Contact__c = contactId;
            fTransaction.TransactionId__c = input.TransactionId;
            fTransaction.TransactionDate__c = Date.today();
            if( input.Credits != null && input.Credits !='')            
                fTransaction.Credits__c = Integer.valueOf(input.Credits);
            fTransaction.TransactionAmount__c = Decimal.valueOf(input.Amount);
            
            if(input.PaymentMode == 'CC'){
            fTransaction.PaymentMode__c = 'Credit Card';	
            } else if (input.PaymentMode =='DD'){
            fTransaction.PaymentMode__c = 'Direct Debit';
            } else if (input.PaymentMode =='DKV'){ 
            fTransaction.PaymentMode__c = 'DKV';	
            } else if (input.PaymentMode =='IPLUS'){
            fTransaction.PaymentMode__c = 'Internet Plus';	
            } else if (input.PaymentMode =='PP'){
            fTransaction.PaymentMode__c = 'Paypal';	
            }  
            insert fTransaction;        
        }
		catch(Exception ex){
            sOutput.ReturnCode = 1;
            sOutput.Error = 'Error during creation a payement transaction';
        }
        return sOutput;   
        
    }
    
    
}