global public with sharing class TlrReportingPoint 
 {
    /* =============================================================================================
    // Input object definition    
    ============================================================================================= */
  global public class CreateComplaintInput
    {
      webservice public String ComplainerLogin;
      webservice public String ComplainerTlRNumber;   
      webservice public String DefaulterTlRNumber;
      webservice public String AdditionalComments;
      webservice public string ComplaintReason;
      /*
      webservice public String ComplaintArea;
      webservice public String ComplaintSubArea;
      webservice public String ComplaintSubArea2;
      */
    }
    
    /* =============================================================================================
    // Output object definition    
    ============================================================================================= */
  global public class CreateComplaintOutput 
    {      
      webservice public Id CaseId;
      webservice public Integer ReturnCode=0;
      webservice public String Error;  
    }
  
   global public class ComplaintReasonOutput 
   {      
      webservice public string ComplaintReason;
      webservice public Integer ReturnCode=0;
      webservice public String Error;    
   }
   private class RPServiceException extends Exception {
        
    } 
  
   
    //webservice static ComplaintReasonOutput CommplaintType(){
    
    //Schema.DescribeFieldResult fieldResult = Account.Complaint_Reason__c.getDescribe();
    //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    //ComplaintReasonOutput ComplReason =   new ComplaintReasonOutput();
    //}
    
    webservice static ComplaintReasonOutput getComplaintReason() {
    ComplaintReasonOutput ComplaintArea = new ComplaintReasonOutput();
    String IsDMS='N'; 
    //Schema.DescribeFieldResult fieldResult = OfficeLocation__c.Country__c.getDescribe();
    //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    try {
    Schema.DescribeFieldResult fieldResult = Case.Complaint_Reason__c.getDescribe();
    LIST <Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    if(ple!= null) {
        ComplaintArea.ComplaintReason = '';
    for (Schema.PicklistEntry CurrentPle: ple){
        
        if(CurrentPle.getLabel()!= null && CurrentPle.getLabel()!= 'DMS Full Service' && CurrentPle.getLabel()!= 'DMS Limited Service'){
        if (CurrentPle.getLabel()=='Payment'){
             IsDMS ='Y';    
             } else {
             IsDMS ='N';    
             } 
        ComplaintArea.ComplaintReason += CurrentPle.getLabel()+';'+IsDMS+';';
                    }
                }   
            }
        } catch(Exception ex){
        ComplaintArea.ReturnCode = 1;
        ComplaintArea.Error = ex.getMessage();
    }   
    return ComplaintArea;
    }
    
     
   
    webservice static CreateComplaintOutput CreateComplaint(CreateComplaintInput input){
    
    /*
    Migrate from free basic to others  
    */
    // Create savepoint to be able to roll back to        
    SavePoint sp = Database.setSavepoint();
    
    // Create result container
    Database.Saveresult ComplaintDmlResult;
    
    //Init a Contact        
    //Contact c = new Contact();
                    
    // Init a Case        
    Case Complaint = new Case();
    
    //Complainer
    //Account ComplainerAccount = new account();
    
    //Defaulter 
    //Account DefaulterAccount = new account ();
    
    //Contact MyContact =[Select Id, Account.Teleroute_Number__c,Email,Username__c FROM Contact Where Username__c=:CreateComplaintInput.ComplainerLogin];
    //Serach if the complainer exists
    String ContactMessage;
    String ComplAccountMessage;
    String DefaultAccountMessage;
    String ComplaintMessage;
    System.debug('Complaint Input'+input);
    
    CreateComplaintOutput ComplaintOutput = new CreateComplaintOutput();
    
    //Serach Complainer Account
    Account [] ComplAccount =[Select Id, Teleroute_Number__c FROM Account where Teleroute_Number__c=: input.ComplainerTlRNumber];
    System.debug('Complainer Account'+ComplAccount);
    if (ComplAccount.size() == 1){
        ComplAccountMessage = 'Complainer found';
            //Serach Complainer Contact
            Contact [] ComplContact =[Select Id, AccountId, Username__c FROM Contact where AccountId =: ComplAccount[0].Id AND(Username__c=: input.ComplainerLogin OR Id=:input.ComplainerLogin)];
            System.debug('Complainer Contact'+ComplContact);
            if(ComplContact.size() == 1){
                ContactMessage = 'Contact found';
                //Serach Defaulter Account
                    Account [] DefaultAccount =[Select Id, Teleroute_Number__c FROM Account where Teleroute_Number__c=: input.DefaulterTlRNumber];
                    System.debug('Defaulter Account'+DefaultAccount);
                    if (DefaultAccount.size() == 1){
                    DefaultAccountMessage = 'Defaulter found';                  
                    // Create New Complaint
                        Complaint.Status ='New';
                        Complaint.Priority='Medium';
                        Complaint.Type='Safe Market Place';
                        Complaint.Origin ='Web';
                        Complaint.AccountId =ComplAccount[0].Id;
                        Complaint.ContactId = ComplContact[0].Id;
                        Complaint.Defaulter_Account_Name__c=DefaultAccount[0].Id;
                        Complaint.Description =input.AdditionalComments;
                        //Complaint.Complaint_Area__c=input.ComplaintArea;
                        //Complaint.Complaint_Sub_Area__c=input.ComplaintSubArea;
                        Complaint.Complaint_Reason__c =input.ComplaintReason;
                        Complaint.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('TLR Complaint Case').getRecordTypeId();
                        try {
                            ComplaintDmlResult = Database.insert(Complaint);
                                             
                            ComplaintMessage = 'Complaint created';
                            ComplaintOutput.CaseId =Complaint.Id; 
                            // Create New activity
                            Case  MyCase = [Select Id from Case where Id=: Complaint.Id];
                            if (MyCase.Id != null){
                            Task newTask = new Task();
                            newTask.WhatId = Complaint.Id;
                            newTask.WhoId = Complaint.ContactId;
                            newTask.Subject_Group__c = 'Complaints';
                            newTask.Subject = 'FX web form';
                            newTask.Status = 'Completed';
                            newTask.Type = 'Administration';
                            newTask.Description =input.AdditionalComments;
                            insert newTask; 
                            } else{
                            ComplaintMessage ='Complaint not found';
                        
                            }                            
                                }catch(Exception ex){
                            ComplaintOutput.ReturnCode = 1;
                            ComplaintOutput.Error = ex.getMessage();
                            Database.rollback(sp);  
                            }
                    }else{
                    //DefaultAccountMessage ='Defaulter not found';
                    ComplaintOutput.Error='Defaulter not found';
                    ComplaintOutput.ReturnCode =4;
                    }
            }else{
            //ContactMessage ='Contact not found';
            ComplaintOutput.Error='Contact not found';
            ComplaintOutput.ReturnCode =3; 
            }
    }else{
        //ComplAccountMessage ='Complainer not found';
        ComplaintOutput.Error='Complainer not found';
        ComplaintOutput.ReturnCode =2; 
    }
    
    return ComplaintOutput;
    } 
    
}