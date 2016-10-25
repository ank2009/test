@isTest
public class SubsPromoLineItemsUtilsTest 
{
	/**
     * Test methods
     */
    
    static testMethod void testCalculateEndDate() {
        Date startDate = Date.newInstance(2011, 1, 15);
        Date result, expectedResult;

        // Test 'Days' duration type
        expectedResult = Date.newInstance(2011, 2, 4);
        result = SubsPromoLineItemsUtils.calculateEndDate(startDate,20,'Days');
        System.assertEquals(result, expectedResult);
         
        // Test 'Months' duration type
        expectedResult = Date.newInstance(2011, 3, 15);
        result = SubsPromoLineItemsUtils.calculateEndDate(startDate,2,'Months');
        System.assertEquals(result, expectedResult);
         
        // Test 'Months prorata' duration type
        expectedResult = Date.newInstance(2011, 3, 1);
        result = SubsPromoLineItemsUtils.calculateEndDate(startDate,2,'Months prorata');
        System.assertEquals(result, expectedResult);
         
        // Test 'Unknown duration type'
        try {
            SubsPromoLineItemsUtils.calculateEndDate(startDate,0,'foo');
        } catch (SubsPromoLineItemsUtils.DurationException e) {
            String message = 'Unknown duration type: "foo"';
            System.assertEquals(e.getMessage(), message);
        }
        
     }
     
     static testMethod void testBuildSubsPromoLineItems() {
         // Data creation
         TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
         Account acc          = TST_AccountTestHelper.createDummyAccount('France',true);
         Contract ctr         = TestData.createTestContract(acc.Id);
         List<ID> servs       = TestData.createTestServices(5);
         Product__c prod      = TestData.createTestProductAndLineItems(servs, false, true);
         Subscription__c subs = TestData.createTestSubscription(prod.Id, ctr.Id);

         Promotion__c promo = TestData.createPromotionWithLineItems(5, false);

         Offer_Template__c ot = TestData.createOfferTemplate(prod, false); 
         Offer_Promo__c    op = TestData.createOfferPromotion(ot, promo);

         // TODO: use TestData class for data creation
         Opportunity opp  = new Opportunity(Name = 'Test Opportunity');
         opp.StageName    = '01 New';
         opp.CloseDate    = Date.today();
         opp.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('WKTS Opportunity').getRecordTypeId();  
         insert opp;
         
         Opp_Promotion__c oppPromo = TestData.createOppPromoWithLineItemsAndLinks(opp.Id, op.Id);
         
         List<Opportunity_Promo_Line_Item__c> promoItems = new List<Opportunity_Promo_Line_Item__c>();
         List<Opportunity_Promo_Line_Item__c> oplis = [SELECT Id
                                                         FROM Opportunity_Promo_Line_Item__c
                                                        WHERE Opp_Promotion__c =: oppPromo.Id];

         Opportunity_Promo_Line_Item__c opli = oplis[0];


         List<Promotion_Line_Item__c> promoLIs = [SELECT Id
                                                    FROM Promotion_Line_Item__c
                                                   WHERE Promotion__c =: promo.Id];
         
         List<Offer_Promo_Line_Item__c> offPromoLIs = TestData.createOfferPromoLIs(op, promoLIs);

         opli.Offer_Promo_Line_Item__c = offPromoLIs[0].Id;
         opli.Duration_Value__c = 1;
         
         // Test execution
         SubsPromoLineItemsUtils.buildSubsPromoLineItems(subs, oppPromo);
         
         // Check the result
         // TODO
     }
}