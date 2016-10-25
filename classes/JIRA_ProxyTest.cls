/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2015 September 23
* @description  unit test for JIRA_Proxy
**/
@isTest
public class JIRA_ProxyTest 
{
    public static testMethod void NotifyCaseUpdatedTestPositive()
    {
        TST_CustomSettingTestHelper.createFXSettings();
        Case c = TST_CaseTestHelper.createDummyCase(TLR_RecordTypeHelper.getId('Case', 'TLR Support Case') , false);
        c.JIRA_Ticket__c = 'OOPS-I-DID-IT-AGAIN';
        insert c;
        
        //c = [SELECT Id FROM Case WHERE Id = :c.Id];
        
        TST_GenericHttpCalloutMock mock = new TST_GenericHttpCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        JIRA_Proxy.NotifyCaseUpdated(c.Id);
        Test.stopTest();
        
        system.assertEquals(true, mock.callWasPerformed, 'Jira call was not performed when required!');
    }
}