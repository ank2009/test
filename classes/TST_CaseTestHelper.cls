/**
* @author		Anton Solovyev (anton_soloveyv@epam.com)
* @date			2013 June 27
* @description	Test class for TLRCaseExt controller extension. 
*/
@isTest
public with sharing class TST_CaseTestHelper
{
	/**	
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 June 27
	* @description	Method to create dummy Case for testing.
	* @param		Id recordTypeId : Which Account Record Type to Create
	* @param		Id contactId : Which Contact Use to Create
	* @param		Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
	* @return		Account
	**/
	public static Case createDummyCase(Id recordTypeId, Id contactId, Boolean insertNow)
	{
		Case dummyCase = new Case();
		
		dummyCase.ContactId = contactId;
		dummyCase.Subject = 'Case Subject';
		dummyCase.RecordTypeId = recordTypeId;
		
		if (insertNow)
			insert dummyCase;	
		return dummyCase;
	}
	
	public static Case createDummyCase(Id recordTypeId, Boolean insertNow)
	{
		Case dummyCase = new Case();
		
		dummyCase.Subject = 'Case Subject';
		dummyCase.RecordTypeId = recordTypeId;
		
		if (insertNow) 
			insert dummyCase;	
		return dummyCase;
	}
}