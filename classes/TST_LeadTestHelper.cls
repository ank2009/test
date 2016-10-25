@isTest
public class TST_LeadTestHelper
{
    public static Lead createLead(boolean insertNow)
	{
        return createLead(null, insertNow);
    }
    
	public static Lead createLead(Id RecordTypeId, boolean insertNow)
	{
		Integer unique     = (Integer) (Math.random() * 2147483647);
		String  uniqueName = 'TST Lead ' + unique;
		
		Lead dummyLead = new Lead();
		dummyLead.RecordTypeId = recordTypeId != null ? recordTypeId : TLR_RecordTypeHelper.getId('Lead', 'TLR Lead');
		dummyLead.Company      = 'TST Company ' + unique;
		dummyLead.LastName     = uniqueName;
		dummyLead.Gender__c    = (Math.mod(unique, 2) == 0) ? 'Male' : 'Female';
		dummyLead.Language__c  = 'English';
		dummyLead.Email		  = (uniqueName+'@example.com').remove(' ');
		dummyLead.LeadSource = 'Events';
		dummyLead.Country = 'Belgium';
		dummyLead.Phone = '+32 2 1234567';
		dummyLead.FirstName = 'Jhon';
        dummyLead.Country            = 'France';
        dummyLead.State              = 'tst shipping state';
        dummyLead.City               = 'shpCity';
        dummyLead.Street             = 'shpStreet 13';
        dummyLead.PostalCode         = '1930';
        dummyLead.Phone                      = '+32 025551212';
        dummyLead.Fax                        = '+32 025551313';
        dummyLead.NumberOfEmployees = 543235;
        
			
		if (insertNow) { insert dummyLead; }
		return dummyLead;
	}
	
    public static List<Lead> createLeadList(Id RecordTypeId, integer leadCount, boolean insertNow)
	{
		List<Lead> retVal = new List<Lead>();
		for (Integer i=1; i<=leadCount; i++)
		{
			retVal.add(createLead(RecordTypeId, false));
		}
		if (insertNow) { insert retVal; }
		return retVal;
	}
    
	public static List<Lead> createLeadList(integer leadCount, boolean insertNow)
	{
		List<Lead> retVal = new List<Lead>();
		for (Integer i=1; i<=leadCount; i++)
		{
			retVal.add(createLead(false));
		}
		if (insertNow) { insert retVal; }
		return retVal;
	}
}