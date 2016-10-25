@IsTest
   /**
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2015 January 05
    * @description  test resend ESB_Interaction_Log record
    **/    
    private class ESB_interactionLog_ControllerTest{
        static testMethod void resendESBlogTest(){
            FXSettings__c settings = New FXSettings__c();
            settings.Name='FXSettings';
            settings.ESB_Url__c = 'https://test.tt';
            settings.ESB_Certificate_name__c = 'testCertName';         
            settings.Company_Directory_ESB_WSDL__c='111'; 
            settings.Forward_Code_of_Conduct_Url__c='222'; 
            settings.SSP_Partial_Registration_URL__c='333'; 
            settings.User_Repository_ESB_WSDL__c='444';
            insert settings;

            ESB_Interaction_Logs__c logRecord = New ESB_Interaction_Logs__c(Body__c = 'abcdefg',
                                                                            Message_direction__c = 'Outgoing', 
                                                                            Message_type__c = 'cm.company.approve', 
                                                                            ESB_response_status__c= 0);
            insert logRecord;                                                                           
            Test.startTest();  
            ApexPages.StandardController sc = new ApexPages.StandardController(logRecord);                  
            PageReference pageRef = Page.ESB_Interaction_Log;
            pageRef.getParameters().put('id', String.valueOf(logRecord.Id));
            Test.setCurrentPage(pageRef);
            ESB_interactionLog_Controller extController = new ESB_interactionLog_Controller(sc);                                  
            extController.reSendESBLog();
            extController.Exit();
            Test.stopTest();
                                                   }
}//end test class