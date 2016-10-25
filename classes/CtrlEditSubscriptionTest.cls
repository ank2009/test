/**
 * @author Nicolas Dolet
 * @date 19/12/2011
 * @description Test CtrlEditSubscription controller
 */
@isTest
public class CtrlEditSubscriptionTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        
        List<ID> servIds = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(servIds, false, true);
        Contract contr = TestData.createTestContract(acc.Id);
        Subscription__c subs = TestData.createTestSubscription(prod.Id, contr.Id);
        
        // Page preparation
        PageReference pageRef = Page.EditSubscription;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', subs.Id);
        
        CtrlEditSubscription controller = new CtrlEditSubscription(new ApexPages.StandardController(subs));
        
        // Test correct save
        String correctSave = controller.save().getUrl();
        System.assertEquals('/' + subs.Id, correctSave);
                
        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + subs.Id, cancelPage);
        
        // Test incorrect save
        delete subs;
        System.assertEquals(null, controller.save());
        
    }

}