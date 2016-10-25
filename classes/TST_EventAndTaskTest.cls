/** 
* @author       Andrey Gordienko (andrey_gordienko@epam.com)
* @date         2015 Jule 22
* @description  tests for Event and Task triggers
**/
@isTest
public class TST_EventAndTaskTest
{
    private static Account testAcc;
    private static Case testCase;
    private static Opportunity testOpp;
    private static Contact testCont;
    private static Lead testLead;
    
	public static testMethod void UpdateTaskFieldsForReportingTest()
	{
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Task task = TST_TaskAndEventTestHelper.createTask(null, TLR_RecordTypeHelper.getId('Task', 'TLR Task'), true);
		task.Subject = 'Subject';
		task.CallDurationInSeconds = 50;
		update task;
		task = [Select Activity_Type__c, Type, Activity_Task_Subject__c, Subject, Activity_Task_Duration__c, CallDurationInSeconds From Task Where Id =: task.Id];
		system.AssertEquals(task.Activity_Type__c, task.Type, 'Task trigger method UpdateTaskFieldsForReporting not work');
		system.AssertEquals(task.Activity_Task_Subject__c, task.Subject, 'Task trigger method UpdateTaskFieldsForReporting not work');
		system.AssertEquals(task.Activity_Task_Duration__c, task.CallDurationInSeconds, 'Task trigger method UpdateTaskFieldsForReporting not work');     
	}
    
	public static testMethod void UpdateAccountLastVisitedDateTaskTest()
	{
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
		Task task = TST_TaskAndEventTestHelper.createTask(acc.Id, TLR_RecordTypeHelper.getId('Task', 'TLR Task'), false);
		task.Type = '23 Visit out';
		task.Status = 'Completed';
		insert task;
		acc = [Select Last_Visited__c From Account Where Id =: acc.Id];
		system.AssertEquals(acc.Last_Visited__c, Date.Today(), 'Update Last Visited Date failed');

	}

	public static testMethod void UpdateOpptyScreenShareTest()
	{
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
		Offer_template__c template = TST_OfferTemplateTestHelper.createDummyOfferTemplate(TLR_RecordTypeHelper.getId('Offer_template__c', 'TLR Offer Template'), true);	
		Opportunity opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, template, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity'), true);
		Task task = TST_TaskAndEventTestHelper.createTask(opp.Id, TLR_RecordTypeHelper.getId('Task', 'TLR Task'), false);
		task.Type = General_Settings__c.getInstance('Default').ScreenSharing_TaskType__c;
		insert task;
		opp = [Select Screenshsare_Count__c From Opportunity Where Id =: opp.Id];
		system.AssertEquals(opp.Screenshsare_Count__c, 1, 'Trigger method UpdateOpptyScreenShare not working correctly');
		update task;
		system.AssertEquals(opp.Screenshsare_Count__c, 1, 'Trigger method UpdateOpptyScreenShare not working correctly');
		opp.Screenshsare_Count__c = -5;
		update opp;
		update task;
		opp = [Select Screenshsare_Count__c From Opportunity Where Id =: opp.Id];
		system.AssertEquals(opp.Screenshsare_Count__c, 0, 'Trigger method UpdateOpptyScreenShare not working correctly');
	}

	public static testMethod void UpdateEventFieldForReportingTest()
	{
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
		Event event = TST_TaskAndEventTestHelper.createEvent(acc.Id, TLR_RecordTypeHelper.getId('Event', 'TLR Event'), false);
		event.StartDateTime = event.ActivityDateTime;
		event.EndDateTime = Datetime.now().addMinutes(50);
		insert event;
		event = [Select Activity_Event_Start__c, StartDateTime, Activity_Event_End__c, EndDateTime, Activity_Event_Type__c, Type, Activity_Event_Subject__c, Subject, Activity_Event_Duration__c, DurationInMinutes From Event Where id =: event.Id];
		system.AssertEquals(event.Activity_Event_Start__c, event.StartDateTime, 'Trigger method UpdateEventFieldForReporting not working correctly');
		system.AssertEquals(event.Activity_Event_End__c, event.EndDateTime, 'Trigger method UpdateEventFieldForReporting not working correctly'); 
		system.AssertEquals(event.Activity_Event_Type__c, event.Type, 'Trigger method UpdateEventFieldForReporting not working correctly');
		system.AssertEquals(event.Activity_Event_Subject__c, event.Subject, 'Trigger method UpdateEventFieldForReporting not working correctly');
		system.AssertEquals(event.Activity_Event_Duration__c, event.DurationInMinutes, 'Trigger method UpdateEventFieldForReporting not working correctly');
	}
	
