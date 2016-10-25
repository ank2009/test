/**
 * @author AK
 * @date 26/12/2011
 */
@isTest
public class CreateSubserviceExtTest{

    public static testMethod void testCreateSubserviceExt() {
    Test.startTest(); 
    Service__c service = TestData.createTestService();
    Subservice_Template__c SubTemp = [SELECT Id, Name FROM Subservice_Template__c  WHERE Parent_Service__c =: service.Id];
    
    // Page preparation
    PageReference pageRef=Page.CreateSubservice;
    Test.setCurrentPage(pageRef);
        
    CreateSubserviceExt controller = new CreateSubserviceExt(new ApexPages.StandardController(SubTemp));
    
    // init() 
    controller.init();
    
    // Test save
    String savePage= controller.save().getUrl();
    System.AssertEquals('/'+SubTemp.Id,savePage);
    //
    controller.getSub();
    // Test saveandNew
    controller = new CreateSubserviceExt(new ApexPages.StandardController(SubTemp));
    // init() 
    controller.init();
    String saveandnewPage= controller.SaveAndNew().getUrl();
    System.AssertEquals('/apex/CreateSubservice?id='+SubTemp.Id,saveandnewPage);

    // Test cancel
    String cancelPage = controller.Cancel().getUrl();
    System.AssertEquals('/'+SubTemp.Id, cancelPage);

    Test.stopTest();
    
    }
}