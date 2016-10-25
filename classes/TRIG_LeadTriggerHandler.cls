/** 
* @author       Andrey Gordienko (andrey_gordienko@epam.com)
* @date         2014 September 5
* @description  Trigger handler for Lead events
**/
public with sharing class TRIG_LeadTriggerHandler extends TRIG_TriggerHandlerAbstract 
{
    Id TLRLeadRecordTypeId;
    public boolean IsTriggerContext
    {
        get
        {
            return isTriggerExecuting;
        }
    }
    
    private class CountryValidationException extends Generic.SObjectValidationException 
    {
        public CountryValidationException(string message, SObject obj)
        {
            super(message, obj);
        }
    }
    
    public TRIG_LeadTriggerHandler (boolean isTriggerExecuting)
    {
        super(isTriggerExecuting);
        TLRLeadRecordTypeId = TLR_RecordTypeHelper.getId('Lead', 'TLR Lead');
    }
    
    public override void OnBeforeInsert(List<sObject> newTriggerValues)
    {
        ValidatePhones(newTriggerValues);
        FillLocation(newTriggerValues);
    }
    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
    {
        TlrLeadAssignmentRules(newTriggerValues);
    }
    public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        FillLocation(newTriggerValues);
        ValidatePhones(newTriggerValues);
    }
    
    public override void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        TlrUpdateTotalNumberEmployee(newTriggerValues, oldTriggerValues);
       	TLR_EventAndTaskHelper.UpdateTaskOrEventSubjectFromLeadOrAccount(oldTriggerValues, newTriggerValues, oldTriggerValuesMap);
    }
    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
    {
    
    }
    public override void OnAfterDelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
    {

    }

    public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
    {
    
    }
    
    private void TlrLeadAssignmentRules(List<Lead> newTriggerValues)
    {
        Map <String, LeadSource__c> LeadSources = LeadSource__c.getAll();
        List<String> websource = new List<String>();
        websource.addAll(LeadSources.keySet());
        List<Lead> LeadsToUpdate = new List<Lead>{}; 
        for(Lead currLead : [Select Id from Lead where Id in :newTriggerValues and LeadSource in :websource])
        {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            dmo.EmailHeader.triggerUserEmail = true;
            currLead.setOptions(dmo);
            LeadsToUpdate.add(currLead);
        }
        Database.update(LeadsToUpdate);
    }
    
    /**
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2015 Jule 26
    * @description  method for fill location field
    */
    private void FillLocation(List<Lead> newTriggerValues)
    {
        List <Schema.PicklistEntry> lstValues = Schema.SObjectType.Lead.fields.getMap().get('Geographical_Organization__c').getDescribe().getPicklistValues();
        Map<String, Country_Parameters__c> existingLocation = Country_Parameters__c.getAll();
        for(Lead lead : newTriggerValues)
        {
            // Complete Geographical Organization
            String pickVal = '';
            if(!string.isEmpty(lead.Country))
            {
                for (Schema.PicklistEntry value : lstValues)
                {
                    if(lead.Country != null)
                    {
                        if (value.getLabel().startsWith(lead.Country))
                        {
                            pickVal = value.getValue();
                            break;
                        }
                    }
                }
                if(pickVal == '')
                {
                    pickVal = 'Other -> Other Countries -> Other';
                }
                if(existingLocation.containsKey(lead.Country))
                {
                    lead.Location__c = existingLocation.get(lead.Country).Location__c;
                }
                lead.Geographical_Organization__c = pickVal;
            } // if Country is empty
        } // for leads
    }
        
    /**
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2014 September 5
    * @description  Validation of phone number format and validity of country code. Moved to trigger since we need capability to quickly add new phone code
    *               using validation rules we can't do so because of many occurences.
    */
    private void ValidatePhones(List<Lead> leads)
    {
        Set<integer> validCountryCodes = new Set<Integer>();
        for(Country_Parameters__c cp : [SELECT Name, Phone_code__c FROM Country_Parameters__c])
            validCountryCodes.add(integer.valueOf(cp.Phone_code__c));
        
        for(Lead l : leads)
        {
            if(string.isNotEmpty(l.Phone))
            {
                if(!Utilities.ValidatePhone(l.Phone, validCountryCodes))
                {
                    l.Soft_Validation_Phone__c = Utilities.getPhoneValidationErrorMessage();
                }
                else
                {
                    l.Soft_Validation_Phone__c = '';
                }
            }
            else
            {
                l.Soft_Validation_Phone__c = '';
            }
            if(string.isNotEmpty(l.Fax))
                if(!Utilities.ValidatePhone(l.Fax, validCountryCodes))
                    l.Fax.addError(Utilities.getPhoneValidationErrorMessage());
            if(string.isNotEmpty(l.MobilePhone))
            {
                if(!Utilities.ValidatePhone(l.MobilePhone, validCountryCodes))
                {
                    l.Soft_Validation_Mobile_Phone__c = Utilities.getPhoneValidationErrorMessage();
                }
                else
                {
                    l.Soft_Validation_Mobile_Phone__c = '';
                }
            }
            else
            {
                l.Soft_Validation_Mobile_Phone__c = '';
            }
        }
    } //ValidatePhones

    
    /*
    * @ Description :- Merged TlrUpdateTotalNumberEmployee trigger
    * @ Date        :- 11-01-2013
    **/
    private void TlrUpdateTotalNumberEmployee(Lead[] newLeads, Lead[] oldLeads)
    {
        List <Account> accountList = new List<Account>();
        for (Integer i = 0; i < newLeads.size(); i++)
        {
            if (newLeads[i].IsConverted == true && oldLeads[i].isConverted == false)
            {
                Set<Id> ConvertedAccountIds = new Set<Id>();
                for (Lead lead : newLeads)
                    ConvertedAccountIds.add(lead.ConvertedAccountId);
                
                Map<Id, Account> MyAccount = new Map<Id, Account>([select Id, Total_employees__c from Account where Id in :ConvertedAccountIds]);
                if(!newLeads.isEmpty()) 
                {
                    for (Lead lead : newLeads)  
                    {
                        for (Account Acc : MyAccount.values()) 
                        {
                            if (lead.NumberOfEmployees != null) 
                            {
                                Acc.Total_employees__c = lead.NumberOfEmployees;
                                //update Acc;
                                accountList.add(Acc);
                            }
                        }
                    }
                }
            }
        }
        if (accountList.size()>0)
            update accountList;
            
        if (newLeads.size() == 1) 
        {
            if ((newLeads[0].RecordTypeId == TLRLeadRecordTypeId ) && (newLeads[0].Status == 'Dropped') && (oldLeads[0].Status != newLeads[0].Status)) 
            {
                Lead lead = [Select l.Id,l.Status from Lead as l where l.Id=:newLeads[0].Id];
                lead.Dropped_Date__c=Date.today();
                update lead;
            }
        }   
    }
}