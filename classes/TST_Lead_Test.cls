@isTest
public class TST_Lead_Test 
{
	public static testMethod void TlrUpdateTotalNumberEmployeeTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Lead testLead = TST_LeadTestHelper.createLead(TLR_RecordTypeHelper.getId('Lead', 'TLR Lead'), false);
        insert testLead;
        testLead.Status = 'Dropped';
        update testLead;
        testLead = [select Id, Dropped_Date__c, NumberOfEmployees from Lead];
        system.assertEquals(Date.today(), testLead.Dropped_Date__c);
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.Id);
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
		System.assert(lcr.isSuccess(), 'Lead is not converted');
        List<Account> accs = [select Id, Name, Total_employees__c from Account];
        system.assertEquals(1, accs.size(), 'One Account must be created');
        system.assertEquals(testLead.NumberOfEmployees, accs[0].Total_employees__c
                            , 'Number of Emploees field on Lead must be copied to Total Emploees field on Account during conversion');
    }
    
    public static testMethod void ValidatePhonesUpdateTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});       
        string phoneValMessage = Utilities.getPhoneValidationErrorMessage();
        string testCorrectPhone = '+32 025551212';
        string testIncorrectPhone = '+32025551212';
        Lead testLead = TST_LeadTestHelper.createLead(false);
        testLead.Phone = null;
        testLead.MobilePhone = null;
        testLead.Fax = null;
        insert testLead;
        
        testLead.Phone = testIncorrectPhone;
        testLead.MobilePhone = testIncorrectPhone;
        update testLead;
        testLead = [select Id, Soft_Validation_Phone__c, Soft_Validation_Mobile_Phone__c from Lead where Id =: testLead.Id];
        system.assertEquals(phoneValMessage, testLead.Soft_Validation_Phone__c, 'Soft Validation Phone must be filled');
        system.assertEquals(phoneValMessage, testLead.Soft_Validation_Mobile_Phone__c, 'Soft Validation Mobile Phone must be filled');
        
        testLead.Phone = testCorrectPhone;
        testLead.MobilePhone = testCorrectPhone;
        update testLead;
        testLead = [select Id, Soft_Validation_Phone__c, Soft_Validation_Mobile_Phone__c from Lead where Id =: testLead.Id];
        system.assert(string.isEmpty(testLead.Soft_Validation_Phone__c), 'Soft Validation Phone must be cleared if phone has been corrected');
        system.assert(string.isEmpty(testLead.Soft_Validation_Mobile_Phone__c), 'Soft Validation Mobile Phone must be cleared if phone has been corrected');
        
        testLead.Phone = testIncorrectPhone;
        testLead.MobilePhone = testIncorrectPhone;
        update testLead;
        testLead = [select Id, Soft_Validation_Phone__c, Soft_Validation_Mobile_Phone__c from Lead where Id =: testLead.Id];
        system.assertEquals(phoneValMessage, testLead.Soft_Validation_Phone__c, 'Soft Validation Phone must be filled');
        system.assertEquals(phoneValMessage, testLead.Soft_Validation_Mobile_Phone__c, 'Soft Validation Mobile Phone must be filled');
        
        testLead.Phone = null;
        testLead.MobilePhone = null;
        update testLead;
        testLead = [select Id, Soft_Validation_Phone__c, Soft_Validation_Mobile_Phone__c from Lead where Id =: testLead.Id];
        system.assert(string.isEmpty(testLead.Soft_Validation_Phone__c), 'Soft Validation Phone must be cleared if phone has been cleared');
        system.assert(string.isEmpty(testLead.Soft_Validation_Mobile_Phone__c), 'Soft Validation Mobile Phone must be cleared if phone has been cleared');
        
        testLead.Fax = testIncorrectPhone;
        DmlException exc;
        try
        {
            update testLead;
        }
        catch(DmlException e)
        {
            Exc = e;
        }
        system.assertNotEquals(null, exc, 'exception must not be null');
        system.assertEquals(phoneValMessage, exc.getDmlMessage(0), 'Error message is wrong');
        
        testLead.Fax = null;
        exc = null;
        try
        {
            update testLead;
        }
        catch(DmlException e)
        {
            Exc = e;
        }
        system.assertEquals(null, exc, 'exception must not be null');
        
        testLead.Fax = testCorrectPhone;
        exc = null;
        try
        {
            update testLead;
        }
        catch(DmlException e)
        {
            Exc = e;
        }
        system.assertEquals(null, exc, 'exception must be null');
        testLead = [select Id, Fax from Lead where Id =: testLead.Id];
        system.assertEquals(testCorrectPhone, testLead.Fax, 'Fax must be updated');
    }
    
    public static testMethod void ValidatePhonesInsertTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});       
        string phoneValMessage = Utilities.getPhoneValidationErrorMessage();
        string testCorrectPhone = '+32 025551212';
        string testIncorrectPhone = '+32025551212';
        Lead testLead = TST_LeadTestHelper.createLead(false);
        testLead.Phone = testIncorrectPhone;
        testLead.MobilePhone = testIncorrectPhone;
        insert testLead;
        testLead = [select Id, Soft_Validation_Phone__c, Soft_Validation_Mobile_Phone__c from Lead where Id =: testLead.Id];
        system.assertEquals(phoneValMessage, testLead.Soft_Validation_Phone__c, 'Soft Validation Phone must be filled');
        system.assertEquals(phoneValMessage, testLead.Soft_Validation_Mobile_Phone__c, 'Soft Validation Mobile Phone must be filled');
        
        delete testLead;
        testLead = TST_LeadTestHelper.createLead(false);
        testLead.Phone = testCorrectPhone;
        testLead.MobilePhone = testCorrectPhone;
        insert testLead;
        testLead = [select Id, Soft_Validation_Phone__c, Soft_Validation_Mobile_Phone__c from Lead where Id =: testLead.Id];
        system.assert(string.isEmpty(testLead.Soft_Validation_Phone__c), 'Soft Validation Phone must be cleared if phone has been corrected');
        system.assert(string.isEmpty(testLead.Soft_Validation_Mobile_Phone__c), 'Soft Validation Mobile Phone must be cleared if phone has been corrected');
        
        delete testLead;
        testLead = TST_LeadTestHelper.createLead(false);
        testLead.Fax = testIncorrectPhone;
        DmlException exc;
        try
        {
            insert testLead;
        }
        catch(DmlException e)
        {
            Exc = e;
        }
        system.assertNotEquals(null, exc, 'exception must not be null');
        system.assertEquals(phoneValMessage, exc.getDmlMessage(0), 'Error message is wrong');
        
        testLead = TST_LeadTestHelper.createLead(false);
        testLead.Fax = testCorrectPhone;
        exc = null;
        try
        {
            insert testLead;
        }
        catch(DmlException e)
        {
            Exc = e;
        }
        system.assertEquals(null, exc, 'exception must not be null');
        testLead = [select Id, Fax from Lead where Id =: testLead.Id];
        system.assertEquals(testCorrectPhone, testLead.Fax, 'Fax must be updated');
    }
    
    public static testMethod void UpdateTaskOrEventSubjectTest()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        integer numberOfActivitiesPerLead = 2;
        integer numberOfLeads = 2;
        Lead testLead;
        Task testTask;
        Event testEvent;
        Map<Id, Lead> leadsMap;
        List<Lead> leads = TST_LeadTestHelper.createLeadList(numberOfLeads, true);
        List<Task> tasks = new List<Task>();
        List<Event> events = new List<Event>();
		for(integer i = 0; i < numberOfLeads; i++)
        {
             for(integer j = 0; j < numberOfActivitiesPerLead; j++)
            {
                testTask = new Task();
                testTask.WhoId = leads[i].Id;
                testTask.Subject1__c = 'test subject subgroup ' + j;
                insert testTask;
                tasks.add(testTask);
                testEvent = new Event();
                testEvent.ActivityDateTime = DateTime.now();
                testEvent.DurationInMinutes = 10;
                testEvent.WhoId = leads[i].Id;
                testEvent.Subject1__c = 'test subject subgroup ' + j;
                insert testEvent;
                events.add(testEvent);                
            }
        }
        tasks = [select Id, WhoId, Subject, Subject1__c from Task where Id =: tasks];
        events = [select Id, WhoId, Subject, Subject1__c from Event where Id =: events];
        leadsMap = new Map<Id, Lead>([select Id, Company from Lead]); 
       	for(Task t : tasks)
        {
            system.assertEquals(t.Subject1__c + ' - ' + leadsMap.get(t.WhoId).Company, t.Subject, 'Subject hasn\'t been correctly filled for Task');
        }
        for(Event e : events)
        {
            system.assertEquals(e.Subject1__c + ' - ' + leadsMap.get(e.WhoId).Company, e.Subject, 'Subject hasn\'t been correctly filled for Event');
        }
        
        for(integer i = 0; i < numberOfLeads; i++)
        {
            leads[i].Company = 'testComanyModified' + i;
        }
        Test.startTest();
        update leads;
        Test.stopTest();
        tasks = [select Id, WhoId, Subject, Subject1__c from Task where Id =: tasks];
        events = [select Id, WhoId, Subject, Subject1__c from Event where Id =: events];
        leadsMap = new Map<Id, Lead>([select Id, Company from Lead]); 
       	for(Task t : tasks)
        {
            system.assertEquals(t.Subject1__c + ' - ' + leadsMap.get(t.WhoId).Company, t.Subject, 'Subject hasn\'t been correctly modified for Task');
        }        
        for(Event e : events)
        {
            system.assertEquals(e.Subject1__c + ' - ' + leadsMap.get(e.WhoId).Company, e.Subject, 'Subject hasn\'t been correctly modified for Event');
        }
    }
    
}