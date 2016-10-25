/**
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2015 April 2
    * @description  Sync User Language with Contact
    * @WKTSCRM-1903 JIRA TASK              
    */

public without sharing class TRIG_UserTriggerHandler extends TRIG_TriggerHandlerAbstract
{

    public boolean IsTriggerContext
    {
        get
        {
            return isTriggerExecuting;
        }
    }
    
    public TRIG_UserTriggerHandler (boolean isTriggerExecuting)
    {
        super(isTriggerExecuting);
    }
    
    public override void OnBeforeInsert(List<sObject> newTriggerValues)
    {
    }
    
    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
    {
        markContactAsDMSSelfServiceAndCommunityUser(newTriggerValues);
    }
    
    public override void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        this.Update_CommunityUsers_Language(oldTriggerValuesMap, newTriggerValuesMap);
        UpdateUserActiveFlagOnContact(newTriggerValues);
    }
    
    
/*************************************************** private section**************************************************************************************/    

    private void Update_CommunityUsers_Language (Map<ID, sObject> oldUsrMap, Map<ID, sObject> newUsrMap)
    {
        Map<Id, Id> usr2ContIds = New Map<Id,Id>();
        for(Id currUsrId: newUsrMap.keySet())
        {
            User oldUsr = (User)oldUsrMap.get(currUsrId);
            User newUsr = (User)newUsrMap.get(currUsrId);      
            if(oldUsr.LanguageLocaleKey != newUsr.LanguageLocaleKey 
            && TLR_UserLanguageHelper.COMMUNITY_PROFILE_IDS.contains(newUsr.ProfileId))
            {
                usr2ContIds.put(currUsrId,newUsr.ContactId);
            }    
        }  
        List<Id> relConId = New List<Id>(usr2ContIds.values());
        List<Contact> con2Update = [SELECT Id, Language__c
                                      FROM Contact
                                     WHERE Id IN:relConId];                                   
        Map<Id,Contact> contMap = New Map<Id,Contact>();                                     
        for(Contact currCon:con2Update)
        {
            contMap.put(currCon.Id, currCon);
        }
        con2Update.clear();
        for(Id currUsrId:usr2ContIds.keySet()) 
        {
                User currUsr = (User)newUsrMap.get(currUsrId);
                Contact currCon = contMap.get(currUsr.ContactId);
                currCon.Language__c = getContactLangFromUser(currUsr.LanguageLocaleKey);
                con2Update.add(currCon); 
        } 
        if(!con2Update.isEmpty())
        {
            update(con2Update);
        }

    }// end Update_CommunityUsers_Language
    
    private string getContactLangFromUser(String usrLocaleKey)
    { 
        String retLanguage;
        
        if(TLR_UserLanguageHelper.CONTACT_LANG_ENABLED.contains(TLR_UserLanguageHelper.USER_LANG_MAP.get(usrLocaleKey)))
        {
            retLanguage = TLR_UserLanguageHelper.USER_LANG_MAP.get(usrLocaleKey);
        }
        else
        {
            retLanguage = 'English US';
        }
        return retLanguage;
    }//getContactLangFromUser
    
    //Author: Jan Selis, Synergy2core BVBA for 4C Consulting
    //Requested by : Rudi Vermeulen
    //Date: 2014-04-24
    //Description: If a Contact is connected to the User, update field DMS_Self_Service_Yes_No__c in Contact
    //             Logic might have to be refined in the future to make sure the Contact is actually a DMS_Self_Service user
    //             and not some other portal user.
    //Modified by: Andrei Lobkis (andrei_lobkis@epam.com)   
    //Description: Is_Community_User__c is set to true in Contact when user is created for this Contact
    private void markContactAsDMSSelfServiceAndCommunityUser(List<User> newTriggerValues)
    {
        //collect Contacts to update
        List<Contact> contactsToUpdate = new List<Contact>();
        for (User u : newTriggerValues)
        {
            if (u.ContactId != null)
            {
            	contactsToUpdate.add(new Contact(Id = u.ContactId, DMS_Self_Service_Yes_No__c = true, Is_Community_User__c = true, Is_Community_User_Active__c = true));
            }
        }
        
        //perform the update
        if(contactsToUpdate.size() > 0)
        {
        	update contactsToUpdate;
        }
    }//markContactAsDMSSelfServiceAndCommunityUser
    private static void UpdateUserActiveFlagOnContact(List<User> newTriggerValues)
    {
        List<User> UseresForUpdate = new List<User>();
        for(User u : newTriggerValues)
        {
            if(u.ContactId != null)
            {
                UseresForUpdate.add(u);
            }
        }
        if(UseresForUpdate.size() > 0)
        {
            System.enqueueJob(new TLR_ContactHelper.QueueableUpdateUserActiveFlagOnContact(UseresForUpdate));
        }
    }
}