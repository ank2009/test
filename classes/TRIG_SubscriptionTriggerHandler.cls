public without sharing class TRIG_SubscriptionTriggerHandler extends TRIG_TriggerHandlerAbstract
{
    private Id subsProvRecordType;
    private Id subsProvInitRecordType;
    private Id subsActiveRecordType;
    private Id subsCancelledRecordType;
    private Id subsTLRRecordType;
    private Id subsTASRecordType;
    
    public boolean IsTriggerContext { get { return isTriggerExecuting;} }
    public TRIG_SubscriptionTriggerHandler (boolean isTriggerExecuting)
    {
        super(isTriggerExecuting);
        
        Map<String,Schema.RecordTypeInfo> mapByName = Schema.getGlobalDescribe().get('Subscription__c').getDescribe().getRecordTypeInfosByName();
        subsProvRecordType       = mapByName.get('TLR Subscription Prov').getRecordTypeId();
        subsProvInitRecordType   = mapByName.get('TLR Subscription Prov Init').getRecordTypeId();
        subsActiveRecordType     = mapByName.get('TLR Subscription Active').getRecordTypeId();
        subsCancelledRecordType  = mapByName.get('TLR Subscription Cancelled').getRecordTypeId();
        subsTLRRecordType        = mapByName.get('TLR Subscription').getRecordTypeId();
        subsTASRecordType        = mapByName.get('TAS Subscription').getRecordTypeId();
    }
    
    public override void OnBeforeInsert(List<sObject> newTriggerValues)
    {
        this.SubscriptionBeforeInsertUpdate(newTriggerValues);
        UpdateSubsRecordType(newTriggerValues);
        UpdatePriceListCode(newTriggerValues);
    }
    
    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
    {
        this.UpdateAccountPLC(newTriggerValues);
    }

    public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues,
            Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        this.SubscriptionBeforeInsertUpdate(newTriggerValues);
        UpdateSubsRecordType(newTriggerValues);
        UpdatePriceListCode(newTriggerValues);
    }

    public override void OnAfterUpdate(List<sObject> oldTriggerValues, List<sObject> newTriggerValues,
            Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        this.UpdateAccountPLC(newTriggerValues);
        this.UpdateContractStatus(newTriggerValues,oldTriggerValuesMap);
        
    }
    
    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    public override void OnAfterDelete  (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) 
    {
        this.UpdateAccountPLC(oldTriggerValues);
    }
    
    public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    
    /*
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 April 22
    * @description  Updating subscription record type depending on status (we need different layouts)
    **/
    private void UpdateSubsRecordType(List<Subscription__c> subs)
    {
        for (Subscription__c s : subs)
        {
            //otIds.add(subs.Offer_Template__c);
            if(s.RecordTypeId == subsTASRecordType)
                continue;
            if(s.Status__c == 'Waiting For Provisioning' || s.Status__c == 'Waiting For Payment')
                s.RecordTypeId = subsProvRecordType;
            else if(s.Status__c == 'Provisioning initiated')
                s.RecordTypeId = subsProvInitRecordType;
            else if(s.Status__c == 'Active' || s.Status__c == 'Migration')
                s.RecordTypeId = subsActiveRecordType;
            else if(s.Status__c == 'On Notice' || s.Status__c == 'Cancelled')
                s.RecordTypeId = subsCancelledRecordType;
            else
                s.RecordTypeId = subsTLRRecordType;
        }
    } //UpdateSubsRecordType
    
    /*
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 April 22
    * @description  Updating subscription  Price List Code
    **/
    private void UpdatePriceListCode(List<Subscription__c> subs)
    {
        Set<Id> otIds = new Set<Id>();
        for (Subscription__c s : subs)
            otIds.add(s.Offer_Template__c);
        
        Map<Id, Offer_Template__c> otNames = new Map<Id, Offer_Template__c>([
            SELECT Name 
            FROM Offer_Template__c 
            WHERE Id IN :otIds
        ]);
        // Put the Offer Template Name
        for (Subscription__c s : subs) 
            if (s.Offer_Template__c != null)
                s.Price_List_Code__c = otNames.get(s.Offer_Template__c).Name;
    } //UpdatePriceListCode
    
    /*
    * @author       Andrey Gordienko (andrey_gordienko@epam.com) (review)
    * @date         2013 December 16
    * @description  Updating subscription field before Insert-Update
    **/
    private void SubscriptionBeforeInsertUpdate(List<Subscription__c> newTriggerValues)
    {
        //-----------------------------------//
        // Update contract Status & End date //
        //-----------------------------------//
        Set<ID> idContracts = new Set<ID>();
        for(Subscription__c subs : newTriggerValues)
            idContracts.add(subs.Contract__c);
        
        // here is map containing all subscriptions related to contracts.
        // At first look this can be stupid, but 2 hours of analisys gave me 
        // general idea of what is going on: one contract can have many subscriptions
        // and we need to process all subscriotions for a contract in some cases,
        // so this map is not the same as map of old trigger values.
        Map<ID, Subscription__c> allSubsMap = new Map<ID, Subscription__c>([
            SELECT Id, Status__c, Contract__c, End_Date__c
            FROM Subscription__c
            WHERE Contract__c IN :idContracts
        ]);
        
        
        if(Trigger.isUpdate)
        {
            this.BeforeUpdate(newTriggerValues, allSubsMap);
        }
        
        // Mapping contract -> list of current + new subscriptions with latest values
        Map<ID, List<Subscription__c>> mapContractSubs = new Map<ID, List<Subscription__c>>();
        for (Subscription__c sub : allSubsMap.Values())
        {
            if (!mapContractSubs.containsKey(sub.Contract__c))
                mapContractSubs.put(sub.Contract__c, new List<Subscription__c>());
            mapContractSubs.get(sub.Contract__c).add(sub);
        }
        
        if(Trigger.isInsert)
        {
            for (Subscription__c sub : newTriggerValues)
            {
                if (!mapContractSubs.containsKey(sub.Contract__c))
                    mapContractSubs.put(sub.Contract__c, new List<Subscription__c>());              
                mapContractSubs.get(sub.Contract__c).add(sub);
            }
        }
        // Contracts processing
        // For Contract status
        Map<ID, String> contractsToUpdate = new Map<ID, String>();
        // For Contract end date
        Map<ID, Date> contractsToUpdate2 = new Map<ID, Date>();
        for (ID cont : mapContractSubs.keySet())
        {
            List<Subscription__c> lstSubs = mapContractSubs.get(cont);
            // Calculate the last end date
            Date maxEndDate;
            Integer nbCancelled = 0;// Check if contract cancelled (= all subscriptions cancelled)
            Integer nbActive    = 0;//etc
            Integer nbOnNotice  = 0;
            for(Subscription__c currSubs : lstSubs)
            {
                if (currSubs.Status__c == 'Cancelled')
                    nbCancelled++;
                else if (currSubs.Status__c == 'Active')
                    nbActive++;
                else if (currSubs.Status__c == 'On Notice')
                    nbOnNotice++;
                if(maxEndDate == null)
                    maxEndDate = currSubs.End_Date__c;
                if(currSubs.End_Date__c != null && currSubs.End_Date__c > maxEndDate)
                    maxEndDate = currSubs.End_Date__c;
            }
            if (nbCancelled == lstSubs.size())
                contractsToUpdate.put(cont, 'Cancelled');
            else if (nbOnNotice > 0 && nbActive == 0)
            {
                contractsToUpdate.put(cont, 'On Notice');
                if(maxEndDate != null)
                    contractsToUpdate2.put(cont, maxEndDate);
            }
        }
        // Update contracts' statuses
        if (contractsToUpdate.size() > 0)
        {
            List<Contract> lstContracts = [SELECT Id, Status__c FROM Contract WHERE Id IN :contractsToUpdate.keySet()];
            List<Contract> toUpdate = new List<Contract>();
            for (Contract cont : lstContracts)
            {
                if (cont.Status__c != contractsToUpdate.get(cont.Id))
                {
                    cont.Status__c = contractsToUpdate.get(cont.Id);
                    toUpdate.add(cont);
                }
            }
            if (toUpdate.size() > 0)
                update toUpdate;
        }
        
        // Update contracts' end dates
        if (contractsToUpdate2.size() > 0)
        {
            List<Contract> lstContracts = [SELECT Id, EndDate FROM Contract WHERE Id IN :contractsToUpdate2.keySet()];
            
            List<Contract> toUpdate = new List<Contract>();
            
            for (Contract cont : lstContracts)
            {
                if (cont.EndDate != contractsToUpdate2.get(cont.Id))
                {
                    cont.EndDate = contractsToUpdate2.get(cont.Id);
                    toUpdate.add(cont);
                }
            }
            
            if (toUpdate.size() > 0)
                update toUpdate;
        }
    }   
    
    
    private void BeforeUpdate(List<Subscription__c> newTriggerValues, Map<ID, Subscription__c> mapSubs)
    {
        Set<ID> idSubs = new Set<ID>();
        List<Subscription__c> listOfSubs = new List<Subscription__c> ();    
        for(Subscription__c sub : newTriggerValues)
        {
            if(sub.Status__c == 'Cancelled' || sub.Status__c == 'On Notice' )
            {
                idSubs.add(sub.Id);
                listOfSubs.add(sub);
            }
            if(mapSubs.containsKey(sub.Id))
            {
                mapSubs.get(sub.Id).Status__c   = sub.Status__c;
                mapSubs.get(sub.Id).End_Date__c = sub.End_Date__c; 
            }
        }
        // Below code is written for CR #WKTS CRM-4
        // We will put all the business logic in helper class, for now we will keep in trigger itself
        // Calling TLR_SubscriptionCancellation Class for Update End Date on Canelletion
        if(! idSubs.isEmpty() && ! listOfSubs.isEmpty())
        {
            List<Subs_Current_Fee__c>  objSubCurrlist = [Select Id, Subscription__c,End_Date__c From Subs_Current_Fee__c where Subscription__c IN :idSubs AND End_Date__c = null];
            for(Subscription__c sub:listOfSubs)
            {
                for(Subs_Current_Fee__c cur:objSubCurrlist)
                {
                    if (cur.Subscription__c == sub.Id)
                    {
                        cur.End_Date__c = sub.End_Date__c;  
                    }
                }
            }
            if(!objSubCurrlist.isEmpty())
                update objSubCurrlist;
        } 
    } //BeforeUpdate
    
    private void UpdateAccountPLC(List<Subscription__c> newValues)
    {
        if(newValues.size() == 1)
        {
            if(newValues[0].Account__c != null)
            {
                String UserName = UserInfo.getName();
                if(!UserName.contains('ESB CM') && !Test.isRunningTest())
                {
                    TLR_AccountMembershipLifeCycleController con = new TLR_AccountMembershipLifeCycleController(newValues[0].Account__c, newValues[0]);
                }
            }
        }
    }
       
    private void UpdateContractStatus(List<Subscription__c> newValues, Map<ID, sObject> oldTriggerValuesMap)
    {
    	List<Id> contractIds = new List<Id>();
    	for(Subscription__c sub: newValues)
    	{
    		if(((Subscription__c)oldTriggerValuesMap.get(sub.Id)).Status__c == 'Provisioning initiated' && sub.Status__c == 'Active')
    		{
    			contractIds.add(sub.Contract__c);
    		}
    	}
    	if(contractIds.size() > 0)
    	{
    		List<Contract> contracts = [Select Status__c From Contract Where Id =: contractIds and Status__c != 'Active'];
    		for(Contract contr:contracts)
    		{
    			contr.Status__c = 'Active';
                contr.Status = 'Activated';
    		}
    		update contracts;
    	}
    }
}