/**
 * @author AK
 * @date 26/12/2011
 */
@isTest
public class CtrlNewOfferPackageAndFeeTest{

    public static testMethod void testCtrlNewOfferPackageAndFee() {
    
    Test.startTest(); 
    // Data generation
    List<ID> services = TestData.createTestServices(10);
    Product__c product = TestData.createTestProductAndLineItems(services, false, true);
    Offer_Template__c offerTemplate = TestData.createOfferTemplate(product,false); 
    List<Offer_Line_Item__c> olis = TestData.createTestOfferTemplateHierarchy(offerTemplate.Id, services);
    PackFee__c PackFee = TestData.createPackageAndFeeWithLineItems(services, true);
    Offer_Package_And_Fee__c OfferPackageAndFee=new Offer_Package_And_Fee__c();
     
    // Page preparation
    PageReference pageRef=Page.NewOfferPackageAndFee;
    Test.setCurrentPage(pageRef);
        
    ApexPages.currentPage().getParameters().put('000_lkid', offerTemplate.Id);
    CtrlNewOfferPackageAndFee controller = new CtrlNewOfferPackageAndFee (new ApexPages.StandardController(OfferPackageAndFee));
      
    // init() 
    controller.init();
    
    // Test save
    controller.getOfferPackageAndFee().Package_Fee__c = PackFee.Id;
    String saveUrl = controller.save().getUrl();
    String prefix  = Schema.getGlobalDescribe().get('Offer_Package_And_Fee__c').getDescribe().getKeyPrefix();
    System.Assert(saveUrl.startsWith('/' + prefix));
    System.AssertEquals('/' + controller.getOfferPackageAndFee().Id, saveUrl);
    
    
     // Test Cancel
    String cancelUrl = controller.cancel().getUrl();
    //String prefix1  = Schema.getGlobalDescribe().get('Offer_Promo__c').getDescribe().getKeyPrefix();
    //System.Assert(cancelUrl.startsWith('/' + prefix1));
    System.AssertEquals('/' + offerTemplate.Id, cancelUrl);
     Test.stopTest();
    }
}