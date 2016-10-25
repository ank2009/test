/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlDeleteServiceAttributeTemplate
 */
@isTest
public class CtrlDeleteServiceAttributeTemplateTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        Service__c s = TestData.createTestService();
        Service_Attribute_Template__c sat = TestData.createServiceAttributeTemplate(s);
        s.Status__c = 'On Notice';
        update s;
        s.Status__c = 'Inactive';
        update s;
        s.Status__c = 'Pending';
        update s;
        
        // Page preparation
        PageReference pageRef = Page.DeleteServiceAttributeTemplate;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', sat.Id);
        ApexPages.currentPage().getParameters().put('retID', s.Id);
        
        CtrlDeleteServiceAttributeTemplate controller = new CtrlDeleteServiceAttributeTemplate(new ApexPages.StandardController(sat));
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + s.Id, cancelPage);

        // Test correct init
        String correctDelete = controller.init().getUrl();
        System.assertEquals('/' + s.Id, correctDelete);

        // Test exception
        Service_Attribute_Template__c sat2 = TestData.createServiceAttributeTemplate(s);
        ApexPages.currentPage().getParameters().put('id', sat2.Id);
        controller = new CtrlDeleteServiceAttributeTemplate(new ApexPages.StandardController(sat2));
        delete sat2;
        System.assertEquals(null, controller.init());

        // Test bad init
        Service_Attribute_Template__c sat3 = TestData.createServiceAttributeTemplate(s);
        s.Status__c = 'Active';
        update s;
        ApexPages.currentPage().getParameters().put('id', sat3.Id);
        controller = new CtrlDeleteServiceAttributeTemplate(new ApexPages.StandardController(sat3));
        System.assertEquals(null, controller.init());
                
        Test.stopTest();
                
    }

}