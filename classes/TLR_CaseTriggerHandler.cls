/*
* @ Description :- Class handles all before and after events of Case object
* @ Author      :- HCL Technologies LTD
* @ Date        :- 09-01-2013 
**/

public without sharing class TLR_CaseTriggerHandler {
    public Boolean isExecuting;
    public Integer size;   
    /**
    *TLR_CaseTriggerHandler Constructor
    *@param isExecuting: Returns true if the current context for the Apex code is a trigger, not a Visualforce page
    *@param size: The total number of records in a trigger invocation, both old and new.
    **/
    public TLR_CaseTriggerHandler(boolean isExecuting,Integer size){
        this.isExecuting = isExecuting;
        this.size = size;
    }
    /**
    *onBeforeInsert method is used to perform the before insert operation
    *@param newCases case list with new values
    **/ 
    public void OnBeforeInsert(Case[] newCases){
        // EXECUTE BEFORE INSERT LOGIC
        system.debug('Case Before insert is called################');
        //Call TlrlinkCaseToDefaulterAccount logic
        TlrlinkCaseToDefaulterAccount(newCases);
        // call TlrFillAndUpdateCasePriority Logic
        TlrFillAndUpdateCasePriority(newCases);
        //call TlrlinkCaseToEntitlement logic
        TlrlinkCaseToEntitlement(newCases);
    }
    /**
    *OnAfterInsert method is used to perform the after insert operation
    *@param newCases case list with new values
    *@param oldCases case list with old values
    *@param newCases case map with new map of case object and id
    *@param oldCases case map with old values of case object and id
    **/
    public void OnAfterInsert(Case[] newCases, Case[] oldCases, Map <Id,Case> newCaseMap,Map <Id,Case> oldCaseMap){
        // EXECUTE AFTER INSERT LOGIC
        // call TlrNumberOf_CHOpen_L12M_DM_L12M logic
        TlrNumberOf_CHOpen_L12M_DM_L12M(newCases,oldCases,newCaseMap,oldCaseMap);
        // call TlrMaxAndMinSanctionDate logic
        TlrMaxAndMinSanctionDate(newCases,oldCases,newCaseMap,oldCaseMap);
    }
    /**
    *OnBeforeUpdate method is used to perform the before update operation
    *@param newCases case list with new values
    *@param oldCases case list with old values
    *@param newCases case map with new map of case object and id
    *@param oldCases case map with old values of case object and id
    **/
    public void OnBeforeUpdate(Case[] newCases, Case[] oldCases, Map <Id,Case> newCaseMap,Map <Id,Case> oldCaseMap){
        // BEFORE UPDATE LOGIC
        //call TlrCreateSanctionActivities logic
        TlrCreateSanctionActivities(newCases);
        //Call TlrlinkCaseToDefaulterAccount logic
        TlrlinkCaseToDefaulterAccount(newCases);
       // call TlrFillAndUpdateCasePriority Logic
        TlrFillAndUpdateCasePriority(newCases);   
    } 
    /**
    *OnAfterUpdate method is used to perform the after update operation
    *@param newCases case list with new values
    *@param oldCases case list with old values
    *@param newCases case map with new map of case object and id
    *@param oldCases case map with old values of case object and id
    **/
    public void OnAfterUpdate(Case[] newCases, Case[] oldCases, Map <Id,Case> newCaseMap,Map <Id,Case> oldCaseMap){
        // AFTER UPDATE LOGIC
        // call TlrNumberOf_CHOpen_L12M_DM_L12M logic
        TlrNumberOf_CHOpen_L12M_DM_L12M(newCases,oldCases,newCaseMap,oldCaseMap);
        // call TlrMaxAndMinSanctionDate logic
        TlrMaxAndMinSanctionDate(newCases,oldCases,newCaseMap,oldCaseMap);
        //call TlrCaseSubmitForApproval logic
        TlrCaseSubmitForApproval(newCases,oldCases,newCaseMap,oldCaseMap);
    }
    /**
    *OnBeforeDelete method is used to perform the before delete operation
    *@param old case map with old values
    **/
    public void OnBeforeDelete(Map <Id,Case> oldCaseMap){
        // BEFORE DELETE LOGIC
    }
    /**
    *OnAfterDelete method is used to perform the after delete operation
    *@param old case map with old values
    **/
    public void OnAfterDelete(Map <Id,Case> oldCaseMap){
        // AFTER DELETE LOGIC
        // call TlrNumberOf_CHOpen_L12M_DM_L12M logic
        TlrNumberOf_CHOpen_L12M_DM_L12M(oldCaseMap);
        // call TlrMaxAndMinSanctionDate logic
        TlrMaxAndMinSanctionDate(oldCaseMap);
    }
    /**
    *OnUndelete method is used to perform the after undelete operation
    *@param old case map with old values
    **/
    public void OnUndelete(Map <Id,Case> oldCaseMap){
        // AFTER UNDELETE LOGIC
    } 
    
    //Implement TlrCreateSanctionActivities Trigger Logic-BEFORE UPDATE event
    public void TlrCreateSanctionActivities(Case[] newCases){       
        List<Task> task = new List<Task>();
        if(! newCases.isEmpty()){
            for(Case objCase: newCases){
                
             if ((objCase.Status == 'Action Applied')&&(objCase.Action_Start_Date__c !=null) && (objCase.TlrGenerateSanctionActivities__c)) {
                    System.debug('triggerfire');
                    task.add(new Task(                  
                        
                        whatid=objCase.Id,
                        OwnerId = objCase.OwnerId,
                        WhoId =objCase.ContactId,
                        Description = 'Activate Sanction',
                        Priority = 'Normal',
                        Type = 'Other',
                        Status = 'Not Started',
                        ActivityDate = objCase.Action_Start_Date__c,
                        Subject='Activate Sanction'
                        ));
                       //newCase[i].Disable_Sanction__c=false; 
                    }             
                    if ((objCase.Status == 'Action Applied')&&(objCase.Action_End_Date__c !=null) && (objCase.TlrGenerateSanctionActivities__c)) {
                    System.debug('triggerfire');
                    task.add(new Task(                  
                        
                        whatid=objCase.Id,
                        OwnerId = objCase.OwnerId,
                        WhoId =objCase.ContactId,
                        Description = 'Deactivate Sanction',
                        Priority = 'Normal',
                        Type = 'Other',
                        Status = 'Not Started',
                        ActivityDate = objCase.Action_End_Date__c,
                        Subject='Deactivate Sanction'
                        ));
                       //newCase[i].Disable_Sanction__c=false; 
                    }     
               }
          }
          if(!task.isEmpty()){
            try{
                insert task;
            }catch(Exception e){
                System.debug('Task list insert Failed==>'+e);
            }
          }
    }//end of TlrCreateSanctionActivities method
    
    //Implement TlrlinkCaseToDefaulterAccount trigger logic- BEFORE INSERT,UPDATE
    public void TlrlinkCaseToDefaulterAccount(Case[] newCases){
        Id[] Ids = new Id[]{};
        if(! newCases.isEmpty()){
             // Loop through the cases
            for (Case c : newCases) {
                // Add the contact to the list
                Ids.add(c.Defaulter_Contact_Name__c);
            }
            // get Contacts bases on id's and put them in a map
            Map<Id, Contact> ContactMap = new Map<Id, Contact>([Select Id, Account.Id From Contact Where Id In: Ids]);    
            if(! Ids.isEmpty()){
                // Loop through the casesand add the id tot he case
                for(Case myCase : newCases){
                  if(myCase.Defaulter_Contact_Name__c <> null){
                      myCase.Defaulter_Account_Name__c = ContactMap.get( myCase.Defaulter_Contact_Name__c).Account.Id;  
                    }
                }
            }
        }       
    }//end of voidTlrlinkCaseToDefaulterAccount method
    
   //Implement TlrFillAndUpdateCasePriority trigger logic- BEFORE INSERT,UPDATE
   public void TlrFillAndUpdateCasePriority(Case[] newCases){
    if(! newCases.isEmpty()){
         // Loop through the cases
        for (Case c : newCases) {
             if ((c.Case_Type__c =='Complaint' || c.Case_Type__c =='Debt Mediation') && 
                 (c.Complaint_Reason__c=='Legal Issues'||c.Complaint_Reason__c=='Payment' || c.Complaint_Reason__c=='Offer Content' ||
                  c.Complaint_Reason__c=='Offer Handling' || c.Complaint_Reason__c=='Professionnal Conduct' || 
                  c.Complaint_Reason__c=='Company not reachable' ||c.Complaint_Reason__c=='Delivery & Quality' || 
                  c.Complaint_Reason__c=='Cash Collection' || c.Complaint_Reason__c=='Safe Market Place' || 
                  c.Complaint_Reason__c =='DMS Full Service' )){
            
                         c.Priority = 'Medium'; 
              }  
              if (c.Case_Type__c =='Complaint' && c.Complaint_Reason__c=='Rumours') {        
                      c.Priority = 'Low';         
              }
              if (c.Case_Type__c =='Complaint' && c.Complaint_Reason__c=='Fraud & Criminality') {          
                   c.Priority = 'High';  
             }
          }
       }
    }//end of method TlrFillAndUpdateCasePriority
   
   //Implement TlrlinkCaseToEntitlement trigger Logic-BEFORE INSERT
   public void TlrlinkCaseToEntitlement(Case[] newCases){
    // get entitlements bases on id's and put them in a map
    List<Entitlement> Entt1List =[Select Id From Entitlement Where Name = 'TLR Support SLO'];    
    List<Entitlement> Entt2List =[Select Id From Entitlement Where Name = 'TLR Complaint SLO'];
    List<Entitlement> Entt3List =[Select Id From Entitlement Where Name = 'TLR DMS SLO'];
    // Loop through the casesand add the id tot he case
    if(! newCases.isEmpty()){
    // Loop through the cases
        for(Case myCase : newCases){
            if(myCase.EntitlementId == null && myCase.Case_Type__c =='Customer Support' && !Entt1List.isEmpty()){
                myCase.EntitlementId= Entt1List.get(0).Id;  
            }
            if(myCase.EntitlementId == null && myCase.Case_Type__c =='Complaint'&& !Entt2List.isEmpty()){
                myCase.EntitlementId= Entt2List.get(0).Id;
                myCase.Handling_Side__c='Complainer';  
            }
            if(myCase.EntitlementId == null && myCase.Case_Type__c =='Debt Mediation'&& !Entt3List.isEmpty()){
                myCase.EntitlementId= Entt3List.get(0).Id;
                myCase.Handling_Side__c='Complainer';   
            }
         }
      } 
   }// end of TlrlinkCaseToEntitlement method
  
  //Implement TlrNumberOf_CHOpen_L12M_DM_L12M trigger logic-AFTER INSERT,UPDATE
  public void TlrNumberOf_CHOpen_L12M_DM_L12M(Case[] newCases, Case[] oldCases, Map <Id,Case> newCaseMap,Map <Id,Case> oldCaseMap){  
    if (UpdateTriggers.updateTriggerToBeCalled()){
        // get list of accounts
        Set<ID> acctIds = new Set<ID>();
        for (Case cse : newCases) {
             acctIds.add(cse.Defaulter_Account_Name__c);
        }
         if(! acctIds.isEmpty()){
            TlrNumberOf_CHOpen_L12M_DM_L12M_CommonMethod(acctIds);
         }          
     }
  }//end of TlrNumberOf_CHOpen_L12M_DM_L12M
  
  //Implement TlrNumberOf_CHOpen_L12M_DM_L12M trigger logic-AFTER DELETE
  public void TlrNumberOf_CHOpen_L12M_DM_L12M(Map <Id,Case> oldCaseMap){  
    if (UpdateTriggers.updateTriggerToBeCalled()){
        // get list of accounts
        Set<ID> acctIds = new Set<ID>();
        for (Case cse : oldCaseMap.values()) {
             acctIds.add(cse.Defaulter_Account_Name__c);
        }
        if(! acctIds.isEmpty()){
            TlrNumberOf_CHOpen_L12M_DM_L12M_CommonMethod(acctIds);
         }      
    }
  }//end of TlrNumberOf_CHOpen_L12M_DM_L12M method
  //This is the TlrNumberOf_CHOpen_L12M_DM_L12M_CommonMethod call from TlrNumberOf_CHOpen_L12M_DM_L12M methods
  @future
  public static void TlrNumberOf_CHOpen_L12M_DM_L12M_CommonMethod(Set<ID> acctIds){
    // Number_CH_Open__c
        Map<ID, Case> casesForAccountsCH = new Map<ID, Case>([select Id , Defaulter_Account_Name__c from Case where Defaulter_Account_Name__c in :acctIds AND RecordType.Name='TLR Complaint Case' AND Status <>'Closed' AND Is_Counted_Star_Index__c=true]);
        Map<ID, Account> acctsToUpdateCH = new Map<ID, Account>([select Id , Number_CH_Open__c from Account where Id in :acctIds]);
                                                                    
        for (Account acctCH : acctsToUpdateCH.values())
        {
            Set<ID> caseIdsCH = new Set<ID>();
            for (Case cseCH : casesForAccountsCH.values()) {
                if (cseCH.Defaulter_Account_Name__c == acctCH.Id)
                    caseIdsCH.add(cseCH.Id);
            }
            if (acctCH.Number_CH_Open__c != caseIdsCH.size())
                acctCH.Number_CH_Open__c = caseIdsCH.size();
        }
        // CH_LM12__c
        Map<ID, Case> casesForAccountsCHL12M = new Map<ID, Case>([select Id , Defaulter_Account_Name__c from Case where Defaulter_Account_Name__c in :acctIds AND RecordType.Name='TLR Complaint Case' AND NumberDays__c <=360 AND Is_Counted_Star_Index__c =true]);
        Map<ID, Account> acctsToUpdateCHL12M = new Map<ID, Account>([select Id ,CH_LM12__c from Account where Id in :acctIds]);
                                                                    
        for (Account acctCHL12M : acctsToUpdateCHL12M.values()) {
            Set<ID> caseIdsCHL12M = new Set<ID>();
            for (Case cseCHL12M : casesForAccountsCHL12M.values()) {
                if (cseCHL12M.Defaulter_Account_Name__c == acctCHL12M.Id)
                    caseIdsCHL12M.add(cseCHL12M.Id);
            }
            if (acctCHL12M.CH_LM12__c != caseIdsCHL12M.size())
                acctCHL12M.CH_LM12__c = caseIdsCHL12M.size();
        }

        // Number_DM_Open__c
        Map<ID, Case> casesForAccountsDM = new Map<ID, Case>([select Id , Defaulter_Account_Name__c from Case where Defaulter_Account_Name__c in :acctIds AND RecordType.Name='TLR DMS Case' AND Status <>'Closed' AND Is_Counted_Star_Index__c=true]);
        Map<ID, Account> acctsToUpdateDM = new Map<ID, Account>([select Id , Number_DM_Open__c from Account where Id in :acctIds]);
                                                                    
        for (Account acctDM : acctsToUpdateDM.values())
        {
            Set<ID> caseIdsDM = new Set<ID>();
            for (Case cseDM : casesForAccountsDM.values()) {
                if (cseDM.Defaulter_Account_Name__c == acctDM.Id)
                    caseIdsDM.add(cseDM.Id);
            }
            if (acctDM.Number_DM_Open__c != caseIdsDM.size())
                acctDM.Number_DM_Open__c = caseIdsDM.size();
        }
        //DM_L12M__c
        Map<ID, Case> casesForAccountsDML12M = new Map<ID, Case>([select Id , Defaulter_Account_Name__c from Case where Defaulter_Account_Name__c in :acctIds AND RecordType.Name='TLR DMS Case' AND NumberDays__c <=360 AND Is_Counted_Star_Index__c=true]);
        Map<ID, Account> acctsToUpdateDML12M = new Map<ID, Account>([select Id ,DM_L12M__c from Account where Id in :acctIds]);
                                                                    
        for (Account acctDML12M : acctsToUpdateDML12M.values()) {
            Set<ID> caseIdsDML12M = new Set<ID>();
            for (Case cseDML12M : casesForAccountsDML12M.values()) {
                if (cseDML12M.Defaulter_Account_Name__c == acctDML12M.Id)
                    caseIdsDML12M.add(cseDML12M.Id);
            }
            if (acctDML12M.DM_L12M__c != caseIdsDML12M.size())
                acctDML12M.DM_L12M__c = caseIdsDML12M.size();
        }
        
        if ((acctsToUpdateCH.size() > 0 || acctsToUpdateCHL12M.size() > 0) || (acctsToUpdateDM.size() > 0 || acctsToUpdateDML12M.size() > 0))
        {
            UpdateTriggers.doNotCallUpdateTrigger();
            try{
                update acctsToUpdateCH.values();
                update acctsToUpdateCHL12M.values();
                update acctsToUpdateDM.values();
                update acctsToUpdateDML12M.values();
            }catch(Exception ex){
                System.debug('Account Update Failed on Case=>'+ex);
            }
        }  
  }//end of TlrNumberOf_CHOpen_L12M_DM_L12M_CommonMethod
 
    //Implement TlrMaxAndMinSanctionDate Trigger logic-AFTER INSERT,UPDATE
    public void TlrMaxAndMinSanctionDate(Case[] newCases, Case[] oldCases, Map <Id,Case> newCaseMap,Map <Id,Case> oldCaseMap){
        // get list of accounts
        Set<ID> acctIds = new Set<ID>();
        for (Case cse : newcases) {
            acctIds.add(cse.Defaulter_Account_Name__c);
        }
        if(!acctIds.isEmpty()){
            // call TlrMaxAndMinSanctionDate_CommonMethod
            TlrMaxAndMinSanctionDate_CommonMethod(acctIds);
        }
    } 
    //Implement TlrMaxAndMinSanctionDate Trigger logic-AFTER DELETE
    public void TlrMaxAndMinSanctionDate(Map <Id,Case> oldCaseMap){
     // get list of accounts
        Set<ID> acctIds = new Set<ID>();
        for (Case cse : oldCaseMap.values()) {
            acctIds.add(cse.Defaulter_Account_Name__c);
        }   
        if(!acctIds.isEmpty()){
            //call TlrMaxAndMinSanctionDate_CommonMethod
            TlrMaxAndMinSanctionDate_CommonMethod(acctIds);
        }
    }  
    //Implement TlrMaxAndMinSanctionDate_CommonMethod logic
    public void TlrMaxAndMinSanctionDate_CommonMethod(Set<ID> acctIds){
        ID DMSrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TLR DMS Case').getRecordTypeId(); 
        ID CHrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TLR Complaint Case').getRecordTypeId(); 
        Map<ID, Account> acctsToUpdate = new Map<ID, Account>([select Id, Last_IC_Closure_Date__c from Account where Id in: acctIds]);
        
        if(acctsToUpdate.size()>0){
            for(Id AccId: acctsToUpdate.keySet()){
                
                AggregateResult maxi= [select MAX(ClosedDate) CloDate from Case where Defaulter_Account_Name__c =: AccId]; 
                Datetime MaxCloDate =(Datetime)maxi.get('CloDate');
                if(MaxCloDate != null){
                    acctsToUpdate.get(AccId).Last_IC_Closure_Date__c = Date.NewInstance(MaxCloDate.year(), MaxCloDate.month(), MaxCloDate.day());
                } else {
                    acctsToUpdate.get(AccId).Last_IC_Closure_Date__c=null;
                }
            }
            try{
                update acctsToUpdate.values();  
            }catch(Exception ex){
                System.debug('Account Update Failed on Case=>'+acctsToUpdate.values());
            }
         }
     }//end of TlrMaxAndMinSanctionDate_CommonMethod    
     
     //Implement TlrCaseSubmitForApproval trigger logic-AFTER UPDATE
     public void TlrCaseSubmitForApproval(Case[] newCases, Case[] oldCases, Map <Id,Case> newCaseMap,Map <Id,Case> oldCaseMap){
        
        if(!newCases.isEmpty() && !oldCases.isEmpty()){     
            for(Case objcase : newCases){               
                if (objcase.Status == 'Pending Approval' && oldCaseMap.get(objcase.Id).Status =='Need Approval'){    
                    // create the new approval request to submit
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Submitted for approval. Please approve.');
                    req.setObjectId(objcase.Id);
                    // submit the approval request for processing
                    Approval.ProcessResult result = Approval.process(req);
                    // display if the reqeust was successful
                    System.debug('Submitted for approval successfully: '+result.isSuccess());
                    // Create a new task and  assign it to the manager
                 }
            }//end of for loop
        }
    }//end of TlrCaseSubmitForApproval method    

}//end of TLR_CaseTriggerHandler class