	public static testMethod void UpdateAccountLastVisitedDateEventTest()
	{
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
		Event event = TST_TaskAndEventTestHelper.createEvent(acc.Id, TLR_RecordTypeHelper.getId('Event', 'TLR Event'), false);
		event.Type = '23 Visit out';
		insert event;
		acc = [Select Last_Visited__c From Account Where Id =: acc.id];
		event = [Select StartDateTime From Event Where id =: event.id];
        Date eventStartDateTimeDate = Date.newInstance(event.StartDateTime.year(), event.StartDateTime.month(), event.StartDateTime.day());
		system.Assert(eventStartDateTimeDate == acc.Last_Visited__c,'Trigger method UpdateAccountLastVisitedDateEvent not working correctly');   
		Event secondEvent = TST_TaskAndEventTestHelper.createEvent(acc.Id, TLR_RecordTypeHelper.getId('Event', 'Sales Event'), false);
		secondEvent.Type = '26 Demonstration'; 
		insert secondEvent;
		acc = [Select Last_Visited__c From Account Where Id =: acc.id];
		secondEvent = [Select StartDateTime From Event Where id =: secondEvent.id];
		//todo
		Date secondEventStartDateTimeDate = Date.newInstance(secondEvent.StartDateTime.year(), secondEvent.StartDateTime.month(), secondEvent.StartDateTime.day());
		system.Assert(secondEventStartDateTimeDate == acc.Last_Visited__c,  'Trigger method UpdateAccountLastVisitedDateEvent not working correctly');
		secondEvent.StartDateTime = Datetime.newInstance(2017, 11, 11);
		update secondEvent;
		acc = [Select Last_Visited__c From Account Where Id =: acc.id];
        secondEventStartDateTimeDate = Date.newInstance(secondEvent.StartDateTime.year(), secondEvent.StartDateTime.month(), secondEvent.StartDateTime.day());
		system.Assert(secondEventStartDateTimeDate == acc.Last_Visited__c, 'Trigger method UpdateAccountLastVisitedDateEvent not working correctly');
		secondEvent.StartDateTime = Datetime.newInstance(2016, 11, 11);
		update secondEvent;
		acc = [Select Last_Visited__c From Account Where Id =: acc.id];
        secondEventStartDateTimeDate = Date.newInstance(secondEvent.StartDateTime.year(), secondEvent.StartDateTime.month(), secondEvent.StartDateTime.day());
		system.Assert(secondEventStartDateTimeDate != acc.Last_Visited__c, 'Trigger method UpdateAccountLastVisitedDateEvent not working correctly');
	}
	

	public static testMethod void UpdateEventLocationTest()
	{
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
		Event event = TST_TaskAndEventTestHelper.createEvent(acc.Id, TLR_RecordTypeHelper.getId('Event', 'TLR Event'), true);
		event = [Select Location From Event Where id =: event.id];
		String addressInfo = '';
		addressInfo = getAddressInfo(acc.ShippingStreet, addressInfo);
		addressInfo = getAddressInfo(acc.ShippingCity, addressInfo);
		addressInfo = getAddressInfo(acc.ShippingCountry, addressInfo);
		addressInfo = getAddressInfo(acc.ShippingPostalCode, addressInfo);
		addressInfo = addressInfo+', '+acc.Phone;
		system.AssertEquals(event.Location, addressInfo, 'Trigger method UpdateEventLocation not working correctly');
	}

