@isTest
private class TLR_ServiceOrderTest
{
	private static Id pmtServiceOrder = TLR_RecordTypeHelper.getId('Service_Order__c', 'PMT ServiceOrder');
	
	static testMethod void PMTCreate()
	{
		Service_Order__c so = new Service_Order__c();
		
		so.recordTypeId = pmtServiceOrder;
		so.Status__c = 'Planned';
		
		so.Start_of_service__c = date.today();
		so.End_of_service__c = date.today().addDays(1);
		so.Comments__c = 'asdasdasd';
		
		so.Subscription__c = createSubs().Id;
		
		
		insert so;
	}
	
	private static Subscription__c createSubs()
	{
		TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		
		Account acc = TST_AccountTestHelper.createDummyAccount(true);
		Offer_template__c ot = TST_OfferTemplateTestHelper.createDummyOfferTemplate(TLR_RecordTypeHelper.getId('Offer_template__c', 'TAS Offer template'), true);
		Opportunity opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, ot, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity'), true);
		Contract contr = TST_ContractTestHelper.createDummyContract(opp, TLR_RecordTypeHelper.getId('Contract', 'TAS Contract'), true);
		Subscription__c subs = TST_SubscriptionTestHelper.createDummySubscription(contr, opp, TLR_RecordTypeHelper.getId('Subscription__c', 'TAS Subscription'), true);
		
		return subs;
	}
}