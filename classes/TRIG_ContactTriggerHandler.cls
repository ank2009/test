/** 
* @author       Andrey Gordienko (andrey_gordienko@epam.com)
* @date         2013 December 9
* @description  Trigger handler for Contact events
**/
public without sharing class TRIG_ContactTriggerHandler extends TRIG_TriggerHandlerAbstract 
{
    public boolean IsTriggerContext
    {
        get
        {
            return isTriggerExecuting;
        }
    }
    public TRIG_ContactTriggerHandler (boolean isTriggerExecuting)
    {
        super(isTriggerExecuting);
    }
    
    public override void OnBeforeInsert(List<sObject> newTriggerValues)
    {
        ValidatePhones(newTriggerValues);
        
        ProcessClonnedContacts(newTriggerValues);
        
        ValidateLanguage(newTriggerValues);
    }
    public override void OnAfterInsert(List<sObject> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
    {
        this.StartDMSUsersAutomaticOperation(newTriggerValues, newTriggerValuesMap);
    }
    
    public override void OnBeforeUpdate (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        ValidatePhones(newTriggerValues);
		BlockEditingContacIfESBUserStatusCREATED(newTriggerValues);
    }
    public override void OnAfterUpdate  (List<sObject> oldTriggerValues, List<sObject> newTriggerValues, Map<ID, sObject> oldTriggerValuesMap, Map<ID, sObject> newTriggerValuesMap)
    {
        this.UpdateContactProvisioningMessage(newTriggerValues, oldTriggerValuesMap);
        this.Esb_UpdateContact(newTriggerValues, oldTriggerValues);
        this.Update_CommunityUsers_Language(oldTriggerValuesMap, newTriggerValuesMap);
        this.StartDMSUsersAutomaticOperation(newTriggerValues, newTriggerValuesMap);
    }
    
    public override void OnBeforeDelete (List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
    {
    
    }
    public override void OnAfterDelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
    {

    }

    public override void OnAfterUndelete(List<sObject> oldTriggerValues, Map<ID, sObject> oldTriggerValuesMap)
    {
    
    }
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2013 December 9
    * @description  Update User Profile that have updated Contacts
    **/
    private void UpdateContactProvisioningMessage(List<SObject> newContacts,Map <Id,SObject> oldContactMap)
    {
        ID userId = UserInfo.getUserId();
        List<ID> contactIdList = new List<ID>();
        List<ID> userProfileIdSet = new List<ID>();
        ID recordTypeId = TLR_RecordTypeHelper.getId('Contact', 'TLR Contact');
        for (SObject con : newContacts)
        {
            contactIdList.add(((Contact)con).Id);
        }
        Boolean disableTrigger = [SELECT Disable_Update_to_IAM__c FROM User WHERE Id = :userId].Disable_Update_to_IAM__c;
        List<User_Profile__c> upList = [SELECT Id,Contact__c FROM User_Profile__c
                                                          WHERE Contact__c IN : contactIdList
                                                          AND Status__c = 'Activated'
                                                          AND Provisioning__r.Subscription__r.Status__c = 'Active'
                                                          AND Provisioning__r.Subscription__r.Start_Date__c <= TODAY];
        if (!disableTrigger && newContacts.size()>0)
        {
            for (SObject obj : newContacts)
            {
                Contact con = (Contact)obj;
                if (con.RecordTypeId == recordTypeId) 
                {
                    if (this.CompareContact((Contact)(oldContactMap.get(con.Id)), con))
                    {
                        if (!upList.isEmpty())
                        {
                            for (User_Profile__c uProfileObj : upList)
                            {
                                if (uProfileObj.Contact__c == con.Id)
                                {
                                    System.Debug('----------He is work!--------------');
                                    userProfileIdSet.add(uProfileObj.Id);
                                }
                            }
                        }
                    }
                }
            }
            List <Id> userIdBatch = new List<Id>();
            if (userProfileIdSet.size() > 0)
            {
                ProvisioningMessagesAsync.SendUpdateContact(userProfileIdSet);
            }
        }
    }
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2013 December 9
    * @description  Comparison two contacts - old and new
    **/
    private boolean CompareContact(Contact firstCon, Contact secondCon)
    {
        return (firstCon.FirstName != secondCon.FirstName
                ||firstCon.LastName != secondCon.LastName
                ||firstCon.Language__c != secondCon.Language__c
                ||firstCon.Job_Title__c != secondCon.Job_Title__c
                ||firstCon.Is_Visible__c != secondCon.Is_Visible__c
                ||firstCon.Email != secondCon.Email
                ||firstCon.Phone != secondCon.Phone
                ||firstCon.MobilePhone != secondCon.MobilePhone
                ||firstCon.Fax != secondCon.Fax
                ||firstCon.MailingStreet != secondCon.MailingStreet
                ||firstCon.MailingState != secondCon.MailingState
                ||firstCon.MailingPostalCode != secondCon.MailingPostalCode
                ||firstCon.MailingCity != secondCon.MailingCity
                ||firstCon.MailingCountry != secondCon.MailingCountry
                ||firstCon.Salutation != secondCon.Salutation); 
    }
    
    /** 
    * @author       Andrey Gordienko (andrey_gordienko@epam.com)
    * @date         2014 June 6
    * @description  sends update erquest to ESB
    **/
    private void Esb_UpdateContact(List<Contact> newContacts, List<Contact> oldContacts)
    {
        // check if we need to do automatic updates
        User u = [SELECT Id, Disable_ESB_calls__c, Disable_ESB_automatic_updates__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(u.Disable_ESB_calls__c || u.Disable_ESB_automatic_updates__c)
            return;
        if(newContacts.size() == 1 && oldContacts.size() == 1)
        {
            // make sure, that contact is already managed by WKTS admin, and not just sent there
            string oldId = oldContacts[0].ESB_BuisnessID__c;
            string newId = newContacts[0].ESB_BuisnessID__c;
            if(string.isNotEmpty(oldId) && string.isNotEmpty(newId))
            {
                string status = newContacts[0].ESB_User_status__c;
                
                // we don't need to send updates if contact is deleted in WKTSA (status == suspended)
                if(status != 'SUSPENDED')
                {
                    if(ESB_ContactChanged(oldContacts[0], newContacts[0]))
                        ESB_Proxy.UpdateSuperUser(newContacts[0].Id);
                }
            }
        }
    }
    
    /**
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2015 January 21
    * @description  we need to know if ESB-related information is changed to not send unneeded updates
    */
    private boolean ESB_ContactChanged(Contact oldCont, Contact newCont)
    {
        List<string> fieldsToSync = new List<string> { 'Name', 'Email', 'MobilePhone', 'Phone', 'Fax',
                'Is_Visible__c', 'Language__c', 'Time_Zone__c', 'Username__c',
                'Gender__c', 'FirstName', 'LastName', 'AccountID' };
        boolean isChanged = false;
        
        for(string field : fieldsToSync)
            isChanged |= (oldCont.get(field) != newCont.get(field));
        
        return isChanged;
    } //ESB_ContactChanged
    
    /**
    * @author       Anton Soloveyv (anton_soloveyv@epam.com)
    * @date         2014 September 5
    * @description  Validation of phone number format and validity of country code. Moved to trigger since we need capability to quickly add new phone code
    *               using validation rules we can't do so because of many occurences.
    */
    private void ValidatePhones(List<Contact> contacts)
    {
        Set<integer> validCountryCodes = new Set<Integer>();
        for(Country_Parameters__c cp : [SELECT Name, Phone_code__c FROM Country_Parameters__c])
            validCountryCodes.add(integer.valueOf(cp.Phone_code__c));
        
        for(Contact c : contacts)
        {
            if(string.isNotEmpty(c.Phone))
                if(!Utilities.ValidatePhone(c.Phone, validCountryCodes))
                    c.Phone.addError(Utilities.getPhoneValidationErrorMessage());
            if(string.isNotEmpty(c.Fax))
                if(!Utilities.ValidatePhone(c.Fax, validCountryCodes))
                    c.Fax.addError(Utilities.getPhoneValidationErrorMessage());
            if(string.isNotEmpty(c.MobilePhone))
                if(!Utilities.ValidatePhone(c.MobilePhone, validCountryCodes))
                    c.MobilePhone.addError(Utilities.getPhoneValidationErrorMessage());
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
                    
                    To detect Clonned contacts (after pressing Clone button on layout) we will do following:
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
    private void ProcessClonnedContacts(List<Contact> contacts)
    {
        for(Contact c : contacts)
        {
            if(c.ClonnedFlag__c == true)
            {
                // action will be performed on clonned accounts only
                c.ESB_User_status__c = '';
                c.ESB_BuisnessID__c = '';
            }
            c.ClonnedFlag__c = true;
        }
    } //ProcessClonnedContacts
    
    
     /**
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2015 April 2
    * @description  Sync User Language with Contact Language
    * @WKTSCRM-1903 JIRA TASK              
    */
    private void Update_CommunityUsers_Language (Map<ID, sObject> oldContactsMap, Map<ID, sObject> newContactsMap)
    {
        List<Id> contIds = New List<Id>();
        for(Id currContId: newContactsMap.keySet()){
            Contact oldCont = (Contact)oldContactsMap.get(currContId);
            Contact newCont = (Contact)newContactsMap.get(currContId);
            if(oldCont.Language__c != newCont.Language__c) contIds.add(currContId);
        }
        List<User> relatedUsr = [ SELECT Id, Profile.Id, Contact.Id, LanguageLocaleKey 
                                    FROM User 
                                   WHERE Contact.Id IN:contIds 
                                     AND Profile.Id IN:TLR_UserLanguageHelper.COMMUNITY_PROFILE_IDS ]; 
        Map<Id, User> mapCont2User = New Map<Id, User>{};
        for(User currUsr:relatedUsr)
        {
            mapCont2User.put(currUsr.Contact.Id,currUsr);
        }                                     
        List<User> usr2Update = New List<User>();                                   
        for(Id currContId:contIds) 
        {
            Contact currCont = (Contact)newContactsMap.get(currContId);
            User currUsr = mapCont2User.get(currContId);           
           if(currUsr != NULL)
           {
                string locale = TLR_UserLanguageHelper.getLocaleFromContact(currCont.Language__c);
	            if(locale != currUsr.LanguageLocaleKey)
	            {
	                currUsr.LanguageLocaleKey = locale;
	                usr2Update.add(currUsr); 
	            }    
            }
        }
        if(!usr2Update.isEmpty())
        {
            update(usr2Update);
        }
   
    }// end Update_CommunityUsers_Language
    
    /**
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         2016 June 2
* @description  Creation of DMS community user from Contact 
*/
    private void StartDMSUsersAutomaticOperation(List<Contact> newTriggerValues, Map<ID, sObject> newTriggerValuesMap)
    {
        Map<Id, Contact> contactsMap = (Map<Id, Contact>)newTriggerValuesMap;
        Set<Id> contactsSetForCreation = new Set<Id>();
        Set<Id> contactsSetForDeactivation = new Set<Id>();
        Set<Id> contactsSetForActivation = new Set<Id>();
        Map<Id,ID> accsContsMap = new Map<Id,ID>();
        Set<Id> accsSet = new Set<Id>();
        List<Subs_Current_Fee__c> scfs = new List<Subs_Current_Fee__c>();
        
        try
        {
            for(Contact cont : newTriggerValues)
            {
                if(cont.Username__c != null
                   && cont.ESB_User_status__c == 'ready'
                   && cont.Admin_Products__c != null 
                   && cont.Admin_Products__c.contains('TFX'))
                {
                    accsContsMap.put(cont.Id, cont.AccountId);  
                }
                else
                {
                    if(cont.Is_Community_User__c && cont.Is_Community_User_Active__c && (cont.Username__c == null
                                                                                         || cont.ESB_User_status__c != 'ready' 
                                                                                         || cont.Admin_Products__c == null 
                                                                                         || !cont.Admin_Products__c.contains('TFX')))
                    {
                        contactsSetForDeactivation.add(cont.Id);
                    }
                }
            }    
            scfs = [Select Id, Account__c
                    From Subs_Current_Fee__c 
                    Where Account__c =: accsContsMap.values()
                    And Name = 'DMS_approved' 
                    And Subscription__r.Status__c IN ('Active', 'On Notice')
                    And Start_Date__c <= TODAY 
                    And (End_Date__c > TODAY OR End_Date__c = null)];    
            
            for(Subs_Current_Fee__c scf : scfs)
            {
                accsSet.add(scf.Account__c);
            }
                       
            for(Id contId : accsContsMap.keySet())
            {
                if(accsSet.contains(accsContsMap.get(contId)))
                {
                    if(!contactsMap.get(contId).Is_Community_User__c)
                    {
                        contactsSetForCreation.add(contId);
                    }
                    else
                    {
                        if(!contactsMap.get(contId).Is_Community_User_Active__c)
                        {
                            contactsSetForActivation.add(contId);
                        }
                    }
                }
                else
                {
                    if(contactsMap.get(contId).Is_Community_User__c && contactsMap.get(contId).Is_Community_User_Active__c)
                    {
                        contactsSetForDeactivation.add(contId);
                    }
                }
            }
            
            if(contactsSetForCreation.size() > 0)
                {
                    TLR_ContactHelper.CreateDMSUsers(contactsSetForCreation, true);
                }
                if(contactsSetForDeactivation.size() > 0)
                {
                    System.enqueueJob(new TLR_ContactHelper.QueueableActivateOrDeactivateDMSUsers(contactsSetForDeactivation));
                }
                if(contactsSetForActivation.size() > 0)
                {
                    System.enqueueJob(new TLR_ContactHelper.QueueableActivateOrDeactivateDMSUsers(contactsSetForActivation));
                }
        }
        catch(Exception e)
        {
            
            TLR_SendEmailHelper.SendEmail(false, 'An error occured during DMS Community user automatic operation or deactivation triggered by Contact update. ' 
                                          + 'Ids of Contacts for creation: ' + contactsSetForCreation
                                          + '. Ids of Contacts for deactivation: ' + contactsSetForDeactivation
                                          + '. Ids of Contacts for activation: ' + contactsSetForActivation
                                          + '. Error message: ' + e.getMessage()+ '. Stack trace: '+e.getStackTraceString(), 
                                          'Salesforce', 'Error during DMS Community Users automatic operation', TLR_ContactHelper.developersAddresses, null, null, 'noreply@salesforce.com');
        }
    }// end CreateDMSUsers
    
    
    
    private void ValidateLanguage(List<Contact> contacts)
    {
        String UserName = UserInfo.getName();
        if(!UserName.startsWith('ESB'))
        {
            for(Contact c : contacts)
            {
                if(!Utilities.ValidateLanguage(c.Language__c))
                {
                    c.Language__c.addError('"'+c.Language__c+'" is invalid value for language. Choose value from the picklist');
                }
            }
        }
    }// end ValidateLanguage    
	
	/**
    * @author       Andrey Nagurny (andrey_nagurny@epam.com)
    * @date         2016 September 2
    * @description  WKTSCRM-2683 Block editing Contact in status 'CREATED' JIRA TASK
    */
    private void BlockEditingContacIfESBUserStatusCREATED(List<Contact> contacts)
    {
		String UserName = UserInfo.getName();
        if(!UserName.equalsIgnoreCase('ESB CM'))
        {
            for(Contact c : contacts)
            {
                if (String.isNotBlank(c.ESB_User_status__c) && c.ESB_User_status__c.equalsIgnoreCase('CREATED'))
                {
                    c.addError('This company was invited from CM. You don\'t allowed to update contact until sending of Provisioning message');
                }
            }
        }
        
    } // end BlockEditingContacIfESBUserStatusCREATED
    
    
}