/**
 * @author Nicolas Dolet
 * @date 22/12/2011
 * @description Test CtrlDeleteSubserviceTemplateLI
 */
@isTest
public class CtrlDeleteSubserviceTemplateLITest {

    public static testMethod void testCtrl() {
    
        // Data generation
        Service__c s1 = TestData.createTestService();
        Subservice_Template__c subsTpl1 = [SELECT Id FROM Subservice_Template__c WHERE Parent_Service__c =: s1.Id];   
        Subservice_Template_Line_Item__c subsTplLI1 = [SELECT Id FROM Subservice_Template_Line_Item__c WHERE Subservice__r.Parent_Service__c =: s1.Id];
        s1.Status__c = 'On Notice';
        update s1;
        s1.Status__c = 'Inactive';
        update s1;
        s1.Status__c = 'Pending';
        update s1;

        Service__c s2 = TestData.createTestService();
        Subservice_Template__c subsTpl2 = [SELECT Id FROM Subservice_Template__c WHERE Parent_Service__c =: s2.Id];   
        Subservice_Template_Line_Item__c subsTplLI2 = [SELECT Id FROM Subservice_Template_Line_Item__c WHERE Subservice__r.Parent_Service__c =: s2.Id];
        s2.Status__c = 'On Notice';
        update s2;
        s2.Status__c = 'Inactive';
        update s2;
        s2.Status__c = 'Pending';
        update s2;

        Service__c s3 = TestData.createTestService();
        Subservice_Template__c subsTpl3 = [SELECT Id FROM Subservice_Template__c WHERE Parent_Service__c =: s3.Id];
        Subservice_Template_Line_Item__c subsTplLI3 = [SELECT Id FROM Subservice_Template_Line_Item__c WHERE Subservice__r.Parent_Service__c =: s3.Id];

        // Page preparation
        PageReference pageRef = Page.DeleteSubserviceTemplateLI;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', subsTplLI1.Id);
        ApexPages.currentPage().getParameters().put('retID', subsTpl1.Id);
        
        CtrlDeleteSubserviceTemplateLI controller = new CtrlDeleteSubserviceTemplateLI(new ApexPages.StandardController(subsTplLI1));
        
        Test.startTest();

        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + subsTpl1.Id, cancelPage);

        // Test correct init
        String correctDelete = controller.init().getUrl();
        System.assertEquals('/' + subsTpl1.Id, correctDelete);

        // Test exception
        ApexPages.currentPage().getParameters().put('id', subsTplLI2.Id);
        controller = new CtrlDeleteSubserviceTemplateLI(new ApexPages.StandardController(subsTplLI2));
        delete subsTplLI2;
        System.assertEquals(null, controller.init());

        // Test bad init
        ApexPages.currentPage().getParameters().put('id', subsTplLI3.Id);
        controller = new CtrlDeleteSubserviceTemplateLI(new ApexPages.StandardController(subsTplLI3));
        System.assertEquals(null, controller.init());
                
        Test.stopTest();
        
    }

}