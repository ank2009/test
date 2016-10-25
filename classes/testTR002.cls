@isTest
private class testTR002 {

   static testMethod void testupdateServiceAttributeParent() {
        
        PAD.myLog('START TR002.testupdateServiceAttributeParent');
        Boolean active=true;
        Id pSystemAdminId = [Select Id, Name from Profile where Name = 'System Administrator' Or Name = 'Administrateur système'].Id;
         User uAdmin = [Select Id,LastName FROM User where ProfileId =: pSystemAdminId and IsActive=: active limit 1];
                      
               System.runAs(uAdmin)
               {
           //record context
           Service__c S = new Service__c(Name = 'Service1', Start_Date__c = Date.today(), Status__c = 'Pending');
           S.RecordTypeId = TestData.getServiceRecordType();
           insert S;
       Service_Attribute_Template__c  SAT = new Service_Attribute_Template__c(Name = 'Service attribut Template1', Start_Date__c = Date.today(), Parent__c = S.Id) ;
       SAT.RecordTypeId = TestData.getServAttrTplRecordType();
       insert SAT;                   
       Service_Attribute__c  SA = new Service_Attribute__c(Name = 'Service attribut1', Start_Date__c = Date.today(), Status__c = 'Pending') ;
        SA.RecordTypeId = TestData.getServAttrRecordType();
        insert SA;
        Service_Attribute_Template_Line_Item__c SATLI = new Service_Attribute_Template_Line_Item__c(Service_Attribute_Template__c = SAT.Id, Service_Attribute__c = SA.Id);
        SATLI.RecordTypeId = TestData.getServAttrTplLIRecordType();
        
        //end record context
        //Start test (declencher trigger)
        PAD.myLog('Start Test');    
        Test.startTest();
            insert SATLI;
        Test.stopTest();
        PAD.myLog('End Test'); 
        //End test
        //Verification
        Service_Attribute__c SATest = [Select Id, Parent__c  From Service_Attribute__c Where Id=:SA.Id Limit 1];
        System.assertEquals(SATest.Parent__c,S.Id);
         }
        PAD.myLog('END TR002.testupdateServiceAttributeParent');
      
    }
}