	public static testMethod void UpdateOpptyScreenShareAndDemosTest()
	{
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Account acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
		Offer_template__c template = TST_OfferTemplateTestHelper.createDummyOfferTemplate(TLR_RecordTypeHelper.getId('Offer_template__c', 'TLR Offer Template'), true);	
		Opportunity opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, template, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity'), true);
		Event event = TST_TaskAndEventTestHelper.createEvent(opp.Id, TLR_RecordTypeHelper.getId('Event', 'TLR Event'), false);
		event.Type = General_Settings__c.getInstance('Default').ScreenSharing_TaskType__c;
		insert event;
		opp = [Select Screenshsare_Count__c From Opportunity Where Id =: opp.Id];
		system.AssertEquals(opp.Screenshsare_Count__c, 1, 'Event Trigger method UpdateOpptyScreenShareAndDemos not working correctly');
		update event;
		system.AssertEquals(opp.Screenshsare_Count__c, 1, 'Event Trigger method UpdateOpptyScreenShareAndDemos not working correctly');
		opp.Screenshsare_Count__c = -5;
		update opp;
		update event;
		opp = [Select Screenshsare_Count__c From Opportunity Where Id =: opp.Id];
		system.AssertEquals(opp.Screenshsare_Count__c, 0, 'Event Trigger method UpdateOpptyScreenShareAndDemos not working correctly');
	}

	public static testMethod void UpdateLeadCounterTest()
	{
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Lead lead = TST_LeadTestHelper.createLead(true);
		system.assert([select Counter_of_All_Activities__c from Lead].Counter_of_All_Activities__c == null);
		Task task =  createTask(lead, TLR_RecordTypeHelper.getId('Task', 'TLR Task'), true);
		system.assert([select Counter_of_All_Activities__c from Lead].Counter_of_All_Activities__c == 1);
		Event event = createEvent(lead, TLR_RecordTypeHelper.getId('Event', 'TLR Event'), true);
		system.assert([select Counter_of_All_Activities__c from Lead].Counter_of_All_Activities__c == 2);
		update event;
		system.assert([select Counter_of_All_Activities__c from Lead].Counter_of_All_Activities__c == 2);
		update task;
		system.assert([select Counter_of_All_Activities__c from Lead].Counter_of_All_Activities__c == 2);
		delete event;
		system.assert([select Counter_of_All_Activities__c from Lead].Counter_of_All_Activities__c == 1);
		delete task;
		system.assert([select Counter_of_All_Activities__c from Lead].Counter_of_All_Activities__c == 0);
	}

	public static testMethod void UpdateCampaignCounterTest()
	{
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		Campaign camp = new Campaign();
		camp.Name = 'test campaign';
		insert camp;
		system.assert([select Counter_of_Activities__c from Campaign].Counter_of_Activities__c == null, '1');
		Task task =  createTask(camp, TLR_RecordTypeHelper.getId('Task', 'TLR Task'), true);
		system.assert([select Counter_of_Activities__c from Campaign].Counter_of_Activities__c == 1, '1');
		Event event = createEvent(camp, TLR_RecordTypeHelper.getId('Event', 'TLR Event'), true);
		system.assert([select Counter_of_Activities__c from Campaign].Counter_of_Activities__c == 2, '1');
		update event;
		system.assert([select Counter_of_Activities__c from Campaign].Counter_of_Activities__c == 2, '2');
		update task;
		system.assert([select Counter_of_Activities__c from Campaign].Counter_of_Activities__c == 2, '3');
		delete event;
		system.assert([select Counter_of_Activities__c from Campaign].Counter_of_Activities__c == 1, '4' );
		delete task;
		system.assert([select Counter_of_Activities__c from Campaign].Counter_of_Activities__c == 0, '5' );
		event = createEvent(camp, TLR_RecordTypeHelper.getId('Event', 'TLR Event'), true);
		system.assert([select Counter_of_Activities__c from Campaign].Counter_of_Activities__c == 1, '6' );
		task =  createTask(camp, TLR_RecordTypeHelper.getId('Task', 'TLR Task'), true);
		system.assert([select Counter_of_Activities__c from Campaign].Counter_of_Activities__c == 2, '7' );
	}
    
    public static testMethod void UpdateTaskOrEventSubjectInsertTestPositive()
    {
        createTestDataForSubjectTests();
        Sobject obj;
        Test.startTest();
        //Task
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TLR Task', testAcc.Id, null);
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testAcc.Name, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during insertion of task related to Account');  
        
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TLR Task', null, testCont.Id);
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testAcc.Name, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during insertion of task related to Contact');
        
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TLR Task', null, testLead.Id);
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testLead.Company, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during insertion of task related to Lead'); 
        
        //Event
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TLR Event', testAcc.Id, null);
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testAcc.Name, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during insertion of event related to Account');
        
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TLR Event', null, testCont.Id);
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testAcc.Name, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during insertion of event related to Contact');
        
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TLR Event', null, testLead.Id);
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testLead.Company, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during insertion of event related to Lead');
    }
    
