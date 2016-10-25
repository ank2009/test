global public with sharing class TlrCompanyManagement {
 
    global public class ReadCompanyInput
    {       
        webservice public String ContactLogin;     
    }
    
    global public class ReadCompanyOutput
    {   
    	webservice public Integer ReturnCode=0;
        webservice public String Error;    
        webservice public String CompanyName;
        //webservice public String StreetAddress;
        webservice public String StreetNumber;
        webservice public String AddressLine1;
        webservice public String AddressLine2;
        webservice public String AddressLine3;
        webservice public String Zipcode;
        webservice public String City;
        webservice public String Country;
        webservice public String VAT;
        webservice public String PhoneNumber;
        webservice public String FaxNumber;
        webservice public String EmailAddress;
		webservice public String SiretNumber;
        webservice public String PaymentMode;//(CC / PP / DD / IPLUS)
        webservice public String BankName;
        webservice public String BankNumber;
        webservice public String IBAN;
        webservice public String BIC_Code;
        webservice public String BankAddress;
        webservice public String BankPostCode;
        webservice public String BankCity;
        webservice public String BankCountry;
        //webservice public String DKV_CardNumber;
        //webservice public String DKV_Validity;         
        webservice public datetime TransactionDate;
        webservice public String TransactionId;       
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
    	Contact ContactInfo =[Select Id, AccountId from Contact where Id=:Input.ContactLogin limit 1];
    	
    	if (ContactInfo.Id != null || ContactInfo.Id !='') {
    	Account CompanyInfo = [Select Id, Name, BillingCountry, BillingState, BillingStreet, BillingCity, BillingPostalCode, Email__c, Fax, Phone, SIRET__c, VAT__c from Account where Id=:ContactInfo.AccountId]; 
	    
	    if (CompanyInfo.Id !=null && CompanyInfo.Id !='') {
	    	
	    	sOutput.CompanyName =CompanyInfo.Name;
	    	sOutput.Country = CompanyInfo.BillingCountry;
	    	sOutput.City=CompanyInfo.BillingCity;
	    	//sOutput.StreetAddress = CompanyInfo.BillingStreet;
	        sOutput.Zipcode = CompanyInfo.BillingPostalCode;
	        List<String> sBillingStreet = new List<String>();
            sBillingStreet = CompanyInfo.BillingStreet.split('\n');
                System.debug('## street line size : '+sBillingStreet.size());
                sOutput.StreetNumber = sBillingStreet[0];
                if(sBillingStreet.size()>1)
                    sOutput.AddressLine2 = sBillingStreet[1];
                if(sBillingStreet.size()>2)
                    sOutput.AddressLine3 = sBillingStreet[2];   
                if(sBillingStreet.size()>3)
                    sOutput.AddressLine3 = sOutput.AddressLine3+' '+sBillingStreet[3];    
	        sOutput.EmailAddress = CompanyInfo.Email__c;
	        sOutput.FaxNumber = CompanyInfo.Fax;
	        sOutput.PhoneNumber =CompanyInfo.Phone;
	        sOutput.SiretNumber = CompanyInfo.SIRET__c;
	        sOutput.VAT = CompanyInfo.VAT__c;
            /* 
            Retrieve info from financial transaction
            */
            FinancialTransaction__c FinanceInfo = [Select Id, TransactionAmount__c, TransactionDate__c, TransactionId__c, PaymentMode__c  from  FinancialTransaction__c where Contact__c =:ContactInfo.Id limit 1];
	        
	        if (FinanceInfo.PaymentMode__c =='Credit Card' || FinanceInfo.PaymentMode__c =='PAYPAL') {
	        sOutput.TransactionDate = FinanceInfo.TransactionDate__c;	
	        } else if (FinanceInfo.PaymentMode__c =='PAYPAL') {
	        sOutput.TransactionDate = FinanceInfo.TransactionDate__c;
	        sOutput.TransactionId = FinanceInfo.TransactionId__c;	
	        } else if (FinanceInfo.PaymentMode__c  =='Direct Debit') {
	        sOutput.IBAN = CompanyInfo.Iban_Number__c; 	
	        sOutput.BIC_Code = CompanyInfo.BIC_Code__c;
	        sOutput.BankNumber = CompanyInfo.Iban_Number__c.substring(14,25);
	        sOutput.BankName = CompanyInfo.Bank_Name__c;
	        sOutput.BankAddress= CompanyInfo.Bank_Street_Address__c;
            sOutput.BankPostCode = CompanyInfo.Bank_Postal_Code__c;
            sOutput.BankCity = CompanyInfo.Bank_City__c;
            sOutput.BankCountry = CompanyInfo.Bank_Country__c;   
	        } 
	        /* Aucune info pour l'instant sur les  champs DKV et Credit Card. (champs non migrés)
	         else if  (FinanceInfo.PaymentMode__c  =='DKV') {
	        	
	        }*/

	    	} else{
	    	sOutput.ReturnCode=1;
	    	sOutput.Error ='Company not found';
	   		}
    		} else {
    		sOutput.ReturnCode=2;
	    	sOutput.Error ='Contact not found';	
    		} 
        
    	} catch(Exception ex){
            sOutput.ReturnCode = 2;
            sOutput.Error = ex.getMessage();
        }
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

}