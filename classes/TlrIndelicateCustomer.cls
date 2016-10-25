global public with sharing class TlrIndelicateCustomer 
{   
    global public class InitializeCaseInput
    {       
        webservice public String ContactLogin;
        webservice public String CodeAppli;
        webservice public String FreeDMS;
        webservice public String PosterContactLastName;
        webservice public String eConfirmNumber;
        webservice public Double TransactionAmount;
        webservice public String PosterCompanyName;
        webservice public String PosterAddress;
        webservice public String PosterZipCode;
        webservice public String PosterCity;
        webservice public String PosterContactLogin;
        webservice public String PosterCountry;
        webservice public String PosterVATnumber;
        webservice public String PosterContactFirstName;
        webservice public String DefaulterTlrNumber;
        webservice public String OfferNumber;
        webservice public String DepartureCountry;
        webservice public String DepartureCity;
        webservice public String ArrivalCountry;
        webservice public String ArrivalCity;
        //webservice public String AdditionalComment;       
    }
    
    global public class SetCaseInformationInput
    {
        webservice public Id CaseId;
        webservice public String ComplainerLogin;
        webservice public String ComplainerCity;
        webservice public String ComplainerCountry;
        webservice public String ComplainerCompanyName;
        webservice public String ComplainerEmailAddress;
        webservice public String ComplainerPhoneNumber;
        webservice public String ComplainerTitle;
        webservice public String ComplainerGender;
        webservice public String ComplainerPrefix;
        webservice public String ComplainerFirstName;
        webservice public String ComplainerLastName;
        webservice public String ComplainerLang;  
        webservice public String IsNewContactComplainer;
        webservice public String IsNewAccountDefaulter;        
        webservice public String IsNewContactDefaulter;
        webservice public String DefaulterSiret;
        webservice public String DefaulterStreetNumber;
        webservice public String DefaulterAddress1;
        webservice public String DefaulterAddress2;
        webservice public String DefaulterAddress3;
        webservice public String DefaulterCity;
        webservice public String DefaulterZipCode;
        webservice public String DefaulterCompanyName;
        webservice public String DefaulterCountry;
        webservice public String DefaulterCRMNumber;
        webservice public String DefaulterFirstName;
        webservice public String DefaulterGender;
        webservice public String DefaulterLang;
        webservice public String DefaulterLastName;
        webservice public String DefaulterPrefix;
        webservice public String DefaulterProvince;     
        webservice public String DefaulterTitle;
        webservice public String DefaulterTLRNumber;
        webservice public Id DefaulterUserID;
        webservice public String DefaulterVATNumber;
        //webservice public String CodeAppli;
        webservice public String FromCity;
        webservice public String FromCountry;
        webservice public String ToCity;
        webservice public String ToCounty;
        webservice public Date LoadingDate;
        webservice public String CMRNumber;
        webservice public Date DeliveryDate;
        webservice public String InvoiceNumber;
        webservice public Date InvoiceDate;
        webservice public Double InvoiceAmount;
        webservice public String FreightOfferNumber;
        webservice public String IsInvoiceInAccordance;
        webservice public String IsExtraCostAccepted;
        webservice public String IsTransportExecuted;
        webservice public String IsGoodCondition;
        webservice public String PaymentTerm;
        webservice public String IsPaymentTermConfirmed;
        webservice public String IsReminder;
        webservice public Double ReminderAmount;
        webservice public String IsRegisteredByPost;
        webservice public String IsContactedByPhone;
        webservice public String IsMailUndelivered;
        webservice public String DefaulterContactLogin;
        webservice public String InvoiceCurrency;
        webservice public String Remark;
        webservice public String withWhom;
        webservice public String IsCMRSigned;
        webservice public Integer RegisteredReminders;
        //webservice public String IsAccordanceAgreement;       
    }
    /* =============================================================================================
    // Output object definition    
    ============================================================================================= */
    global public class InitializeCaseOutput
    {       
        webservice public Integer ReturnCode =0;
        webservice public String Error;
        webservice public Id CaseId;
    }
    
    global public class FormSubmittedInput
    {       
        webservice public Id CaseId;
    }
    
    global public class FormSubmittedOutput
    {   
        webservice public Integer ReturnCode =0;    
        webservice public String Error;
        webservice public String Submitted;
    }
    
    
    global public class GetCaseInformationOutput
    { 
        webservice public Integer ReturnCode=0;
        webservice public String Error;
        webservice public String ComplainerCity;
        webservice public String ComplainerCompanyName;
        webservice public String ComplainerCountry;
        webservice public String DefaulterSiret;
        webservice public String ComplainerFirstName;
        webservice public String ComplainerGender;
        webservice public String ComplainerContactLogin;
        webservice public String ComplainerLang;
        webservice public String ComplainerLastName;
        webservice public String ComplainerLogin;
        webservice public String ComplainerEmailAddress;
        webservice public String ComplainerPrefix;
        webservice public String ComplainerTitle;
        webservice public String DefaulterAddress1;
        webservice public String DefaulterAddress2;
        webservice public String DefaulterAddress3;
        webservice public String DefaulterCity;
        webservice public String DefaulterCompanyName;
        webservice public String DefaulterCountry;
        webservice public String DefaulterCRMNumber;
        webservice public String DefaulterFirstName;
        webservice public String DefaulterGender;
        webservice public String DefaulterLang;
        webservice public String DefaulterLastName;
        webservice public String DefaulterPrefix;
        webservice public String DefaulterProvince;
        webservice public String ComplainerPhoneNumber;
        webservice public String DefaulterStreetNumber;
        webservice public String DefaulterTitle;
        webservice public String DefaulterTLRNumber;
        webservice public Id DefaulterUserID;
        webservice public String DefaulterVATNumber;
        webservice public String DefaulterZipCode;
        webservice public String DefaulterSiretNumber;
        webservice public String IsNewAccountDefaulter;
        webservice public String IsNewContactComplainer;
        webservice public String IsNewContactDefaulter;
        webservice public String eConfirmNumber;
        webservice public String TransactionAmount;
        webservice public String PosterCompanyName;
        webservice public String PosterCity;
        webservice public String PosterContactFirstName;
        webservice public String PosterContactLastName;
        webservice public String OfferNumber;
        webservice public String DepartureCountry;
        webservice public String DepartureCity;
        webservice public String ArrivalCountry;
        webservice public String ArrivalCity;
        webservice public String CMRNumber;
        webservice public Date DeliveryDate;
        webservice public String InvoiceNumber;
        webservice public Date InvoiceDate;
        webservice public Double InvoiceAmount;
        webservice public String FreightOfferNumber;
        webservice public String DefaulterContactLogin;
        //webservice public String IsAccordanceAgreement;
    }    
    
    global private class FeeInput {  
       webservice public Id ComplainerContactId;
       webservice public String CodeAppli;
       webservice public String FeeName;
       webservice public String SubLineItem;
       webservice public Id CaseId;
       global public FeeInput(Id ComplainerContactId, String CodeAppli, String FeeName, String SubLineItem, Id CaseId)
        {
            this.ComplainerContactId = ComplainerContactId;
            this.CodeAppli = CodeAppli;
            this.FeeName= FeeName;
            this.SubLineItem = SubLineItem;
            this.CaseId = CaseId;
        }
    }
    
    public static Case[] findCaseEconfirm(String EconfirmNumber){
        
        Case [] CEconfirm =[Select Id, Form_Status__c, Status   from Case where eConfirm_Number__c=: EconfirmNumber];
        return CEconfirm; 
    }

    /* =============================================================================================
    // Internals methods    
    ============================================================================================= */
    
    private class DMSException extends Exception {

    }
    
   
     
     private static void createNewFee(FeeInput Input){
     
     
       
     //FeeOutput Fee = new  FeeOutput();
        Contact ComplContact = new Contact();
        Subscription_Line_Item__c SubLiItem = new Subscription_Line_Item__c();
        Subs_Current_Fee__c NewFee = new  Subs_Current_Fee__c();
        User_Profile__c UserProfile = new User_Profile__c(); 
        
        if(input.CodeAppli =='WEB3')
        input.CodeAppli ='WEB3N';
     
        SavePoint sp = Database.setSavepoint();
        Database.Saveresult DMSFeeResult;
        
        System.debug('ContactId:'+Input.ComplainerContactId);
        System.debug('CodeAppli:'+Input.CodeAppli);
        System.debug('FeeName:'+Input.FeeName);
        System.debug('SubscriptionLineItem:'+Input.SubLineItem);

        try {
        ComplContact = [Select Id, AccountId, Account.AccountNumber, Username__c from Contact where Id=: Input.ComplainerContactId limit 1];    
          
        }catch(Exception ex){
           Generic.StandardException stex = new Generic.StandardException();     
           stex.ReturnCode=1;
           stex.Error='Error during the Account search : '+ex.getMessage();
           throw stex;
        }     
	      
	      System.debug('ComplContact:'+ComplContact.Id);
	      System.debug('AccountId:'+ComplContact.AccountId);
	
	    try {   
	     /*ComplContract =  [Select Id from Contract where AccountId=:ComplContact.AccountId and Status__c ='Active' and RecordTypeId=:Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName().get('TLR Contract').getRecordTypeId()];*/         
	    UserProfile =[Select Id, Provisioning__r.Subscription__c, Provisioning__r.Subscription__r.CurrencyIsoCode  from User_Profile__c where Contact__c =:ComplContact.Id and Provisioning__r.Subscription__r.Access_Kind__c =: input.CodeAppli limit 1];   
	     
	    }catch(Exception ex){
	           Generic.StandardException stex = new Generic.StandardException();
	           stex.ReturnCode=2;
	           stex.Error='Error during thethe UserProfile Search : '+ex.getMessage();
	           throw stex;
	    }       
       
        System.debug('User Profile ID and  Subscription Id:'+UserProfile.Provisioning__r.Subscription__c);
         
        try {  
       
        SubLiItem = [Select Id from Subscription_Line_Item__c where Subscription__c =: UserProfile.Provisioning__r.Subscription__c and  Service__r.Name =:Input.SubLineItem limit 1]  ; 
        
        }catch(Exception ex){
           Generic.StandardException stex=new Generic.StandardException();
           stex.ReturnCode=3;
           stex.Error='Error during the service name search : '+ex.getMessage();
           throw stex;
        }           
        
        System.debug('Subs Line Item:'+SubLiItem.Id);
        
        try {

        NewFee.Name = Input.FeeName;
        NewFee.Account__c = ComplContact.AccountId;
        NewFee.Subscription__c = UserProfile.Provisioning__r.Subscription__c;
        NewFee.Subscription_Line_Item__c =SubLiItem.Id;
        NewFee.User_Profile__c = UserProfile.Id;
        NewFee.CurrencyIsoCode = UserProfile.Provisioning__r.Subscription__r.CurrencyIsoCode;
        NewFee.Start_Date__c = Date.today();
        NewFee.End_Date__c = Date.today();
        //NewFee.Notes__c = 'Case Number: '+input.CaseNumber;              
        NewFee.Case__c =input.CaseId;
        DMSFeeResult = Database.insert(NewFee);     
        
        }catch(Exception ex){
           Generic.StandardException stex = new Generic.StandardException();
           stex.ReturnCode=4;
           stex.Error='Error during fee creation : '+ex.getMessage();
           Database.rollback(sp);
        }
        System.debug('FeeId: '+DMSFeeResult.getId() );
        }  
    
    /* =============================================================================================
    // Webservices methods    
    ============================================================================================= */
    webservice static InitializeCaseOutput InitializeCase(InitializeCaseInput input){
        /*
        Migrate from free basic to others   
        */
        
        InitializeCaseOutput icOutput = new InitializeCaseOutput();
        
        System.Debug('Init Case Input'+input); 
        String ErrorMessage='';
        Integer CodeError=0;
        String Comment='';
        Boolean CreateFee=true;
        
        /* Create savepoint to be able to roll back to        
        */
        SavePoint sp = Database.setSavepoint();
        /* Create result container
        */
        Database.Upsertresult DMSResult; 
       
        
        /* 
        Init a DMS Case
        */
        Case DMSCase = new Case();
        Case NewDMSCase = new Case();
        Contact ComplContact = new Contact();
        String ComplAccount;
        String NormalDMSCase;
        
        
	  try {
	   
	     try {
		       ComplContact =[Select Id, Username__c, AccountId From Contact where Username__c=:input.ContactLogin]; 
		       ComplAccount =ComplContact.AccountId;
	            
	                          
	         	}catch (Exception ex){
	            Generic.StandardException stex=new Generic.StandardException();
	            stex.ReturnCode=1;
	            stex.setMessage('Error during contact search: '+ex.getMessage());
	            stex.Error='Error during contact search: '+ex.getMessage();
	            throw stex;
		     	} 
		     
		     /*Check if the case has an econfirm number.
		     */
			 	if(Input.eConfirmNumber !=null && Input.eConfirmNumber.trim().length()>0 ){
		         	input.FreeDMS='Y';
		        	CreateFee = false;
		         	}
		    
		     /*Check the case is a free DMS.
		     */	
		     	if(input.FreeDMS=='Y'&& Input.eConfirmNumber != null && Input.eConfirmNumber.trim().length() > 0){
		         	NewDMSCase.Additional_Comments__c='DMS Free Case';          
		         	} 
          
              
	        /*
	        Check if EConfirm Number is  not empty
	        */
            
            	if (input.eConfirmNumber !=null && input.eConfirmNumber.trim().length() > 0){
	            /* 
	            Serach if a case  is already created with the following Econfirm number
	            */
		            CreateFee = false; 
		            Case [] FoundCaseEconfirm = findCaseEconfirm(input.eConfirmNumber);
            
		            if  (FoundCaseEconfirm.size() > 0){
		                NormalDMSCase='N';
		                System.debug('Normal DMS Case'+NormalDMSCase);
		                for (Case CaseEco: FoundCaseEconfirm){
		                if(CaseEco.Form_Status__c =='Initialized'){ 
		                   	try {
		                    NewDMSCase =[select Id from Case where Id=:CaseEco.Id limit 1];
		                    
		                    }catch (Exception ex){
				            Generic.StandardException stex=new Generic.StandardException();
				            stex.ReturnCode=1;
				            stex.setMessage('Error during case selection: '+ex.getMessage());
				            stex.Error='Error during the case selection: '+ex.getMessage();
				            throw stex;
		                    }
		                	CreateFee=false;               
		                }
		                if(CaseEco.Form_Status__c !='Initialized'){
		                icOutput.ReturnCode =100;   
		                icOutput.Error='A case has already been submitted with this eConfirm, Case Id='+CaseEco.Id;  
		                return icOutput;
		                System.debug('iCOutput'+icOutput);
		                }
		              }
		            } else {
                     
			            /*
			            Create new case
			            */  
			            NewDMSCase.eConfirm_Number__c=input.eConfirmNumber;
			            NewDMSCase.Freight_Offer_Number__c=input.OfferNumber;
			            NewDMSCase.From_City__c=input.DepartureCity;
			            if (input.DepartureCountry !='' && input.DepartureCountry.trim().length() > 0){
			            String DepCountryName =[Select Name from pw_cc__CountryObject__c where IRU_Country_Code__c =:input.DepartureCountry limit 1].Name;   
			            NewDMSCase.From_Country__c=DepCountryName;
			            }
			            NewDMSCase.To_City__c=input.ArrivalCity;
			            if (input.ArrivalCountry !='' && input.ArrivalCountry.trim().length() > 0){
			            String ArriCountryName =[Select Name from pw_cc__CountryObject__c where IRU_Country_Code__c =:input.ArrivalCountry limit 1].Name;    
			            NewDMSCase.To_Country__c=ArriCountryName;
			            }
			            NewDMSCase.Invoice_Amount__c=input.TransactionAmount;  
                 		}
             		} else{
		             NormalDMSCase ='Y';
		             System.debug('Normal DMS Case'+NormalDMSCase);     
            		}
	         /*
	         Add info
	         */
	         NewDMSCase.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('TLR DMS Case').getRecordTypeId();
	         NewDMSCase.Priority='Medium';
	         NewDMSCase.Status='New';
	         NewDMSCase.Origin ='Web';
	         NewDMSCase.Form_Status__c='Initialized';
	         NewDMSCase.Complaint_Reason__c='DMS Full Service';
	         NewDMSCase.Additional_Comments__c=Comment;
	         NewDMSCase.Access_Kind__c=input.CodeAppli;
         
	         /*
	         select the complainer Account     
	         */
	         try {
	         Account ComplainerAccount =[Select Id from Account where Id=:ComplAccount];    
	         NewDMSCase.AccountId =ComplainerAccount.Id;                
	         }catch(Exception ex){
	            Generic.StandardException stex=new Generic.StandardException();
	            stex.ReturnCode=2;
	            stex.setMessage('Complainer Account not found: '+ex.getMessage());
	            stex.Error='Complainer Account not found: '+ex.getMessage();
	            throw stex;
	            
	         } 
	         /*
	         select the Complainer Contact
	         */
	         try {
	         Contact ComplainerContact = [Select Id from Contact where Username__c=:input.ContactLogin];
	         NewDMSCase.ContactId =ComplainerContact.Id;
	         
	         }catch(Exception ex){
	            Generic.StandardException stex=new Generic.StandardException();
	            stex.ReturnCode=3;
	            stex.setMessage('Complainer Contact not found: '+ex.getMessage());
	            stex.Error='Complainer Contact not found: '+ex.getMessage();
	            throw stex;
	         } 
	         /*
	         select the defaulter account
	         */
	         /*
	         If Econfirm number is not null or not empty we retrieve the defaulter contact. 
	         */
	         if(input.PosterContactLogin !=null && input.PosterContactLogin.trim() !='') {
	         
			         try {
			         Contact DefaulterContact = [Select Id, AccountId  from Contact where Contact.Username__c=:input.PosterContactLogin];
			            NewDMSCase.Defaulter_Contact_Name__c = DefaulterContact.Id;
			            NewDMSCase.Defaulter_Account_Name__c = DefaulterContact.AccountId;  
			            }catch(Exception ex){
			            Generic.StandardException stex=new Generic.StandardException();
	                	stex.ReturnCode=4;
	                	stex.setMessage('The defaulter contact not found: '+ex.getMessage());
	                	stex.Error='The defaulter contact not found: '+ex.getMessage();
	                	throw stex;
			            }   
			 } else {
	         
	         	//if (input.DefaulterTlrNumber!=null && input.DefaulterTlrNumber.trim()!=''){
			         try {
			         Account DefaulterAccount = [Select Id  from Account where Teleroute_Number__c=:input.DefaulterTlrNumber];
			            NewDMSCase.Defaulter_Account_Name__c = DefaulterAccount.Id; 
			            }catch(Exception ex){
			            Generic.StandardException stex=new Generic.StandardException();
	                	stex.ReturnCode=5;
	                	stex.setMessage('The defaulter account not found: '+ex.getMessage());
	                	stex.Error='The defaulter account not found: '+ex.getMessage();
	                	throw stex;  	
			            }
	         		/*} else {
		         	   icOutput.ReturnCode = 5;
				       icOutput.Error ='The defaulter account not found';
				       return icOutput;
				       System.debug('icOutput'+icOutput);	
	         		}*/      
	         }
         
         /* 
         DMSResult = Database.insert(NewDMSCase);
         */
         DMSResult = Database.upsert(NewDMSCase);       
         icOutput.CaseId =DMSResult.getId();  
         
         /*
         Create DMS Fee for TGO prepaid
         */
            String DMSFeeName ='Debt Mediation';
        	String DMSService ='Debt Mediation'; 
         	System.debug('ContactId: '+NewDMSCase.ContactId);
         	System.debug('CodeAppli: '+input.CodeAppli);   
         	if (CreateFee == true && input.CodeAppli =='WEB3S') {
          	Id CaseId =[Select Id from Case where Id=:icOutput.CaseId].Id;      
          	FeeInput FInput = new FeeInput(NewDMSCase.ContactId,input.CodeAppli,DMSFeeName,DMSService, CaseId);
          	createNewFee(FInput); 
            }                                  
         
        }catch(Generic.StandardException sex)
        {
            icOutput.returnCode = sex.ReturnCode;
            icOutput.error = sex.Error;
            System.debug('## '+sex.getMessage());
            Database.rollback(sp);
        }catch(Exception ex){
            icOutput.returnCode = 1;
            icOutput.error = ex.getMessage();
            System.debug('## '+ex.getMessage());
            Database.rollback(sp);
        }
         return icOutput;
    }  
    
    webservice static GetCaseInformationOutput GetCaseInformation(Id CaseId){
        /*
        Migrate from free basic to others   
        */
        GetCaseInformationOutput gcOutput = new GetCaseInformationOutput();
        Case DMSCase = new Case();
        try{
        DMSCase =[Select 
        Id,
        Country__c, 
        Account.Name,Account.BillingCity, 
        Contact.FirstName,
        Contact.LastName, 
        Contact.Gender__c,
        Contact.Username__c,
        Contact.Email,
        Contact.Phone,
        Contact.Title,
        Complainer_Language__c,
        Defaulter_Account_Name__r.Name,
        Defaulter_Country__c,
        Defaulter_Account_Name__r.SIRET__c, 
        Defaulter_Contact_Name__r.FirstName, 
        Defaulter_Contact_Name__r.LastName, 
        Defaulter_Contact_Name__r.Gender__c,
        Defaulter_Language__c,
        CMR_Number__c,
        Defaulter_Contact_Name__r.Title,
        Teleroute_Number_Defaulter__c,
        Defaulter_Account_Name__r.VAT__c,
        Delivery_Date__c,
        Defaulter_Contact_Name__r.Username__c,
        eConfirm_Number__c,
        Invoice_Amount__c,
        Freight_Offer_Number__c,
        From_Country__c,
        From_City__c,
        To_Country__c,
        To_City__c,
        IsNewContactComplainer__c,
        IsNewAccountDefaulter__c,
        IsNewContactDefaulter__c
        from Case 
        where Id=:CaseId 
        limit 1];
        
        
        if (DMSCase.Id != null){
            
        /*
        Retrieve Complainer Information
        */
        gcOutput.ComplainerCompanyName=DMSCase.Account.Name;
        gcOutput.ComplainerLogin=DMSCase.Contact.Username__c;
        gcOutput.ComplainerCity=DMSCase.Account.BillingCity;
        gcOutput.ComplainerCountry=DMSCase.Country__c;
        gcOutput.ComplainerEmailAddress=DMSCase.Contact.Email;
        gcOutput.ComplainerFirstName=DMSCase.Contact.FirstName;
        gcOutput.ComplainerGender=DMSCase.Contact.Gender__c;
        gcOutput.ComplainerLang=DMSCase.Complainer_Language__c;
        gcOutput.ComplainerLastName=DMSCase.Contact.LastName;
        gcOutput.ComplainerPhoneNumber=DMSCase.Contact.Phone;
        gcOutput.ComplainerTitle=DMSCase.Contact.Title;
        /*
        Retrieve Defaulter Information
        */
        gcOutput.DefaulterCompanyName =DMSCase.Defaulter_Account_Name__r.Name;
        gcOutput.DefaulterContactLogin =DMSCase.Defaulter_Contact_Name__r.Username__c;
        gcOutput.DefaulterCountry=DMSCase.Defaulter_Country__c;
        gcOutput.DefaulterCRMNumber=DMSCase.CMR_Number__c;
        gcOutput.DefaulterFirstName=DMSCase.Defaulter_Contact_Name__r.FirstName;
        gcOutput.DefaulterLastName=DMSCase.Defaulter_Contact_Name__r.Lastname;
        gcOutput.DefaulterGender=DMSCase.Defaulter_Contact_Name__r.Gender__c;
        gcOutput.DefaulterLang=DMSCase.Defaulter_Language__c;
        gcOutput.DefaulterSiret=DMSCase.Defaulter_Account_Name__r.SIRET__c;
        gcOutput.DefaulterTitle=DMSCase.Defaulter_Contact_Name__r.Title;
        gcOutput.DefaulterTLRNumber=DMSCase.Teleroute_Number_Defaulter__c;
        gcOutput.DefaulterVATNumber=DMSCase.Defaulter_Account_Name__r.VAT__c;
        gcOutput.DeliveryDate=DMSCase.Delivery_Date__c;
        gcOutput.DefaulterContactLogin=DMSCase.Defaulter_Contact_Name__r.Username__c;
        gcOutput.eConfirmNumber=DMScase.eConfirm_Number__c;
        gcOutput.InvoiceAmount =DMSCase.Invoice_Amount__c;
        gcOutput.OfferNumber=DMSCase.Freight_Offer_Number__c;
        gcOutput.DepartureCountry=DMSCase.From_Country__c;
        gcOutput.DepartureCity=DMSCase.From_City__c;
        gcOutput.ArrivalCountry=DMSCase.To_Country__c;
        gcOutput.ArrivalCity=DMSCase.To_City__c;
        
        if(DMSCase.IsNewContactComplainer__c==true){
        gcOutput.IsNewContactComplainer ='Y';               
        } else {
        gcOutput.IsNewContactComplainer ='N';   
        }
        if(DMSCase.IsNewAccountDefaulter__c==true){
        gcOutput.IsNewAccountDefaulter ='Y';                
        } else {
        gcOutput.IsNewAccountDefaulter ='N';    
        }
        if(DMSCase.IsNewContactDefaulter__c==true){
        gcOutput.IsNewContactDefaulter ='Y';                
        } else {
        gcOutput.IsNewContactDefaulter ='N';    
        }
       
        //gcOutput.ComplainerCompanyName=DMSCase.A  
        }
        else{
        gcOutput.ReturnCode = 1;
        gcOutput.Error = 'Case not found';  
        }
            
        }catch(Exception ex){
            gcOutput.ReturnCode = 2;
            gcOutput.Error = ex.getMessage();
        }
        return gcOutput;
    }
    
   webservice static Generic.StandardOutput SetCaseInformation(SetCaseInformationInput input){
        
        //Migrate from free basic to others   
        
        System.debug('Input SetCase Infor: '+input);
        Generic.StandardOutput sOutput = new Generic.StandardOutput();
        
        SavePoint sp = Database.setSavepoint();  
        String freeDMS ='N';
        String DMSFeeName = 'Debt Mediation';
        String DMSService = 'Debt Mediation';
        
        Case DMSCase = new Case();   
        Case CaseToUpdate = new  Case();
              
        try{            
        DMSCase =[Select Id FROM Case Where Id=:input.CaseId];
        
        if (DMSCase.Id != null){
            CaseToUpdate = [ Select 
            Id,
            CaseNumber,
            Form_Status__c,
            Status,
            Additional_Comments__c,
            eConfirm_Number__c,
            AccountId,
            ContactId,
            IsNewAccountDefaulter__c,
            Defaulter_Information__c,
            IsNewContactDefaulter__c,
            IsNewContactComplainer__c,
            From_City__c,
            From_Country__c,
            To_City__c,
            To_Country__c,
            Invoice_Amount__c,
            Invoice_Date__c,
            Invoice_Number__c,
            Currency__c,
            Freight_Offer_Number__c,
            Delivery_Date__c,
            Loading_Date__c,
            With_whom__c,
            Payment_term_agreed_on__c,
            Number_of_reminders_sent__c,
            Invoice_in_accordance__c,
            Transport_executed__c,
            CMR_signed_without_remarks__c,
            Did_mail_return_undelivered__c,
            Goods_lacking_or_damaged__c,
            Payment_term_confirmed_in_agreement__c,
            Reminder_sent_for_the_disputed_invoice__c,
            The_reminder_was_registered_by_post__c,
            Contacted_by_phone__c,
            SuppliedCompany,
            SuppliedName,
            SuppliedPhone,
            SuppliedEmail,
            Access_Kind__c
            from Case where Id =: DMSCase.Id limit 1];
            System.debug('Case Id'+CaseToUpdate.Id);   
            if((CaseToUpdate.Form_Status__c =='Initialized' || CaseToUpdate.Form_Status__c =='Submitted')&& CaseToUpdate.Status =='New'){
                if(CaseToUpdate.Additional_Comments__c == 'DMS Free Case'){
                freeDMS = 'Y';              
                    }
                if(CaseToUpdate.eConfirm_Number__c != null && CaseToUpdate.eConfirm_Number__c!=''){                 
                 freeDMS = 'Y';              
                    }
                    
                if(CaseToUpdate.Form_Status__c =='Initialized'){
                
                // Check user application  
                System.debug('Webform Status'+CaseToUpdate.Form_Status__c);
                System.debug('Free DMS Case'+freeDMS); 
                System.debug('CodeAppli'+CaseToUpdate.Access_Kind__c);            
                if(CaseToUpdate.Access_Kind__c != 'WEB3S' && freeDMS =='N'){
                 FeeInput NewFeeInput =new FeeInput(CaseToUpdate.ContactId, CaseToUpdate.Access_Kind__c, DMSFeeName,DMSService, CaseToUpdate.Id);                       
                 createNewFee(NewFeeInput);
                 System.debug('Fee Input'+NewFeeInput);               
                 } else {
                 System.debug('TGO user or Econfirm case, no fee');    
                    }                     
                 }
                if (input.IsNewContactComplainer=='Y'){
                CaseToUpdate.SuppliedCompany = Input.ComplainerCompanyName;
                CaseToUpdate.SuppliedName = input.ComplainerTitle +' '+ input.ComplainerFirstName+' '+input.ComplainerLastName;
                CaseToUpdate.SuppliedPhone = input.ComplainerPhoneNumber;
                CaseToUpdate.SuppliedEmail = input.ComplainerEmailAddress;
                CaseToUpdate.SuppliedEmail = input.ComplainerEmailAddress;
                CaseToUpdate.IsNewContactComplainer__c =true;            
                }
               
                
               if (input.IsNewAccountDefaulter=='Y'){
    
               //Update DMS Case    
               CaseToUpdate.Defaulter_Information__c ='Company Name: '+input.DefaulterCompanyName +'\n';
               CaseToUpdate.Defaulter_Information__c +='Siret Number: '+input.DefaulterSiret+'\n';
               CaseToUpdate.Defaulter_Information__c +='Teleroute Number: '+input.DefaulterTLRNumber+'\n';
               CaseToUpdate.Defaulter_Information__c +='VAT Number: '+input.DefaulterVATNumber+'\n';
               CaseToUpdate.Defaulter_Information__c +='Address: '+'\n';         
               CaseToUpdate.Defaulter_Information__c +='Street Number: '+input.DefaulterStreetNumber+'\n';
               CaseToUpdate.Defaulter_Information__c +='Address line 1: '+input.DefaulterAddress1+'\n';
               CaseToUpdate.Defaulter_Information__c +='Address line 2: '+input.DefaulterAddress2+'\n';
               CaseToUpdate.Defaulter_Information__c +='Addresse Line3: '+input.DefaulterAddress3+'\n';
               CaseToUpdate.Defaulter_Information__c +='Zip Code: '+input.DefaulterZipCode+'\n';    
               CaseToUpdate.Defaulter_Information__c +='City: '+input.DefaulterCity+'\n';    
               CaseToUpdate.Defaulter_Information__c +='Province: '+input.DefaulterProvince+'\n';
               
               if (input.DefaulterCountry !='' && input.DefaulterCountry.trim().length() > 0){
               String DefCountry =[Select Name from pw_cc__CountryObject__c where IRU_Country_Code__c =:input.DefaulterCountry limit 1].Name;    
               CaseToUpdate.Defaulter_Information__c +='Country: '+DefCountry+'\n';
               } else {
               CaseToUpdate.Defaulter_Information__c +='Country: '+input.DefaulterCountry+'\n';	
               } 	
               CaseToUpdate.IsNewAccountDefaulter__c=true;
               }
               if (input.IsNewContactDefaulter =='Y'){
               CaseToUpdate.Defaulter_Information__c +='Contact Name: '+ input.DefaulterTitle+' '+input.DefaulterFirstName+' '+ input.DefaulterLastName+'\n';
               CaseToUpdate.Defaulter_Information__c +='Contact Username: '+input.DefaulterContactLogin+'\n';
               CaseToUpdate.Defaulter_Information__c +='Contact Gender: '+input.DefaulterGender+'\n';
               CaseToUpdate.Defaulter_Information__c +='Contact Language: '+Language_Code__c.getValues(input.DefaulterLang).Label__c+'\n';
               CaseToUpdate.IsNewContactComplainer__c=true;
               //DMSCase.Defaulter_Information__c +='Titile: '+input.D+'/n';
               //DMSCase.Defaulter_Information__c +='Titile: '+input.DefaulterTitle+'/n';
               }
               
               CaseToUpdate.CMR_Number__c = input.DefaulterCRMNumber;
               CaseToUpdate.From_City__c =input.FromCity;
               /*CaseToUpdate.From_Country__c=input.FromCountry;*/
               if (input.FromCountry !='' && input.FromCountry.trim().length() > 0){
               String FromCountryName =[Select Name from pw_cc__CountryObject__c where IRU_Country_Code__c =:input.FromCountry limit 1].Name;    
               CaseToUpdate.From_Country__c=FromCountryName;
               }
               CaseToUpdate.To_City__c=input.ToCity;
               /*CaseToUpdate.To_Country__c=input.ToCounty;*/
               if (input.ToCounty !='' && input.ToCounty.trim().length() > 0){
               String ToCountryName =[Select Name from pw_cc__CountryObject__c where IRU_Country_Code__c =:input.ToCounty limit 1].Name; 
               CaseToUpdate.To_Country__c=ToCountryName;
               }
               CaseToUpdate.Invoice_Amount__c=input.InvoiceAmount;
               if(input.InvoiceDate !=null){
               CaseToUpdate.Invoice_Date__c=input.InvoiceDate;
               }
               CaseToUpdate.Invoice_Number__c=input.InvoiceNumber;
               CaseToUpdate.Currency__c=input.InvoiceCurrency;
               CaseToUpdate.Freight_Offer_Number__c=input.FreightOfferNumber;
               if(input.DeliveryDate != null){
               CaseToUpdate.Delivery_Date__c =input.DeliveryDate;
               }
               if(input.LoadingDate !=null){
               CaseToUpdate.Loading_Date__c=input.LoadingDate;
               }
               CaseToUpdate.Additional_Comments__c=input.Remark;
               CaseToUpdate.With_whom__c=input.WithWhom;
               System.debug('WithWhom: '+input.WithWhom);
               CaseToUpdate.Payment_term_agreed_on__c=input.PaymentTerm;
               System.debug('PaymentTerm'+input.PaymentTerm);
               CaseToUpdate.Number_of_reminders_sent__c=input.RegisteredReminders;
               System.debug('RegisteredReminders'+input.RegisteredReminders);
 
               if (input.IsInvoiceInAccordance =='Y'){
                CaseToUpdate.Invoice_in_accordance__c=true;
                System.debug('IsInvoiceInAccordance'+input.IsInvoiceInAccordance);
                
               }
               if (input.IsTransportExecuted=='Y'){
                CaseToUpdate.Transport_executed__c=true;
                System.debug('IsTransportExecuted'+input.IsTransportExecuted);
               }       
               if (input.IsCMRSigned=='Y'){
                CaseToUpdate.CMR_signed_without_remarks__c=true;
                System.debug('IsCMRSigned'+input.IsCMRSigned);
               }
               if (input.IsMailUndelivered=='Y'){
                CaseToUpdate.Did_mail_return_undelivered__c=true;
                System.debug('IsMailUndelivered'+input.IsMailUndelivered);
               }
               if (input.IsGoodCondition=='Y'){
                CaseToUpdate.Goods_lacking_or_damaged__c=true;
                System.debug('IsGoodCondition'+input.IsGoodCondition);
               }
               if (input.IsPaymentTermConfirmed=='Y'){
                CaseToUpdate.Payment_term_confirmed_in_agreement__c=true;
                System.debug('IsPaymentTermConfirmed'+input.IsPaymentTermConfirmed);
               }
               if (input.IsReminder=='Y'){
                CaseToUpdate.Reminder_sent_for_the_disputed_invoice__c=true;
                 System.debug('IsReminder'+input.IsReminder);
               }
               if (input.IsRegisteredByPost=='Y'){
                CaseToUpdate.The_reminder_was_registered_by_post__c=true;
                System.debug('IsRegisteredByPost'+input.IsRegisteredByPost);
               }
               if (input.IsContactedByPhone=='Y'){
                CaseToUpdate.Contacted_by_phone__c=true;
                System.debug('IsContactedByPhone'+input.IsContactedByPhone);
               }
               if (input.IsExtraCostAccepted=='Y'){
                CaseToUpdate.Freight_forwarder_accepts_the_charges__c=true;
                System.debug('IsExtraCostAccepted'+input.IsExtraCostAccepted);
               }
               
               // Update DMS form status to "Submitted"
               CaseToUpdate.Form_Status__c ='Submitted';
               update CaseToUpdate;

            } else
            {
                sOutput.ReturnCode=3;
                sOutput.Error='The Case can not be updated because the status of the case:'+CaseToUpdate.Id +' is '+CaseToUpdate.Form_Status__c;
            }
        
        
        } else {
          SOutput.ReturnCode =1;
          SOutput.Error = 'DMS Case not found:'+input.CaseId;   
            
        }
                
        }catch(Exception ex){
            sOutput.ReturnCode = 2;
            sOutput.Error = ex.getMessage();
        }
        return sOutput;
    }
    
    webservice static FormSubmittedOutput FormSubmitted(FormSubmittedInput input){
        
        FormSubmittedOutput cfOutput = new FormSubmittedOutput (); 
        Case CaseSubmitted = new Case();
        try {
        
        CaseSubmitted = [Select Id, Status, Form_Status__c from Case where Id=:input.CaseId limit 1];
        
        if(CaseSubmitted.Form_Status__c =='Initialized') 
            {   
            cfOutput.Submitted ='N';
            } else {
            cfOutput.Submitted ='Y';    
            }
                        
            }catch(Exception e){
            cfOutput.ReturnCode =1;
            cfOutput.Error ='Case not found'+e.getMessage();
            }
       System.debug('cfOutput'+cfOutput);  
       return cfOutput;   
        
    }
    
    
    
}