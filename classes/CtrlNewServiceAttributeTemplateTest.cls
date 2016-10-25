/**
 * @author AK
 * @date 26/12/2011
 */
@isTest
public class CtrlNewServiceAttributeTemplateTest{

    public static testMethod void testCtrlNewServiceAttributeTemplate() {

    Test.startTest();
    Service__c service = TestData.createTestService();
    Service_Attribute_Template__c serAttribute = TestData.createServiceAttributeTemplate(service);
    
    // Cover code of trigger before update
//    serAttribute.Name = 'Service Attribute Template Test';
    update serAttribute;
  
    // Page preparation
    PageReference pageRef=Page.NewServiceAttributeTemplate;
    Test.setCurrentPage(pageRef);
        
    ApexPages.currentPage().getParameters().put('retURL', '/'+ service.Id);
    CtrlNewServiceAttributeTemplate controller = new CtrlNewServiceAttributeTemplate (new ApexPages.StandardController(serAttribute));
    
        // init() 
    controller.init();

    // Test save
    String savePage= controller.save().getUrl();
    String prefix  = Schema.SObjectType.Service_Attribute_Template__c.getKeyPrefix();
    System.Assert(savePage.startsWith('/' + prefix));
    
    String cancelPage = controller.Cancel().getUrl();
    String prefix1  = Schema.SObjectType.Service__c.getKeyPrefix();
    System.Assert(cancelPage.startsWith('/' + prefix1));
    
    controller = new CtrlNewServiceAttributeTemplate (new ApexPages.StandardController(serAttribute));
    controller.init();
    controller.srvAttrTpl.Start_Date__c = Date.Today() - 1;
    //System.AssertEquals(null, controller.save());
    
    Test.stopTest();
        
    }
}