    public static testMethod void UpdateTaskOrEventSubjectInsertTestNegative()
    {
        createTestDataForSubjectTests();
        Sobject obj;
        Test.startTest();
        //Task
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TWD Task', testAcc.Id, null);
        system.assertEquals(null, obj.get('Subject'), 'Subject must not be set for this record type');
        
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TWD Task', null, testCont.Id);
        system.assertEquals(null, obj.get('Subject'), 'Subject must not be set for this record type');
        
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TWD Task', null, testLead.Id);
        system.assertEquals(null, obj.get('Subject'), 'Subject must not be set for this record type');
        
        //Event
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TWD Event', testAcc.Id, null);
        system.assertEquals(null, obj.get('Subject'), 'Subject must not be set for this record type');
        
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TWD Event', null, testCont.Id);
        system.assertEquals(null, obj.get('Subject'), 'Subject must not be set for this record type');
        
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TWD Event', null, testLead.Id);
        system.assertEquals(null, obj.get('Subject'), 'Subject must not be set for this record type');
    }
    
    public static testMethod void UpdateTaskOrEventSubjectUpdateTestPositive_1()
    {
        createTestDataForSubjectTests();
        Sobject obj;
        Test.startTest();
        //Task
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TLR Task', null, null);
        obj = prepareTaskOrEventForSubjectTests('Task', obj, null, testAcc.Id, null); //update
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testAcc.Name, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during update of task related to Account');
        
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TLR Task', null, null);
        obj = prepareTaskOrEventForSubjectTests('Task', obj, null, null, testCont.Id);//update
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testAcc.Name, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during update of task related to Contact');
        
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TLR Task', null, null);
        obj = prepareTaskOrEventForSubjectTests('Task', obj, null, null, testLead.Id);//update
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testLead.Company, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during update of task related to Lead');  
        
        //Event
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TLR Event', null, null);
        obj = prepareTaskOrEventForSubjectTests('Event', obj, null, testAcc.Id, null);//update
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testAcc.Name, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during update of event related to Account');
        
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TLR Event', null, null);
        obj = prepareTaskOrEventForSubjectTests('Event', obj, null, null, testCont.Id);//update
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testAcc.Name, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during update of event related to Contact');
        
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TLR Event', null, null);
        obj = prepareTaskOrEventForSubjectTests('Event', obj, null, null, testLead.Id);//update
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testLead.Company, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during update of event related to Lead');        
    }
	
    public static testMethod void UpdateTaskOrEventSubjectUpdateTestPositive_2()
    {
     	createTestDataForSubjectTests();
        Sobject obj;
        Test.startTest();
        //Task
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TLR Task', testAcc.Id, null);
        obj = prepareTaskOrEventForSubjectTests('Task', obj, null, testAcc.Id, null, 'new Sobject1'); //update
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testAcc.Name, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during update of task related to Account');
        
        obj = prepareTaskOrEventForSubjectTests('Task', obj, null, null, testCont.Id, 'new Sobject1'); //update
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testAcc.Name, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during update of task related to Contact');
        
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TLR Task', null, testLead.Id);
        obj = prepareTaskOrEventForSubjectTests('Task', obj, null, null, testLead.Id, 'new Sobject1'); //update
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testLead.Company, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during update of task related to Lead');  
        
        //Event        
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TLR Event', testAcc.Id, null);
        obj = prepareTaskOrEventForSubjectTests('Event', obj, null, testAcc.Id, null, 'new Sobject1'); //update
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testAcc.Name, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during update of event related to Account');
        
        obj = prepareTaskOrEventForSubjectTests('Event', obj, null, null, testCont.Id, 'new Sobject1'); //update
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testAcc.Name, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during update of event related to Contact');
        
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TLR Event', null, testLead.Id);
        obj = prepareTaskOrEventForSubjectTests('Event', obj, null, null, testLead.Id, 'new Sobject1'); //update
        system.assertEquals(obj.get('Subject1__c') + ' - ' + testLead.Company, obj.get('Subject'), 
                            'Subject hasn\'t been correctly set during update of event related to Lead');           
    }
    
