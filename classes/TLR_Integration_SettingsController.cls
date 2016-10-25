global with sharing class TLR_Integration_SettingsController{
/**
* @author       Aleh Tsilko (aleh_tsilko@epam.com)
* @date         2015 January 09
* @description  Controller for Integration settings page in AdminApp custom application
**/

    private static final string FXSETTINGS_RECORDNAME='FXSettings';
    private static final string GENERALSETTINGS_RECORDNAME='Default';
    private static final string SIMSETTINGS_RECORDNAME='SIMSettings';
    private static final string URLSETTINGS_RECORDNAME1='Qualif v1';
    private static final string URLSETTINGS_RECORDNAME2='Qualif v2';    
    
    private list<sObject> settingsList = New List<sObject>();
    
    public FXSettings__c FXSetting {get; set;}
    public General_Settings__c General_Setting {get; set;}   
    public SIMSettings__c SIMSetting {get; set;}                                                                                                                       
    public STATIC_URLS__c STATIC_URL1 {get; set;}
    public STATIC_URLS__c STATIC_URL2 {get; set;} 
                                          
    public TLR_Integration_SettingsController(){
    
        FXSetting = [SELECT Id,
                           Name, 
                           ESB_Url__c,
                           ESB_Certificate_name__c,
                           WKTS_Bridge_Profile__c,
                           Bridge_certificate_name__c,
                           Company_Directory_ESB_WSDL__c,
                           User_Repository_ESB_WSDL__c,
                           Forward_Code_of_Conduct_Url__c,
                           SSP_Partial_Registration_URL__c,
                           Proxy_ESB_Certificate__c
                      FROM FXSettings__c     
                     WHERE Name =: FXSETTINGS_RECORDNAME][0];
        
        General_Setting = [SELECT Id,
                                  Name, 
                                  ESB_Dual_provisioning_enabled__c
                             FROM General_Settings__c     
                            WHERE Name =: GENERALSETTINGS_RECORDNAME][0];  
                            
        SIMSetting = [SELECT Id,
                             Name, 
                             Approval_Process_Name__c,
                             Forward_CoC_Process_Name__c,
                             SIMAuthURL__c,
                             SIMInstanceName__c,
                             SIMPassword__c,
                             SIMURL__c,
                             SIMUser__c,
                             Suspension_Process_Name__c,
                             TLR_Contact_List_Identifier__c,
                             TLR_Lead_List_Identifier__c
                        FROM SIMSettings__c     
                       WHERE Name =: SIMSETTINGS_RECORDNAME][0];        
                                    
        STATIC_URL1 = [SELECT Id,
                              Name, 
                              URL_ESB_Provisioning_v1__c,
                              URL_ESB_Provisioning_v2__c
                         FROM STATIC_URLS__c     
                        WHERE Name =: URLSETTINGS_RECORDNAME1][0];      

        STATIC_URL2 = [SELECT Id,
                              Name, 
                              URL_ESB_Provisioning_v1__c,
                              URL_ESB_Provisioning_v2__c
                         FROM STATIC_URLS__c     
                        WHERE Name =: URLSETTINGS_RECORDNAME2][0];      
                            
                                               }    
    
    public PageReference save() {
        settingsList.clear();
        settingsList.add(FXSetting);
        settingsList.add(General_Setting);
        settingsList.add(SIMSetting);        
        settingsList.add(STATIC_URL1);        
        settingsList.add(STATIC_URL2);
         try {
             update settingsList;
             } 
         catch(System.DMLException e) {
            ApexPages.addMessages(e);
                                      }                                      
        return null;
                                }
    
}