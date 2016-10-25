/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2015 September 24
* @description  unit test for Attachment trigger
**/
@isTest
public class TST_AttachmentTest 
{
	public static testMethod void InsertTestPositive()
    {
        TST_CustomSettingTestHelper.createFXSettings();
        Case c = TST_CaseTestHelper.createDummyCase(TLR_RecordTypeHelper.getId('Case', 'TLR Support Case') , false);
        c.JIRA_Ticket__c = 'OOPS-I-DID-IT-AGAIN';
        insert c;
        
        Attachment a = new Attachment();
        a.Name = 'test attachment';
        a.Body = Blob.valueOf('Test Attachment Body');
        a.ParentId = c.Id;
        
        TST_GenericHttpCalloutMock mock = new TST_GenericHttpCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        insert a;
        Test.stopTest();
        
        system.assertEquals(true, mock.callWasPerformed, 'Jira call was not performed when required!');
    }
    
    public static testMethod void InsertTestNegative1()
    {
        TST_CustomSettingTestHelper.createCountryParams();
        TST_CustomSettingTestHelper.createFXSettings();
        Lead l = TST_LeadTestHelper.createLead(true);
        Attachment a = new Attachment();
        a.Name = 'test attachment';
        a.Body = Blob.valueOf('Test Attachment Body');
        a.ParentId = l.Id;
        
        TST_GenericHttpCalloutMock mock = new TST_GenericHttpCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        insert a;
        Test.stopTest();
        
        system.assertEquals(false, mock.callWasPerformed, 'Jira call was performed when it should be skipped!');
    }
    
    public static testMethod void InsertTestNegative2()
    {
        TST_CustomSettingTestHelper.createFXSettings();
        Case c = TST_CaseTestHelper.createDummyCase(TLR_RecordTypeHelper.getId('Case', 'TLR Support Case') , true);
        
        Attachment a = new Attachment();
        a.Name = 'test attachment';
        a.Body = Blob.valueOf('Test Attachment Body');
        a.ParentId = c.Id;
        
        TST_GenericHttpCalloutMock mock = new TST_GenericHttpCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        insert a;
        Test.stopTest();
        
        system.assertEquals(false, mock.callWasPerformed, 'Jira call was performed when it should be skipped!');
    }
}