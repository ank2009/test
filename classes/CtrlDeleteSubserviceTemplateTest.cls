/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlDeleteSubserviceTemplate
 */
@isTest
public class CtrlDeleteSubserviceTemplateTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        Service__c s1 = TestData.createTestService();
        Subservice_Template__c subsTpl1 = [SELECT Id FROM Subservice_Template__c WHERE Parent_Service__c =: s1.Id];
        s1.Status__c = 'On Notice';
        update s1;
        s1.Status__c = 'Inactive';
        update s1;
        s1.Status__c = 'Pending';
        update s1;

        Service__c s2 = TestData.createTestService();
        Subservice_Template__c subsTpl2 = [SELECT Id FROM Subservice_Template__c WHERE Parent_Service__c =: s2.Id];
        s2.Status__c = 'On Notice';
        update s2;
        s2.Status__c = 'Inactive';
        update s2;
        s2.Status__c = 'Pending';
        update s2;

        Service__c s3 = TestData.createTestService();
        Subservice_Template__c subsTpl3 = [SELECT Id FROM Subservice_Template__c WHERE Parent_Service__c =: s3.Id];

        
        // Page preparation
        PageReference pageRef = Page.DeleteSubserviceTemplate;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', subsTpl1.Id);
        ApexPages.currentPage().getParameters().put('retID', s1.Id);
        
        CtrlDeleteSubserviceTemplate controller = new CtrlDeleteSubserviceTemplate(new ApexPages.StandardController(subsTpl1));
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + s1.Id, cancelPage);

        // Test correct init
        String correctDelete = controller.init().getUrl();
        System.assertEquals('/' + s1.Id, correctDelete);

        // Test exception
        ApexPages.currentPage().getParameters().put('id', subsTpl2.Id);
        controller = new CtrlDeleteSubserviceTemplate(new ApexPages.StandardController(subsTpl2));
        delete subsTpl2;
        System.assertEquals(null, controller.init());

        // Test bad init
        ApexPages.currentPage().getParameters().put('id', subsTpl3.Id);
        controller = new CtrlDeleteSubserviceTemplate(new ApexPages.StandardController(subsTpl3));
        System.assertEquals(null, controller.init());
                
        Test.stopTest();
        
    }

}