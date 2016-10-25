/**	
* @author		HCL, Anton Solovyev (anton_soloveyv@epam.com)
* @date			2014 Feb 28
* @description	Controller for TLR_EmailLookup page.
**/
public with sharing class TLR_EmailLookup
{
	public string objectToSearch { get; set; }
	public String searchText { get; set; }
	public List<ContactInfo> contactInformationList { get; set; }
	public String selectedRecordIds {get;set;}
	
	public TLR_EmailLookup()
	{
		contactInformationList = new list<ContactInfo>();
		objectToSearch = 'User';
		searchContacts();
	} 
	
	/**	
	* @author		HCL, Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2014 Feb 28
	* @description	performs search using gicen criterias
	**/
	public PageReference searchContacts()
	{
		try
		{
			contactInformationList.clear();
			
			System.debug('----------------- TLR_EmailLookup: searchContacts: objectToSearch : ' + objectToSearch);
			
			if(objectToSearch.equals('User'))
				contactInformationList = queryUsers(searchText);
			if(objectToSearch.equals('Account'))
				contactInformationList = queryAccounts(searchText);
			if(objectToSearch.equals('Contact'))
				contactInformationList = queryContacts(searchText);
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'An unexpected error has occurred. Please contact your System Admin'));
			System.debug('----------------- TLR_EmailLookup: searchContacts: Exception : ' + ex.getMessage());
		}
		return null;
	} //searchContacts
	
	/**	
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2014 Feb 28
	* @description	returns wrapper list for Users
	**/
	public List<ContactInfo> queryUsers(string searchPattern)
	{
		List<ContactInfo> retVal = new List<ContactInfo>();
		
		string query = 'SELECT Id, Name, Email FROM User WHERE isActive = true ';
		if(!string.isEmpty(searchPattern))
			query += 'AND ( Name like \'' + searchPattern + '%\')';
		query += 'ORDER BY Name LIMIT 200';
		
		System.debug('----------------- TLR_EmailLookup: queryUsers: query : ' + query);
		
		for(User u : Database.query(query))
		{
			retVal.add(new ContactInfo(u.Id, u.Name, u.Email, false));
		} // for each user
		return retVal;
	} //queryUsers
	
	/**	
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2014 Feb 28
	* @description	returns wrapper list for Accounts
	**/
	public List<ContactInfo> queryAccounts(string searchPattern)
	{
		List<ContactInfo> retVal = new List<ContactInfo>();
		
		string query = 'SELECT Id, Name, Email__c FROM Account  ';
		if(!string.isEmpty(searchPattern))
			query += 'WHERE ( Name like \'' + searchPattern + '%\')';
		query += 'ORDER BY Name LIMIT 200';
		
		System.debug('----------------- TLR_EmailLookup: queryAccounts: query : ' + query);
		
		for(Account a : Database.query(query))
		{
			retVal.add(new ContactInfo(a.Id, a.Name, a.Email__c, false));
		} // for each user
		return retVal;
	} //queryAccounts
	
	/**	
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2014 Feb 28
	* @description	returns wrapper list for Accounts
	**/
	public List<ContactInfo> queryContacts(string searchPattern)
	{
		List<ContactInfo> retVal = new List<ContactInfo>();
		
		string query = 'SELECT Id, Name, Email FROM Contact ';
		if(!string.isEmpty(searchPattern))
			query += 'WHERE ( Name like \'' + searchPattern + '%\')';
		query += 'ORDER BY Name LIMIT 200';
		
		System.debug('----------------- TLR_EmailLookup: queryContacts: query : ' + query);
		
		for(Contact c : Database.query(query))
		{
			retVal.add(new ContactInfo(c.Id, c.Name, c.Email, false));
		} // for each user
		return retVal;
	} //queryContacts
	
	/**	
	* @author		HCL, Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2014 Feb 28
	* @description	wrapper class to display information on page
	**/
	public class ContactInfo
	{
		public Boolean isSelected { get; set; }
		public Boolean isDisabled { get { return string.isEmpty(emailAddress); } }
		
		public Id objectId { get; set; }
		public string displayName { get; set; }
		public string emailAddress { get; set; }
		
		public ContactInfo(Id objId, string name, string email, Boolean selected)
		{
			objectId = objId;
			displayName = name;
			emailAddress = email;
			isSelected = selected;
		}
	} //ContactInfo class
}