    public static testMethod void UpdateTaskOrEventSubjectUpdateTestNegative_1()
    {
        createTestDataForSubjectTests();
        Sobject obj;
        Test.startTest();
        //Task
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TWD Task', null, null);
        obj = prepareTaskOrEventForSubjectTests('Task', obj, null, testAcc.Id, null);
        system.assertEquals(null, obj.get('Subject'), 'Subject must not be updated for this record type');
        
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TWD Task', null, null);
        obj = prepareTaskOrEventForSubjectTests('Task', obj, null, null, testCont.Id);
        system.assertEquals(null, obj.get('Subject'), 'Subject must not be updated for this record type');
        
        obj = prepareTaskOrEventForSubjectTests('Task', null, 'TWD Task', null, null);
        obj = prepareTaskOrEventForSubjectTests('Task', obj, null, null, testLead.Id);
        system.assertEquals(null, obj.get('Subject'), 'Subject must not be updated for this record type');       
        
        //Event
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TWD Event', null, null);
        obj = prepareTaskOrEventForSubjectTests('Event', obj, null, testAcc.Id, null);
        system.assertEquals(null, obj.get('Subject'), 'Subject must not be updated for this record type');
        
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TWD Event', null, null);
        obj = prepareTaskOrEventForSubjectTests('Event', obj, null, null, testCont.Id);
        system.assertEquals(null, obj.get('Subject'), 'Subject must not be updated for this record type');
        
        obj = prepareTaskOrEventForSubjectTests('Event', null, 'TWD Event', null, null);
        obj = prepareTaskOrEventForSubjectTests('Event', obj, null, null, testLead.Id);
        system.assertEquals(null, obj.get('Subject'), 'Subject must not be updated for this record type');     
    }
        
    public static testMethod void UpdateTaskOrEventSubjectUpdateTestNegative_2()
    {
     	createTestDataForSubjectTests();
        Sobject obj;
        Test.startTest();
        obj = prepareTaskOrEventForSubjectTests('Task', 'some subject', null, 'TLR Task', null, null);
        obj = prepareTaskOrEventForSubjectTests('Task', obj, null, testAcc.Id, null);
        system.assertEquals('some subject', obj.get('Subject'), 'Subject must not be changed if it is not constructed in the trigger');
        obj = prepareTaskOrEventForSubjectTests('Task', obj, null, null, testCont.Id);
        system.assertEquals('some subject', obj.get('Subject'), 'Subject must not be changed if it is not constructed in the trigger');
        obj = prepareTaskOrEventForSubjectTests('Task', obj, null, null, testLead.Id);
        system.assertEquals('some subject', obj.get('Subject'), 'Subject must not be changed if it is not constructed in the trigger');     
        obj = prepareTaskOrEventForSubjectTests('Event', 'some subject', null, 'TLR Event', null, null);
        obj = prepareTaskOrEventForSubjectTests('Event', obj, null, testAcc.Id, null);
        system.assertEquals('some subject', obj.get('Subject'), 'Subject must not be changed if it is not constructed in the trigger');
        obj = prepareTaskOrEventForSubjectTests('Event', obj, null, null, testCont.Id);
        system.assertEquals('some subject', obj.get('Subject'), 'Subject must not be changed if it is not constructed in the trigger');
        obj = prepareTaskOrEventForSubjectTests('Event', obj, null, null, testLead.Id);
        system.assertEquals('some subject', obj.get('Subject'), 'Subject must not be changed if it is not constructed in the trigger');      
    }
    
    public static testMethod void getAccountIdTest()
    {
        createTestDataForSubjectTests();
        system.assertEquals(testAcc.Id, TLR_EventAndTaskHelper.getAccountId(testCase.Id), 'Method hasn\'t returned the correct Id value for Case');
        system.assertEquals(testAcc.Id, TLR_EventAndTaskHelper.getAccountId(testOpp.Id), 'Method hasn\'t returned the correct Id value for Opportunity');
        system.assertEquals(testAcc.Id, TLR_EventAndTaskHelper.getAccountId(testCont.Id), 'Method hasn\'t returned the correct Id value for Contact');
        system.assertEquals(testAcc.Id, TLR_EventAndTaskHelper.getAccountId(testAcc.Id), 'Method hasn\'t returned the correct Id value for Account');
    }
    
    private static SObject prepareTaskOrEventForSubjectTests(string objectType, string subject, SObject obj, string recordTypeName, Id whatId, Id whoId, string subject1)
    {
        return prepareTaskOrEventForSubjectTests(objectType, subject, true, obj, recordTypeName, whatId, whoId, subject1, true);
    }
    
