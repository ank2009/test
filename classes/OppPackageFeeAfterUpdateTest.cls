@isTest
public class OppPackageFeeAfterUpdateTest
{
    public static testMethod void testTrigger() 
    {
        // Data generation
        // Services
        List<ID> services = TestData.createTestServices(10);
        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
        serviceNbSA.put(id, 2);
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        // Product
        Product__c product = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c OfferTemplate = TestData.createOfferTemplate(product,false);
        
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        Opportunity Opp= TestData.createTestOpportunity(acc.Id);
        Opportunity InsertedOpp = [SELECT Id, Name, Offer_Template__c, CloseDate , Start_Usage_Payment_Date__c, Maximum_Invoice_Amount__c, CUG_Allowed__c 
                                    FROM Opportunity WHERE Id =: Opp.Id];
        
        PackFee__c packFee = TestData.createPackageAndFeeWithLineItems(services,true);
        Offer_Package_And_Fee__c OfferPackFee = TestData.createOfferPackageAndFeeAndLineItems(OfferTemplate.Id, packFee.Id);
        
        Package_and_Fee_Line_Item__c  pfli = [SELECT Id, Weight__c, Service__c From Package_and_Fee_Line_Item__c WHERE Parent__c = :packFee.Id LIMIT 1];
        Offer_Package_And_Fee_Line_Item__c opfli = new Offer_Package_And_Fee_Line_Item__c();
        opfli.PackFee__c                = OfferPackFee.Id;
        opfli.Offer_Package_And_Fee__c       = OfferPackFee.Id;
        opfli.PackFee_Line_Item__c         = pfli.Id;
        opfli.Weight__c               = pfli.Weight__c;
        opfli.Service__c             = pfli.Service__c;
      
        insert opfli;
        
        Opp_Package_And_Fee__c OppPackFee = TestData.createOppPackageAndFeeWithLineItems(InsertedOpp.Id,OfferPackFee.Id);
        //OfferTemplate.Status__c='Active';
        //update OfferTemplate;
        
        Opp_Package_And_Fee_Line_Item__c opppfli = [SELECT Id, PackFee__c FROM Opp_Package_And_Fee_Line_Item__c WHERE Opp_Package_And_Fee__c = :OppPackFee.Id];
        
        opppfli.PackFee__c = null;
        update opppfli;
        
        OppPackFee.Name='Test abdel';
        update OppPackFee;
    }
}