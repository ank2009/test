/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2015 September 24
* @description  unit test for CaseComment trigger
**/
@isTest
public class TST_CaseCommentTest
{
	public static testMethod void InsertTestPositive()
    {
        TST_CustomSettingTestHelper.createFXSettings();
        Case c = TST_CaseTestHelper.createDummyCase(TLR_RecordTypeHelper.getId('Case', 'TLR Support Case') , false);
        c.JIRA_Ticket__c = 'OOPS-I-DID-IT-AGAIN';
        insert c;
        CaseComment cc = new CaseComment();
        cc.ParentId = c.Id;
        cc.CommentBody = 'test comment body';
        
        TST_GenericHttpCalloutMock mock = new TST_GenericHttpCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        insert cc;
        Test.stopTest();
        
        system.assertEquals(true, mock.callWasPerformed, 'Jira call was not performed when required!');
    }
    
    public static testMethod void InsertTestNegative()
    {
        TST_CustomSettingTestHelper.createFXSettings();
        Case c = TST_CaseTestHelper.createDummyCase(TLR_RecordTypeHelper.getId('Case', 'TLR Support Case') , true);
        CaseComment cc = new CaseComment();
        cc.ParentId = c.Id;
        cc.CommentBody = 'test comment body';
        
        TST_GenericHttpCalloutMock mock = new TST_GenericHttpCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        insert cc;
        Test.stopTest();
        
        system.assertEquals(false, mock.callWasPerformed, 'Jira call was performed when it should be skipped!');
    }
}