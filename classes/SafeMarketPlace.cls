global public with sharing class SafeMarketPlace {
    global public enum CodeOfConductStatus
    {
        Accepted,
        Refused,
        Reset,
        Suspended
    }
    /* =============================================================================================
    // Input object definition    
    ============================================================================================= */
    global public class ForwardCodeOfConductInput
    { 
        webservice public String LastName;
        webservice public String FirstName;
        webservice public String Email;
        webservice public String AccountId;
        webservice public String Gender;
        webservice public String Language;
        webservice public String FirstContactId;
        webservice public String ContactId;
    }
    
    global public class DeleteCertificationInput
    {
        webservice public String AccountNumber; 
        webservice public String CertificationIdToRemove;
    }
    
    /* =============================================================================================
    // Output object definition    
    ============================================================================================= */
    
    /* =============================================================================================
    // Internals methods    
    ============================================================================================= */
    private static void deNotifyCustomers(Id accountId, Id contactId)
    {
        //DeNotifyCustomers (Remove right 290)
        try
        {
            List<Contact> contactToDenotifyList = [select Username__c from Contact where Username__c <> '' and AccountId =:accountId and Id <>:contactId];
            for(Contact contactToDenotify : contactToDenotifyList)
            {
                Generic.RemoveRight(contactToDenotify.Username__c, '290');
            }
        }
        catch(Exception ex)
        {
            Generic.StandardException stex=new Generic.StandardException();
            stex.ReturnCode=101;
            stex.setMessage('deNotifyCustomers : Error in Contact loading : '+ex.getMessage());
            stex.Error='deNotifyCustomers : Error in Contact loading : '+ex.getMessage();
            throw stex;   
        }
    }
    
        private static void notifyCustomers(Id accountId, Id contactId)
    {
        //DeNotifyCustomers (Add right 290)
        try
        {
            List<Contact> contactToDenotifyList = [select Username__c from Contact where Username__c <> '' and AccountId =:accountId and Id <>:contactId];
            for(Contact contactToDenotify : contactToDenotifyList)
            {
                Generic.AddRight(contactToDenotify.Username__c, '290');
            }
        }
        catch(Exception ex)
        {
            Generic.StandardException stex=new Generic.StandardException();
            stex.ReturnCode=101;
            stex.setMessage('deNotifyCustomers : Error in Contact loading : '+ex.getMessage());
            stex.Error='deNotifyCustomers : Error in Contact loading : '+ex.getMessage();
            throw stex;   
        }
    }
    

    /* =============================================================================================
    // Webservices methods    
    ============================================================================================= */
    webservice static Generic.StandardOutput StoreActivityForCoC(String login,CodeOfConductStatus cocStatus)
    {
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        Contact contact;
        try
        {
            try
            {
                contact = [select AccountId,Id from Contact where Username__c=:login limit 1];
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=2;
                stex.setMessage('Error in Contact loading : '+ex.getMessage());
                stex.Error='Error in Contact loading : '+ex.getMessage();
                throw stex;   
            }
            try
            {
                Task activityCoC = new Task();
                //activityCoCapproved.AccountId = contact.AccountId;
                activityCoC.WhoId = contact.Id;
                activityCoC.Subject_Group__c = 'Safe Market Place';
                activityCoC.Type = 'Administration';
                
                if(cocStatus == CodeOfConductStatus.Accepted)
                {
                    activityCoC.Subject = 'CoC approved';
                    activityCoC.Status = 'Completed';
                    //activityCoC.Description = 'This is an automatically generated message once a user has accepted the CoC for his company.';
                    activityCoC.Description = 'Code of Conduct accepted';
                }
                else if(cocStatus == CodeOfConductStatus.Refused)
                {   
                    activityCoC.Subject = 'CoC rejected';
                    activityCoC.Status = 'Completed';
                    //activityCoC.Description = 'This is an automatically generated message once a user has refused the CoC for his company. The CoC can be reset on request of customer, by resetting the value to undecided in the SMP dashboard. ';
                    activityCoC.Description = 'Code of Conduct refused';
                }
                else if(cocStatus == CodeOfConductStatus.Reset)
                {   
                    activityCoC.Subject = 'CoC reset by TLR';
                    activityCoC.Status = 'Completed';
                    //activityCoC.Description = 'This is an automatically generated message once the CoC has been reset to "undecided" by TLR in the SMP dashboard on request of the TLR steering committee after the customer corrected this behaviour.';
                    activityCoC.Description = 'Code of Conduct reset by TLR';
                }
                else if(cocStatus == CodeOfConductStatus.Suspended)
                {   
                    activityCoC.Subject = 'CoC suspended by TLR';
                    activityCoC.Status = 'Completed';
                    //activityCoC.Description = 'This is an automatically generated message once the CoC has been suspended by TLR in the SMP dashboard on request of the TLR steering commitee after bad behaviour of the customer.';
                    activityCoC.Description = 'Code of Conduct suspended by TLR';
                }
                insert activityCoC;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=7;
                stex.setMessage('Error in creation of activity Code of Conduct rejected : '+ex.getMessage());
                stex.Error='Error in creation of activity Code of Conduct rejected : '+ex.getMessage();
                throw stex;   
            }  
        }catch(Generic.StandardException sex)
        {
            output.returnCode = sex.ReturnCode;
            output.error = sex.Error;
            System.debug('## '+sex.getMessage());
            Database.rollback(sp);
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            System.debug('## '+ex.getMessage());
            Database.rollback(sp);
        }
        return output;
    }
    
    webservice static Generic.StandardOutput AcceptCodeOfConduct(String contactId)
    {
        //Accept a code of conduct
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        Contact contact;
        Account accountToUpdate;        
        List<Contact> contactAlreadyFlaggedList;
        try
        {
            try
            {
                contact = [select AccountId/*, CoC_Decider__c*/ from Contact where Id=:contactId limit 1];
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=2;
                stex.setMessage('Error in Contact loading : '+ex.getMessage());
                stex.Error='Error in Contact loading : '+ex.getMessage();
                throw stex;   
            }  
            try{        
                accountToUpdate = [select Id, Status_CoC__c, Last_accepted_by_CoC__c, Last_accepted_date_CoC__c from Account where Id=:contact.AccountId limit 1];
            }
            catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=3;
                stex.setMessage('Error in Account loading : '+ex.getMessage());
                stex.Error='Error in Account loading : '+ex.getMessage();
                throw stex;   
            }
            try{
                //We have to check if another contact is already flagged as Code of Conduct Decider to unflag him.
                /*contactAlreadyFlaggedList = [select Id, CoC_Decider__c from Contact where AccountId=:accountToUpdate.Id];
                for(Contact contactAlreadyFlagged : contactAlreadyFlaggedList)
                {
                    
                    if(contactAlreadyFlagged.CoC_Decider__c)
                    {
                        contactAlreadyFlagged.CoC_Decider__c=false;
                        update contactAlreadyFlagged;
                    }
                }*/
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=4;
                stex.setMessage('Error in searching of other Code of Conduct deciders and in updating : '+ex.getMessage());
                stex.Error='Error in searching of other Code of Conduct deciders and in updating : '+ex.getMessage();
                throw stex;   
            }   
            try{        
                accountToUpdate.Status_CoC__c = 'Accepted';
                accountToUpdate.Last_accepted_by_CoC__c = contact.Id;
                accountToUpdate.Last_accepted_date_CoC__c = Date.today();
                update accountToUpdate;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=5;
                stex.setMessage('Error in updating of account Code of Conduct Status : '+ex.getMessage());
                stex.Error='Error in updating of account Code of Conduct Status : '+ex.getMessage();
                throw stex;   
            }  
            try
            {
                //contact.CoC_Decider__c=true;
                update contact;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=6;
                stex.setMessage('Error in updating of contact Code of Conduct Decider Flag : '+ex.getMessage());
                stex.Error='Error in updating of contact Code of Conduct Decider Flag : '+ex.getMessage();
                throw stex;   
            }  
            
            //Create activity
            try
            {
                Task activityCoCapproved = new Task();
                //activityCoCapproved.AccountId = contact.AccountId;
                activityCoCapproved.WhoId = contact.Id;
                activityCoCapproved.Subject_Group__c = 'Safe Market Place';
                activityCoCapproved.Subject = 'CoC approved';
                activityCoCapproved.Status = 'Completed';
                //activityCoCapproved.Description = 'This is an automatically generated message once a user has accepted the CoC for his company.';
                activityCoCapproved.Description = 'Code of Conduct accepted';
                activityCoCapproved.Type = 'Administration';
                insert activityCoCapproved;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=7;
                stex.setMessage('Error in creation of activity Code of Conduct rejected : '+ex.getMessage());
                stex.Error='Error in creation of activity Code of Conduct rejected : '+ex.getMessage();
                throw stex;   
            }  
                        
            notifyCustomers(contact.AccountId,contact.Id);
        }catch(Generic.StandardException sex)
        {
            output.returnCode = sex.ReturnCode;
            output.error = sex.Error;
            System.debug('## '+sex.getMessage());
            Database.rollback(sp);
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            System.debug('## '+ex.getMessage());
            Database.rollback(sp);
        }
        return output;
    }    
    
    webservice static Generic.StandardOutput RefuseCodeOfConduct(String contactId)
    {
        //Refuse a code of conduct
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        Contact contact;
        Account accountToUpdate;        
        List<Contact> contactAlreadyFlaggedList;
        try
        {
            try
            {
                contact = [select AccountId/*,CoC_Decider__c*/ from Contact where Id=:contactId limit 1];
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=2;
                stex.setMessage('Error in Contact loading : '+ex.getMessage());
                stex.Error='Error in Contact loading : '+ex.getMessage();
                throw stex;   
            }  
            try{        
                accountToUpdate = [select Id, Status_CoC__c,Last_rejected_by_CoC__c,Last_rejected_date_CoC__c from Account where Id=:contact.AccountId limit 1];
            }
            catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=3;
                stex.setMessage('Error in Account loading : '+ex.getMessage());
                stex.Error='Error in Account loading : '+ex.getMessage();
                throw stex;   
            }
            try{
                //We have to check if another contact is already flagged as Code of Conduct Decider to unflag him.
                /*contactAlreadyFlaggedList = [select CoC_Decider__c from Contact where AccountId=:accountToUpdate.Id];
                for(Contact contactAlreadyFlagged : contactAlreadyFlaggedList)
                {
                    if(contactAlreadyFlagged.CoC_Decider__c)
                    {
                        contactAlreadyFlagged.CoC_Decider__c=false;
                        update contactAlreadyFlagged;
                    }   
                }*/
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=4;
                stex.setMessage('Error in searching of other Code of Conduct deciders and in updating : '+ex.getMessage());
                stex.Error='Error in searching of other Code of Conduct deciders and in updating : '+ex.getMessage();
                throw stex;   
            }   
            try{        
                accountToUpdate.Status_CoC__c = 'Refused';
                accountToUpdate.Last_rejected_by_CoC__c = contact.Id;
                accountToUpdate.Last_rejected_date_CoC__c = Date.today();
                update accountToUpdate;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=5;
                stex.setMessage('Error in updating of account Code of Conduct Status : '+ex.getMessage());
                stex.Error='Error in updating of account Code of Conduct Status : '+ex.getMessage();
                throw stex;   
            }  
            try
            {
                //contact.CoC_Decider__c=true;
                update contact;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=6;
                stex.setMessage('Error in updating of contact Code of Conduct Decider Flag : '+ex.getMessage());
                stex.Error='Error in updating of contact Code of Conduct Decider Flag : '+ex.getMessage();
                throw stex;   
            }  
            
            //Create activity
            try
            {
                Task activityCoCrejected = new Task();
                //activityCoCrejected.AccountId = contact.AccountId;
                activityCoCrejected.WhoId = contact.Id;
                activityCoCrejected.Subject_Group__c = 'Safe Market Place';
                activityCoCrejected.Subject = 'CoC rejected';
                activityCoCrejected.Status = 'Completed';
                //activityCoCrejected.Description = 'This is an automatically generated message once a user has refused the CoC for his company. The CoC can be reset on request of customer, by resetting the value to undecided in the SMP dashboard. ';
                activityCoCrejected.Description = 'Code of Conduct refused';
                activityCoCrejected.Type = 'Administration';
                insert activityCoCrejected;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=7;
                stex.setMessage('Error in creation of activity Code of Conduct rejected : '+ex.getMessage());
                stex.Error='Error in creation of activity Code of Conduct rejected : '+ex.getMessage();
                throw stex;   
            }  
                        
            deNotifyCustomers(contact.AccountId,contact.Id);
        }catch(Generic.StandardException sex)
        {
            output.returnCode = sex.ReturnCode;
            output.error = sex.Error;
            System.debug('## '+sex.getMessage());
            Database.rollback(sp);
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            System.debug('## '+ex.getMessage());
            Database.rollback(sp);
        }
        return output;
    }   
    
    webservice static Generic.StandardOutput ResetCodeOfConduct(String accountId)
    {
        //CoC is reseted for all contacts of the account (+ activity creation)
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        String contactId;
        List<Contact> contactAlreadyFlaggedList;
        try
        {
            try{
                //We have to unflag the Code of Conduct Decider. He must be uniq but to be sure.
                /*contactAlreadyFlaggedList = [select Id,CoC_Decider__c from Contact where AccountId=:accountId];
                for(Contact contactAlreadyFlagged : contactAlreadyFlaggedList)
                {
                    if(contactAlreadyFlagged.CoC_Decider__c)
                    {
                        contactId = contactAlreadyFlagged.Id;
                        contactAlreadyFlagged.CoC_Decider__c=false;
                        update contactAlreadyFlagged;
                    }   
                }*/
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=4;
                stex.setMessage('Error in searching of other Code of Conduct deciders and in updating : '+ex.getMessage());
                stex.Error='Error in searching of other Code of Conduct deciders and in updating : '+ex.getMessage();
                throw stex;   
            }   

        
            //Create activity
            try
            {
                Task activityCoCreset = new Task();
                activityCoCreset.WhoId = contactId;
                activityCoCreset.Subject_Group__c = 'Safe Market Place';
                activityCoCreset.Subject = 'CoC reset by TLR';
                activityCoCreset.Status = 'Completed';
                //activityCoCreset.Description = 'This is an automatically generated message once the CoC has been reset to "undecided" by TLR in the SMP dashboard on request of the TLR steering committee after the customer corrected this behaviour.';
                activityCoCreset.Description = 'Code of Conduct reset by TLR';
                activityCoCreset.Type = 'Administration';
                insert activityCoCreset;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=7;
                stex.setMessage('Error in creation of activity Code of Conduct reset : '+ex.getMessage());
                stex.Error='Error in creation of activity Code of Conduct reset : '+ex.getMessage();
                throw stex;   
            }  
                        
            deNotifyCustomers(accountId,contactId);
        }catch(Generic.StandardException sex)
        {
            output.returnCode = sex.ReturnCode;
            output.error = sex.Error;
            System.debug('## '+sex.getMessage());
            Database.rollback(sp);
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            System.debug('## '+ex.getMessage());
            Database.rollback(sp);
        }
        return output;
    }   
    
    webservice static Generic.StandardOutput SuspendCodeOfConduct(String accountId)
    {
        //CoC is suspended for all contacts of the account (+ activity creation)
       Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        String contactId;
        List<Contact> contactAlreadyFlaggedList;
        try
        {
            try{
                //We have to unflag the Code of Conduct Decider. He must be uniq but to be sure.
                /*contactAlreadyFlaggedList = [select Id,CoC_Decider__c from Contact where AccountId=:accountId];
                for(Contact contactAlreadyFlagged : contactAlreadyFlaggedList)
                {
                    if(contactAlreadyFlagged.CoC_Decider__c)
                    {
                        contactId = contactAlreadyFlagged.Id;
                    }   
                }*/
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=4;
                stex.setMessage('Error in searching of other Code of Conduct deciders and in updating : '+ex.getMessage());
                stex.Error='Error in searching of other Code of Conduct deciders and in updating : '+ex.getMessage();
                throw stex;   
            }   

        
            //Create activity
            try
            {
                Task activityCoCsuspended = new Task();
                activityCoCsuspended.WhoId = contactId;
                activityCoCsuspended.Subject_Group__c = 'Safe Market Place';
                activityCoCsuspended.Subject = 'CoC suspended by TLR';
                activityCoCsuspended.Status = 'Completed';
                //activityCoCreset.Description = 'This is an automatically generated message once the CoC has been suspended by TLR in the SMP dashboard on request of the TLR steering commitee after bad behaviour of the customer.';
                activityCoCsuspended.Description = 'Code of Conduct suspended by TLR';
                activityCoCsuspended.Type = 'Administration';
                insert activityCoCsuspended;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=7;
                stex.setMessage('Error in creation of activity Code of Conduct reset : '+ex.getMessage());
                stex.Error='Error in creation of activity Code of Conduct reset : '+ex.getMessage();
                throw stex;   
            }  
                        
            deNotifyCustomers(accountId,contactId);
        }catch(Generic.StandardException sex)
        {
            output.returnCode = sex.ReturnCode;
            output.error = sex.Error;
            System.debug('## '+sex.getMessage());
            Database.rollback(sp);
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            System.debug('## '+ex.getMessage());
            Database.rollback(sp);
        }
        return output;
    }   
    
    webservice static Generic.StandardOutput ForwardCodeOfConduct(ForwardCodeOfConductInput input)
    {
        //Send an email to a user explaining him he has been choosen to sign the Code Of Conduct
        Generic.StandardOutput output = new Generic.StandardOutput();
        //Savepoint sp = Database.setSavepoint();
        try{
            Contact contactToForward;
            System.debug('## >>> ForwardCodeOfConduct : BEGIN <<< input : '+input);
            try
            {
                contactToForward=[select Id from Contact
                where
                    Account.AccountNumber=:input.AccountId and
                    FirstName=:input.FirstName and
                    LastName=:input.LastName and
                    Email=:input.Email
                ];
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=2;
                stex.setMessage('Error in search of contact which has to sign Code of Conduct : '+ex.getMessage());
                stex.Error='Error in search of contact which has to sign Code of Conduct : '+ex.getMessage();
                throw stex;   
            }  
            String listIdentifier='';
            String forwardCoCProcessName='';
            try
            {
                System.debug('## >>> Forward Code of Conduct <<<');
                listIdentifier = SIMSettings__c.getValues('SIMSettings').TLR_Contact_List_Identifier__c;
                //listIdentifier = [select Value__c from Configuration_Parameter__c where Key__c='TLR Contact' and Type__c='SIM list identifier'].Value__c;
                //forwardCoCProcessName = [select Value__c from Configuration_Parameter__c where Key__c='FORWARD_COC_PROCESS_NAME' and Type__c='SIM list identifier'].Value__c;
                forwardCoCProcessName = SIMSettings__c.getValues('SIMSettings').Forward_CoC_Process_Name__c;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=3;
                stex.setMessage('Error in loading of parameters to interract with SIM : '+ex.getMessage());
                stex.Error='Error in loading of parameters to interract with SIM : '+ex.getMessage();
                throw stex;   
            }  

            try
            {
                //SIM 
                System.debug('## >>> SIM Call : BEGIN <<<');
                SIM.IndividualSoap iSoap = new SIM.IndividualSoap();
                SIM.AutomationAuthHeader authHeader = new SIM.AutomationAuthHeader();
                authHeader.Login =  SIMSettings__c.getValues('SIMSettings').SIMUser__c;//'teleroute_admin';
                authHeader.Password = SIMSettings__c.getValues('SIMSettings').SIMPassword__c;//'tELEr0ute@2';
                iSoap.AutomationAuthHeader = authHeader;
                
                SIM.TriggerCampaignForUser_element request_x = new SIM.TriggerCampaignForUser_element();
                SIM.TriggerCampaignForUserResponse_element response_x;
                request_x.List1 = listIdentifier;
                request_x.GateName = forwardCoCProcessName;
            
                
                SIM.Property simPropertyContactId = new SIM.Property();
                simPropertyContactId.Key = 'SFDC_ID';
                simPropertyContactId.Value = contactToForward.Id;
            
                //Configuration_Parameter__c cfgPLink = [select Value__c from Configuration_Parameter__c where Key__c='AW Forward Code of Conduct Url' and Type__c='Url'];
                SIM.Property simPropertyLink = new SIM.Property();
                simPropertyLink.Key = 'FORWARD_COC_LINK';
                simPropertyLink.Value = FXSettings__c.getValues('FXSettings').Forward_Code_of_Conduct_Url__c + '?params'; 
                
                System.debug('## simPropertyContactId : key : '+simPropertyContactId.Key);
                System.debug('## simPropertyContactId : value : '+simPropertyContactId.Value);
                System.debug('## simPropertyLink : key : '+simPropertyLink.Key);
                System.debug('## simPropertyLink : value : '+simPropertyLink.Value);    
                        
                request_x.InputData = new SIM.ArrayOfProperty();
                request_x.InputData.Property = new List<SIM.Property>();
                request_x.InputData.Property.add(simPropertyContactId);
                request_x.InputData.Property.add(simPropertyLink);
    
                SIM.TriggerCampaignForUserResponse_element tcfuResponse = iSoap.TriggerCampaignForUser(request_x.List1,request_x.GateName,request_x.InputData);
                
                System.debug('## response_x : Result : '+tcfuResponse.TriggerCampaignForUserResult);
                System.debug('## response_x : Error : '+tcfuResponse.ErrorStr);
                System.debug('## >>> SIM Call End : END <<<');
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=3;
                stex.setMessage('Error in sending of parameters to SIM : '+ex.getMessage());
                stex.Error='Error in sending of parameters to SIM : '+ex.getMessage();
                throw stex;   
            }
        }catch(Generic.StandardException sex)
        {
            output.returnCode = sex.ReturnCode;
            output.error = sex.Error;
            System.debug('## '+sex.getMessage());            
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            System.debug('## '+ex.getMessage());
        }
        return output;
    }   
    
    webservice static Generic.StandardOutput DeleteCertification(DeleteCertificationInput input)
    {
        //Remove a certification
        Generic.StandardOutput output = new Generic.StandardOutput();
        Savepoint sp = Database.setSavepoint();
        try{
            try
            {
                System.debug('## >>> Delete Certificate <<<');
                Certificate__c certifToDelete = [select Id from Certificate__c where Certificate__c.Id=:input.CertificationIdToRemove];
                delete certifToDelete;
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=2;
                stex.setMessage('Error in deleting of certificate : '+ex.getMessage());
                stex.Error='Error in deleting of certificate : '+ex.getMessage();
                throw stex;   
            }  
            try
            {
                System.debug('## >>> Decrease the certification level if needed <<<');
                Account account = [select Id,Level_of_Certification__c from Account where Account.AccountNumber=:input.AccountNumber];
                if (Integer.valueOf(account.Level_of_Certification__c)>1)
                {
                    //To avoid to unusefull call webservices we do previously this test:
                    List<Certificate__c> certifs = [select Id from Certificate__c where Certificate__c.Account__c=:account.Id];
                    if (certifs.size()>0)
                    {
                        List<TcdCertificate> tcdCertifs = TcdParser.queryCertificates(input.AccountNumber);
                        boolean atLeastOneCertifActive = false;
                        for(TcdCertificate tcdCertif : tcdCertifs)
                        {
                        
                            if(tcdCertif.certif.Expiration_Date__c>Date.today())
                            {
                                atLeastOneCertifActive = true;
                                break;
                            }
                        }
                        if(!atLeastOneCertifActive)
                        {
                            account.Level_of_Certification__c = '1';
                            update account;
                        }
                    }
                }
            }catch(Generic.StandardException sex)
            {
                output.returnCode = sex.ReturnCode;
                output.error = sex.Error;
                System.debug('## '+sex.getMessage());               
            }catch(Exception ex){
                Generic.StandardException stex=new Generic.StandardException();
                stex.ReturnCode=3;
                stex.setMessage('Error in decreasing of certificate : '+ex.getMessage());
                stex.Error='Error in decreasing of certificate : '+ex.getMessage();
                throw stex;   
            } 
            
        }catch(Exception ex){
            output.returnCode = 1;
            output.error = ex.getMessage();
            Database.rollback(sp);
        }
        return output;
    }   
}