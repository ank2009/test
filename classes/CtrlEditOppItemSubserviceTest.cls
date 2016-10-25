/**
 * @author Nicolas Dolet
 * @date 19/12/2011
 * @description Test EditOppItemSubservice controller
 */
@isTest
public class CtrlEditOppItemSubserviceTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        List<Opportunity_Line_Item__c> oppLI = TestData.createTestOpportunityWithLI(acc.Id, 1);
        Opp_Item_Subservice__c oppItemSubservice = TestData.createOppItemSubservice(oppLI[0]);
        
        // Page preparation
        PageReference pageRef = Page.EditOppItemSubservice;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', oppItemSubservice.Id);
        ApexPages.currentPage().getParameters().put('retURL', '/' + oppLI[0].Id);
        
        CtrlEditOppItemSubservice controller = new CtrlEditOppItemSubservice(new ApexPages.StandardController(oppItemSubservice));
        
        // Test correct save
        String correctSave = controller.save().getUrl();
        System.assertEquals('/' + oppItemSubservice.Id, correctSave);
                
        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + oppItemSubservice.Id, cancelPage);
        
        // Test incorrect save
        delete oppItemSubservice;
        System.assertEquals(null, controller.save());
        
    }

}