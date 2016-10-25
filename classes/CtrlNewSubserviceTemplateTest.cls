/**
 * @author AK
 * @date 26/12/2011
 */
@isTest
public class CtrlNewSubserviceTemplateTest{

    public static testMethod void testCtrlNewSubserviceTemplate() {

    Test.startTest(); 
    Service__c service = TestData.createTestService();
        
    // Page preparation
    PageReference pageRef=Page.NewSubserviceTemplate;
    Test.setCurrentPage(pageRef);
        
    ApexPages.currentPage().getParameters().put('retURL', '/'+ service.Id);
    CtrlNewSubserviceTemplate controller = new CtrlNewSubserviceTemplate(new ApexPages.StandardController(service));
    
    // init() 
    controller.init();

    // Test save
    String savePage= controller.save().getUrl();
    String prefix  = Schema.SObjectType.Subservice_Template__c.getKeyPrefix();
    System.Assert(savePage.startsWith('/' + prefix));
    
    String cancelPage = controller.Cancel().getUrl();
    String prefix1  = Schema.SObjectType.Service__c.getKeyPrefix();
    System.Assert(cancelPage.startsWith('/' + prefix1));
   
    delete controller.subsTpl;
    System.assertEquals(null, controller.save());
        
    Test.stopTest();
        
    }
}