    private static SObject prepareTaskOrEventForSubjectTests(string objectType, string subject, SObject obj, string recordTypeName, Id whatId, Id whoId)
    {
        return prepareTaskOrEventForSubjectTests(objectType, subject, true, obj, recordTypeName, whatId, whoId, null, false);
    }
    
    
    private static SObject prepareTaskOrEventForSubjectTests(string objectType, SObject obj, string recordTypeName, Id whatId, Id whoId, string subject1)
    {
        return prepareTaskOrEventForSubjectTests(objectType, null, false, obj, recordTypeName, whatId, whoId, subject1, true);
    }
    
    private static SObject prepareTaskOrEventForSubjectTests(string objectType, SObject obj, string recordTypeName, Id whatId, Id whoId)
    {
        return prepareTaskOrEventForSubjectTests(objectType, null, false, obj, recordTypeName, whatId, whoId, null, false);
    }
    
    private static SObject prepareTaskOrEventForSubjectTests(string objectType, string subject, boolean changeSubject, SObject obj, string recordTypeName
                                                             , Id whatId, Id whoId, string subject1, boolean changeSubject1)
    {
        if(objectType != 'Task' && objectType != 'Event')
            return null;
        SObject sobj;
        if(obj == null)
        {
            if(objectType == 'Task')
            {
                sobj = TST_TaskAndEventTestHelper.createTask(null, false);
            }
            if(objectType == 'Event')
            {
                sobj = TST_TaskAndEventTestHelper.createEvent(null, false);
            }
            sobj.put('RecordTypeId', TLR_RecordTypeHelper.getId(objectType, recordTypeName));
            sobj.put('WhoId', whoId);
            sobj.put('WhatId', whatId);
            if(changeSubject1)
            	sobj.put('Subject1__c', subject1);
            if(changeSubject)
            	sobj.put('Subject', subject);
            insert sobj;
        }
        else
        {
            sobj = obj;
            sobj.put('WhoId', whoId);
            sobj.put('WhatId', whatId);
            if(changeSubject1)
            	sobj.put('Subject1__c', subject1);
            if(changeSubject)
            	sobj.put('Subject', subject);
            update sobj;
        }
        sobj = Database.query('select Id, Subject, Subject1__c from ' + objectType + ' where Id = \'' + sobj.get('Id') + '\'');
        return sobj;
    }
    
    private static void createTestDataForSubjectTests()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        testAcc = TST_AccountTestHelper.createDummyAccount('Belgium', true);   
        testCase = TST_CaseTestHelper.createDummyCase(TLR_RecordTypeHelper.getId('Case', 'TAS Support Case'), false);   
        testCase.AccountId = testAcc.Id;
        insert testCase;
        testOpp = TST_OpportunityTestHelper.createDummyOpportunity(testAcc, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity'), true);
        testCont = TST_ContactTestHelper.createDummyContact(testAcc, TLR_RecordTypeHelper.getId('Contact', 'TAS Contact'), true);
        testLead = TST_LeadTestHelper.createLead(true);
    }

	private static string getAddressInfo(string arg, string addressInfo)
	{
		if(String.isNotEmpty(arg))
		{
			if(String.isNotEmpty(addressInfo))
			{
				addressInfo = addressInfo+', '+arg;
			}
			else 
			{
				addressInfo = arg;
			}
		}
		return addressInfo;
	}
    
	public static Event createEvent(SObject obj, string RecordTypeId, Boolean insertNow)
	{
		Event event = new Event();
		if(obj.getSObjectType() == Lead.getSObjectType())
		{
			Lead l = (Lead)obj;
			event.WhoId = l.Id;
		}
		else if(obj.getSObjectType() == Campaign.getSObjectType())
		{
			Campaign c = (Campaign)obj;
			event.Campaign__c = c.Id;
		}
		else 
		{
			return null;
		}
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
		if(insertNow)
			insert event;
		return event;
	}
    
	public static Task createTask(SObject obj, string RecordTypeId, Boolean insertNow)
	{
		Task task = new Task();
		if(obj.getSObjectType() == Lead.getSObjectType())
		{
			Lead l = (Lead)obj;
			task.WhoId = l.Id;
		}
		else if(obj.getSObjectType() == Campaign.getSObjectType())
		{
			Campaign c = (Campaign)obj;
			task.Campaign__c = c.Id;
		}
		else 
		{
			return null;
		}
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
}