/**
 * @author Nicolas Dolet
 * @date 17/01/2012
 * @description Test trigger OppItemSubVDLineItem
 */
@isTest
public class OppItemSubVDLineItemTest {

    public static testMethod void testTrigger() {
    
        // Data generation
        List<ID> services                             = TestData.createTestServices(10);
        Product__c product                            = TestData.createTestProductAndLineItems(services, false, true);
        Volume_Discount__c vd                         = TestData.createVolumeDiscountWithBrackets(3, true);
        PackFee__c pf                                 = TestData.createPackageAndFeeWithLineItems(services, true);
        Promotion__c promo                            = TestData.createPromotionWithLineItems(2, true);
        Offer_Template__c ot                          = TestData.createOfferTemplate(product, false);
        List<Offer_Line_Item__c> offerLIs             = TestData.createTestOfferTemplateHierarchy(ot.Id, services);
        Offer_Item_Subservice__c ois                  = [SELECT Id FROM Offer_Item_Subservice__c WHERE Offer_Line_Item__c = :offerLIs[0].Id LIMIT 1];
        List<Offer_Item_Sub_VD_Line_Item__c> oisvdlis = TestData.createOfferItemSubVDLI(ois, vd.Id);
        Offer_Package_And_Fee__c opf                  = TestData.createOfferPackageAndFeeAndLineItems(ot.Id, pf.Id);
        Offer_Promo__c opromo                         = TestData.createOfferPromoWithLineItemsAndLinks(ot.Id, promo.Id, new List<ID>{opf.Id});
/*        
        ot.Contract_Term__c = 1; 
        ot.Default_Invoice_Level__c = 'Site'; 
        ot.Default_Invoice_Media__c = 'Paper';
        ot.Default_Payment_Method__c = 'Direct Debit';
        update ot;
        ot.Status__c = 'Active';
        update ot;
*/                   
        List<ID> offerLineItems = new List<ID>();
        for (Offer_Line_Item__c oli : offerLIs)
            offerLineItems.add(oli.Id);
            
        List<ID> offerItemSubVDLIs = new List<ID>();
        for (Offer_Item_Sub_VD_Line_Item__c oisvdli : oisvdlis)
            offerItemSubVDLIs.add(oisvdli.Id);
                
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount(true);
        Opportunity opp = TestData.createTestOpportunity(a.Id);
        opp.Offer_Template__c = null;
        update opp;
        
        List<Opportunity_Line_Item__c> oppLIs = TestData.createTestOpportunityHierarchy(opp.Id, offerLineItems);
        
        Opp_Item_Subservice__c oppis = [SELECT Id FROM Opp_Item_Subservice__c WHERE Opportunity_Line_Item__c = :oppLIs[0].Id LIMIT 1];
        
        List<Opp_Item_Sub_VD_Line_Item__c> oppisvdlis = TestData.createOppItemSubVDLI(oppis.Id, offerItemSubVDLIs);
        
        
        oisvdlis[0].Min_Price__c = 0;
        oisvdlis[0].Max_Price__c = 100;
        update oisvdlis[0];
        
        oppisvdlis[0].Offer_Item_Sub_VD_Line_Item__c = oisvdlis[0].Id;
        oppisvdlis[0].Sales_Price__c = 50;
        update oppisvdlis[0];
    
    }
}