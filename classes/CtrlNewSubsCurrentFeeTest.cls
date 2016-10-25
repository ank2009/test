@isTest
public class CtrlNewSubsCurrentFeeTest{

    public static testMethod void testCtrlNewSubsCurrentFee() {
    
        Test.startTest(); 
        //Data Prepration
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account accnt = TST_AccountTestHelper.createDummyAccount(true); 
        // Contract
        Id contractId = TestData.createTestContract(accnt.Id).Id;
        // Services
        List<ID> services = TestData.createTestServices(10);
        List<Service__c> service = [SELECT Id, Name FROM Service__c WHERE Id =: services[0]];
        //------ 
        List<Subservice__c> subservices=[SELECT Id, Name FROM Subservice__c  WHERE Parent_Service__c =:services[0]] ;
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        // Product
        Product__c product = TestData.createTestProductAndLineItems(services, false, true);
        // Offer template
        Offer_Template__c offerTemplate = TestData.createOfferTemplate(product,false); 
        // Subscription
        Subscription__c subs = TestData.createTestSubscription(product.Id, contractId);
        PackFee__c PackFee = TestData.createPackageAndFee();
        Subs_Package_And_Fee__c SubsPackFee = new Subs_Package_And_Fee__c();
        SubsPackFee.Name='test Subs Pack fee';
        SubsPackFee.Package_and_Fee__c=PackFee.Id;
        SubsPackFee.Subscription__c=subs.Id;
        insert SubsPackFee;
        Subs_Current_Fee__c SubsKurFee = new Subs_Current_Fee__c();
        SubsKurFee.Name='test abdel';
        SubsKurFee.Subscription__c = subs.Id;
        SubsKurFee.Account__c= accnt.Id;
        SubsKurFee.Subs_Package_And_Fee__c=SubsPackFee.Id;
        SubsKurFee.Start_Date__c=Date.today();
        //-----------
   
    // Page preparation
    PageReference pageRef=Page.NewSubsCurrentFee;
    Test.setCurrentPage(pageRef);
    CtrlNewSubsCurrentFee controller = new CtrlNewSubsCurrentFee(new ApexPages.StandardController(SubsKurFee));

    // init() 
    controller.init();

    // Test save
    /*String savePage= */controller.save();//.getUrl();
    //System.AssertEquals('/'+SubsKurFee.Id,savePage);
    
    // Test cancel
    String cancelPage= controller.Cancel().getUrl();
    //System.AssertEquals('/'+SubsKurFee.Subscription__c,cancelPage);
    
    controller = new CtrlNewSubsCurrentFee(new ApexPages.StandardController(SubsKurFee));
    controller.init();
    controller.scf.Account__c = null;
    //System.AssertEquals(null, controller.save());
    
/*     controller = new CtrlNewSubsCurrentFee(new ApexPages.StandardController(SubsKurFee));
    controller.init();
    controller.scf.Account__c = null;
    System.AssertEquals(null, controller.save());
    
    */
        
    Test.stopTest();
    }
}