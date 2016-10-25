/**
* @author       Andrey Gordienko (andrey_gordienko@epam.com)
* @date         2015 Jule 21
* @description  This class is intended to facilitate creating and populating dummy Task or Event for unit testing.*
*/
@isTest
public class TST_TaskAndEventTestHelper {
	
    public static Task createTask(String whatId, Boolean insertNow)
    {
        return createTask(whatId, TLR_RecordTypeHelper.getId('Task','Sales Task'),insertNow);
    }
    public static Task createTask(String whatId, string RecordTypeId, Boolean insertNow)
    {
    	Task task = new Task();
    	task.WhatId = whatId;
    	task.RecordTypeId = RecordTypeId;
    	task.OwnerId = UserInfo.getUserId();
    	task.Type = '12 E-mail in';
    	task.Product__c = 'TFC';
    	task.Subject_Group__c = '95 Sales Process';
    	task.Subject1__c = '23 Migration';
    	task.Status = 'Not Started';
    	task.Priority = 'Normal';
    	task.ActivityDate = Date.Today();
    	if(insertNow)
    		insert task;
    	return task;
    }
    
    public static Event createEvent(String whatId, Boolean insertNow)
    {
        return createEvent(whatId, TLR_RecordTypeHelper.getId('Event','Sales Event'),insertNow);
    }
    
    public static Event createEvent(String whatId,string RecordTypeId, Boolean insertNow)
    {
    	Event event = new Event();
    	event.WhatId = whatId;
    	event.RecordTypeId = RecordTypeId;
    	event.OwnerId = UserInfo.getUserId();
    	event.Type = '12 E-mail in';
    	event.Product__c = 'TFC';
    	event.Subject_Group__c = '95 Sales Process';
    	event.Subject1__c = '23 Migration';
    	event.Start__c = Date.Today();
    	event.End__c = Date.today();
        event.DurationInMinutes = 50;
        event.ActivityDateTime = Datetime.now();
		event.StartDateTime = event.ActivityDateTime;
    	if(insertNow)
    		insert event;
    	return event;
    }
}