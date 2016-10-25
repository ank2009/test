@isTest
private class TLR_QuoteExtTest
{
	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 September 18
	* @description  Test method. Just creates class instance.
	**/
	public static testMethod void QuoteExtConstructorTest()
	{
		/*Quote q = CreateTestQuote();
		ApexPages.StandardController controller = new ApexPages.StandardController(q);

		TLR_QuoteExt qExt = new TLR_QuoteExt(controller);*/
	}

	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 September 18
	* @description  Test method. Just creates class instance.
	**/
	private static Quote CreateTestQuote()
	{
		Account acc = TST_AccountTestHelper.createDummyAccount(true);
		Offer_template__c ot = TST_OfferTemplateTestHelper.createDummyOfferTemplate(TLR_RecordTypeHelper.getId('Offer_template__c', 'TAS Offer template'), true);
		Opportunity opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, ot, TLR_RecordTypeHelper.getId('Opportunity', 'TAS Opportunity'), true);
		Quote q = TST_QuoteTestHelper.CreateDummyQuote(opp.Id, TLR_RecordTypeHelper.getId('Quote', 'TAS New quote'));

		insert q;
		return q;
	}
}