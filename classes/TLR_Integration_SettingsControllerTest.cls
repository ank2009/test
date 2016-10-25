@IsTest
   /**
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2015 January 12
    * @description  test resend ESB_Interaction_Log record
    **/    
    private class TLR_Integration_SettingsControllerTest{
    
        static testMethod void Integration_SettingsControllerTest(){
            TST_CustomSettingTestHelper.createFXSettings();
            TST_CustomSettingTestHelper.createStaticURLs();
            TST_CustomSettingTestHelper.createGeneralSettings();
            TST_CustomSettingTestHelper.createSIMSetting();
            Test.startTest(); 
            PageReference pageRef = Page.TLR_Integration_Settings;
            Test.setCurrentPage(pageRef);
            TLR_Integration_SettingsController controller = New TLR_Integration_SettingsController();
            controller.FXSetting.ESB_Url__c='changed url';
            controller.Save();
            Test.stopTest();
            FXSettings__c[] FXSetting = [SELECT id,
                                                Name, 
                                                ESB_Url__c
                                           FROM FXSettings__c 
                                           WHERE Name = 'FXSettings'];
            System.assertEquals('changed url', FXSetting[0].ESB_Url__c);
                                                                   }                                                                 
                                         
                                                         }