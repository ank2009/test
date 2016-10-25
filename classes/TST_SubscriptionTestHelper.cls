/**
* @author       Brian Kessler (Brian_Kessler@epam.com)
* @date         2013 June 26
* @description  This class is intended to facilitate creating and populating dummy Subscriptions for unit testing.
**/
@isTest
public with sharing class TST_SubscriptionTestHelper
{
    // Methods for creating one Subscription -----------------------------------------------------------------------

    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Subscription for testing.
    * @param        Contract dummyContract  :   The dummy Contract to use for this Subscription
    * @param        Opportunity dummyOpportunity    :   The dummy Opportunity to use for this Subscription
    * @param        Contract dummyContract : Which Contract to associate the subscription with.
    * @param        Id recordTypeId : Which Subscription Record Type to Create.
    * @return       Subscription
    **/
    public static Subscription__c createDummySubscription(Contract dummyContract, Opportunity dummyOpportunity, Id recordTypeId, Boolean insertNow)
    {
        Integer unique     = (Integer) (Math.random() * 2147483647);
        String  uniqueName = 'Dummy Subscription ' + unique;
         
        Subscription__c dummySubscription = new Subscription__c();
                        dummySubscription.RecordTypeId                      = recordTypeId;
                        dummySubscription.Name                              = 'Subscription - ' + dummyOpportunity.Name;
                        dummySubscription.Contract__c                       = dummyContract.id;
                        dummySubscription.Opportunity__c                    = dummyOpportunity.id;
                        dummySubscription.Offer_Template__c                 = dummyOpportunity.Offer_Template__c;
                        dummySubscription.Access_Kind__c                    = dummyOpportunity.Offer_Template__r.Access_Kind__c;
                        dummySubscription.Product__c                        = dummyOpportunity.Offer_Template__r.Base_Product__c;
                        dummySubscription.Start_Date__c                     = Date.today();
                        dummySubscription.Start_Usage_Payment__c            = dummyOpportunity.Start_Usage_Payment_Date__c;
                        dummySubscription.Status__c                         = 'Sent';
                        dummySubscription.CUG_allowed__c                    = dummyOpportunity.CUG_allowed__c;
                        dummySubscription.Maximum_Subscription_Amount__c    = dummyOpportunity.Maximum_Invoice_Amount__c;
                        dummySubscription.CurrencyISOCode                   = dummyOpportunity.CurrencyISOCode;
                        dummySubscription.Account__c                        = dummyOpportunity.AccountId;
                
        if (insertNow) { insert dummySubscription; }    
        return dummySubscription;
    }

    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Subscription for testing; won't be inserted into SFDC DB at create time.
    * @param        Contract dummyContract  :   The dummy Contract to use for this Subscription
    * @param        Opportunity dummyOpportunity    :   The dummy Opportunity to use for this Subscription
    * @param        Id recordTypeId : Which Subscription Record Type to Create
    * @return       Subscription
    **/
    public static Subscription__c createDummySubscription(Contract dummyContract, Opportunity dummyOpportunity, Id recordTypeId)
    { 
        return createDummySubscription(dummyContract, dummyOpportunity, recordTypeId, false); 
    }
    

    // Methods for creating multiple Subscriptions -----------------------------------------------------------------------
    
    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Subscription list for testing.
    * @param        Contract dummyContract  :   The dummy Contract to use for this Subscription
    * @param        Opportunity dummyOpportunity    :   The dummy Opportunity to use for this Subscription
    * @param        Id recordTypeId : Which Subscription Record Type to Create
    * @param        Integer numberOfSubscriptions : How many Subscriptions to create
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       List<Subscription>
    **/
    public static List<Subscription__c> createDummySubscriptionList(Contract dummyContract, Opportunity dummyOpportunity, Id recordTypeId, Integer numberOfSubscriptions, Boolean insertNow)
    {
        List<Subscription__c> dummySubscriptionList = new List<Subscription__c>();
        for (Integer i=1; i<=numberOfSubscriptions; i++)
        {
            dummySubscriptionList.add(createDummySubscription(dummyContract, dummyOpportunity, recordTypeId));          
        }
        if (insertNow) { insert dummySubscriptionList; }    
        return dummySubscriptionList;
    }
    
    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy Subscription list for testing; won't be inserted into SFDC DB at create time.
    * @param        Contract dummyContract  :   The dummy Contract to use for this Subscription
    * @param        Opportunity dummyOpportunity    :   The dummy Opportunity to use for this Subscription
    * @param        Id recordTypeId : Which Subscription Record Type to Create
    * @param        Integer numberOfSubscriptions : How many Subscriptions to create
    * @return       List<Subscription>
    **/
    public static List<Subscription__c> createDummySubscriptionList(Contract dummyContract, Opportunity dummyOpportunity, Id recordTypeId, Integer numberOfSubscriptions) 
    { 
        return createDummySubscriptionList(dummyContract, dummyOpportunity, recordTypeId, numberOfSubscriptions, false); 
    }
    
    // Methods for creating one SubscriptionFxUser -----------------------------------------------------------------------

    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy SubscriptionFxUser for testing.
    * @param        Subscription__c dummySubscription : Which dummy Subscription to associate the dummy SubscriptionFxUser with.
    * @param        Contact dummyContact : Which dummy Contact to associate the dummy SubscriptionFxUser with.
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       SubscriptionFxUser
    **/
    public static Subscription_User__c createDummySubscriptionFxUser(Subscription__c dummySubscription, Contact dummyContact, Boolean insertNow)
    {
        Integer unique     = (Integer) (Math.random() * 2147483647);
        String  uniqueName = 'Dummy SubscriptionFxUser ' + unique;
         
        Subscription_User__c dummySubscriptionFxUser = new Subscription_User__c();
                          dummySubscriptionFxUser.Subscription__c          = dummySubscription.id;
                          dummySubscriptionFxUser.Contact__c               = dummyContact.id;


        if (insertNow) { insert dummySubscriptionFxUser; }  

        return dummySubscriptionFxUser;
    }

    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy SubscriptionFxUser for testing; won't be inserted into SFDC DB at create time.
    * @param        Subscription__c dummySubscription : Which dummy Subscription to associate the dummy SubscriptionFxUser with.
    * @param        Contact dummyContact : Which dummy Contact to associate the dummy SubscriptionFxUser with.
    * @return       SubscriptionFxUser
    **/
    public static Subscription_User__c createDummySubscriptionFxUser(Subscription__c dummySubscription, Contact dummyContact)
    { 
        return createDummySubscriptionFxUser(dummySubscription, dummyContact, false); 
    }
    

    // Methods for creating multiple SubscriptionFxUsers -----------------------------------------------------------------------
    
    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy SubscriptionFxUser list for testing.
    * @param        Subscription__c dummySubscription : Which dummy Subscription to associate the dummy SubscriptionFxUser with.
    * @param        List<Contact> dummyContactList : Which dummy Contacts to associate the dummy SubscriptionFxUser in the returned list with.
    * @param        Integer numberOfSubscriptionFxUsers : How many SubscriptionFxUsers to create.
    *               This should be less-than or equal-to the dummyContactList.size();
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       List<SubscriptionFxUser>
    **/
    public static List<Subscription_User__c> createDummySubscriptionFxUserList(Subscription__c dummySubscription, List<Contact> dummyContactList, Integer numberOfSubscriptionFxUsers, Boolean insertNow)
    {
        List<Subscription_User__c> dummySubscriptionFxUserList = new List<Subscription_User__c>();
        for (Integer i=1; i<=numberOfSubscriptionFxUsers; i++)
        {
            dummySubscriptionFxUserList.add(createDummySubscriptionFxUser(dummySubscription, dummyContactList[i-1]));           
        }
        if (insertNow) { insert dummySubscriptionFxUserList; }  
        return dummySubscriptionFxUserList;
    }
    
    /** 
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 June 26
    * @description  Method to create dummy SubscriptionFxUser list for testing; won't be inserted into SFDC DB at create time.
    * @param        Subscription__c dummySubscription : Which dummy Subscription to associate the dummy SubscriptionFxUser with.
    * @param        List<Contact> dummyContactList : Which dummy Contacts to associate the dummy SubscriptionFxUser in the returned list with.
    * @param        Integer numberOfSubscriptionFxUsers : How many SubscriptionFxUsers to create.
    *               This should be less-than or equal-to the dummyContactList.size();
    * @return       List<SubscriptionFxUser>
    **/
    public static List<Subscription_User__c> createDummySubscriptionFxUserList(Subscription__c dummySubscription, List<Contact> dummyContactList, Integer numberOfSubscriptionFxUsers)
    { 
        return createDummySubscriptionFxUserList(dummySubscription, dummyContactList, numberOfSubscriptionFxUsers, false); 
    }
    
        /**
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2014 December 18
    * @description  Method to creation Packages and Fee and Offer Line Items to Offer Tempalate
    **/
    public static void AddPackagesAndLineItems(Subscription__c sub)
    {
        Service__c ser = new  Service__c();
        ser.Name = 'TestServ';
        ser.Status__c = 'Pending';
        ser.Billable_Service__c = true;
        ser.Start_Date__c = Date.Today();
        insert ser;
        Subservice__c subSer = new Subservice__c();
        subSer.Start_Date__c = Date.Today();
        subSer.Status__c = 'Pending';
        subSer.Attribute__c ='asdas';
        subSer.Name = 'Name';
        subSer.Parent_Service__c = ser.Id;
        insert subSer;
        Subservice_Template__c subServTemp = new Subservice_Template__c();
        subServTemp.Name ='asds';
        subServTemp.Parent_Service__c = ser.Id;
        subServTemp.Start_Date__c = Date.Today(); 
        insert subServTemp;
        Subservice_Template_Line_Item__c subServLI = new Subservice_Template_Line_Item__c();
        subServLI.Template__c = subServTemp.Id;
        subServLI.Subservice__c = subSer.Id;
        insert subServLI;
        subSer.Status__c = 'Active';
        update subSer;
        ser.Status__c = 'Active';
        update ser; 
        
        Subscription_Line_Item__c subLineItem = new Subscription_Line_Item__c();
        subLineItem.Name = 'TestSubLineItem';
        subLineItem.Service__c = ser.Id;
        subLineItem.Subscription__c = sub.Id;
        insert subLineItem ;
        
        Subs_Item_Subservice__c subItSub= new Subs_Item_Subservice__c();
        subItSub.Name = 'TestOfferItemSubservice';
        subItSub.Sales_Price__c = 1.0;
        subItSub.Billing_Base__c = 'Unit';
        subItSub.Subscription_Line_Item__c = subLineItem .Id;
        subItSub.Applied_To__c = 'Subscription';
        insert subItSub;
        
        PackFee__c pack = new PackFee__c();
        pack.Name = 'TestPack';
        pack.Type__c = 'Fee';
        pack.Level__c = 'Subscription';
        pack.Status__c = 'Pending';
        pack.CurrencyIsoCode = 'EUR';
        pack.Frequency__c = 'Monthly';
        pack.Start_Date__c = Date.Today();
        insert pack;
        pack.Status__c = 'Active';
        update pack;
        
        Opportunity_Line_Item__c oppLi = new Opportunity_Line_Item__c();
        
        Subs_Package_And_Fee__c offPack = new Subs_Package_And_Fee__c();
        offPack.Package_and_Fee__c = pack.Id;
        offPack.Subscription__c= sub.Id;
        insert offPack;
    }
}