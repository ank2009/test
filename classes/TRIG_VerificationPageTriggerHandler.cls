/**
* @author       Andrey Gordienko (andrey_gordienko@epam.com)
* @date         2016 April 16
* @description  Trigger handler for Verification Page
**/
public without sharing class TRIG_VerificationPageTriggerHandler extends TRIG_TriggerHandlerAbstract
{
    
    public boolean IsTriggerContext { get { return isTriggerExecuting;} }
    public TRIG_VerificationPageTriggerHandler (boolean isTriggerExecuting)
    {
        super(isTriggerExecuting);
          
    }
    
    public override void OnBeforeInsert(List<sObject> newTriggerValues)
    {
		this.SetChecksDoneBy(newTriggerValues, null); 
    } 
    
    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap) 
    { 
        this.SetStateOfVereficationPagesForAccount(newTriggerValues);
        this.LockUnlockRecord(newTriggerValues); 
    }

    public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues,
            Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        this.SetChecksDoneBy(newTriggerValues,oldTriggerValuesMap);
        this.LockUnlockRecord(newTriggerValues);
    }

    public override void OnAfterUpdate(List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    { 
        this.SetStateOfVereficationPagesForAccount(newTriggerValues);
    }
    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    public override void OnAfterDelete  (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) 
    {
       this.SetStateOfVereficationPagesForAccount(oldTriggerValues); 
    }    
    public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2016 April 17
    * @description  Fill 'Checks done by' field use following format 'UserName + Current Time'
    * 				in case of filling field Integrity_Check_Status__c
    **/
    private void SetChecksDoneBy(List<Verification_Page__c> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
    {      
        for(Verification_Page__c vp : newTriggerValues)
        {
            if(String.isEmpty(vp.Checks_done_by__c))
            {
                if(oldTriggerValuesMap != null)
                {
                    System.Debug('---------' + ((Verification_Page__c)oldTriggerValuesMap.get(vp.Id)).Integrity_Check_Status__c);
                }
                if(oldTriggerValuesMap == null && String.isNotEmpty(vp.Integrity_Check_Status__c) && vp.Integrity_Check_Status__c != 'Open')
                {
                    vp.Checks_done_by__c = Userinfo.getName() + ', ' + Datetime.now().format('dd/MM/yyyy hh:mm a');
                }
                else if(oldTriggerValuesMap != null && vp.Integrity_Check_Status__c != 'Open')
                {
                    string oldIntegrityStatus = ((Verification_Page__c)oldTriggerValuesMap.get(vp.Id)).Integrity_Check_Status__c;
                    if(String.isEmpty(oldIntegrityStatus) || oldIntegrityStatus == 'Open')
                    {
                    	vp.Checks_done_by__c = Userinfo.getName() + ', ' + Datetime.now().format('dd/MM/yyyy hh:mm a');
                    }
                }
            }
        }
    }
    
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2016 April 16
    * @description  Filling 'Has_Active_Verification_Page__c' field on Account level based on existence of Active VP
    **/
    private void SetStateOfVereficationPagesForAccount(List<Verification_Page__c> newTriggerValues)
    {
        Set<Id> accountIds = new Set<Id>();
        for(Verification_Page__c vp :newTriggerValues)
        {
            accountIds.add(vp.Account__c);
        }
        Map<Id,Account> accounts = new Map<Id,Account>([Select Id,Has_Active_Verification_Page__c From Account Where Id =: accountIds]);
        List<Verification_Page__c> vPages = [Select Id,Account__c, Integrity_Check_Completed__c From Verification_Page__c Where Account__c =: accounts.keySet()];
        Map<Id,List<Verification_Page__c>> accWitnVP = new Map<Id, List<Verification_Page__c>>();
        for(Verification_Page__c vp:vPages) 
        {
            if(!accWitnVP.containsKey(vp.Account__c))
            {
                accWitnVP.put(vp.Account__c, new List<Verification_Page__c>());
            }
            accWitnVP.get(vp.Account__c).add(vp);
        }
        Set<Account> accToUpdate = new Set<Account>();
        if(accWitnVP.size() == 0)
        {
            for(Account acc:accounts.values())
            {
                acc.Has_Active_Verification_Page__c = false;
            	accToUpdate.add(acc);
            }
        }
        for(Id accId : accWitnVP.keySet()) 
        {
            boolean hasActiveVP = false;
            for(Verification_Page__c vp :accWitnVP.get(accId)) 
            {
                if(vp.Integrity_Check_Completed__c == 'Active')
                { 
                    hasActiveVP = true;
                }
            }
            if(hasActiveVP && !accounts.get(accId).Has_Active_Verification_Page__c)
            {
                accounts.get(accId).Has_Active_Verification_Page__c = true;     
                accToUpdate.add(accounts.get(accId));
            }
            if((!hasActiveVP && accounts.get(accId).Has_Active_Verification_Page__c) || accWitnVP.get(accId).size() == 0)
            {
                accounts.get(accId).Has_Active_Verification_Page__c = false;     
                accToUpdate.add(accounts.get(accId));
            }
        }
        if(accToUpdate.size() > 0)
        { 
            update new List<Account>(accToUpdate);
        }

    }
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2016 April 16
    * @description  Locking record if status Active or Expired
    **/
    private void LockUnlockRecord(List<Verification_Page__c> newTriggerValues)
    {
        for(Verification_Page__c vp : newTriggerValues)
        {
            if(vp.Integrity_Check_Completed__c == 'Active' || vp.Integrity_Check_Completed__c == 'Expired')
            {
                Approval.lock(vp, true);
            }
            else
            {
                Approval.unlock(vp);
            }
        }
        
    }
}