/**
* @author       Brian Kessler (Brian_Kessler@epam.com)
* @date         2013 June 26
* @description  This class is intended to facilitate creating and populating dummy Opportunitys for unit testing.
**/
@isTest
public class TST_OpportunityTestHelper 
{
    // Methods for creating one Opportunity -----------------------------------------------------------------------

    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Opportunity for testing.
    * @param        Account dummyAccount : Which dummy Account to associate the dummy Opportunity with.
    * @param        Id recordTypeId : Which Opportunity Record Type to Create
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       Opportunity
    **/
    public static Opportunity createDummyOpportunity(Account dummyAccount, Offer_Template__c dummyOfferTemplate, Id recordTypeId, Boolean insertNow)
    {
        Integer unique     = (Integer) (Math.random() * 2147483647);
        String  uniqueName = 'Dummy Opportunity ' + unique;
         
        Opportunity dummyOpportunity = new Opportunity();
                dummyOpportunity.RecordTypeId                 = recordTypeId;
                dummyOpportunity.Name                         = uniqueName;
                dummyOpportunity.Type                         = 'Acquisition';
                dummyOpportunity.StageName                    = 'New not worked';
                dummyOpportunity.CloseDate                    = Date.today();
                dummyOpportunity.AccountId                    = dummyAccount.id;
                dummyOpportunity.Maximum_Invoice_Amount__c    = (Math.random() * 999999);
                dummyOpportunity.Start_Usage_Payment_Date__c  = Date.today();
                dummyOpportunity.Offer_Template__c            = dummyOfferTemplate.id;
                dummyOpportunity.CUG_allowed__c               = true;
                dummyOpportunity.CurrencyIsoCode              = 'EUR';

        if (insertNow) { insert dummyOpportunity; } 
        return dummyOpportunity;
    }
    
    
    public static Opportunity createDummyOpportunity(Account dummyAccount, Id recordTypeId, Boolean insertNow)
    {
        Integer unique     = (Integer) (Math.random() * 2147483647);
        String  uniqueName = 'Dummy Opportunity ' + unique;
         
        Opportunity dummyOpportunity = new Opportunity();
                dummyOpportunity.RecordTypeId                 = recordTypeId;
                dummyOpportunity.Name                         = uniqueName;
                dummyOpportunity.Type                         = 'Acquisition';
                dummyOpportunity.StageName                    = 'New not worked';
                dummyOpportunity.CloseDate                    = Date.today();
                dummyOpportunity.AccountId                    = dummyAccount.id;
                dummyOpportunity.Maximum_Invoice_Amount__c    = (Math.random() * 999999);
                dummyOpportunity.Start_Usage_Payment_Date__c  = Date.today();
                dummyOpportunity.CUG_allowed__c               = true;
                dummyOpportunity.CurrencyIsoCode              = 'EUR';

        if (insertNow) { insert dummyOpportunity; } 
        return dummyOpportunity;
    }

    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Opportunity for testing; won't be inserted into SFDC DB at create time.
    * @param        Account dummyAccount : Which dummy Account to associate the dummy Opportunity with.
    * @param        Id recordTypeId : Which Opportunity Record Type to Create
    * @return       Opportunity
    **/
    public static Opportunity createDummyOpportunity(Account dummyAccount, Offer_Template__c dummyOfferTemplate, Id recordTypeId) 
    { 
        return createDummyOpportunity(dummyAccount, dummyOfferTemplate,  recordTypeId, false); 
    }
    
    public static Opportunity createDummyOpportunity(Account dummyAccount, Id recordTypeId) 
    { 
        return createDummyOpportunity(dummyAccount, recordTypeId, false); 
    }

    // Methods for creating multiple Opportunitys -----------------------------------------------------------------------
    
    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Opportunity list for testing.
    * @param        Integer numberOfOpportunitys : How many Opportunitys to create
    * @param        Id recordTypeId : Which Opportunity Record Type to Create
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       List<Opportunity>
    **/
    public static List<Opportunity> createDummyOpportunityList(
                            Account dummyAccount, Offer_Template__c dummyOfferTemplate, Integer numberOfOpportunitys, Id recordTypeId, Boolean insertNow
        )
    {
        List<Opportunity> dummyOpportunityList = new List<Opportunity>();
        for (Integer i=1; i<=numberOfOpportunitys; i++)
        {
            dummyOpportunityList.add(createDummyOpportunity(dummyAccount, dummyOfferTemplate, recordTypeId));           
        }
        if (insertNow) { insert dummyOpportunityList; } 
        return dummyOpportunityList;
    }
    
    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Opportunity list for testing; won't be inserted into SFDC DB at create time.
    * @param        Integer numberOfOpportunitys : How many Opportunitys to create
    * @param        Id recordTypeId : Which Opportunity Record Type to Create
    * @return       List<Opportunity>
    **/
    public static List<Opportunity> createDummyOpportunityList(Account dummyAccount, Offer_Template__c dummyOfferTemplate, Integer numberOfOpportunitys, Id recordTypeId) 
    { 
        return createDummyOpportunityList(dummyAccount, dummyOfferTemplate, numberOfOpportunitys, recordTypeId, false); 
    }
}