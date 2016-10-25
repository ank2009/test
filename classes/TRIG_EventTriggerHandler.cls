/** 
* @author       Andrey Gordienko (andrey_gordienko@epam.com)
* @date         2014 February 14
* @description  Trigger handler for Event events
**/
public with sharing class TRIG_EventTriggerHandler extends TRIG_TriggerHandlerAbstract
{
    public boolean IsTriggerContext { get { return isTriggerExecuting;} }
    private ID TLREventRecordTypeId;
    private ID SalesEventRecordTypeId;
    
    public TRIG_EventTriggerHandler (boolean isTriggerExecuting) 
    {
        super(isTriggerExecuting);
        TLREventRecordTypeId = TLR_RecordTypeHelper.getId('Event','TLR Event'); 
        SalesEventRecordTypeId = TLR_RecordTypeHelper.getId('Event','Sales Event'); 
    }
    
    public override void OnBeforeInsert(List<sObject> newTriggerValues) 
    {
        TLR_EventAndTaskHelper.UpdateTaskOrEventSubject(null, newTriggerValues);
        this.UpdateEventLocation(newTriggerValues);
        this.UpdateEventFieldForReporting(newTriggerValues);
    }
    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap) 
    {
        this.UpdateAccountLastVisitedDateEvent(newTriggerValues);
        UpdateOpptyScreenShareAndDemos(newTriggerValues, null, false);
        TLR_EventAndTaskHelper.UpdateLeadCounter(newTriggerValues, null);
        TLR_EventAndTaskHelper.UpdateCampaignCounter(newTriggerValues, null);
    }
    
    public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap) 
    {
        TLR_EventAndTaskHelper.UpdateTaskOrEventSubject(oldTriggerValues, newTriggerValues);
        this.UpdateEventFieldForReporting(newTriggerValues);
    }
    
    public override void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap) 
    {
        this.UpdateOpptyScreenShareAndDemos(newTriggerValues, oldTriggerValuesMap, false);
        TLR_EventAndTaskHelper.UpdateLeadCounter(newTriggerValues, oldTriggerValuesMap);
        TLR_EventAndTaskHelper.UpdateCampaignCounter(newTriggerValues, oldTriggerValuesMap);
        this.UpdateAccountLastVisitedDateEvent(newTriggerValues);
    }
    
    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    public override void OnAfterDelete  (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
    {
        UpdateOpptyScreenShareAndDemos(oldTriggerValues, null, true);
        TLR_EventAndTaskHelper.UpdateLeadCounter(oldTriggerValues, null);
        TLR_EventAndTaskHelper.UpdateCampaignCounter(oldTriggerValues, null);
    }

    public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    
    
    private void UpdateEventFieldForReporting(Event[] newEvents)
    {
        if(!newEvents.isEmpty())
        {
            for(Event event : newEvents)
            {
                if(event.RecordTypeId == TLREventRecordTypeId)
                {
                    if(event.StartDateTime != null)
                    {
                        event.Activity_Event_Start__c = event.StartDateTime;
                    }
                    if(event.EndDateTime != null)
                    {
                        event.Activity_Event_End__c = event.EndDateTime; 
                    }
                    if(event.Type != null)
                    {
                        event.Activity_Event_Type__c = event.Type;
                    }
                    if(event.Subject != null)
                    {
                        event.Activity_Event_Subject__c = event.Subject;
                    }
                    if(event.DurationInMinutes != null)
                    {
                        event.Activity_Event_Duration__c = event.DurationInMinutes;
                    }
                }
            }
        }
    }
    
    private void UpdateAccountLastVisitedDateEvent(Event[] newEvents)
    {
        Set<ID> acctIds= new Set<ID>();
        if(!newEvents.isEmpty())
        {
            for (Event e : newEvents)
            {
                if(e.AccountId != null)
                {
                    acctIds.add(e.AccountId);
                }
            }   
            Map<ID, Account> accounts = new Map<ID, Account>([SELECT Id,Last_Visited__c FROM Account WHERE Id IN :acctIds]);
            Account Acc = null;
            for(Event NewEvent : newEvents)
            {
                if((NewEvent.Type =='26 Demonstration' || NewEvent.Type =='23 Visit out') && NewEvent.AccountId != null)
                {
                    String accID = (String)NewEvent.get('AccountId');
                    Acc = accounts.get(accID);
                    Date newEventStartDateTimeDate = Date.newInstance(NewEvent.StartDateTime.year(), NewEvent.StartDateTime.month(), NewEvent.StartDateTime.day());
                    boolean result = Acc.Last_Visited__c < newEventStartDateTimeDate || Acc.Last_Visited__c == null;
                    if(Acc.Last_Visited__c < newEventStartDateTimeDate || Acc.Last_Visited__c == null)
                    {
                        Acc.Last_Visited__c = newEventStartDateTimeDate;
                        accounts.put(accID, Acc);
                    }
                }
            } // for events
            try
            {
                update accounts.values();
            }
            catch(Exception ex)
            {
                System.debug('Update Failed Account on Event=>'+ex);
            }
        } // if events is not empty
    }//end of UpdateAccountLastVisitedDateEvent method
    
    private void UpdateEventLocation(Event[] newEvents)
    {
        if(newEvents.get(0) != null && (newEvents.get(0).RecordTypeId == TLREventRecordTypeId || newEvents.get(0).RecordTypeId == SalesEventRecordTypeId))
        {
            if(!String.isNotEmpty(newEvents.get(0).Location) && String.isNotEmpty(newEvents.get(0).WhatId))
            {
                Account acc;
                String accId = TLR_EventAndTaskHelper.getAccountId(newEvents.get(0).WhatId);
                if(String.isNotEmpty(accId))
                {
                    acc = [SELECT Id,Name,BillingStreet,BillingState,BillingPostalCode,BillingCountry,
                        BillingCity,ShippingStreet,ShippingCity,ShippingCountry,ShippingPostalCode,Phone,Last_Visited__c 
                        FROM Account WHERE Id =: accId];
                }
                if(acc != null)
                {
                    String addressInfo='';
                    addressInfo = this.getAddressInfo(acc.ShippingStreet, addressInfo);
                    addressInfo = this.getAddressInfo(acc.ShippingCity, addressInfo);
                    addressInfo = this.getAddressInfo(acc.ShippingCountry, addressInfo);
                    addressInfo = this.getAddressInfo(acc.ShippingPostalCode, addressInfo);
                    if(acc.Phone!=null)
                    {
                        newEvents.get(0).Location = addressInfo+', '+acc.Phone; 
                    }
                }
            }
            
        }
    }
    
    private string getAddressInfo(string arg, string addressInfo)
    {
        if(String.isNotEmpty(arg))
        {
            if(String.isNotEmpty(addressInfo))
            {
                addressInfo = addressInfo+', '+arg;
            }
            else 
                addressInfo = arg;
        }
        return addressInfo;
    }
    
    /*
     * @author       Anton Soloveyv (anton_soloveyv@epam.com)
     * @date         2014 August 20
     * @description  Updates oppty fields with count of specific events
     */
    private void UpdateOpptyScreenShareAndDemos(List<Event> newEvents, Map<ID,SObject> oldTriggerValues, boolean isRemoved)
    {
        string oppPrefix = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getKeyPrefix();
        Set<Id> opptyIdSet = new Set<Id>();
        string demoEventType = General_Settings__c.getInstance('Default').Demonstration_EventType__c; // 'Demonstration';
        string screenshareEventType = General_Settings__c.getInstance('Default').ScreenSharing_EventType__c; // '21 Screen sharing';
        
        for(Event e : newEvents)
        {
            if(e.WhatId != null)
            {
                string sId = string.valueOf(e.WhatId);
                if(sId.startsWith(oppPrefix))
                    opptyIdSet.add(e.WhatId);
            }
        }
        
        if(opptyIdSet.size() > 0)
        {
            Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>([
                SELECT
                    Id, Name, Demos_Count__c, Screenshsare_Count__c
                FROM Opportunity
                WHERE Id IN :opptyIdSet
            ]);
            Map<ID, Opportunity> oppToUpdate = new Map<ID,Opportunity>();
            // fix null field values
            for(Id oppId : opptyMap.keySet())
            {
                if(opptyMap.get(oppId).Demos_Count__c == null)
                    opptyMap.get(oppId).Demos_Count__c = 0;
                if(opptyMap.get(oppId).Screenshsare_Count__c == null)
                    opptyMap.get(oppId).Screenshsare_Count__c = 0;
            }
            for(Event e : newEvents)
            {
                if(opptyMap.containsKey(e.WhatId))
                {
                    if(e.Type == demoEventType)
                    {
                        opptyMap.get(e.WhatId).Demos_Count__c = (isRemoved ? opptyMap.get(e.WhatId).Demos_Count__c-1 : opptyMap.get(e.WhatId).Demos_Count__c+1);
                        if(!oppToUpdate.containsKey(e.WhatId))
                            oppToUpdate.put(e.WhatId,opptyMap.get(e.WhatId));
                    }
                    if(e.Type == screenshareEventType)
                    {
                        opptyMap.get(e.WhatId).Screenshsare_Count__c = (isRemoved ? opptyMap.get(e.WhatId).Screenshsare_Count__c-1 : opptyMap.get(e.WhatId).Screenshsare_Count__c+1);
                        if(!oppToUpdate.containsKey(e.WhatId))
                            oppToUpdate.put(e.WhatId,opptyMap.get(e.WhatId));
                    }
                    if(oldTriggerValues != null)
                    {
                        Event oldEvent = (Event)oldTriggerValues.get(e.Id);
                        if(oldEvent.Type == demoEventType)
                        {
                            opptyMap.get(e.WhatId).Demos_Count__c = opptyMap.get(e.WhatId).Demos_Count__c-1;
                            if(!oppToUpdate.containsKey(e.WhatId))
                                oppToUpdate.put(e.WhatId,opptyMap.get(e.WhatId));
                        }
                        if(oldEvent.Type == screenshareEventType)
                        {
                            opptyMap.get(e.WhatId).Screenshsare_Count__c = opptyMap.get(e.WhatId).Screenshsare_Count__c-1;
                            if(!oppToUpdate.containsKey(e.WhatId))
                                oppToUpdate.put(e.WhatId,opptyMap.get(e.WhatId));
                        }
                    }
                    if(opptyMap.get(e.WhatId).Demos_Count__c < 0)
                    {
                        opptyMap.get(e.WhatId).Demos_Count__c = 0;
                    }
                    if(opptyMap.get(e.WhatId).Screenshsare_Count__c < 0)
                    {
                        opptyMap.get(e.WhatId).Screenshsare_Count__c = 0;
                        if(!oppToUpdate.containsKey(e.WhatId))
                            oppToUpdate.put(e.WhatId,opptyMap.get(e.WhatId));
                    }
                }
            }
            
            update oppToUpdate.values();
        }
    }//UpdateOpptyScreenShareAndDemos
}