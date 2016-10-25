/**
* @author       Brian Kessler (Brian_Kessler@epam.com)
* @date         2013 June 26
* @description  This class is intended to facilitate creating and populating dummy Contracts for unit testing.
*/
@isTest
public class TST_ContractTestHelper 
{
    // Methods for creating one Contract -----------------------------------------------------------------------

    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Contract for testing.
    * @param        Opportunity dummyOpportunity : Which dummy Opportunity to associate the dummy Contract with.
    * @param        Id recordTypeId : Which Contract Record Type to Create
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       Contract
    **/
    public static Contract createDummyContract(Opportunity dummyOpportunity, Id recordTypeId, Boolean insertNow)
    {
        Integer unique     = (Integer) (Math.random() * 2147483647);
        String  uniqueName = 'Dummy Contract ' + unique;
         
        Contract dummyContract = new Contract();
                 dummyContract.RecordTypeId = recordTypeId;
                 dummyContract.Name         = dummyOpportunity.Name;
				dummyContract.AccountId = dummyOpportunity.AccountId;
        if (insertNow) { insert dummyContract; }    
        return dummyContract;
    }

    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Contract for testing; won't be inserted into SFDC DB at create time.
    * @param        Opportunity dummyOpportunity : Which dummy Opportunity to associate the dummy Contract with.
    * @param        Id recordTypeId : Which Contract Record Type to Create
    * @return       Contract
    **/
    public static Contract createDummyContract(Opportunity dummyOpportunity, Id recordTypeId) 
    { 
        return createDummyContract(dummyOpportunity, recordTypeId, false); 
    }

    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Contract for testing, including most dependencies; 
    *               won't be inserted into SFDC DB at create time.
    * @param        Account dummyAccount : Which dummy Opportunity to associate the dummy Contract with.
    * @param        Integer numberOfContacts : How many contracts account should have
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       Contract
    **/
    public static Contract createDummyContract (Account dummyAccount, Integer numberOfContacts, Boolean insertNow)
    {
        List<Contact> dummyContactList  = null;
        if (numberOfContacts > 0)
        {
            Id contactRecordTypeId           = TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'); 
                          dummyContactList   = TST_ContactTestHelper.createDummyContactList(dummyAccount, numberOfContacts, contactRecordTypeId, true);
        }            

        Id offerTemplateRecordTypeId         = TLR_RecordTypeHelper.getId('Offer_Template__c', 'TLR Offer Template'); 
        Offer_Template__c dummyOfferTemplate = TST_OfferTemplateTestHelper.createDummyOfferTemplate(offerTemplateRecordTypeId, true);
        
        Id opportunityRecordTypeId           = TLR_RecordTypeHelper.getId('Opportunity', 'TLR Opportunity'); 
        Opportunity dummyOpportunity         = TST_OpportunityTestHelper.createDummyOpportunity(dummyAccount, dummyOfferTemplate, opportunityRecordTypeId, true); 

        Id contractRecordTypeId              = TLR_RecordTypeHelper.getId('Contract', 'TLR Contract'); 
        return createDummyContract(dummyOpportunity, contractRecordTypeId, insertNow);
    }

    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Contract for testing, including most dependencies; 
    *               won't be inserted into SFDC DB at create time.
    * @param        Account dummyAccount : Which dummy Opportunity to associate the dummy Contract with.
    * @param        Integer numberOfContacts : How many contracts account should have
    * @return       Contract
    **/
    public static Contract createDummyContract (Account dummyAccount, Integer numberOfContacts)
    {
        return createDummyContract (dummyAccount, numberOfContacts, false);
    }

    

    // Methods for creating multiple Contracts -----------------------------------------------------------------------
    
    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Contract list for testing.
    * @param        Integer numberOfContracts : How many Contracts to create
    * @param        Id recordTypeId : Which Contract Record Type to Create
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       List<Contract>
    **/
    public static List<Contract> createDummyContractList(
                            Opportunity dummyOpportunity, Integer numberOfContracts, Id recordTypeId, Boolean insertNow
        )
    {
        List<Contract> dummyContractList = new List<Contract>();
        for (Integer i=1; i<=numberOfContracts; i++)
        {
            dummyContractList.add(createDummyContract(dummyOpportunity, recordTypeId));         
        }
        if (insertNow) { insert dummyContractList; }    
        return dummyContractList;
    }
    
    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Contract list for testing; won't be inserted into SFDC DB at create time.
    * @param        Integer numberOfContracts : How many Contracts to create
    * @param        Id recordTypeId : Which Contract Record Type to Create
    * @return       List<Contract>
    **/
    public static List<Contract> createDummyContractList(Opportunity dummyOpportunity, Integer numberOfContracts, Id recordTypeId) 
    { 
        return createDummyContractList(dummyOpportunity, numberOfContracts, recordTypeId, false); 
    }
    
    	// Assign Lookups for Contacts and Users ------------------------------------------------------------------------------

	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 July 04
	* @description	Method to assign contacts to the contract
	* @param		Contract dummyContract  : Contract to modify and return	
	* @param		Contact contractContact : Who is responsibile for negotiating the Contract (?)
	* @param		Contact primaryContact : Who is responsible for the Account (?)
	* @param		Contact signingContact : Who is responsible for signing the Contract (?)
	* @param		Contact billingContact : Who is responsible for paying for the Contract
	* @param		Contact siteContact	   : Who is responsible for the site (?)
	* @return		Contract
	**/
	public static Contract assignContacts (
											Contract dummyContract, Contact contractContact, 
											Contact primaryContact, Contact signingContact,
											Contact billingContact, Contact siteContact 
					) 
	{
		dummyContract.Contract_Contact__c	= contractContact.id;
		dummyContract.Primary_Contact__c 	= primaryContact.id;
		dummyContract.CustomerSignedId		= signingContact.id;
		dummyContract.Billing_Contact__c 	= billingContact.id;
		dummyContract.Site_Contact__c		= siteContact.id;

		return dummyContract;
	}

	private static Integer chooseContact (Integer listSize, Integer ordinal)
	{
		return (listSize >= ordinal) ? (ordinal - 1) : (listSize - 1);
	}

	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 July 04
	* @description	Method to assign contacts to the contract
	* @param		Contract dummyContract : Contract to modify and return	
	* @param		List<Contact> dummyContactList : List of contacts to be distributed through contract contact lookup fields
	* @return		Contract
	**/
	public static Contract assignContacts (Contract dummyContract, List<Contact> dummyContactList) 
	{
		return assignContacts (	
									dummyContract,
									dummyContactList[0],
									dummyContactList[chooseContact(dummyContactList.size(), 2)],
									dummyContactList[chooseContact(dummyContactList.size(), 3)],
									dummyContactList[chooseContact(dummyContactList.size(), 4)],
									dummyContactList[chooseContact(dummyContactList.size(), 5)]
								);
								
	}
	
	/**	
	* @author		Brian Kessler (Brian_Kessler@epam.com)
	* @date			2013 July 04
	* @description	Method to assign the signing user to the Contract
	* @param		Contract dummyContract : Contract to modify and return	
	* @param		User dummyUser  : User to assign as the "Signing User"
	* @return		Contract
	**/
	public static Contract assignSigningUser (Contract dummyContract, User dummyUser) 
	{
		dummyContract.Teleroute_Signing_User__c = dummyUser.id;
		return dummyContract;
	}
}