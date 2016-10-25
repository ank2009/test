/**
* @author		Anton Solovyev (anton_soloveyv@epam.com)
* @date			2013 September 18
* @description	Create quote object to test.
*/
@isTest
public class TST_QuoteTestHelper
{
	public static Quote CreateDummyQuote(Id opptyId, Id RecordTypeId, Boolean insertNow)
	{
		Integer unique     = (Integer) (Math.random() * 2147483647);
		String  uniqueName = 'Dummy Quote ' + unique;

		Quote q = new Quote();
		q.Name = uniqueName;
		q.RecordTypeId = RecordTypeId;
		q.OpportunityId = opptyId;

		if(insertNow)
			insert q;
		return q;
	} //CreateDummyQuote

	public static Quote CreateDummyQuote(Id opptyId, Id RecordTypeId)
	{
		return CreateDummyQuote(opptyId, RecordTypeId, false);
	} //CreateDummyQuote

	public static Quote_Package_And_Fee__c CreateDummyQuotePF(Id quoteId, Boolean insertNow)
	{
		Integer unique     = (Integer) (Math.random() * 2147483647);
		String  uniqueName = 'Dummy Quote PackFee ' + unique;

		Quote_Package_And_Fee__c qpf = new Quote_Package_And_Fee__c();
		qpf.Name = uniqueName;
		qpf.Quote__c = quoteId;

		if(insertNow)
			insert qpf;
		return qpf;
	} //CreateDummyQuotePF
}