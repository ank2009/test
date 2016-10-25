global public with sharing class TlrPrivacyPolicy {

 /* =============================================================================================
    // Input object definition    
    ============================================================================================= */
    global public class UnSubscribeNewsLetterInput
    { 
      webservice public Boolean UnSubscribeNewsLetter;
      webservice public String Login;
    }
    
    global public class UnSubscribeEMailInput
    {
      webservice public String Login; 
      webservice public Boolean UnSubscribeEmail;
    }
    
    global public class ChargePrivacyPolicyChangesInput
    {
      webservice public String Login; 
      webservice public Boolean AllowsPhoneCall;
      webservice public Boolean AllowsEmailSending;
      webservice public Boolean allowsFaxSending;
    }
    
    /* =============================================================================================
    // Output object definition    
    ============================================================================================= */
    
    /* =============================================================================================
    // Internals methods    
    ============================================================================================= */
    
    /* =============================================================================================
    // Webservices methods    
    ============================================================================================= */
  webservice static Generic.StandardOutput UnSubscribeNewsLetter(UnSubscribeNewsLetterInput input)
    {
    	
    	 System.debug('Input  News Letter'+input);
      //Subscribe or unsubscribe a user to newsletters
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        try{
        	
        Contact sContact = [select Id, Newsletter_susbcription__c from Contact where  Username__c =: input.Login  limit 1];	
        
        	if (input.UnSubscribeNewsLetter == true) {
        		
        		sContact.Newsletter_susbcription__c = true;
        	
        	} else if (input.UnSubscribeNewsLetter == false){
        		
        		sContact.Newsletter_susbcription__c = false;        		
        	}
        	update sContact;	

        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            Database.rollback(sp);
        }
        return output;
    }    
    
    webservice static Generic.StandardOutput UnSubscribeEMail(UnSubscribeEMailInput input)
    {
    	
    	 System.debug('Input Email'+input);
      //Unsubscribe to all Teleroute emails
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        try{
        Contact sContact = [select Id, HasOptedOutOfEmail from Contact where  Username__c =: input.Login  limit 1];	
           
            if (input.UnSubscribeEmail == true){
            	
            	sContact.HasOptedOutOfEmail = false;
            	 
            } else if (input.UnSubscribeEmail == false){
            	
            	sContact.HasOptedOutOfEmail = true;
            	
            }
            update sContact;
            
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            Database.rollback(sp);
        }
        return output;
    }    
    
    webservice static Generic.StandardOutput ChargePrivacyPolicyChanges(ChargePrivacyPolicyChangesInput input)
    {
    	
    	  System.debug('Input Charge Privacy Policy'+input);
      //Set the opt-in/opt-out checkboxes
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        try{
        Contact sContact = [select Id, DoNotCall,  HasOptedOutOfEmail, 	HasOptedOutOfFax  from Contact where  Username__c =: input.Login  limit 1];
            
            if (input.AllowsEmailSending == true){
            	System.debug('Email Sending OK');
            	sContact.HasOptedOutOfEmail = false; 	
            } else if (input.AllowsEmailSending == false){
            	System.debug('Email Sending KO');
            	sContact.HasOptedOutOfEmail = true;
            }
            
            if (input.allowsFaxSending == true){
            	System.debug('Fax Sending OK');
            	sContact.HasOptedOutOfFax = false; 
            } else if (input.allowsFaxSending == false){
            	System.debug('Fax Sending KO');
            	sContact.HasOptedOutOfFax = true;
            }
            
            if (input.AllowsPhoneCall == true){
            	System.debug('Phone OK');
            	sContact.DoNotCall = false; 
            } else if (input.AllowsPhoneCall == false){
            	System.debug('Phone KO');
            	sContact.DoNotCall = true;
            }
            update sContact;
            
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            Database.rollback(sp);
        }
        return output;
    }    
}