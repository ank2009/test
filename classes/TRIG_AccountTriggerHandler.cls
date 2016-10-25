/**
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2013 November 14
* @description  Trigger handler for Account events
**/
public without sharing class TRIG_AccountTriggerHandler extends TRIG_TriggerHandlerAbstract
{
    public boolean IsTriggerContext { get { return isTriggerExecuting;} }
    
    private class CountryValidationException extends Generic.SObjectValidationException 
    {
    	public CountryValidationException(string message, SObject obj)
    	{
    		super(message, obj);
    	}
    }
    private class TimeZoneValidationException extends Generic.SObjectValidationException 
	{
    	public TimeZoneValidationException(string message, SObject obj)
    	{
    		super(message, obj);
    	}
    }
    
    public TRIG_AccountTriggerHandler (boolean isTriggerExecuting) 
    {
        super(isTriggerExecuting);
    }
    
    public override void OnBeforeInsert(List<sObject> newTriggerValues) 
    {
    	try
    	{
    		FillShippingAddress(newTriggerValues);
        	FillSegmentationDates(newTriggerValues, null);
        	FillTlrNumber(newTriggerValues);
        	FillOrganization(newTriggerValues);
        	CreateSepaMandateID(newTriggerValues, null);
        	SetTimeZone(newTriggerValues);
        	ValidatePhones(newTriggerValues); 
        	ProcessClonnedAccounts(newTriggerValues);
        	FillISO2Code(newTriggerValues);
    	}
    	catch(CountryValidationException ex)
    	{
    		((Account)ex.wrongObject).ShippingCountry.addError(ex.getMessage());
    	}
    	catch(TimeZoneValidationException ex)
    	{
    		((Account)ex.wrongObject).Time_Zone__c.addError(ex.getMessage());
    	}
    	
    	
    }
    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
    {
    	GenerateAccountNumber(newTriggerValues, true);
    } 
    
    public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap) 
    {
    	try
    	{
	        FillSegmentationDates(newTriggerValues, oldTriggerValuesMap);
	        FillTlrNumber(newTriggerValues);
	        FillOrganization(newTriggerValues);
	        CreateSepaMandateID(newTriggerValues, oldTriggerValues);
	        GenerateAccountNumber(newTriggerValues, false);
	        ValidatePhones(newTriggerValues);
	        FillISO2Code(newTriggerValues);
            SetTFXAgreedMigrationEvolutionDate(newTriggerValues, oldTriggerValuesMap);
        }
    	catch(CountryValidationException ex)
    	{
    		((Account)ex.wrongObject).ShippingCountry.addError(ex.getMessage());
    	}
    	catch(TimeZoneValidationException ex)
    	{
    		((Account)ex.wrongObject).Time_Zone__c.addError(ex.getMessage());
    	}
    	
        // Below code is written for CR #WKTS CRM-3/2 
        // We will put all the business logic in helper class, for now we will keep in trigger itself 
        /* Description : Followin code prompt to complete any missing Consolidation level of subscription package/fee 
                        must always be less than or equal the invoice level of parent contract. 
        * Date        : 28-10-2012 
        *
        */
        // 1 getRecordTypeId call, 1 SOQL query
        //AccounLevelValidationProxy(newTriggerValues, oldTriggerValuesMap);
        
        //topParentAccountNumber(newAccounts,oldAccountMap); DO WE REALLY NED IT?
        //tmsProviderValidator(newAccounts); MOVED TO VALIDATION RULES
    }
    
    public override void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap) 
    {
        TLR_EventAndTaskHelper.UpdateTaskOrEventSubjectFromLeadOrAccount(oldTriggerValues, newTriggerValues, oldTriggerValuesMap);
        // 3+ SOQL queries per each account in list, depends on hierarchy and its position in it
        UpdateKeyAccountHierarchy(newTriggerValues, oldTriggerValuesMap);
        // 3 SOQL query + future methods call
        UpdateAccountProvisioningMessage(newTriggerValues, oldTriggerValuesMap);
        // 1 DML insert call
        UpdateAccountCertificationLevel(newTriggerValues, oldTriggerValuesMap);
        Esb_UpdateAccounts(newTriggerValues, oldTriggerValues);
    }
    
    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    public override void OnAfterDelete  (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}

    public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    
    //====================================================================================================
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2014 November 18
    * @description  Fill billing address (if empty) from shipping (if exists)
    				this happens when lead is converting to an account, because lead address mapped to billing address
    **/
    private void FillShippingAddress(List<Account> newValues)
    {
    	for(Account a : newValues)
        {
        	// if shipping address is set - we will not process this account
        	if( string.isNotEmpty(a.ShippingCountry) ||
        		string.isNotEmpty(a.ShippingCity) ||
        		string.isNotEmpty(a.ShippingState) ||
        		string.isNotEmpty(a.ShippingStreet) ||
        		string.isNotEmpty(a.ShippingPostalCode))
	    		continue;
	    	
	    	// if billing address is set - we will copy shipping to billing address
	    	if( string.isNotEmpty(a.BillingCountry) ||
        		string.isNotEmpty(a.BillingCity) ||
        		string.isNotEmpty(a.BillingState) ||
        		string.isNotEmpty(a.BillingStreet) ||
        		string.isNotEmpty(a.BillingPostalCode))
        	{
        		a.ShippingCountry = a.BillingCountry;
        		a.ShippingCity = a.BillingCity;
        		a.ShippingState = a.BillingState;
        		a.ShippingStreet = a.BillingStreet;
        		a.ShippingPostalCode = a.BillingPostalCode;
        	}
        	
        	if(string.isEmpty(a.ShippingCountry))
        		throw new CountryValidationException('Country not filled, cannot create an account',a);
        }
    } //FillBillingAddress
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 November 22
    * @description  Fill ABC and SML segmentation dates
    **/
    private void FillSegmentationDates(List<sObject> newValues, Map<Id, sObject> oldValues)
    {
        for(sObject obj : newValues)
        {
            Account acc = (Account)obj;
            if(oldValues == null)
            {
                acc.ABC_Segmentation_Date__c = date.today();
                acc.SML_Segmentation_Date__c = date.today();
            } // if account is inserting
            else
            {
                Account oldAccount = (Account)oldValues.get(acc.Id);
                // Update ABC Segmentation Date
                if(oldAccount.ABC_Segmentation__c != acc.ABC_Segmentation__c)
                {
                    acc.ABC_Segmentation_Date__c = date.today();
                }
                // Update SML Segmentation Date
                if(oldAccount.SML_Segmentation_Calculated__c != acc.SML_Segmentation_Calculated__c)
                {
                    acc.SML_Segmentation_Date__c = date.today();
                }
                // Update Account Life Cycle
                if(acc.Account_Life_Cycle__c != oldAccount.Account_Life_Cycle__c 
                    && acc.Account_Life_Cycle__c == 'New Customer'
                    && (acc.Level_of_Certification__c == null || Integer.valueOf(acc.Level_of_Certification__c) < 2) 
                    )
                {
                    acc.Level_of_Certification__c = '2';
                }
            } // if account is updating
        } // for accounts
    } // FillSegmentationDates
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 November 22
    * @description  Fill AccountNumber, TLR_Account_Number__c, Teleroute_Number__c
    *               4 CustomSetting.getAll calls + 2 DML update calls
    **/
    private void FillTlrNumber(List<sObject> newValues)
    {
        Map<String,Integer> countTelNum = new Map<String,Integer>();
        Map<String, Mapping_Organization_Country__c> existingShippingCountryMapping = Mapping_Organization_Country__c.getAll();
        for(sObject obj : newValues)
        {
            Account acc = (Account)obj;
             if (string.isEmpty(acc.ShippingCountry))
                 throw new CountryValidationException('The Shipping Country is Mandatory',acc);
            else if (string.isEmpty(acc.Organization_Country__c))
                acc.Organization_Country__c = acc.ShippingCountry;
                
            
            if(string.isEmpty(acc.Teleroute_Name__c))
                acc.Teleroute_Name__c = acc.Name;
            
            // this is very stupid in fact, because we have only one value for this settings. But this is how it was.
            string trlTelerouteNumberingKey = 'TR_Teleroute_Numbering';
            if(existingShippingCountryMapping.get(acc.Organization_Country__c) != null)
            	trlTelerouteNumberingKey = existingShippingCountryMapping.get(acc.Organization_Country__c).Teleroute_Numbering_Key__c;
            
            system.debug('---------- TRIG_AccountTriggerHandler: FillTlrNumber: acc: ' + acc);
            system.debug('---------- TRIG_AccountTriggerHandler: FillTlrNumber: existingShippingCountryMapping: ' + existingShippingCountryMapping);
            if (string.isEmpty(acc.Teleroute_Number__c))
            {
                String telAccNum = existingShippingCountryMapping.get(acc.Organization_Country__c).Teleroute_Numbering_Key__c;
                if(countTelNum.containsKey(telAccNum))
                {
                    countTelNum.put(telAccNum, countTelNum.get(telAccNum)+1);
                }
                else
                {
                    countTelNum.put(telAccNum, 1);
                }
            }
        }
        Map<String, Integer> telerouteNumberMap = new Map<String, Integer>();
        if(countTelNum.size() > 0)
        {
            telerouteNumberMap = TLR_CustomSettingsHelper.GetTelerouteNumber(countTelNum);
        }
        for(sObject obj : newValues)
        {
            Account acc = (Account)obj;
            // this is very stupid in fact, because we have only one value for this settings. But this is how it was.
            string trlTelerouteNumberingKey = 'TR_Teleroute_Numbering';
            if(existingShippingCountryMapping.get(acc.Organization_Country__c) != null)
            	trlTelerouteNumberingKey = existingShippingCountryMapping.get(acc.Organization_Country__c).Teleroute_Numbering_Key__c;
            // Generate Teleroute Number
            if (string.isEmpty(acc.Teleroute_Number__c) && telerouteNumberMap.size() > 0)
            {
                acc.Teleroute_Number__c  = String.valueof(telerouteNumberMap.get(trlTelerouteNumberingKey));
                telerouteNumberMap.put(trlTelerouteNumberingKey, telerouteNumberMap.get(trlTelerouteNumberingKey)+1);  
            } // if empty TLR number
        } // for accounts
        
    } // FillTlrNumber
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 November 22
    * @description  Fill Organization__c
                    previous comment was 'Complete Geographical Organization'
                    I have no idea, what is it
    **/
    private void FillOrganization(List<sObject> newValues)
    {
        List <Schema.PicklistEntry> lstValues = Schema.SObjectType.Account.fields.getMap().get('Organization__c').getDescribe().getPicklistValues();
        Map<String, Country_Parameters__c> existingLocation = Country_Parameters__c.getAll();
        for(sObject obj : newValues)
        {
            Account acc = (Account)obj;
            // Complete Geographical Organization
            String pickVal = '';
            if(!string.isEmpty(acc.ShippingCountry))
            {
                for (Schema.PicklistEntry value : lstValues)
                {
                	if(acc.Organization_Country__c != null)
                	{
	                    if (value.getLabel().startsWith(acc.Organization_Country__c))
	                    {
	                        pickVal = value.getValue();
	                        break;
	                    }
                	}
                }
                if(pickVal == '')
                {
                    pickVal = 'Other -> Other Countries -> Other';
                }
            	if(acc.Organization_Country__c != null&&existingLocation.containsKey(acc.Organization_Country__c))
            	{
            		acc.Location__c = existingLocation.get(acc.Organization_Country__c).Location__c;
            	}
                acc.Organization__c = pickVal;
            } // if Shipping country is empty
            else 
            {
                	throw new CountryValidationException('The Shipping Country is Mandatory',acc);
            }
        } // for accounts
    } //FillOrganization
    
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 November 25
    * @description  sends upadate command to IAM in case some account fields are updated
    **/
    private void UpdateAccountProvisioningMessage(List<sObject> newObjects, Map<Id, sObject> oldObjectsMap)
    {
        //ID userId = UserInfo.getUserId();
        Boolean disableIAMCalls = [SELECT Disable_Update_to_IAM__c FROM User WHERE Id = :UserInfo.getUserId()].Disable_Update_to_IAM__c;
        if(disableIAMCalls)
            return;
        
        for(sObject obj : newObjects)
        {
            Account acc = (Account)obj;
            Account oldAcc = (Account)oldObjectsMap.get(acc.Id);
            if( //newAccounts.size()==1  && WTF is it? 
                (oldAcc.Level_of_Certification__c != acc.Level_of_Certification__c
                    ||oldAcc.Website != acc.Website
                    ||oldAcc.VAT__c != acc.VAT__c
                    ||oldAcc.Phone != acc.Phone
                    ||oldAcc.ParentId != acc.ParentId
                    ||oldAcc.Fax != acc.Fax
                    ||oldAcc.Deactivation_Date__c != acc.Deactivation_Date__c
                    ||oldAcc.ShippingStreet != acc.ShippingStreet
                    ||oldAcc.ShippingState != acc.ShippingState
                    ||oldAcc.ShippingPostalCode != acc.ShippingPostalCode
                    ||oldAcc.ShippingCountry != acc.ShippingCountry
                    ||oldAcc.ShippingCity != acc.ShippingCity
                    ||oldAcc.Activation_Date__c != acc.Activation_Date__c
                    ||oldAcc.Account_Level__c != acc.Account_Level__c
                    ||oldAcc.About_Specialization__c != acc.About_Specialization__c
                    ||oldAcc.BIC_Code__c != acc.BIC_Code__c
                    ||oldAcc.AccountNumber != acc.AccountNumber
                    ||oldAcc.Level_of_Certification__c != acc.Level_of_Certification__c
                    ||oldAcc.Description != acc.Description
                    ||oldAcc.Company_Creation_Date__c != acc.Company_Creation_Date__c
                    ||oldAcc.Completion_Level__c != acc.Completion_Level__c
                    ||oldAcc.CurrencyIsoCode != acc.CurrencyIsoCode
                    ||oldAcc.Customer_Since__c != acc.Customer_Since__c
                    ||oldAcc.Total_employees__c != acc.Total_employees__c
                    ||oldAcc.Iban_Number__c != acc.Iban_Number__c
                    ||oldAcc.ISO_Certification__c != acc.ISO_Certification__c
                    ||oldAcc.Company_Registration_Number__c != acc.Company_Registration_Number__c
                    ||oldAcc.Teleroute_Number__c != acc.Teleroute_Number__c
                    ||oldAcc.Number_of_trucks_owned__c != acc.Number_of_trucks_owned__c
                    ||oldAcc.Teleroute_Name__c != acc.Teleroute_Name__c
                    ||oldAcc.TCD_Published_status__c != acc.TCD_Published_status__c
                    ||oldAcc.TCD_Visibility__c != acc.TCD_Visibility__c
                )
            )
            {
				System.Debug('## A synchronized field has been updated in Account');
                //We check that at least one subscription is Active
                 List<Subscription__c> subsList = [
                    SELECT Id FROM Subscription__c 
                    WHERE Contract__r.AccountId = :acc.Id 
                    AND Status__c = 'Active' and (Access_Kind__c != 'TWD' and Access_Kind__c != 'TFX' and Access_Kind__c != 'CD')
                ];
                
                if (subsList.size() > 0)
                {
                    //The account has at least one subscription activated so it has been provisioned
                    ProvisioningMessagesAsync.SendUpdateAccount(subsList[0].Id);
                    System.Debug('## A synchronized field has been updated in Account : End');
                }
                // BUG #45 START -----------------------------------------------
                else
                {
                    // Simulate same process as for contact provisioning trigger -> take one active UP
                    // Query all User Profile attached to contacts who belong to this company, who have a valid status (linked to the subscription)
                    List<User_Profile__c> upList = [
                        SELECT Id FROM User_Profile__c 
                        WHERE Contact__c IN (SELECT Id From Contact WHERE Contact.AccountId =: acc.Id) 
                        AND Status__c = 'Activated'
                        AND Provisioning__r.Subscription__r.Status__c = 'Active' 
                        AND Provisioning__r.Subscription__r.Start_Date__c <= TODAY 
                        LIMIT 1
                    ];
                    
                    if(!upList.isEmpty())
                    {
                        List<Id> upIds = new List <Id>();
                        for(User_Profile__c up : upList)
                            upIds.add(up.Id);
                        // If the list is not empty, then call Provisioning Message class as if it was a contact update                    
                        ProvisioningMessagesAsync.SendUpdateContact(upIds);
                        System.Debug('## A synchronized field has been updated in Account-contact : End');
                    }
                } // BUG #45 END =================================================
            } // if some of fields updated
        } // for new values
    } //UpdateAccountProvisioningMessage
    
    /** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 November 25
    * @description  processing of updated account certification level: corresponding activity creation
    **/
    private void UpdateAccountCertificationLevel(List<sObject> newValues, Map<Id, sObject> oldValuesMap)
    {
        List<Task> activities = new List<Task>();
        Task actUpdateLevelCertif;
        List<Id> accToUpdateIdList = new List<Id>();
        
        for(sObject obj : newValues)
        {
            Account acc = (Account)obj;
            Account oldAcc = (Account)oldValuesMap.get(acc.Id);
            if(acc.Level_of_Certification__c != oldAcc.Level_of_Certification__c)
            {
                if(
                    (oldAcc.Level_of_Certification__c == '2' && acc.Level_of_Certification__c == '1')
                    ||(oldAcc.Level_of_Certification__c == '3' && acc.Level_of_Certification__c == '2')
                    ||(oldAcc.Level_of_Certification__c == '2' && acc.Level_of_Certification__c == '3')
                    ||(oldAcc.Level_of_Certification__c == '1' && acc.Level_of_Certification__c == '2')
                )
                {
                    actUpdateLevelCertif = new Task();
                    actUpdateLevelCertif.WhatId = acc.Id;
                    //actUpdateLevelCertif.WhoId = contact.Id;
                    actUpdateLevelCertif.Subject_Group__c = 'Safe Market Place';
                    actUpdateLevelCertif.Type = 'Administration';
                    
                    if(oldAcc.Level_of_Certification__c == '2' && acc.Level_of_Certification__c == '1')
                    {
                        actUpdateLevelCertif.Subject = 'Downgraded to Level 1';
                        actUpdateLevelCertif.Status = 'Completed';
                        //actUpdateLevelCertif.Description = 'This is an automatically generated message for customer that did not update their data and went from level 2 to 1 verified. If they update their data they can be manually given the level 2 verification.';
                        actUpdateLevelCertif.Description = 'Certification downgraded to level 1';
                    }
                    if(oldAcc.Level_of_Certification__c == '3' && acc.Level_of_Certification__c == '2')
                    {
                        actUpdateLevelCertif.Subject = 'Downgraded to Level 2';
                        actUpdateLevelCertif.Status = 'Completed';
                        //actUpdateLevelCertif.Description = 'This is an automatically generated Activity when a customer is downgraded from level 3 to level 2 verified.';
                        actUpdateLevelCertif.Description = 'Customer certificate was downgraded to level 2';
                    }
                    if(oldAcc.Level_of_Certification__c == '1' && acc.Level_of_Certification__c == '2')
                    {
                        actUpdateLevelCertif.Subject = 'Update Level 1 to 2';
                        actUpdateLevelCertif.Status = 'Completed';
                        //actUpdateLevelCertif.Description = 'This is an automatically generated message for customer that updated their data and went from level 1 to 2 verified.';
                        actUpdateLevelCertif.Description = 'Customer updated their data and went from level 1 to 2 verified.';
                    }
                    if(oldAcc.Level_of_Certification__c == '2' && acc.Level_of_Certification__c == '3')
                    {
                        actUpdateLevelCertif.Subject = 'Update Level 2 to 3';
                        actUpdateLevelCertif.Status = 'Completed';
                        //actUpdateLevelCertif.Description = 'This is an automatically generated message for customer that went from level 2 to 3 verified.';
                        actUpdateLevelCertif.Description = 'Customer went from level 2 to 3 verified';
                    }
                    activities.add(actUpdateLevelCertif);
                } // if certification level
            } // if certification level is changed
        } // for new values
        if(activities.size() > 0)
        {
            system.debug('## >>> The following update certification Level activities will be created : ' + activities);
            insert activities;
        }
    } // UpdateAccountCertificationLevel
    
   
    /**
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2014 January 20(end review ... I think end)
    * @description  Compute Sepa Mandate ID
    */
    private void CreateSepaMandateID(List<Account> newValues,List<Account> oldValues)
    {
        if(oldValues != null)
        {
            for(Integer i = 0; i < newValues.size() && i < oldValues.size(); i++)
            {
                if(String.isNotEmpty(oldValues[i].SEPA_MNDID__c) && oldValues[i].Iban_Number__c != newValues[i].Iban_Number__c)
                {
                    newValues[i].SEPA_MNDID__c = null;
                }
            }
        }
        Map<String,Integer> accountSepaCountryMap = new Map<String,Integer>();
        Map<string,Sepa_Unique_Number__c> sepaUniqCountryMap = Sepa_Unique_Number__c.getAll();
        for(Account acc: newValues)
        {
            if(String.isNotEmpty(acc.ShippingCountry) && acc.Direct_Debit__c && acc.SEPA_MNDID__c == null && sepaUniqCountryMap.containsKey(acc.ShippingCountry))
            {
                if(accountSepaCountryMap.containsKey(acc.ShippingCountry))
                {
                    accountSepaCountryMap.put(acc.ShippingCountry,accountSepaCountryMap.get(acc.ShippingCountry)+ 1);
                }
                else
                {
                    accountSepaCountryMap.put(acc.ShippingCountry,1);
                }
            }
        }
        if(accountSepaCountryMap.size() > 0)
        {
            accountSepaCountryMap = TLR_CustomSettingsHelper.GetSepaNumber(accountSepaCountryMap);
        }
        List<pw_cc__CountryObject__c> countryObjectList = [SELECT Name, pw_cc__IsoCode_2__c FROM pw_cc__CountryObject__c ORDER BY Name ASC];  
        /*Map<String,String> sepaSignCity = new Map<String,String> {  'Belgium' => 'Bruxelles',
                                                                    'Luxembourg'  =>'Bruxelles',
                                                                    'Italy' => 'Milano',
                                                                    'Pologna' =>'Warshow',
                                                                    'Portugal' => 'Lisbon',
                                                                    'Netherlands' => 'Alphen',
                                                                    'Spain' => 'Madrid',
                                                                    'France' => 'Paris',
                                                                    'Germany' => 'Mainz',
                                                                    'Austria' => 'Mainz' };
        Map<String,String> sepaCreditorID = new Map<String,String> {'Spain' => 'ES78002A83191700',
                                                                    'Netherlands' => 'NL87ZZZ332236310000',
                                                                    'Portugal' => 'PT470015059401242529',
                                                                    'Italy' => 'IT060010000003729530968',
                                                                    'France' => 'FR74TLR525873',
                                                                    'Monaco' => 'FR20TLR525875',
                                                                    'Switzerland FR' => 'FR20TLR525875',
                                                                    'Germany' => 'DE75D3100000478090',
                                                                    'Switzerland DE' => 'DE75D3100000478090',
                                                                    'Austria' => 'DE75A3100000478090',
                                                                    'Belgium' => 'BE32ZZZ0872586165'};    */                                                          
        Map<String,String> isoMap = new Map<String,String>(); 
        for(pw_cc__CountryObject__c obj : countryObjectList)
        {
            isoMap.put(obj.Name,obj.pw_cc__IsoCode_2__c);
        }
        for(Account acc : newValues)
        {
            if(String.isNotEmpty(acc.ShippingCountry) && acc.Direct_Debit__c && String.isNotEmpty(isoMap.get(acc.ShippingCountry)) && acc.SEPA_MNDID__c == null)
            {
                /*
                if(sepaSignCity.get(acc.ShippingCountry) != null)
                    acc.SEPA_Sign_City__c = sepaSignCity.get(acc.ShippingCountry);
                if(sepaCreditorID.get(acc.ShippingCountry) != null)
                    acc.SEPA_CRDID__c = sepaCreditorID.get(acc.ShippingCountry);
                */
                if(sepaUniqCountryMap.get(acc.ShippingCountry).Sign_City__c != null)
                    acc.SEPA_Sign_City__c = sepaUniqCountryMap.get(acc.ShippingCountry).Sign_City__c;
                if(sepaUniqCountryMap.get(acc.ShippingCountry).Creditor_ID__c != null)
                    acc.SEPA_CRDID__c = sepaUniqCountryMap.get(acc.ShippingCountry).Creditor_ID__c;
                
                acc.SEPA_Sign_Date__c = Date.today();
                acc.SEPA_Valid_From__c = Date.today();
                acc.SEPA_Pay_Type__c = 'Non One Time Payment';
                acc.SEPA_Status__c = 'Active';
                acc.SEPA_Valid_To__c = Date.newInstance(2099, 12,31);
                if(sepaUniqCountryMap.containsKey(acc.ShippingCountry))
                {
                    acc.SEPA_MNDID__c = isoMap.get(acc.ShippingCountry) + String.valueOf(accountSepaCountryMap.get(acc.ShippingCountry)).leftPad(7).replaceAll(' ', '0');
                }
            }
        } 
    }
    
   
    /**
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2014 June
    * @description  provide updates notification to WKTSAdmin
    */
	private void Esb_UpdateAccounts(List<Account> newValues, List<Account> oldValues)
    {
    	// check, if we need automatic updates
    	User u = [SELECT Id, Disable_ESB_calls__c, Disable_ESB_automatic_updates__c FROM User WHERE Id=:UserInfo.getUserId()];
    	if(u.Disable_ESB_calls__c || u.Disable_ESB_automatic_updates__c)
    		return;
    	// we will send updates only in manual updates mode (no mass updates, otherwise we will face @future calls limit)
    	// second condition: we will send updates only for companies, need to be synced with WKTSAdmin:
    	// if ESB_Company_status__c is not empty and not CREATED. If CREATED - this means it is created in WKTSAdmin
    	// and we will approve it in future, no need to send updates before approval
		if(newValues.size() == 1 && oldValues.size() == 1 && newValues[0].ESB_Company_status__c != null && newValues[0].ESB_Company_status__c != 'CREATED')
		{
			system.debug('----------TRIG_AccountTriggerHandler: Esb_UpdateAccounts: oldAccount: ' + oldValues[0] + ', newAccount' + newValues[0]);
			// in case of our company goes from CREATED to APPROVED - this will be separate handling inside TLR_SubscriptionExt
			if(!(newValues[0].ESB_Company_status__c == 'APPROVED' && oldValues[0].ESB_Company_status__c != 'APPROVED'))
			{
				if(ESB_AccountsChanged(oldValues[0], newValues[0]))
					ESB_Proxy.UpdateCompany(newValues[0].Id, false);
			}
		}
    } //Esb_UpdateAccounts
    
    /**
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2015 January 21
    * @description  we need to know if ESB-related information is changed to not send unneeded updates
    */
    private boolean ESB_AccountsChanged(Account oldAcc, Account newAcc)
    {
    	List<string> fieldsToSync = new List<string> { 'Name', 'Company_Type__c', 'VAT__c', 'Email__c', 'Fax', 'Phone', 'Website', 
                'ShippingCountry', 'ShippingState', 'ShippingCity', 'ShippingPostalCode', 'ShippingStreet',
                'Time_Zone__c', 'AccountNumber', 'Customer_Since__c', 'Company_Registration_Number__c', 'Transport_Licence__c', 'ParentID',
                'ESB_Company_Type__c', 'ESB_ShippingAddress_ID__c', 'Parent_TWA__c' };
    	boolean isChanged = false;
    	
    	for(string field : fieldsToSync)
    		isChanged |= (oldAcc.get(field) != newAcc.get(field));
    	
    	return isChanged;
    } //ESB_AccountsChanged
    
    /**
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2014 September 4
    * @description  Calculate account number using modified value of standard salesforce counter.
    * 				Modification caused by security reason - we need to randomize predictable counter value
    *				doe to used logic it must be called inside after insert or before update
    */
	private void GenerateAccountNumber(List<Account> accounts, boolean isInsert)
	{
		if(isInsert)
		{
			List<Account> accToUpdate = new List<Account>();
			for(Account acc : accounts)
			{
				Account a = new Account();
				a.Id = acc.Id;
				a.AccountNumber = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaCaps, 4) + string.valueOf(acc.ESB_BuisnessID_Counter__c);
				a.TLR_Account_Number__c = a.AccountNumber;
				accToUpdate.add(a);
			}
			if(accToUpdate.size() > 0)
			update accToUpdate;
		}
		else // will be executed in before update (will not perform trigger)
		{
			for(Account acc : accounts)
			{
				if(string.isNotEmpty(acc.AccountNumber))
					continue;
				
				acc.AccountNumber = Utilities.getRandomString(Utilities.randomStringAlphabets.alphaCaps, 4) + string.valueOf(acc.ESB_BuisnessID_Counter__c);
				acc.TLR_Account_Number__c = acc.AccountNumber;
			}
		}
		
	} //SetESBBusinessId
	
	/**
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2014 September 5
    * @description  Validation of phone number format and validity of country code. Moved to trigger since we need capability to quickly add new phone code
    *				using validation rules we can't do so because of many occurences.
    */
	private void ValidatePhones(List<Account> accounts)
	{
		Set<integer> validCountryCodes = new Set<Integer>();
		for(Country_Parameters__c c : [SELECT Name, Phone_code__c FROM Country_Parameters__c])
			validCountryCodes.add(integer.valueOf(c.Phone_code__c));
		
		for(Account a : accounts)
		{
			if(string.isNotEmpty(a.Phone))
				if(!Utilities.ValidatePhone(a.Phone, validCountryCodes))
					a.Phone.addError(Utilities.getPhoneValidationErrorMessage());
			if(string.isNotEmpty(a.Fax))
				if(!Utilities.ValidatePhone(a.Fax, validCountryCodes))
					a.Fax.addError(Utilities.getPhoneValidationErrorMessage());
		}
	} //ValidatePhones
	
	/**
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2014 December 8
    * @description  Perform processing if record is clonned.
    				How it works: in accordance with salesforce order of execution, we have following sequence
    				in case of INSERT (simplified list)
    				1) before insert triggers
    				2) after insert triggers
    				3) workflow rules
    					in case of updates in workflows runs
    					a) before update
    					b) after update
    				4) commits record to a database
    				
    				To detect Clonned accounts (after pressing Clone button on layout) we will do following:
    				1) in before insert i will perform check of ClonnedFlag__c flag
    					clonned accounts already have this flag set, so don't bother about them
    				2) in after insert trigger i will set ClonnedFlag__c to true
    				3) we need to set this flag for all existing accounts
    					otherwise this will not work
    					
    				for an account created viw 'new' button this flag will be empty
    				for an account created via 'clone' button this flag will be set
    				
    				ClonnedFlag__c FIELD NEEDS TO BE ON PAGE LAYOUT, THIS IS ABSOLUTELY REQUIRED
    				OTHERWISE THIS PIECE OF CODE WILL NOT WORK
    				
    				just because 'clone' button will not copy all the fields, only these, which are on page layout 
    */
	private void ProcessClonnedAccounts(List<Account> accounts)
	{
		for(Account a : accounts)
		{
			if(a.ClonnedFlag__c == true)
			{
				// action will be performed on clonned accounts only
				a.ESB_Company_status__c = '';
				a.ESB_Billing_Address_ID__c = '';
				a.ESB_ShippingAddress_ID__c = '';
				
				// legacy
				a.Debtor_Number__c = '';
				a.Teleroute_Number__c = '';
			}
			a.ClonnedFlag__c = true;
		}
	} //ProcessClonnedAccounts
	
	/** 
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 November 25
    * @description  updates National_Key_Account__c and International_Key_Account__c for entire account hierarchy
    *
    * returned with customer request, 2015 March 25, aleh_tsilko@epam.com
    **/
    private void UpdateKeyAccountHierarchy(List<sObject> newObjects, Map<Id, sObject> oldObjectsMap)
    {
        // if we need to calculate this
        if(! General_Settings__c.getInstance('Default').Enable_IKA_NKA_calculation__c)
            return;
        
        if (FollowUpTriggersUpdateKeyAccount.updateTriggerToBeCalled())
        {
            if ( newObjects.size() != 1 )
                return; // Anton Soloveyv: stupig thing, i agree, buth without it all mass-updates are blocked.
            for(sObject obj : newObjects)
            {
                Account acc = (Account) obj;
                Account oldAcc = (Account)oldObjectsMap.get(acc.Id);
                 if(oldAcc.International_Key_Account__c != acc.International_Key_Account__c
                           || oldAcc.National_Key_Account__c != acc.National_Key_Account__c)
                 {
                    if (acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('WKTS Account').getRecordTypeId())
                    {
                        AccountStructure controller = new AccountStructure();
                        controller.setcurrentId(acc.Id);
                        AccountStructure.ObjectStructureMap[] accountIkaNka = new AccountStructure.ObjectStructureMap[]{};
                        // 1 SOQL query per account position in hierarhy (to find top parent) plus 1 query per each account in hierarchy
                        // for example we have 5 accounts in hierarchy, if our account is 3rd from top we will have 3 + 5 = 8 SOQL queries
                        // or 2 queries if account is standalone (without parent)
                        accountIkaNka = controller.getObjectStructure();
                        List<ID> listAccount = new List <ID>();
                    
                        for (AccountStructure.ObjectStructureMap a : accountIkaNka)
                        {
                            listAccount.add(a.getaccount().Id);
                        }
                        List<Account> accountList = [
                            SELECT Id, parentID, BillingCountry , International_Key_Account__c, National_Key_Account__c
                              FROM  Account
                             WHERE Id IN :listAccount
                        ];
                        if(oldAcc.International_Key_Account__c != acc.International_Key_Account__c
                           || oldAcc.National_Key_Account__c != acc.National_Key_Account__c)
                        {
                            for(Account a : accountList)
                            {
                                a.International_Key_Account__c = acc.International_Key_Account__c;
                                a.National_Key_Account__c = acc.National_Key_Account__c;
                            }
                            if (accountList.size() > 0)
                            {
                                FollowUpTriggersUpdateKeyAccount.doNotCallUpdateTrigger();
                                update accountList;
                            }
                        }
                    } // if account is tlr
                 } // if keys changed   
                } // for accounts
            } // if we need to call trigger
    } //UpdateKeyAccountHierarchy
	
	private void SetTimeZone(List<Account> accounts)
	{
		Map<String, Country_Parameters__c> params = Country_Parameters__c.getAll();
		for(Account acc:accounts)
		{
			if(String.isEmpty(acc.Time_Zone__c) && params.containsKey(acc.ShippingCountry))
			{
				String timeZone = params.get(acc.ShippingCountry).Time_Zone__c;
				if(String.isEmpty(timeZone))
				{
					throw new TimeZoneValidationException('Please, select the Time Zone',acc);
				}
				else
				{
					acc.Time_Zone__c = timeZone;
				}
			}
		}
	}
	
	private void FillISO2Code(List<Account> accounts)
	{
		Map<String,Country_Parameters__c> params = Country_Parameters__c.getAll();
		for(Account a: accounts)
		{
			if(params.containsKey(a.ShippingCountry))
			{
				a.ISO2_Country_Code__c = params.get(a.ShippingCountry).ISO2_code__c;
			}
		}
	}
    
    private void SetTFXAgreedMigrationEvolutionDate(List<Account> newValues, Map<Id, sObject> oldObjectsMap)
    {
        for(Account acc : newValues)
        {
            Date previousAgreedDate = ((Account)oldObjectsMap.get(acc.Id)).Sales_TFX_Migration_Start_Date__c;
            if(acc.Sales_TFX_Migration_Start_Date__c != null && acc.Sales_TFX_Migration_Start_Date__c != previousAgreedDate)
            {
                acc.TFX_Agreed_Migration_Evolution_Date__c = Date.today();
            }
        }
    }
	
	private void Ser(List<Account> newValues, Map<Id, sObject> oldObjectsMap)
    {
        Map<String,Country_Parameters__c> params = Country_Parameters__c.getAll();
		for(Account a: accounts)
		{
			if(params.containsKey(a.ShippingCountry))
			{
				a.ISO2_Country_Code__c = params.get(a.ShippingCountry).ISO2_code__c;
			}
		}
    }
}