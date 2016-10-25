/**
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         2016 June 02
* @description  Helper class for Contact object
**/
public class TLR_ContactHelper 
{
    public static final List<string> developersAddresses = new List<string> { 'andrei_lobkis@epam.com', 'Andrey_Nagurny@epam.com'}; 
         
	public static  List<User> CreateDMSUsers(Set<Id> contactsIds, boolean insertNow)
    {
        string errorMessage = '';
        List<User> users2Add = new List<User>();
        List<Contact> contacts = [Select Id, Name, Username__c, Language__c, ESB_User_status__c, 
                                  Email, Admin_Products__c, FirstName, LastName 
                                  From Contact 
                                  Where Id =: contactsIds];
        List<Contact> contactsForUsersCreation = new List<Contact>();
        Set<string> allUsernames = new Set<string>();
        Set<string> fedIdsFoundByUsernames = new Set<string>();
        List<User> usersHavingSameFedId = new List<User>();
        Map<string,Set<Id>> duplicateUsernamesContactsMap = new Map<string,Set<Id>>();
        Map<string,Id>  fedIdsFoundByUsernameContactsMaps = new Map<string,Id>();
         
        if(contacts.size() == 0)
        {
            return users2Add;
        }
        
        for(Contact cont : contacts)
        {
            if(allUsernames.contains(cont.Username__c))
            {
                duplicateUsernamesContactsMap.put(cont.Username__c, new Set<Id>());
            }
            else
            {
                allUsernames.add(cont.Username__c);
            }
        }
        usersHavingSameFedId = [select Id, Name, FederationIdentifier from User where FederationIdentifier =: allUsernames];
        
        if(usersHavingSameFedId.size() > 0)
        {
            for(User currUser : usersHavingSameFedId)
            {
                fedIdsFoundByUsernameContactsMaps.put(currUser.FederationIdentifier, null);
            }
        }
        
        for(Contact cont : contacts)
        {
            if(!duplicateUsernamesContactsMap.containsKey(cont.Username__c) 
               && !fedIdsFoundByUsernameContactsMaps.containsKey(cont.Username__c))
            {
                contactsForUsersCreation.add(cont);
            }
            else
            {
                if(duplicateUsernamesContactsMap.containsKey(cont.Username__c))
                {
                    duplicateUsernamesContactsMap.get(cont.Username__c).add(cont.Id);
                }
                if(fedIdsFoundByUsernameContactsMaps.containsKey(cont.Username__c))
                {
                    fedIdsFoundByUsernameContactsMaps.put(cont.Username__c, cont.Id);
                }
            }
        }
        
        string DmsProfileId = General_Settings__c.getValues('Default').DMS_Community_User_Profile_Id__c; 
        for(Contact cont : contactsForUsersCreation)
        {
            User u = new User();
            string lastNameSubstr = (cont.LastName.length() >= 3) ? cont.LastName.substring(0,3) : cont.LastName;
            u.Email = cont.Email;
            u.ProfileId = DmsProfileId;                
            u.UserName = cont.Email + '.' + cont.Username__c; 
            if(String.isNotEmpty(cont.FirstName))
            {
                u.Alias = cont.FirstName.substring(0,1) + lastNameSubstr;                  
            }
            else
            {
                u.Alias = lastNameSubstr;
            }
            u.Alias = u.Alias.ToLowerCase();
            u.LanguageLocaleKey = TLR_UserLanguageHelper.getLocaleFromContact(cont.Language__c);
            u.LocaleSidKey = TLR_UserLanguageHelper.getLocaleFromContact(cont.Language__c);
            u.ContactId = cont.Id;
            u.FirstName = cont.FirstName;
            u.LastName = cont.LastName;
            u.EmailEncodingKey = 'ISO-8859-1';
            u.TimeZoneSidKey = 'Europe/Brussels';
            u.FederationIdentifier = cont.Username__c;
            users2Add.add(u);                      
        }
        
        if(insertNow && users2Add.size() > 0)
        {
            insert users2Add;
        }
        
        if(duplicateUsernamesContactsMap.keySet().size() > 0)
        {
            errorMessage += 'Duplicate usernames have been found among Contacts ready for DMS users creation: \n';

            for(string username : duplicateUsernamesContactsMap.keySet())
            {
                errorMessage += '     For Username = ' +username+ ' there are Contacts with Ids: ' + duplicateUsernamesContactsMap.get(username) + '\n';
            }
        }
        if(usersHavingSameFedId.size() > 0)
        {
            errorMessage += 'There are Users that already have Federation Ids equal to Usernames of some Contacts ready for Users creation: \n';
            
            for(User currUser : usersHavingSameFedId)
            {
                errorMessage += '     ' + currUser + 'has Federation Id that equals ';
                if(duplicateUsernamesContactsMap.containsKey(currUser.FederationIdentifier))
                {
                    errorMessage += 'Usernames of Contacts with Ids: ' + duplicateUsernamesContactsMap.get(currUser.FederationIdentifier) + '\n';
                }
                else
                {
                    errorMessage += 'Username of Contact with Id: ' + fedIdsFoundByUsernameContactsMaps.get(currUser.FederationIdentifier) + '\n';
                }
            }
        }
        if(string.isNotBlank(errorMessage))
        {
            TLR_SendEmailHelper.SendEmail(false, errorMessage
                                          , 'Salesforce', 'Error during DMS Community Users creation', developersAddresses, null, null, 'noreply@salesforce.com');
        }
        return users2Add;
    }
    
