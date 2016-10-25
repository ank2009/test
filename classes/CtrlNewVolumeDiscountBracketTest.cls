/**
 * @author AK
 * @date 26/12/2011
 */
@isTest
public class CtrlNewVolumeDiscountBracketTest{

    public static testMethod void testCtrlNewVolumeDiscountBracket() {

    Test.startTest(); 
    Volume_Discount__c VolDis = TestData.createVolumeDiscount() ;
//    List<Volume_Discount_Bracket__c> VolDisBrackets = TestData.createVolumeDiscountBrackets(VolDis,1);
    Volume_Discount_Bracket__c VDB = new Volume_Discount_Bracket__c ();
    VDB.Volume_Discount__c=VolDis.Id;
    VDB.Max_Value__c =10;
    VDB.Min_Value__c =0;
        
    // Page preparation
    PageReference pageRef=Page.NewVolumeDiscountBracket;
    Test.setCurrentPage(pageRef);
    CtrlNewVolumeDiscountBracket  controller = new CtrlNewVolumeDiscountBracket(new ApexPages.StandardController(VDB));
    
    // Test save
    String savePage= controller.save().getUrl();
    String prefix  = Schema.SObjectType.Volume_Discount__c.getKeyPrefix();
    System.Assert(savePage.startsWith('/' + prefix));
    
    String cancelPage = controller.Cancel().getUrl();
    String prefix1  = Schema.SObjectType.Volume_Discount__c.getKeyPrefix();
    System.Assert(cancelPage.startsWith('/' + prefix1));

    Volume_Discount_Bracket__c VDB2 = new Volume_Discount_Bracket__c ();
    VDB2.Volume_Discount__c=VolDis.Id;
    VDB2.Max_Value__c =20;
    controller = new CtrlNewVolumeDiscountBracket(new ApexPages.StandardController(VDB2));    


    VolDis.Status__c='Active';
    update VolDis; 
    Volume_Discount_Bracket__c VDB1 = new Volume_Discount_Bracket__c ();
    VDB1.Volume_Discount__c=VolDis.Id;
    VDB1.Max_Value__c =0;
    controller = new CtrlNewVolumeDiscountBracket(new ApexPages.StandardController(VDB1));    
    controller.save();

    Test.stopTest();
        
    }
}