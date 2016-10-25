@isTest
public class CreateServiceAttrExtTest 
{
	public static testMethod void testCreateServiceAttrExt() 
	{
	    // Services
        Service__c service = TestData.createTestService();
        
        // Service Attributes Template
        Service_Attribute_Template__c ServAttrTpl = new Service_Attribute_Template__c();
        ServAttrTpl.Name = 'Test Service Attribute Template';
        ServAttrTpl.Parent__c = service.Id;
        ServAttrTpl.Start_Date__c = Date.Today();
        insert ServAttrTpl;
        
        Test.StartTest(); 
	    
	    // Page preparation
	    PageReference pageRef = Page.CreateServiceAttr;
	    Test.setCurrentPage(pageRef);
	        
	    CreateServiceAttrExt controller = new CreateServiceAttrExt(new ApexPages.StandardController(ServAttrTpl));
	    
	    // Init() 
	    controller.init();
	    System.AssertEquals(service.Id, controller.getServ().Parent__c);
	    
	    // Test Save
	    String savePage= controller.Save().getUrl();
	    System.AssertEquals('/' + ServAttrTpl.Id, savePage);
	    
	    // Test SaveAndNew
	    controller = new CreateServiceAttrExt(new ApexPages.StandardController(ServAttrTpl));
	    controller.init();
	    
	    String saveandnewPage = controller.SaveAndNew().getUrl();
	    System.AssertEquals('/apex/CreateServiceAttr?id=' + ServAttrTpl.Id, saveandnewPage);
	
	    // Test Cancel
	    String cancelPage = controller.Cancel().getUrl();
	    System.AssertEquals('/' + ServAttrTpl.Id, cancelPage);
	
	    Test.stopTest();
    }
}