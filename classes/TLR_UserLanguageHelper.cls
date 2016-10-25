public without sharing class TLR_UserLanguageHelper
{     /**
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2015 April 2
    * @description  Helper for Sync User Language with Contact
    * @WKTSCRM-1903 JIRA TASK              
    */
    public static final Set<Id> COMMUNITY_PROFILE_IDS; 
    public static final Map<String, String> USER_LOCALE_ENABLED;
    public static final Set<String> CONTACT_LANG_ENABLED;
    public static final Map<String, String> USER_LANG_MAP;
    
    static 
    {
     // Query and cache community profile Ids
        COMMUNITY_PROFILE_IDS = New Set<Id>();
        Set<String> profileNames = New Set<String>();
        for(Community_Users_Profiles__c currProfileName: [SELECT Name FROM Community_Users_Profiles__c])
        {
            profileNames.add(currProfileName.Name);
        }   
        for(Profile currProfile: [SELECT Id FROM Profile WHERE Name IN:profileNames])
        {
            COMMUNITY_PROFILE_IDS.add(currProfile.Id);
        }
                
     //Query and cache possible User locales
       USER_LOCALE_ENABLED = New Map<String,String>(); 
            for(Schema.PicklistEntry currPLValue : User.LanguageLocaleKey.getDescribe().getPicklistValues())
            { 
                USER_LOCALE_ENABLED.put(currPLValue.getLabel(),currPLValue.getValue());
            }    
            
     //Query and cache possible Contact languages
       CONTACT_LANG_ENABLED = New Set<String>(); 
            for(Schema.PicklistEntry currPLValue : Contact.Language__c.getDescribe().getPicklistValues())
            { 
                CONTACT_LANG_ENABLED.add(currPLValue.getLabel());
            }    
            
     //Query and cache possible User languages
       USER_LANG_MAP = New Map<String,String>(); 
            for(Schema.PicklistEntry currPLValue : User.LanguageLocaleKey.getDescribe().getPicklistValues())
            { 
                USER_LANG_MAP.put(currPLValue.getValue(),currPLValue.getLabel());
            }     
                        
    }//static
    
    public static string getLocaleFromContact(String contLanguage)
    { 
        String retLocale;
        if(TLR_UserLanguageHelper.USER_LOCALE_ENABLED.containsKey(contLanguage))
        {
            retLocale = TLR_UserLanguageHelper.USER_LOCALE_ENABLED.get(contLanguage);
        }
        else
        {
            retLocale = 'En_US';
        }
        return retLocale;
    }//getLocaleFromContact
}