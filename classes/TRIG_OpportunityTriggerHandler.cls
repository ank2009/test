public with sharing class TRIG_OpportunityTriggerHandler extends TRIG_TriggerHandlerAbstract
{
    public boolean IsTriggerContext { get { return isTriggerExecuting;} }

    public TRIG_OpportunityTriggerHandler (boolean isTriggerExecuting) 
    {
        super(isTriggerExecuting);
    }
    
    public override void OnBeforeInsert(List<sObject> newTriggerValues) 
    {
        CheckStageBeforeCreation(newTriggerValues);
    }
    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap) 
    {
        this.OpportunityAfterInsertUpdate(newTriggerValues, null);
        this.UpdateAccountPLC(newTriggerValues);
    }
    
    public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap) 
    {
                
        System.Debug('------- TRIG_OpportunityTriggerHandler: OnBeforeUpdate: Store Last Update On Sales Stage Date');
        
        for(sObject oOpp : newTriggerValues)
        {
            Opportunity opp = (Opportunity)oOpp;
            Opportunity oldOpp = (Opportunity)oldTriggerValuesMap.get(opp.Id);
            
            if (opp.StageName != oldOpp.StageName)
            {
                opp.Last_Update_on_Sales_Stage_Date__c = Date.today();
            }
        } 
        
        System.Debug('------- TRIG_OpportunityTriggerHandler: OnBeforeUpdate: CheckContactRoles');

        this.CheckContactRoles(newTriggerValues, oldTriggerValuesMap);
    }
    
    public override void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap) 
    {
        this.OpportunityAfterInsertUpdate(newTriggerValues, oldTriggerValuesMap);
        this.UpdateAccountPLC(newTriggerValues);
        this.GenerateWKTSProjectNumber(newTriggerValues,oldTriggerValuesMap);        
    }
    
    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    public override void OnAfterDelete  (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) 
    {
    	this.UpdateAccountPLC(oldTriggerValues);
    }

    public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    
    private void OpportunityAfterInsertUpdate(List<Opportunity> newTriggerValues, Map<Id,SObject> oldTriggerValuesMap)
    {
        Opportunity[] lstOpportunityToFill   = new Opportunity[]{};
        for (Opportunity newopp : newTriggerValues)
        {
            // we don't need to update TAS oppty
            if(newopp.Product_Interest__c == 'TAS')
                continue;           
            if (oldTriggerValuesMap == null ? newopp.Offer_Template__c != null : ((Opportunity)oldTriggerValuesMap.get(newopp.Id)).Offer_Template__c != newopp.Offer_Template__c)
            {
                lstOpportunityToFill.add(newopp);
            }
        }
        if (lstOpportunityToFill.size() > 0)
        {
            (new TR006Opportunity()).AddOpportunityElement(lstOpportunityToFill); 
        }
    }
    
    private void GenerateWKTSProjectNumber(List<Opportunity> newValues, Map<ID,SObject> oldValues)
    {
        List<Opportunity> forGeneration = new List<Opportunity>();
        List<Opportunity> oppWithOffer = [Select WKTS_project_number__c, Offer_Template__c, Offer_Template__r.Name From Opportunity Where Id =: newValues];
        for(Opportunity opp:oppWithOffer)
        {
            if(opp.WKTS_project_number__c == null && opp.Offer_Template__c != null && opp.Offer_Template__r.Name == 'TWA PCL Offer' && ((Opportunity)oldValues.get(opp.Id)).Offer_Template__c == null)
            {
                forGeneration.add(opp);
            }
        }
        if(forGeneration.size() > 0)
        {
            List<String> numbers = TLR_CustomSettingsHelper.GetTWAOppProjectNumber(forGeneration.size());
            Integer i = 0;
            for(Opportunity opp:forGeneration)
            {
                opp.TWD_old_SF_Opportunity_ID__c = numbers[i];
                i++;
            }
            update forGeneration;
        }
    }
    
    private void UpdateAccountPLC(List<Opportunity> newValues)
    {
    	if(newValues.size() == 1)
    	{
    		if(newValues[0].AccountId != null)
    		{
    			String UserName = UserInfo.getName();
    			if(!UserName.contains('ESB')&&!Test.isRunningTest())
    			{
    				TLR_AccountMembershipLifeCycleController con = new TLR_AccountMembershipLifeCycleController(newValues[0].AccountId);
    			}
    		}
    	}
    }
    
        /** 
    * @author       Andrei Lobkis (andrei_lobkis@epam.com)
    * @date         2016 August 15
    * @description  WKTSCRM-2664 Do not allow Creating an Opportunity in a Stage requiring a Contact Role
    **/
    private void CheckStageBeforeCreation(List<Opportunity> newTriggerValues)
    {
		for(Opportunity opp : newTriggerValues) 
        {
            if(Opportunity_Stages_Need_Contact_Roles__c.getValues(opp.StageName) == null)
            {
                opp.StageName.addError('This value is not allowed for new Opportunity');
            }
        }
    }
    
        /** 
    * @author       Andrei Lobkis (andrei_lobkis@epam.com)
    * @date         2016 July 28
    * @description  WKTSCRM-2608 Opportunity: At least 1 Contact Role should be added when moving to Stage 05 Offer Sent
    **/
    private void CheckContactRoles(List<Opportunity> newTriggerValues, Map<ID,SObject> oldTriggerValuesMap)
    {
        Map<ID,Opportunity> oldOppValuesMap = (Map<ID,Opportunity>)oldTriggerValuesMap;
        Opportunity currOldValue;
        List<Opportunity> oppsToCheckForContactRoles = new List<Opportunity>();
        
        for(Opportunity opp : newTriggerValues)
        {
            currOldValue = oldOppValuesMap.get(opp.Id);
            if(opp.RecordTypeId == TLR_RecordTypeHelper.getId('Opportunity','WKTS Opportunity') && opp.StageName != currOldValue.StageName 
               && Opportunity_Stages_Need_Contact_Roles__c.getValues(opp.StageName) == null)
            {
                oppsToCheckForContactRoles.add(opp);
            }
        }
        if(oppsToCheckForContactRoles.size() > 0)
        {
            List<OpportunityContactRole> contRoles = [select Id, OpportunityId from OpportunityContactRole where OpportunityId =: oppsToCheckForContactRoles];
            Set<Id> oppsWithContactRolesIdsSet = new Set<Id>();
            for(OpportunityContactRole contRole : contRoles)
            {
                oppsWithContactRolesIdsSet.add(contRole.OpportunityId);
            }
            for(Opportunity opp : oppsToCheckForContactRoles)
            {
                if(!oppsWithContactRolesIdsSet.contains(opp.Id))
                {
                    opp.addError('At least 1 Contact Role should be added in the ‘Contact Roles’ related list to move opportunity stage to ‘05 Offer Sent’ or higher');
                }
            }       
        }        
    }
}