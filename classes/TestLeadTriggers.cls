@isTest
private class TestLeadTriggers {

    static testMethod void LeadTriggersTest()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        // TO DO: implement unit test
        
      test.startTest();
	        Lead L = TST_LeadTestHelper.createLead(false);
	        L.Status ='Open';
	        L.Language__c = 'English';
	        L.LeadSource = 'webform';
	        L.Country ='France';

	        insert L;
	   test.stopTest();
    }
}