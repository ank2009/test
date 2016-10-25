@isTest
public class TR006OpportunityTest
{
    public static testMethod void testTR006Opportunity()
    {
     // Data creation
     
     test.startTest();
     TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
     Account accnt = TST_AccountTestHelper.createDummyAccount(true);
     Opportunity Opp=TestData.createTestOpportunity(accnt.Id);
     List<Opportunity> InsertedOpportunity= [SELECT Id, NAME, AccountId, Offer_Template__c FROM Opportunity
                                       WHERE AccountId=:accnt.Id];
     
     List<Opportunity_Line_Item__c> OppLI = TestData.createTestOpportunityWithLI(accnt.Id, 10); 
     For (Opportunity_Line_Item__c oli :OppLI )
     {
     Opp_Item_Subservice__c Opp_I_Sub = TestData.createOppItemSubservice(oli);
     }
     List<ID> services = TestData.createTestServices(10);
     Product__c prod = TestData.createTestProductAndLineItems(services, false, true);
     Promotion__c promo = TestData.createPromotion();
     Offer_Template__c OfferTemplate= TestData.createOfferTemplate(prod,false);
     Offer_Promo__c OffTempromo = TestData.createOfferPromotion(OfferTemplate,promo);   
     Volume_Discount__c VD=TestData.createVolumeDiscount();
     List<Volume_Discount_Bracket__c> VDB = TestData.createVolumeDiscountBrackets(VD,5);
     // Offer Line Items
     
     // Offer Item Subservice
     
     // Offer Item Sub VD Line Item 
     
     //OfferTemplate.Status__c='Active';
     update OfferTemplate;
     (new TR006Opportunity()).AddOpportunityElement(InsertedOpportunity);
     
    }
}