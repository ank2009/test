@isTest
public class CtrlDeleteAddOnTest
{
    public static testMethod void testCtrl()
    {
        // Data generation
        List<ID> services = TestData.createTestServices(5);
        ID addOnId        = TestData.createTestProductAndLineItems(services, true, false).Id;
        ID addOnId2       = TestData.createTestProductAndLineItems(services, true, false).Id;
        ID addOnIdAct     = TestData.createTestProductAndLineItems(services, true, false).Id;
        ID productId      = TestData.createTestProductAndLineItems(services, false, false).Id;
        Add_on_Parent__c addOnParent    = TestData.createTestAddOnParent(addOnId, productId);
        Add_on_Parent__c addOnParent2   = TestData.createTestAddOnParent(addOnId, productId);
        Add_on_Parent__c addOnParentAct = TestData.createTestAddOnParent(addOnIdAct, productId);
    
        // Page preparation
        PageReference pageRef = Page.DeleteAddOn;
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', addOnParent.Id);
        ApexPages.currentPage().getParameters().put('retURL', '/' + productId);
        
        CtrlDeleteAddOn controller = new CtrlDeleteAddOn(new ApexPages.StandardController(addOnParent));
              
        // Methods calls: First execution, bad 'from'
        System.assertEquals(null, controller.init());
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals('Add-ons cannot be unlinked from here. They must be unlinked from their own view!', messages[messages.size() - 1].getSummary());
        
        // Second Execution: Parent not Pending
        ApexPages.currentPage().getParameters().put('id', addOnParentAct.Id);
        ApexPages.currentPage().getParameters().put('retURL', '/' + addOnIdAct);
        
        //controller = new CtrlDeleteAddOn(new ApexPages.StandardController(addOnParentAct));
        
        //System.assertEquals(null, controller.init());
        //messages = ApexPages.getMessages();
        //System.assertEquals('Parents can be deleted only if Add-On is under Pending status.', messages[messages.size() - 1].getSummary());
        
        // Third Execution: Exception during deleting
        ApexPages.currentPage().getParameters().put('id', addOnParent2.Id);
        ApexPages.currentPage().getParameters().put('retURL', '/' + addOnId2);
        
        controller = new CtrlDeleteAddOn(new ApexPages.StandardController(addOnParent2));
        
        delete addOnParent2;
        
        System.assertEquals(null, controller.init());
        
        // Fourth Execution: Execution ok
        ApexPages.currentPage().getParameters().put('id', addOnParent.Id);
        ApexPages.currentPage().getParameters().put('retURL', '/' + addOnId);
        
        controller = new CtrlDeleteAddOn(new ApexPages.StandardController(addOnParent));
        
        String initPage = controller.init().getUrl();
        
        System.assertEquals('/' + addOnId, initPage);
        
        // Fourth Execution: Cancel method
        String cancelPage = controller.Cancel().getUrl();
        
        System.assertEquals('/' + addOnId, cancelPage);
    }
}