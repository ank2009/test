@isTest
private class testTR001 {

     static testMethod void testupdateSubserviceParent() {
        
        PAD.myLog('START TR001.testupdateSubserviceParent');
        Boolean active=true;
        Id pSystemAdminId = [Select Id, Name from Profile where Name = 'System Administrator' Or Name = 'Administrateur système'].Id;
         User uAdmin = [Select Id,LastName FROM User where ProfileId =: pSystemAdminId and IsActive=: active limit 1];
                      
               System.runAs(uAdmin)
               {
           //record context
           Service__c S = new Service__c(Name = 'Service1', Start_Date__c = Date.today(), Status__c = 'Pending');
           S.RecordTypeId = TestData.getServiceRecordType();
           insert S;
       Subservice_Template__c  Subst = new Subservice_Template__c(Name = 'Subservice Template1', Start_Date__c = Date.today(), Parent_Service__c = S.Id) ;
       Subst.RecordTypeId = TestData.getSubsTplRecordType();
       insert Subst;                     
       Subservice__c  Subs = new Subservice__c(Name = 'Subservice1', Start_Date__c = Date.today(), Status__c = 'Pending') ;
       Subs.RecordTypeId = TestData.getSubserviceRecordType();
        insert Subs;
        Subservice_Template_Line_Item__c Substli = new Subservice_Template_Line_Item__c(Template__c = Subst.Id, Subservice__c = Subs.Id);
        Substli.RecordTypeId = TestData.getSubsTplLIRecordType();
        
        //end record context
        //Start test (declencher trigger)
        PAD.myLog('Start Test');    
        Test.startTest();
            insert Substli;
        Test.stopTest();
        PAD.myLog('End Test'); 
        //End test
        //Verification
        Subservice__c SubsTest = [Select Id, Parent_Service__c  From Subservice__c Where Id=:Subs.Id Limit 1];
        System.assertEquals(SubsTest.Parent_Service__c,S.Id);
         }
        PAD.myLog('END TR001.testupdateSubserviceParent');
      
    }
}