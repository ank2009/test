/**
* @author		Brian Kessler (Brian_Kessler@epam.com)
* @date			2013 June 26
* @description	This class is intended to facilitate creating and populating dummy Contacts for unit testing.
*/
@isTest
public class TST_ContactTestHelper
{
	// Methods for creating one contact -----------------------------------------------------------------------

	/**
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to create dummy contact for testing.
	* @param		Account dummyAccount : Which dummy Account to associate the dummy Contact with.
	* @param		Id recordTypeId : Which Contact Record Type to Create
	* @param		Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
	* @return		Contact
	**/
	public static Contact createDummyContact(Account dummyAccount, Id recordTypeId, Boolean insertNow)
	{
		Integer unique     = (Integer) (Math.random() * 2147483647);
		String  uniqueName = 'Dummy Contact ' + unique;
		
		Contact dummyContact = new Contact();
		dummyContact.RecordTypeId = recordTypeId;
		dummyContact.LastName     = uniqueName;
		dummyContact.Gender__c    = (Math.mod(unique, 2) == 0) ? 'Male' : 'Female';
		dummyContact.Language__c  = 'English';
		dummyContact.Email		  = (uniqueName+'@example.com').remove(' ');
		dummyContact.AccountId    = dummyAccount.id;
		dummyContact.Phone = '+32 123 45678';
		dummyContact.FirstName = 'Jhon';
		
		dummyContact.Salutation = 'Mr.';
		dummyContact.MailingCountry = 'Belguim';
		dummyContact.MailingStreet = 'TSt Steret, 2';
		dummyContact.MailingState = 'Brabant';
        dummyContact.Language__c = 'English';
			
		if (insertNow) { insert dummyContact; }
		return dummyContact;
	}

	/**
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to create dummy contact for testing; won't be inserted into SFDC DB at create time.
	* @param		Account dummyAccount : Which dummy Account to associate the dummy Contact with.
	* @param		Id recordTypeId : Which Contact Record Type to Create
	* @return		Contact
	**/
	public static Contact createDummyContact(Account dummyAccount, Id recordTypeId)
	{
		return createDummyContact(dummyAccount, recordTypeId, false);
	}


	// Methods for creating multiple contacts -----------------------------------------------------------------------

	/**
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to create dummy contact list for testing.
	* @param		Integer numberOfContacts : How many contacts to create
	* @param		Id recordTypeId : Which Contact Record Type to Create
	* @param		Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
	* @return		List<Contact>
	**/
	public static List<Contact> createDummyContactList(
							Account dummyAccount, Integer numberOfContacts, Id recordTypeId, Boolean insertNow
		)
	{
		List<Contact> dummyContactList = new List<Contact>();
		for (Integer i=1; i<=numberOfContacts; i++)
		{
			dummyContactList.add(createDummyContact(dummyAccount, recordTypeId));
		}
		if (insertNow) { insert dummyContactList; }
		return dummyContactList;
	}

	/**
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 June 26
	* @description	Method to create dummy contact list for testing; won't be inserted into SFDC DB at create time.
	* @param		Integer numberOfContacts : How many contacts to create
	* @param		Id recordTypeId : Which Contact Record Type to Create
	* @return		List<Contact>
	**/
	public static List<Contact> createDummyContactList(Account dummyAccount, Integer numberOfContacts, Id recordTypeId)
	{
		return createDummyContactList(dummyAccount, numberOfContacts, recordTypeId, false);
	}
}