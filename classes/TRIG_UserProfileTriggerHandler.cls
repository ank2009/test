/*
* @ Description :- Class handles all before and after events of User Profile object
* @ Author      :- HCL Technologies LTD
* @ Date        :- 11-01-2013
**/
public without sharing class TRIG_UserProfileTriggerHandler extends TRIG_TriggerHandlerAbstract
{
    public boolean IsTriggerContext { get { return isTriggerExecuting;} }
    public TRIG_UserProfileTriggerHandler (boolean isTriggerExecuting){ super(isTriggerExecuting); }

    public override void OnBeforeInsert(List<sObject> newTriggerValues)
    {
    	system.debug('----- TLR_UserProfileTriggerHandler: OnBeforeInsert: start.');
        System.debug('----- TLR_UserProfileTriggerHandler: OnBeforeInsert: newTriggerValues: ' + newTriggerValues);
        UpdateUserProfilesApplication(newTriggerValues);
        wktsBridgePRofileOperations(newTriggerValues, null, null, null);
    }

    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
    {
        CreatePackageFee(newTriggerValues, null);
        UpdateProductContact(newTriggerValues);
    }

    public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues,
            Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        System.debug('----- TLR_UserProfileTriggerHandler: OnBeforeUpdate: start.');
        System.debug('----- TLR_UserProfileTriggerHandler: OnBeforeUpdate: newTriggerValues: ' + newTriggerValues);
        System.debug('----- TLR_UserProfileTriggerHandler: OnBeforeUpdate: oldTriggerValues: ' + oldTriggerValues);
        UpdateUserProfilesApplication(newTriggerValues);
        wktsBridgePRofileOperations(newTriggerValues, oldTriggerValues, newTriggerValuesMap, oldTriggerValuesMap);
    }

    public override void OnAfterUpdate(List<sObject> oldTriggerValues, List<sObject> newTriggerValues,
            Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        CreatePackageFee(newTriggerValues, oldTriggerValuesMap);
        UpdateProductContact(newTriggerValues);
    }

    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}
    public override void OnAfterDelete  (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}

    public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap) {}

    /**
    * @author       Anton Solovyev (anton_soloveyv@epam.com)
    * @date         2013 October 7
    * @description  Reads available profile settings from FXSettings custom settings object
    **/
    private Map<string, string> getAvailableProfilesFromSettings()
    {
        Map<string, string> retVal = new Map<string, string>();

        // get settings map
        Map<String, Bridge_Profile_Settings__c> settingsMap = Bridge_Profile_Settings__c.getAll();
        for(string nm : settingsMap.keySet())
            retVal.put(settingsMap.get(nm).Name, settingsMap.get(nm).value__c);

        return retVal;
    } // getAvailableProfilesFromSettings

    /*
    *  @ Author      : Hcl Technology, Anton Soloviev remix (2013-10-07)
    *  @ Description : Method handles all wkts bridge profile related activities
    *  @ Date        : 17-05-2013
    */
    public void wktsBridgeProfileOperations(User_Profile__c[] newUserProfiles, User_Profile__c[] oldUserProfiles,
            Map <Id, sObject> newUserProfileMap, Map <Id, sObject> oldUserProfileMap)
    {
        //if(Test.isRunningTest()) return;
        if(! General_Settings__c.getInstance('Default').Enable_Bridge_calls__c)
        {
        	system.debug('---- wktsBridgeProfileOperations: webservice calls are disabled. ');
        	return;
        }

        Map<string, string> bridgeProfileMap = getAvailableProfilesFromSettings();

        system.debug('---- wktsBridgeProfileOperations start.');
        
        Map<Id,String> bridgeProfileOldMap = new Map<Id, String>();

        List<Id> userProfilesToAssignBridge = new List<Id>();
        Map<Id, String> userProfilesToSuppressBridge = new Map<Id, String>();

        system.debug('---- wktsBridgeProfileOperations: newUserProfiles: ' + newUserProfiles);
        system.debug('---- wktsBridgeProfileOperations: oldUserProfiles: ' + oldUserProfiles);
        system.debug('---- wktsBridgeProfileOperations: bridgeProfileMap: ' + bridgeProfileMap);
        if (oldUserProfiles != null)
        {
            for (User_Profile__c up :oldUserProfiles)
                bridgeProfileOldMap.put(up.Id, up.WKTS_Profiles__c);
        }
        if (newUserProfiles.size() > 0)
        {
            for(User_Profile__c up : newUserProfiles)
            {
                system.debug('---- wktsBridgeProfileOperations: new User_Profile__c.Name: ' + up.Name);
                system.debug('---- wktsBridgeProfileOperations: new User_Profile__c.WKTS_Profiles__c: ' + up.WKTS_Profiles__c);
                
                // skip already processed objects, or those, who we don't need to process
                if(up.Bridge_processing_status__c == 'Done')
                {
                    system.debug('---- wktsBridgeProfileOperations: processing is done, no need to update profile once again. Cleaning processing status.');
                    up.Bridge_processing_status__c = '';
                    continue;
                }
                
                // Bridge profiles can be assigned only to FX users
                // it means in our terms - with activated user profiles
                if(up.Status__c == 'Activated' )
                {
                    string oldProfiles = up.Id == null ? '' : bridgeProfileOldMap.get(up.Id);
                    // true if one of values is not empty, valse if both are empty, or both have a value
                    boolean isChanged = (string.isEmpty(up.WKTS_Profiles__c) ^ string.isEmpty(oldProfiles));
                    // in second case we need to do string comparsion, sure if there are not nulls
                    if(!isChanged)
                        isChanged = string.isEmpty(oldProfiles) ? false : !oldProfiles.equalsIgnoreCase(up.WKTS_Profiles__c);
                    
                    System.debug('---- wktsBridgeProfileOperations: up.Id: ' + up.Id +
                                ', up.WKTS_Profiles__c: ' + up.WKTS_Profiles__c +
                                ', old value is: ' + oldProfiles +
                                ', isChanged: ' + isChanged);
                    // now we know, if profiles are changed
                    if(oldUserProfiles != null && isChanged && oldUserProfileMap.containsKey(up.Id))
                    {
                        up.Bridge_processing_status__c = 'Pending';
                        string profile = ((User_Profile__c)oldUserProfileMap.get(up.Id)).WKTS_Profiles__c;
                        if(profile != null)
                            userProfilesToSuppressBridge.put(oldUserProfileMap.get(up.Id).Id, profile);
                    }
                    // assign new profiles
                    if(!string.isEmpty(up.WKTS_Profiles__c) && isChanged)
                    {
                        up.Bridge_processing_status__c = 'Pending';
                        userProfilesToAssignBridge.add(up.Id);
                    }
                } //if(up.Status__c == 'Activated' )\
                else
                {
                	up.Bridge_processing_status__c = 'Done';
                	up.Bridge_Error__c = 'Bridge profiles can be assigned only to Active user profiles!';
                } // else
            } //for each user profile
            
            if(userProfilesToSuppressBridge.size() > 0)
            {
                system.debug('---- wktsBridgeProfileOperations (if userProfilesToSuppressBridge.size()): bridgeProfileMap: ' + bridgeProfileMap);
                system.debug('---- wktsBridgeProfileOperations (if userProfilesToSuppressBridge.size()): userProfilesToSuppressBridge: ' + userProfilesToSuppressBridge);
                TLR_BridgeHelper.SuppressBridgeProfiles(userProfilesToSuppressBridge, bridgeProfileMap);
            }
            if(userProfilesToAssignBridge.size() > 0)
            {
                system.debug('---- wktsBridgeProfileOperations (if userProfilesToAssignBridge.size()): bridgeProfileMap: ' + bridgeProfileMap);
                system.debug('---- wktsBridgeProfileOperations (if userProfilesToAssignBridge.size()): userProfilesToAssignBridge: ' + userProfilesToAssignBridge);
                TLR_BridgeHelper.AssignBridgeProfiles(userProfilesToAssignBridge, bridgeProfileMap);
            }
        } //if (newUserProfiles.size()>0 )
    } //wktsBridgePRofileOperations


        /**
    * @author       Andrey Gordienko (andrey_gordienko@epam.com) (review)
    * @date         2013 December 12
    * @description  Update User Profiles Application
    **/

    private void UpdateUserProfilesApplication(User_Profile__c[] newUserProfiles)
    {
		System.Debug('## Start UpdateUserProfilesApplication');
		Set<ID> idProv = new Set<ID>();
		for (User_Profile__c ups : newUserProfiles)
		{
			if (ups.Provisioning__c != null)
				idProv.add(ups.Provisioning__c);
		}
		System.Debug('## Provisionings impacted: ' + idProv);
		Map<Id, Provisioning__c> mapProv = new Map<Id, Provisioning__c>([SELECT Subscription__r.Access_Kind__c
																		 FROM Provisioning__c WHERE Id IN :idProv]);
		for (User_Profile__c UserProfile : newUserProfiles)
		{
            // If Application__c is not null, do nothing, else put the Access_Kind__c From the related Subscription__c
			if (UserProfile.Application__c == null && UserProfile.Provisioning__c != null)
			{
				String accessKind = mapProv.get(UserProfile.Provisioning__c).Subscription__r.Access_Kind__c;
				if (accessKind != null && accessKind != '')
				{
					UserProfile.Application__c = accessKind;
					System.Debug('## 1 User profile treated - New value: ' + UserProfile.Application__c);
				}
			}
		}
		System.Debug('## End UpdateUserProfilesApplication');
	}

    /**
    * @author       Andrey Gordienko (andrey_gordienko@epam.com) (review)
    * @date         2013 December 12
    * @description  Update Product Contacts
    **/

	private void UpdateProductContact(User_Profile__c[] newUserProfiles)
	{
		Set <Id> IdContacts = new Set <Id> ();
		for (User_Profile__c up: newUserProfiles) 
		{
			if(up.Contact__c != null)
				IdContacts.add(up.Contact__c);
		}
		Map <Id, Contact> sContacts = new Map <Id ,Contact>([SELECT Id, Product__c FROM Contact WHERE Id in:IdContacts]);
		Map <Id, Product__c> Prods = new Map <Id, Product__c>([SELECT Id,Name FROM Product__c Limit 1000]);
		for (Contact con : sContacts.values())
		{
			Set <String> Products = new Set <String>();
			for (User_Profile__c  up : newUserProfiles)
			{
				if(up.Contact__c == con.Id && up.Product__c != null && (up.Status__c =='Activated' || up.Status__c =='Suspended'))
					Products.add(Prods.get(up.Product__c).Name);
			}
			if (Products.size() > 0)
			{
				for (String str: Products)
				{
					if(con.Product__c == null || con.Product__c =='' )
					{
						con.Product__c = str;
					}
					else if (!con.Product__c.contains(str))
					{
						con.Product__c= con.Product__c+ ';'+ str ;
					}
				}
			}
		}
		update sContacts.values();
	}
	
    /**
    * @author       Andrey Gordienko (andrey_gordienko@epam.com) (review)
    * @date         2013 December 12
    * @description  Insert Subs_Current_Fee__c after insert User Profile or  Update, Remove Subs_Current_Fee__c after update User Profile
    **/
	private void CreatePackageFee(User_Profile__c[] newUserProfiles , Map <Id,sObject> oldUserProfileMap)
	{
		Set<ID> upIds = new Set<ID>();
		Set<ID> spafIds = new Set<ID>();
		for (User_Profile__c up : newUserProfiles)
		{
			upIds.add(up.Id);
			if (up.Package_And_Fee__c != null)
				spafIds.add(up.Package_And_Fee__c);
		}
		Map<ID, Subs_Package_And_Fee__c> mapSPAF = new Map<ID, Subs_Package_And_Fee__c>([SELECT Name FROM Subs_Package_And_Fee__c WHERE Id IN :spafIds]);
		Map<ID, User_Profile__c> userProfiles = new Map<ID, User_Profile__c>([SELECT Provisioning__r.Subscription__c, Provisioning__r.Account__c, 
																				Provisioning__r.Subscription__r.RecordTypeId, 
																				Provisioning__r.Subscription__r.Start_Date__c,
																				Provisioning__r.Subscription__r.End_Date__c, 
																				Provisioning__r.Subscription__r.CurrencyIsoCode
																				 FROM User_Profile__c WHERE Id IN :upIds]);
		Set<ID> subsIds = new Set<ID>();
		for (User_Profile__c up : userProfiles.values())
			subsIds.add(up.Provisioning__r.Subscription__c);
		Map<ID, Subscription__c> mapSub = new Map<ID, Subscription__c>([SELECT Id,(SELECT Id, End_Date__c, Start_Date__c, Subs_Package_And_Fee__c, 
																		User_Profile__c FROM Subs_Current_Fees__r ORDER BY Start_Date__c DESC)
																		FROM Subscription__c WHERE Id IN :subsIds]);
		ID recordTypeSubsCF = TLR_RecordTypeHelper.getId('Subs_Current_Fee__c', 'TLR Subs Current Fee'); //hard code. If in future we shall have new record type for Subs_Current_Fee we will must review this code
		List<Subs_Current_Fee__c> subsCFToInsert = new List<Subs_Current_Fee__c>();
		List<Subs_Current_Fee__c> subsCFToUpdate = new List<Subs_Current_Fee__c>();
		List<Subs_Current_Fee__c> subsCFToRemove = new List<Subs_Current_Fee__c>();
		if (Trigger.isUpdate)
		{
			Map<ID, List<ID>> mapIDup = new Map<ID, List<ID>>();
			for (User_Profile__c up : newUserProfiles)
			{
				User_Profile__c beforeUpdate = (User_Profile__c)oldUserProfileMap.get(up.Id);
				if (up.Package_And_Fee__c != beforeUpdate.Package_And_Fee__c)
				{
					if (beforeUpdate.Package_And_Fee__c != null)
					{
                        // From one to another: Update/Remove old subs current fee + New one
                        // First find old subs current fee
						List<Subs_Current_Fee__c> subsCFs = mapSub.get(userProfiles.get(up.Id).Provisioning__r.Subscription__c).Subs_Current_Fees__r;
						Boolean found = false;
						Subs_Current_Fee__c oldSubsCF;
						for (Subs_Current_Fee__c scf : subsCFs)
						{
							if (scf.User_Profile__c == up.Id && scf.Subs_Package_And_Fee__c == beforeUpdate.Package_And_Fee__c)
							{
								found = true;
								oldSubsCF = scf;
								break;
							}
						}
						if (!found)
						{
							Generic.StandardException ex = new Generic.StandardException('Subs Current Fee for subscription ' +
										userProfiles.get(up.Id).Provisioning__r.Subscription__c + ' and user profile ' + up.Id +
										' and package ' + beforeUpdate.Package_And_Fee__c + ' not found!');
							throw ex;
						}
						if (userProfiles.get(up.Id).Provisioning__r.Subscription__r.Start_Date__c > Date.Today())
						{
                            // Subscription not yet active: Remove old subs current fee
							subsCFToRemove.add(oldSubsCF);
						}
						else
						{
                            // Subscription already active: Update/Remove old subs current fee
							if (oldSubsCF.Start_Date__c.monthsBetween(Date.Today()) == 0)
							{
                                // Old fee started during this month: Remove old subs current fee
								subsCFToRemove.add(oldSubsCF);
							}
							else
							{
                                // Old fee started during previous months: Update old subs current fee
								oldSubsCF.End_Date__c = Date.Today();
								subsCFToUpdate.add(oldSubsCF);
							}
						}
					}
                    // New subs current fee if necessary
					if (up.Package_And_Fee__c != null)
					{
						Subs_Current_Fee__c scf      = new Subs_Current_Fee__c();
						scf.Name                     = mapSPAF.get(up.Package_And_Fee__c).Name;
						scf.RecordTypeId             = recordTypeSubsCF;
						scf.Account__c               = userProfiles.get(up.Id).Provisioning__r.Account__c;
						scf.User_Profile__c          = up.Id;
						scf.Subscription__c          = userProfiles.get(up.Id).Provisioning__r.Subscription__c;
						scf.CurrencyIsoCode          = userProfiles.get(up.Id).Provisioning__r.Subscription__r.CurrencyIsoCode;
						scf.Subs_Package_And_Fee__c  = up.Package_And_Fee__c;
						scf.Start_Date__c            = (userProfiles.get(up.Id).Provisioning__r.Subscription__r.Start_Date__c > Date.Today()) ? userProfiles.get(up.Id).Provisioning__r.Subscription__r.Start_Date__c : Date.Today();
						scf.End_Date__c              = userProfiles.get(up.Id).Provisioning__r.Subscription__r.End_Date__c;
						subsCFToInsert.add(scf);
					} // (up.Package_And_Fee__c != null)
				} //if (up.Package_And_Fee__c != beforeUpdate.Package_And_Fee__c)
			} //for (User_Profile__c up : newUserProfiles)
		} // if (Trigger.isUpdate)
		else
		{
            // Insert
			for (User_Profile__c up : newUserProfiles)
			{
				if (up.Package_And_Fee__c != null)
				{
					Subs_Current_Fee__c scf      = new Subs_Current_Fee__c();
					scf.Name                     = mapSPAF.get(up.Package_And_Fee__c).Name;
					scf.RecordTypeId             = recordTypeSubsCF;
					scf.Account__c               = userProfiles.get(up.Id).Provisioning__r.Account__c;
					scf.User_Profile__c          = up.Id;
					scf.Subscription__c          = userProfiles.get(up.Id).Provisioning__r.Subscription__c;
					scf.CurrencyIsoCode          = userProfiles.get(up.Id).Provisioning__r.Subscription__r.CurrencyIsoCode;
					scf.Subs_Package_And_Fee__c  = up.Package_And_Fee__c;
					scf.Start_Date__c            = (userProfiles.get(up.Id).Provisioning__r.Subscription__r.Start_Date__c > Date.Today()) ? userProfiles.get(up.Id).Provisioning__r.Subscription__r.Start_Date__c : Date.Today();
					scf.End_Date__c              = userProfiles.get(up.Id).Provisioning__r.Subscription__r.End_Date__c;
					subsCFToInsert.add(scf);
				}
			} //for (User_Profile__c up : newUserProfiles)
		} // else
		if (subsCFToUpdate.size() > 0)
			update subsCFToUpdate;
		if (subsCFToInsert.size() > 0)
			insert subsCFToInsert;
		if (subsCFToRemove.size() > 0)
			delete subsCFToRemove;
    } //CreatePackageFee
    
    
}