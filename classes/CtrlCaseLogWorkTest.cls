@isTest
public class CtrlCaseLogWorkTest 
{
    static Case testCase;
    static CtrlCaseLogWork ext;
    
    public static testMethod void TestStartWorkPositive() 
    {
        CreateTestData();		

        ext = new CtrlCaseLogWork(new ApexPages.StandardSetController(new List<Case_Timelog__c>()));
        ext.init();
        testCase = [select Id, Work_Start_Time__c from Case where Id =: testCase.Id];
        system.assertNotEquals(null, testCase.Work_Start_Time__c, 'Work Start Time must be set');
        Long StartTimeNowDifference = DateTime.now().getTime() - testCase.Work_Start_Time__c.getTime();
        system.assert(StartTimeNowDifference < 10000, 'Work Start Time must be set to now. Actual difference between Start time and now in milliseconds: ' +StartTimeNowDifference);        
        system.assertEquals(0, apexpages.getMessages().size(), 'There must not be apex messages');
    }
    
    public static testMethod void TestStartWorkNegative() 
    {
        CreateTestData();
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User usr1 = New User(Alias = 'testUsr1', 
                             Username = 'testUsr1@test.ww',
                             CommunityNickname = 'testUsr1',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles');  
        usr1.Disable_Validation_Rules_and_Workflows__c = true;
        insert usr1;
        system.runAs(usr1)
        {
            testCase.Loading_Date__c = Date.today();
            testCase.Delivery_Date__c = Date.today() - 1;
            update testCase;
        }
        ext = new CtrlCaseLogWork(new ApexPages.StandardSetController(new List<Case_Timelog__c>()));
        system.assert(apexpages.getMessages().size() == 0, 'there must not be apex messages by now');
        ext.init();
        system.assert(apexpages.getMessages().size() > 0, 'there must be apex messages');
    }
    
    public static testMethod void TestStopPositive()
    {
        CreateTestData();
        DateTime initialTime = DateTime.now().addMinutes(-100);
        testCase.Work_Start_Time__c = initialTime;   
        update testCase;
        testCase = [select Id, Work_Start_Time__c from Case where Id =: testCase.Id];
        system.assertEquals(initialTime, testCase.Work_Start_Time__c, 'Work Start Time is not set correctly');
        ext = new CtrlCaseLogWork(new ApexPages.StandardSetController(new List<Case_Timelog__c>()));
        ext.init();
        testCase = [select Id, Work_Start_Time__c from Case where Id =: testCase.Id];
        system.assertEquals(initialTime, testCase.Work_Start_Time__c, 'Work Start Time must not be changed');
        ext.log.Subject_Group__c = 'qwer';
        ext.log.Subject__c = 'asdf';
        ext.log.Description__c = 'some description';
        ext.Save();
        testCase = [select Id, Work_Start_Time__c from Case where Id =: testCase.Id];
        system.assertEquals(null, testCase.Work_Start_Time__c, 'Work Start Time on Case must be cleared');
        List<Case_Timelog__c> logs = [select Id, Subject_Group__c, Subject__c, Description__c, Intervention_minutes__c, Start_Time__c, Case__c 
                                      from Case_Timelog__c];
        system.assertEquals(1, logs.size(), 'One Case Time Log must be crested');
        Case_Timelog__c log = logs[0];
        system.assertEquals('qwer', log.Subject_Group__c, 'Subject group is wrong');
        system.assertEquals('asdf', log.Subject__c, 'Subject is wrong');
        system.assertEquals('some description', log.Description__c, 'Description group is wrong');
        system.assertEquals(initialTime, log.Start_Time__c, 'Start Date is wrong');
        system.assert(log.Intervention_minutes__c <= 101 && log.Intervention_minutes__c >= 99, 'Calculated spent time is wrong');    	
        system.assertEquals(0, apexpages.getMessages().size(), 'There must not be apex messages');
    }
    
    public static testMethod void TestStopNegative()
    {
        CreateTestData();
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User usr1 = New User(Alias = 'testUsr1', 
                             Username = 'testUsr1@test.ww',
                             CommunityNickname = 'testUsr1',
                             LastName = 'Testing', 
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = commProfile.Id, 
                             Email = 'testUsr1@test.ww',
                             EmailEncodingKey = 'UTF-8',                                 
                             TimeZoneSidKey = 'America/Los_Angeles');  
        usr1.Disable_Validation_Rules_and_Workflows__c = true;
        insert usr1;        
        DateTime initialTime = DateTime.now().addMinutes(-100);
        testCase.Work_Start_Time__c = initialTime;   
        update testCase;
        ext = new CtrlCaseLogWork(new ApexPages.StandardSetController(new List<Case_Timelog__c>()));
        ext.init();
        system.runAs(usr1)
        {
            testCase.Loading_Date__c = Date.today();
            testCase.Delivery_Date__c = Date.today() - 1;
            update testCase;
        }
        ext.log.Subject_Group__c = 'qwer';
        ext.log.Subject__c = 'asdf';
        ext.log.Description__c = 'some description';
        system.assert(apexpages.getMessages().size() == 0, 'there must not be apex messages by now');
        ext.Save();
        system.assert(apexpages.getMessages().size() > 0, 'there must be apex messages');
        List<Case_Timelog__c> logs = [select Id from Case_Timelog__c];
        system.assertEquals(0, logs.size(), 'No Case Logs must be created');
        testCase = [select Id, Work_Start_Time__c from Case where Id =: testCase.Id];
        system.assertEquals(initialTime, testCase.Work_Start_Time__c, 'Work Start Time on Case must not be cleared');        
    }
    
    public static void CreateTestData()
    {
        testCase = new Case();
        insert testCase;
        ApexPages.currentPage().getParameters().put('Id', TestCase.Id);
    }
}