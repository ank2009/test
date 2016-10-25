/**
 * @author Nicolas Dolet
 * @date 23/12/2011
 * @description Test EligibilityController
 */
@isTest
public class EligibilityControllerTest {

    public static testMethod void testCtrl() {
    
        // Data generation
        List<ID> services = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false);

        // Page preparation
        PageReference pageRef = Page.Eligibility;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', ot.Id);
        
        EligibilityController controller = new EligibilityController();
        
        String filterLogic = '1 OR 2 OR 3 OR 4 OR 5<br>account;name;eq;A<br>account;no_emailing__c;neq;true<br>account;number_of_trucks_owned__c;lt;100<br>user;managerid;eq;123456789<br>account;type_of_freight__c;eq;Air cargo,Bulk transport<br>';
        ot.Eligibility_Criteria_Int__c = filterLogic;
        update ot;
        
        Test.startTest();

        // Test init
        controller.init();
        System.assertEquals(controller.error, false);

        // Test correct save
        controller.selectAll();
        controller.check = true;
        controller.index = 1;
        controller.saveAndExit();
        controller.check = false;
        controller.saveAndExit();
        
        controller.deselectAll();
        
        controller.save();
        
        controller.getOptions();
        controller.getObjectItems();
        controller.addFilter();
        controller.getOfferName();
        controller.getFilterLogic();
        controller.setFilterLogic(filterLogic);
        controller.getCriteria();
        controller.lookupWnd();
        controller.rmvCriterion();
        controller.showPopup();
        List<String> vc = new List<String>();
        vc.add('France');
        controller.valChk = vc;
        controller.saveAndExit();
        
        controller.cancel();
        
        // Test bad init
        /*ot.Status__c = 'Active';
        update ot;
        controller.init();
        System.assertEquals(controller.error, true);
        */
        Test.stopTest();
                
    }

}