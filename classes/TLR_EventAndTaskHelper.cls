/**
* @author		Andrei Lobkis (Andrei_Lobkis@epam.com)
* @date			2015 November 30
* @description	Methods to assist working with Events and Tasks
* 		
*/


public class TLR_EventAndTaskHelper 
{
    private static string SalesTaskRecordType = TLR_RecordTypeHelper.getId('Task','Sales Task');
    private static string TLRTaskRecordType = TLR_RecordTypeHelper.getId('Task','TLR Task');
    private static string SalesEventRecordType = TLR_RecordTypeHelper.getId('Event','Sales Event');
    private static string TLREventRecordType = TLR_RecordTypeHelper.getId('Event','TLR Event');
    
		/**	
	* @author		Andrei Lobkis (Andrei_Lobkis@epam.com)
	* @date			2015 November 30
	* @description	Method to update Counter_of_All_Activities__c field in Lead object
	**/	
    public static void UpdateLeadCounter(List<SObject> newActivities, Map<ID,SObject> oldTriggerValues)
    {
        Set<Id> leadIdSet = new Set<Id>();
        List<Task> tasks = new List<Task>();
        List<Event> events = new List<Event>();
        Map<Id,Integer> activitiesMap = new Map<Id,Integer>();
        List<SObject> newActs = new List<SObject>(newActivities);
        if(oldTriggerValues!=null)
        {
            newActs.addAll(oldTriggerValues.values());
        }
        if(newActivities.getSObjectType() == Task.getSObjectType())
        {
            List<Task> newTasks = (List<Task>)newActs;
            for(Task t : newTasks)
            {
                if(t.WhoId != null)
                {
                    leadIdSet.add(t.WhoId);
                }
            }
        }
        else
        if(newActivities.getSObjectType() == Event.getSObjectType())
        {
            List<Event> newEvents = (List<Event>)newActs;
            for(Event e : newEvents)
            {
                if(e.WhoId != null)
                {
                    leadIdSet.add(e.WhoId);
                }
            }
        }
        
  
        if(leadIdSet.size() > 0)
        {
            tasks = [select  Id, WhoId from Task where WhoId =: leadIdSet and CreatedDate >=: system.Date.today().addMonths(-12)];
            events = [select  Id, WhoId from Event where WhoId =: leadIdSet and CreatedDate >=: system.Date.today().addMonths(-12)];

            for(Id l : leadIdSet)
            {
                activitiesMap.put(l, 0);
            }
            
            for(Task t : tasks)
            {
                activitiesMap.put(t.WhoId,activitiesMap.get(t.WhoId)+1);
            }
            for(Event e : events)
            {
                activitiesMap.put(e.WhoId,activitiesMap.get(e.WhoId)+1);
            }
            
            List<Lead> leadsToUpdate = new List<Lead>([
                SELECT
                    Id, Name, Counter_of_All_Activities__c
                FROM Lead
                WHERE Id IN :leadIdSet
            ]); 
            for(Lead l : leadsToUpdate)
            {
                l.Counter_of_All_Activities__c = activitiesMap.get(l.Id);
            }
            update leadsToUpdate;
        }
    }
    	/**	
	* @author		Andrei Lobkis (Andrei_Lobkis@epam.com)
	* @date			2015 November 30
	* @description	Method to update Counter_of_Activities__c field in Campaign object
	**/	
    public static void UpdateCampaignCounter(List<SObject> newActivities, Map<ID,SObject> oldTriggerValues)
    {
        Set<Id> campIdSet = new Set<Id>();
        List<Task> tasks = new List<Task>();
        List<Event> events = new List<Event>();
        Map<Id,Integer> activitiesMap = new Map<Id,Integer>();
        List<SObject> newActs = new List<SObject>(newActivities);
        if(oldTriggerValues!=null)
        {
            newActs.addAll(oldTriggerValues.values());
        }
        
        if(newActivities.getSObjectType() == Task.getSObjectType())
        {
            List<Task> newTasks = (List<Task>)newActs;
            for(Task t : newTasks)
            {
                if(t.Campaign__c != null)
                {
                    campIdSet.add(t.Campaign__c);
                }
            }
        }
        else
        if(newActivities.getSObjectType() == Event.getSObjectType())
        {
            List<Event> newEvents = (List<Event>)newActs;
            for(Event e : newEvents)
            {
                if(e.Campaign__c != null)
                {
                    campIdSet.add(e.Campaign__c);
                }
            }
        }
    
        if(campIdSet.size() > 0)
        {
            tasks = [select  Id, Campaign__c from Task where Campaign__c =: campIdSet];
            events = [select  Id, Campaign__c from Event where Campaign__c =: campIdSet];

            for(Id l : campIdSet)
            {
                activitiesMap.put(l, 0);
            }
            
            for(Task t : tasks)
            {
                activitiesMap.put(t.Campaign__c,activitiesMap.get(t.Campaign__c)+1);
            }
            for(Event e : events)
            {
                activitiesMap.put(e.Campaign__c,activitiesMap.get(e.Campaign__c)+1);
            }
            
            List<Campaign> campsToUpdate = new List<Campaign>([
                SELECT
                    Id, Name, Counter_of_Activities__c
                FROM Campaign
                WHERE Id IN :campIdSet
            ]);
            for(Campaign c : campsToUpdate)
            {
                c.Counter_of_Activities__c = activitiesMap.get(c.Id);
            }
            update campsToUpdate;
        }
    }
    
