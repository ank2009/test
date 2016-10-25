/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlDeleteServiceAttributeTemplateLI
 */
@isTest
public class CtrlDeleteServiceAttributeTemplateLITest {

    public static testMethod void testCtrl() {
    
        // Data generation
        Service__c s = TestData.createTestService();
        Service_Attribute_Template__c sat = TestData.createServiceAttributeTemplate(s);        
        Service_Attribute__c sa = TestData.createTestServiceAttribute(s.Id);
        Service_Attribute_Template_Line_Item__c satli = TestData.createServiceAttributeTemplateLineItem(sa, sat);
        s.Status__c = 'On Notice';
        update s;
        s.Status__c = 'Inactive';
        update s;
        s.Status__c = 'Pending';
        update s;

        // Page preparation
        PageReference pageRef = Page.DeleteServiceAttributeTemplateLI;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', satli.Id);
        ApexPages.currentPage().getParameters().put('retID', sat.Id);
        
        CtrlDeleteServiceAttributeTemplateLI controller = new CtrlDeleteServiceAttributeTemplateLI(new ApexPages.StandardController(satli));
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + sat.Id, cancelPage);

        // Test correct init
        String correctDelete = controller.init().getUrl();
        System.assertEquals('/' + sat.Id, correctDelete);

        // Test exception
        Service_Attribute_Template_Line_Item__c satli2 = TestData.createServiceAttributeTemplateLineItem(sa, sat);
        ApexPages.currentPage().getParameters().put('id', satli2.Id);
        controller = new CtrlDeleteServiceAttributeTemplateLI(new ApexPages.StandardController(satli2));
        delete satli2;
        System.assertEquals(null, controller.init());

        // Test bad init
        Service_Attribute_Template_Line_Item__c satli3 = TestData.createServiceAttributeTemplateLineItem(sa, sat);
        s.Status__c = 'Active';
        update s;
        ApexPages.currentPage().getParameters().put('id', satli3.Id);
        controller = new CtrlDeleteServiceAttributeTemplateLI(new ApexPages.StandardController(satli3));
        System.assertEquals(null, controller.init());
        
        Test.stopTest();
                
    }

}