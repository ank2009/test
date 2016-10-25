/**
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         2016 April 27
* @description  Schedulable Batch process for checking Contacts data quality
**/
global class CheckContactsDataQualityBatch  implements Database.Batchable<sObject>
{
    global final string query = 'select Id, Phone, MobilePhone, Fax, Data_Quality__c, Language__c from Contact';  
    User currentUser = [select Id, Disable_All_Triggers__c, Disable_Validation_Rules_and_Workflows__c from User where Id =: UserInfo.getUserId()];
    Set<integer> validCountryCodes = new Set<Integer>();
    boolean Disable_All_Triggers = currentUser.Disable_All_Triggers__c;
    boolean Disable_Validation_Rules_and_Workflows = currentUser.Disable_Validation_Rules_and_Workflows__c;
    List<Contact> contactsToUpdate;
    
    public CheckContactsDataQualityBatch()
    {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        currentUser.Disable_All_Triggers__c = true;
        currentUser.Disable_Validation_Rules_and_Workflows__c = true;
        update currentUser;
        return DataBase.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {   
        for(Country_Parameters__c cp : [SELECT Name, Phone_code__c FROM Country_Parameters__c])
            validCountryCodes.add(integer.valueOf(cp.Phone_code__c));
        contactsToUpdate = new List<Contact>();
        for(Contact currContact : scope)    
        {
            ValidatePhones(currContact);
            ValidateLanguage(currContact);
            if(!string.isEmpty(currContact.Data_Quality__c))
            {
                contactsToUpdate.add(currContact);
            }
        }
        if(contactsToUpdate.size() > 0)
		{
			update contactsToUpdate;
		}
    }
    
    global void finish(Database.BatchableContext BC)
    {
        currentUser.Disable_All_Triggers__c = Disable_All_Triggers;
        currentUser.Disable_Validation_Rules_and_Workflows__c = Disable_Validation_Rules_and_Workflows;
        update currentUser;
    }    
    
    private void validatePhones(Contact cont)
    {
        string phoneValidationError = Utilities.getPhoneValidationErrorMessage();
        if(string.isNotEmpty(cont.Phone))
            if(!Utilities.ValidatePhone(cont.Phone, validCountryCodes))
            addErrorMessage(cont,'Phone: '+phoneValidationError);
        if(string.isNotEmpty(cont.Fax))
            if(!Utilities.ValidatePhone(cont.Fax, validCountryCodes))
            addErrorMessage(cont,'Fax: '+phoneValidationError);
        if(string.isNotEmpty(cont.MobilePhone))
            if(!Utilities.ValidatePhone(cont.MobilePhone, validCountryCodes))
            addErrorMessage(cont,'Mobile: '+phoneValidationError);
    }
    
    private void ValidateLanguage(Contact cont)
    {
        if(!Utilities.ValidateLanguage(cont.Language__c))
        {
            addErrorMessage(cont,'Language: "'+cont.Language__c+'" is invalid value for language. Choose value from the picklist');
        }
    }
    
    private void addErrorMessage(Contact cont, string errorMessage)
    {
        if(string.isEmpty(cont.Data_Quality__c))
        {
            cont.Data_Quality__c = errorMessage;
        }
        else
        {
            cont.Data_Quality__c += '\n'+errorMessage;
        }
    }
}