      	/**	
	* @author		Andrei Lobkis (Andrei_Lobkis@epam.com)
	* @date			2016 August 5
	* @description	Method for updating Subject field of Tasks and Events after update of Company field of Lead or Name field of Account
	**/	
    public static void UpdateTaskOrEventSubjectFromLeadOrAccount(List<SObject> oldTriggerValues, List<SObject> newTriggerValues, Map<Id, SObject> oldTriggerValuesMap)
    {
        string objectType = newTriggerValues.getSObjectType().getDescribe().getName();
        List<Task> tasksToUpdate = new List<Task>();
        List<Event> eventsToUpdate = new List<Event>();
		for(SObject obj : newTriggerValues)
        {
            string title = (objectType == 'Lead') ? string.valueOf(obj.get('Company')) : string.valueOf(obj.get('Name'));			
            string oldTitle = (objectType == 'Lead') ? string.valueOf((oldTriggerValuesMap.get((Id)obj.get('Id'))).get('Company')) 
                										: string.valueOf((oldTriggerValuesMap.get((Id)obj.get('Id'))).get('Name'));
            if(title != oldTitle)        
            {
                string queryTasks = 'Select Id, Subject, Subject1__c From Task Where ' 
                    + ((objectType == 'Lead') ? 'WhoId = \'' : 'AccountId = \'')
                    + string.valueOf(obj.get('Id')) + '\' and (RecordTypeId = \'' +  SalesTaskRecordType + '\' or RecordTypeId = \''
                    + TLRTaskRecordType + '\')';
                string queryEvents = 'Select Id, Subject, Subject1__c, isChild From Event Where ' 
                    + ((objectType == 'Lead') ? 'WhoId = \'' : 'AccountId = \'')
                    + string.valueOf(obj.get('Id')) + '\' and (RecordTypeId = \'' +  SalesEventRecordType + '\' or RecordTypeId = \''
                    + TLREventRecordType + '\')';                
                List<Task> tasks = Database.query(queryTasks);
                List<Event> events = Database.query(queryEvents);
                for(Task t: tasks)
                {
                    if((t.Subject == t.Subject1__c + ' - ' + oldTitle))                       
                    {
                        t.Subject = t.Subject1__c + ' - ' + title;
                        tasksToUpdate.add(t);
                    }
                }
                for(Event e: events)
                {
                    if(!e.isChild && e.Subject == e.Subject1__c + ' - ' + oldTitle)
                    {
                        e.Subject = e.Subject1__c + ' - ' + title;
                        eventsToUpdate.add(e);
                    }
                }
            }
        }
        if(tasksToUpdate.size() > 0)
                update tasksToUpdate; 
        if(eventsToUpdate.size() > 0)
                update eventsToUpdate;
    }
    
