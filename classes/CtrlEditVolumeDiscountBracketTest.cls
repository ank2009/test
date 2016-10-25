/**
* @author Nicolas Dolet
* @date 19/12/2011
* @description Test Edit Volume Discount Bracket controller
*/
@isTest
public class CtrlEditVolumeDiscountBracketTest {

    /*public static testMethod void testCtrl() {
    
        // Data generation
        Volume_Discount__c vd = TestData.createVolumeDiscount();
        List<Volume_Discount_Bracket__c> vdbs = TestData.createVolumeDiscountBrackets(vd, 10);
                
        // Page preparation
        PageReference pageRef = Page.EditVolumeDiscountBracket;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', vdbs[7].Id);
        
        CtrlEditVolumeDiscountBracket controller = new CtrlEditVolumeDiscountBracket(new ApexPages.StandardController(vdbs[7]));
        
        // Test errors
        controller.vdb.Max_Value__c = 100000;
        PageReference pr = controller.save();
        System.assertEquals(null, pr);

        vd.Status__c = 'Active';
        update vd;
        vd.Status__c = 'On notice';
        update vd;
        vd.Status__c = 'Inactive';
        update vd;
        controller = new CtrlEditVolumeDiscountBracket(new ApexPages.StandardController(vdbs[7]));
        System.assertEquals(true,controller.error);
        
        vd.Status__c = 'Pending';
        update vd;


        controller = new CtrlEditVolumeDiscountBracket(new ApexPages.StandardController(vdbs[7]));
        
        // Test correct save
        String correctSave = controller.save().getUrl();
        System.assertEquals('/' + vd.Id, correctSave);
                
        // Test cancel
        String cancelPage = controller.cancel().getUrl();
        System.assertEquals('/' + vd.Id, cancelPage);
        
        // Test errors
        
        // Test incorrect save
        delete vdbs[7];
        System.assertEquals(null, controller.save());
        
    }*/

}