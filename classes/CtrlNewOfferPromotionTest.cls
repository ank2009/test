/**
 * @author AK
 * @date 26/12/2011
 */
@isTest
public class CtrlNewOfferPromotionTest {

    public static testMethod void testCtrlNewOfferPromotion() {
        
        Test.startTest(); 
        // Data generation
        List<ID> services = TestData.createTestServices(10);
        Product__c product = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c offerTemplate = TestData.createOfferTemplate(product,false); 
        offerTemplate.Status__c='Pending';
        update offerTemplate;
        Promotion__c Promo = TestData.createPromotion();
        Offer_Promo__c OffPromo = new Offer_Promo__c();
        //OffPromo.Name = 'Test Offer Promotion';
        //OffPromo.Level__c='Service(s)';
        //OffPromo.Offer_Template__c=offerTemplate.Id;
        //OffPromo.Promotion__c=Promo.Id;
        
        // Page preparation
        PageReference pageRef=Page.NewOfferPromotion;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('retURL', '/'+offerTemplate.Id);
        CtrlNewOfferPromotion controller = new CtrlNewOfferPromotion (new ApexPages.StandardController(OffPromo));
        
        // init() 
        controller.init();

        // Test save
        controller.getOfferPromo().Promotion__c = Promo.Id;
        String saveUrl = controller.save().getUrl();
        String prefix  = Schema.getGlobalDescribe().get('Offer_Promo__c').getDescribe().getKeyPrefix();
        System.Assert(saveUrl.startsWith('/' + prefix));
        System.AssertEquals('/' + controller.getOfferPromo().Id, saveUrl);
        
        
        // Test cancel
        String cancelUrl = controller.cancel().getUrl();
        //String prefix1  = Schema.getGlobalDescribe().get('Offer_Promo__c').getDescribe().getKeyPrefix();
        //System.Assert(cancelUrl.startsWith('/' + prefix1));
        System.AssertEquals('/' + offerTemplate.Id, cancelUrl);
        
        //offerTemplate.Status__c='Active';
        //update offerTemplate;
        controller = new CtrlNewOfferPromotion (new ApexPages.StandardController(OffPromo));
        controller.init();
        
        Test.stopTest();    
        
    }

}