    public static void UpdateTaskOrEventSubject(List<sObject> oldTriggerValues, List<sObject> newTriggerValues)
    {
        if(newTriggerValues.size() == 1)
        {
            SObject oldObj = (oldTriggerValues != null && oldTriggerValues.size() == 1) ? oldTriggerValues[0] : null;
            sObject newObj = newTriggerValues[0];
            boolean originalSubjectCorrect = false;
            boolean newSubjEmpty = String.isEmpty((string)newObj.get('Subject'));
            if(!newSubjEmpty && oldObj == null)
            	return;
            string subject;
            string objType = newObj.getSObjectType().getDescribe().getName();
            string SalesRecordType = (objType == 'Task') ? SalesTaskRecordType : SalesEventRecordType;
            string TLRRecordType = (objType == 'Task') ? TLRTaskRecordType : TLREventRecordType;
            if(((string)newObj.get('RecordTypeId') == TLRRecordType || (string)newObj.get('RecordTypeId') == SalesRecordType) 
               && (String.isNotEmpty((string)newObj.get('WhatId')) || String.isNotEmpty((string)newObj.get('WhoId'))))        
            { 
                
                if(newObj.get('Subject1__c') != null)
                {
                    Account acc;
                    String accId;
                    String whoId = (string)newObj.get('WhoId');
                    String whatId = (string)newObj.get('WhatId');
                    if(String.isNotempty(whatId))
                    {
                        accId = getAccountId(whatId);
                    }
                    else if(String.isNotempty(whoId))
                    {
                        accId = getAccountId(whoId);
                    }
                    if(String.isNotEmpty(accId))
                    {
                        acc = [SELECT Name FROM Account WHERE Id =: accId];
                        if(acc != null)
                        {
                            originalSubjectCorrect = checkOriginalSubject(oldObj, newObj, acc.Name);
                            subject = setNewSubject(oldObj, newObj, acc.Name);
                        }
                    }
                    else if(whoId.substring(0,3)=='00Q')
                    {
                        Lead lead = [Select Company From Lead Where Id =: whoId];
                        if(lead != null)
                        {
                            originalSubjectCorrect = checkOriginalSubject(oldObj, newObj, lead.Company);
                            subject = setNewSubject(oldObj, newObj, lead.Company);
                        }
                    }
                    if(newSubjEmpty || originalSubjectCorrect)
                    {
                        newObj.put('Subject', subject);
                    }
                }
            }
        }
    }
    
    private static boolean checkOriginalSubject(SObject oldObj, SObject newObj, string title)
    {
        if(oldObj != null && (string)oldObj.get('Subject') == (string)oldObj.get('Subject1__c') + ' - ' + title 
                    && (string)oldObj.get('Subject1__c') != (string)newObj.get('Subject1__c'))
                    return true;
        return false;
    }
    
    private static string setNewSubject(SObject oldObj, SObject newObj, string title)
    {
        return (string)newObj.get('Subject1__c') + ' - ' + title;
    }
   
    public static String getAccountId(String whatId)
    {
        // 001- Account, 500-Case,003-contact,006-opportunity
        if (whatId.substring(0,3)=='006')
        {
            List<Opportunity> oppIdLst = [select Id,AccountId from Opportunity where Id = : whatId];
            return oppIdLst[0].AccountId;
        }
        if (whatId.substring(0,3)=='001')
        {
            return whatId;
        }
        if(whatId.substring(0,3)=='500')
        {
            List<Case> casesList = [select Id,AccountId from Case where Id = : whatId];
            if(String.isNotEmpty(casesList.get(0).AccountId))
            {
                return casesList.get(0).AccountId;
            }
            return  '';
        }
        if (whatId.substring(0,3)=='003')
        {
            List <Contact> contactLst = [select Id,AccountId from Contact where Id = : whatId];
            return contactLst[0].AccountId;
        }
        return '';
    }
}