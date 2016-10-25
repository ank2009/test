/*
* @ Description :- Class handles all before and after events of Lead object
* @ Author      :- HCL Technologies LTD
* @ Date        :- 11-01-2013 
**/

public without sharing class TLR_LeadTriggerHandler {
    
    private boolean isExecuting = false;
    ID recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('TLR Lead').getRecordTypeId();
    
    public TLR_LeadTriggerHandler(boolean isExecuting){
        isExecuting = isExecuting;
    }
    
    public void OnBeforeInsert(Lead[] newLeads, Lead[] oldLeads, 
                                Map <Id,Lead> newLeadMap,Map <Id,Lead> oldLeadMap){
        // EXECUTE BEFORE INSERT LOGIC
        tmsProviderValidator(newLeads);
    }

    public void OnAfterInsert(Lead[] newLeads, Lead[] oldLeads, 
                                Map <Id,Lead> newLeadMap,Map <Id,Lead> oldLeadMap){
        // EXECUTE AFTER INSERT LOGIC
       //TlrLeadAssignmentRules(newLeads);
    }

    public void OnBeforeUpdate(Lead[] newLeads, Lead[] oldLeads,
                                Map <Id,Lead> newLeadMap,Map <Id,Lead> oldLeadMap){
        // BEFORE UPDATE LOGIC
       // handleALCActivitiesOnLead(newLeads,oldLeads,newLeadMap,oldLeadMap);
       tmsProviderValidator(newLeads);
       
    }

    public void OnAfterUpdate(Lead[] newLeads, Lead[] oldLeads, 
                                Map <Id,Lead> newLeadMap,Map <Id,Lead> oldLeadMap){
        // AFTER UPDATE LOGIC
        TlrUpdateTotalNumberEmployee(newLeads,oldLeads);
    }

    public void OnBeforeDelete(Lead[] newLeads, Lead[] oldLeads, 
                                Map <Id,Lead> newLeadMap,Map <Id,Lead> oldLeadMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Lead[] newLeads, Lead[] oldLeads, 
                                Map <Id,Lead> newLeadMap,Map <Id,Lead> oldLeadMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Lead[] newLeads, Lead[] oldLeads, 
                            Map <Id,Lead> newLeadMap,Map <Id,Lead> oldLeadMap){
        // AFTER UNDELETE LOGIC
    }

    public boolean IsTriggerContext{
        get{ return isExecuting;}
    }
    
    /*
    * @ Description :- Method validate TMS fiels is selected or not.
    * @ Date        :- 26-04-2013
    **/
    
    public void tmsProviderValidator(Lead[] newLeads){
        ID recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('TLR Lead').getRecordTypeId();
    
        for (Lead lead :newLeads){
            if (newLeads[0].RecordTypeId == recordTypeId){
                if (lead.TMS_in_use__c == true){
                    if (lead.Name_TMS_used__c == null || lead.Name_TMS_used__c ==''){
                        lead.Name_TMS_used__c.addError('User must select TMS provider value or deselect TMS use check box.');
                    }else if(lead.Name_TMS_used__c == 'Other' && (lead.TMS_Other__c == null || lead.TMS_Other__c == '')){
                        lead.Name_TMS_used__c.addError('User must enter TMS Other value!');
                    }
                } else {
                    if (lead.Name_TMS_used__c != null && lead.Name_TMS_used__c !='None'){
                        lead.Name_TMS_used__c.addError('User must checked TMS in Use checkbox or select -NONE- in TMS Provider value.');
                    }
                }
                  if(lead.TMS_Other__c != null && lead.Name_TMS_used__c != 'Other'){
                        lead.TMS_Other__c.addError('User must select TMS Provider "Other" value or make TMS Other blank!');
                }
            }   
        }
    }
   
    /*
    * @ Description :- Merged TlrLeadAssignmentRules trigger
    * @ Date        :- 11-01-2013
    **/
    
    private void TlrLeadAssignmentRules(Lead[] newLeads){
        
         Map <String, LeadSource__c> LeadSources = LeadSource__c.getAll();
        List<String> websource = new List<String>();
        websource.addAll(LeadSources.keySet()); 
        
        List<Id> LeadIds = new List<Id>{};
       
        for (Lead theLead :newLeads) 
            LeadIds.add(theLead.Id);
        
        List<Lead> Leads = new List<Lead>{}; 
        for(Lead LId : [Select Id from Lead where Id in :LeadIds and LeadSource in :websource])
        {
            Database.DMLOptions dmo = new Database.DMLOptions();
 
            //dmo.assignmentRuleHeader.useDefaultRule = true;
            dmo.assignmentRuleHeader.assignmentRuleId = '01Q20000000Ie9F';
            LId.setOptions(dmo);
            
            Leads.add(LId);
        }

        Database.update(Leads);
    }
    
    /*
    * @ Description :- Merged TlrUpdateTotalNumberEmployee trigger
    * @ Date        :- 11-01-2013
    **/
    private void TlrUpdateTotalNumberEmployee(Lead[] newLeads, Lead[] oldLeads){
        
        List <Account> accountList = new List<Account>();
        for (Integer i = 0; i < newLeads.size(); i++){
            if (newLeads[i].IsConverted == true && oldLeads[i].isConverted == false){
                Set<Id> ConvertedAccountIds = new Set<Id>();
                for (Lead lead : newLeads){
                    ConvertedAccountIds.add(lead.ConvertedAccountId);
                }
                Map<Id, Account> MyAccount = new Map<Id, Account>([select Id, Total_employees__c from Account where Id in :ConvertedAccountIds]);      
                if(!newLeads.isEmpty()) {
                    for (Lead lead : newLeads)  {
                        for (Account Acc : MyAccount.values()) {
                            if (lead.NumberOfEmployees != null) {
                                Acc.Total_employees__c = lead.NumberOfEmployees;
                                //update Acc;
                                accountList.add(Acc);
                            }
                        }
                    }
                }
            }
        }
        if (accountList.size()>0){
            update accountList;
        }
        if (newLeads.size() == 1) {
            if ((newLeads[0].RecordTypeId == recordTypeId ) && (newLeads[0].Status == 'Dropped') && (oldLeads[0].Status != newLeads[0].Status)) {
                Lead lead = [Select l.Id,l.Status from Lead as l where l.Id=:newLeads[0].Id];
                lead.Dropped_Date__c=Date.today();
                update lead;
            }
        }   
    }
}