    public static void CreateDMSUsersForAccount(Id AccId, boolean hasDMSFee)
    {
        Set<Id> contactsSetForCreation = new Set<Id>();
        Set<Id> contactsSetForDeactivation = new Set<Id>();
        Set<Id> contactsSetForActivation = new Set<Id>();
        try
        {
            Map<Id,Contact> contactsMap = new Map<Id,Contact>([Select Id, ESB_User_status__c, Admin_Products__c, Username__c, Is_Community_User__c, Is_Community_User_Active__c 
                                                               From Contact 
                                                               Where AccountId =: AccId ]);
            
            if(contactsMap.size() > 0)
            {     
                if(!hasDMSFee)
                {
                    for(Contact cont : contactsMap.values())
                    {
                        if(cont.Is_Community_User__c && cont.Is_Community_User_Active__c)
                        {
                            contactsSetForDeactivation.add(cont.Id);
                        }
                    }
                }
                else
                {
                    for(Contact cont : contactsMap.values())
                    {
                        if(cont.ESB_User_status__c == 'Ready' && cont.Username__c != null && cont.Admin_Products__c != null && cont.Admin_Products__c.contains('TFX'))
                        {
                            if(!cont.Is_Community_User__c)
                            {
                                contactsSetForCreation.add(cont.Id);
                            }
                            else
                            {
                                if(!cont.Is_Community_User_Active__c)
                                {
                                    contactsSetForActivation.add(cont.Id);
                                }
                            }
                        }
                        else
                        {
                            if(cont.Is_Community_User__c && cont.Is_Community_User_Active__c)
                            {
                                contactsSetForDeactivation.add(cont.Id);
                            }
                        }
                    }
                }
                
                if(contactsSetForCreation.size() > 0)
                {
                    CreateDMSUsers(contactsSetForCreation, true);
                }
                if(contactsSetForDeactivation.size() > 0)
                {
                    System.enqueueJob(new QueueableActivateOrDeactivateDMSUsers(contactsSetForDeactivation));
                }
                if(contactsSetForActivation.size() > 0)
                {
                    System.enqueueJob(new QueueableActivateOrDeactivateDMSUsers(contactsSetForActivation));
                }
            }
           
        }
        catch(Exception e)
        {
            TLR_SendEmailHelper.SendEmail(false, 'An error occured during DMS Community user automatic operation triggered by Subscription Current Fee ' 
                                          + 'insert or Subscription activation. '
                                          + 'Ids of Contacts for creation: ' + contactsSetForCreation
                                          + '. Ids of Contacts for deactivation: ' + contactsSetForDeactivation
                                          + '. Ids of Contacts for activation: ' + contactsSetForActivation
                                          + '. Error message: ' + e.getMessage()+ '. Stack trace: '+e.getStackTraceString()
                                          , 'Salesforce', 'Error during DMS Community Users automatic operation', developersAddresses, null, null, 'noreply@salesforce.com');
        }
    }
        
    public class QueueableActivateOrDeactivateDMSUsers implements Queueable 
    {
        Set<Id> contactsIds;
        
        public QueueableActivateOrDeactivateDMSUsers(Set<Id> contactsIds) 
        {
     		this.contactsIds = contactsIds;
        }
        public void execute(QueueableContext context) 
        {
            string DmsProfileId = General_Settings__c.getValues('Default').DMS_Community_User_Profile_Id__c;
            List<User> usersToUpdate = [select Id, IsActive from User where ContactId =: contactsIds and ProfileId =: DmsProfileId];
            for(User u : usersToUpdate)
            {
                u.IsActive = !u.IsActive;
            }
            try
            {
                update usersToUpdate;
            }
            catch(Exception e)
            {
                TLR_SendEmailHelper.SendEmail(false, 'An error occured during DMS Community user automatic operation. ' 
                                              + 'Users for activation/deactivation: ' + usersToUpdate
                                              + '. Error message: ' + e.getMessage()+ '. Stack trace: '+e.getStackTraceString(), 
                                              'Salesforce', 'Error during DMS Community Users automatic operation', TLR_ContactHelper.developersAddresses, null, null, 'noreply@salesforce.com');
            }
        }
    }
    
    public class QueueableUpdateUserActiveFlagOnContact implements Queueable 
    {
        List<User> updatedUseres;
        
        public QueueableUpdateUserActiveFlagOnContact(List<User> updatedUseres) 
        {
     		this.updatedUseres = updatedUseres;
        }
        public void execute(QueueableContext context) 
        {
            List<Contact> contacts = new List<Contact>();
            for (User u : updatedUseres)
            {
                contacts.add(new Contact(Id = u.ContactId, Is_Community_User_Active__c = u.IsActive) );
            }    
            try
            {
                update contacts;    
            }
            catch(Exception e)
            {
                TLR_SendEmailHelper.SendEmail(false, 'An error occured during DMS Community user automatic operation. ' 
                                              + 'Contacts for update after activation/deactivation of user: ' + contacts
                                              + '. Error message: ' + e.getMessage()+ '. Stack trace: '+e.getStackTraceString(), 
                                              'Salesforce', 'Error during DMS Community Users automatic operation', TLR_ContactHelper.developersAddresses, null, null, 'noreply@salesforce.com');
            }
        }
    }
}