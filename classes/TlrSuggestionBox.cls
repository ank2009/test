global public with sharing class TlrSuggestionBox {

/* =============================================================================================
// Input object definition
============================================================================================= */
    global public class SBInputObject 
        {
        // Input fields
        webservice String contactlogin;
        webservice String contactPhone;
        webservice String contactEmailAddress;
        webservice String SBDescription;
        
        //var login = Inputs.GetProperty("login")
        //var phoneNumber = Inputs.GetProperty("phoneNumber");
        //var emailAddress = Inputs.GetProperty("emailAddress");    
        //var comments = Inputs.GetProperty("comments");
        }
    global public class SBOutputObject
        {
        webservice Integer ReturnCode =0;
        webservice String Error ='';    
    
        }   
    //global public class SBOutputObject 
    //  {   
    //    webservice Boolean overAllResult;
    //    webservice String overAllStatusMessage;
    //    webservice CaseResultObject CaseResult;
    //  }
    // global public class CaseResultObject {
    //    webservice Boolean CaseResult;
    //    webservice String[] CaseStatusMessages;
    //    webservice String CaseSfId;
    //}       
    
    global private class SBServiceException extends Exception {
        
    } 
    
/* =============================================================================================
// Validate Input
============================================================================================= */
    webservice static SBOutputObject CreateNewSB(SBInputObject SbIn) {
        
        if(SbIn.contactlogin == null || SbIn.contactlogin.trim() == '') {
            throw new SBServiceException('Login missing!');
        }
        if(SbIn.SBDescription == null || SbIn.SBDescription.trim() == '') {
            throw new SBServiceException('Suggestion description missing!');
        }
        
        // Create savepoint to be able to roll back to
        SavePoint sp = Database.setSavepoint();
        
        // For storing error state
        Boolean errorOccurred = false;
        
        // Create result containers
        Database.Saveresult CaseDmlResult;
        
        // Init a Contact
        Contact c = new Contact();
        
        // Init a Case
        Case myCase = new Case();

        
        // Init a Contact message
        String contactMessage = '';

        // 
        // Init a Case message
        String myCaseMessage = '';
        
        
        SBOutputObject SBOutput = new SBOutputObject();
        
        Contact[] myContacts =[Select Id, AccountId,Email,Username__c FROM Contact Where Username__c=:SbIn.contactlogin];
        
        if(myContacts.size()> 1){
            
            //contactMessage = 'More than 1 Contact record was found with Login'+SbIn.contactlogin+'!';
            SBOutput.Error ='More than 1 Contact record was found with Login'+SbIn.contactlogin+'!';
            //errorOccurred = true;
            SBOutput.ReturnCode= 1;
        } else if(myContacts.size() == 0) {
            //contactMessage = 'No Contact record found with Login '+SbIn.contactlogin+'!';        
            //errorOccurred = true;
            SBOutput.Error ='No Contact record found with Login '+SbIn.contactlogin+'!';
            SBOutput.ReturnCode= 1;
            }
                
        else{
        c = myContacts[0];
        myCase.ContactId = c.Id;
        myCase.AccountId = c.AccountId;
        myCase.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('TLR Support Case').getRecordTypeId();
        myCase.Subject = 'Suggestion Box';
        myCase.Description = SbIn.SBDescription;
        myCase.Status = 'New';
        myCase.Priority = 'Medium';
        myCase.Severity__c = 'Normal';
        myCase.Origin = 'Web';
        myCase.Type = 'Customer Suggestion Box'; 
        if(SbIn.contactPhone != null || SbIn.contactPhone.trim() != '') {
            myCase.FX_Phone__c = SbIn.contactPhone;
        }
        if(SbIn.contactEmailAddress != null || SbIn.contactEmailAddress.trim() != '') {
            myCase.FX_Email__c = SbIn.contactEmailAddress;
        }
        
        try {
            CaseDmlResult = Database.insert(myCase);
            myCaseMessage = 'SuggestionBox created';
            //Create activity
            
            // Create New  Activity
                            Case  SBox = [Select Id, ContactId, AccountId from Case where Id=: myCase.Id limit 1];
                            if (SBox.Id != null){
                            Task newTask = new Task();
                            newTask.WhatId = SBox.Id;
                            newTask.Subject_Group__c = 'Suggestion Box';
                            newTask.Subject = 'Form Submission';
                            newTask.Status = 'Completed';
                            newTask.Type = 'Web - Inbound';
                            newTask.WhoId = SBox.ContactId;
                            //newTask.WhatId = SBox.AccountId;
                            newTask.Description =SbIn.SBDescription+'\n'+SbIn.contactPhone+'\n'+SbIn.contactEmailAddress;
                            newTask.Display_In__c = 'Activities Only'; 
                            insert newTask;
                                    
                            } else{
                            myCaseMessage ='Suggestion box not found';
                        
                            }                            
                }
                catch(Exception e) {
                    //throw new SBServiceException('An exception occurred creating a Case. Error: '+e.getMessage());
                    //myCaseMessage = 'An exception occurred when creating a Case. Error: '+e.getMessage();
                    SBOutput.Error ='An exception occurred when creating a Case. Error: '+e.getMessage();
                    SBOutput.ReturnCode=1;
                    Database.rollback(sp);
                    //errorOccurred = true;
                }         
        }
        return SBOutput;
        
        //SBOutputObject retVal = new SBOutputObject();
        // Stores results for Suggestion Box
        //CaseResultObject retCase = new CaseResultObject();
        //retCase.CaseStatusMessages = new List<String>();
        
        // Populate the CaseResultObject
        //if(CaseDmlResult != null) {
            
        //    if(CaseDmlResult.isSuccess()) {
        //        retCase.CaseResult = true;
        //        retCase.CaseSfId = CaseDmlResult.getId();
        //        retCase.CaseStatusMessages.add(myCaseMessage);
                                    
        //    } else {
        //        retCase.CaseResult = false;
        //        retCase.CaseSfId = null;
        //        for(Database.Error dbe : CaseDmlResult.getErrors()) {
        //            retCase.CaseStatusMessages.add(dbe.getMessage());
        //        }
        //    }
        //} else {
            //
            // No DML occurred for the case, init an error result; DML should always occur
        //    retCase.CaseResult = false;
        //    retCase.CaseSfId = myCase.Id;
        //    retCase.CaseStatusMessages.add(myCaseMessage);
        //}
        
        //
        // Wrap things up:
        // 1) Finish the SuggestionBox
        // 2) Finish transaction (implicit) or roll back (explicit)
        //if(retCase.CaseResult && !errorOccurred) {
        //    retVal.overAllResult = true;
        //    retVal.overAllStatusMessage = 'Changes committed';      
        //} else {
        //    retVal.overAllResult = false;
        //    retVal.overAllStatusMessage = 'Changes rolled back';
        //    Database.rollback(sp);      
        //}
        //retVal.CaseResult = retCase;
        //return retVal;

   }
 }