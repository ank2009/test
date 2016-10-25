/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TLR_ALCControllerTest {

    private static void Helper(String offerName, String productName, List<String> packagesNames, boolean EndDate, boolean forFields) 
    {
        
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});  
        if(forFields)
        {
            Map<String,General_Settings__c> def = General_Settings__c.getAll();
        	def.values()[0].Enable_PLC_Update__c = true;
        	update def.values();
        }
		Account acc = TST_AccountTestHelper.createDummyAccount('France', false);
        acc.Bank_Code_FR__c = '12939';
        acc.BIC_Code__c = 'BDUPFR2S';
        acc.Cashier_Code_FR__c = '00067';
        acc.Bank_Number__c = '40000586606';
        acc.RIB_Key_FR__c = '25';
        acc.Payment_Terms__c = 45;
        acc.Account_Level__c = 'Site';
        insert acc; 
        Contact cont = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TWD Contact'), true);
		Test.setCurrentPageReference(Page.TLR_AccountMembershipLifeCycle);
		ApexPages.currentPage().getParameters().put('id', acc.Id);
        Offer_template__c off = TST_OfferTemplateTestHelper.createFullOfferTemplate(productName,offerName, packagesNames);
        Opportunity opp = new Opportunity();
        opp.Name = 'Opp';
        opp.Offer_Template__c = off.Id;
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today();
        opp.StageName = '01 New';
        opp.Product_Interest__c = 'TFC';
        insert opp;
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = cont.Id;
        ocr.OpportunityId = opp.Id;
        insert ocr;   
        opp.StageName = '10 Closed Won';
        opp.BANT_Assessment_Done__c = true;
        opp.Recurring_Revenue__c = 10;
        opp.Recurring_Revenue_Date__c = Date.Today();
        update opp;
        test.startTest();
        TLR_OpportunityExt ext = new TLR_OpportunityExt(opp.Id);
        ext.InitCreateContractPage(); 
        test.stopTest();
        Subscription__c sub = [Select ID, Status__c From Subscription__c Where Account__r.Id =: acc.Id];
        List<Subs_Package_And_Fee__c> subPack = [Select ID, Name From Subs_Package_And_Fee__c Where Subscription__c =: sub.Id];
        List<Subs_Current_Fee__c> fees = new List<Subs_Current_Fee__c>();
        for(Subs_Package_And_Fee__c f:subPack)
        {
            Subs_Current_Fee__c fee = new Subs_Current_Fee__c();
            fee.Start_Date__c = date.today();
            if(EndDate)
            {
                fee.Start_Date__c = date.newInstance(2012, 2, 1);
                fee.End_Date__c = date.newInstance(2013, 2, 1);
                EndDate = false;
            }
            fee.Name = f.Name;
            fee.Subs_Package_And_Fee__c = f.Id;
            fee.Subscription__c = sub.Id;
            fee.Price__c = 100;
            fees.add(fee);
        }
        insert fees;
        sub.Status__c = 'Waiting For Verification';
        sub.Flag_IntegrityChecks__c = true;
        update sub;
        sub.Status__c = 'Waiting For Provisioning';
        update sub;
        sub.Status__c = 'Active';
        update sub;
        if(forFields)
        {
            TLR_AccountMembershipLifeCycleController con = new TLR_AccountMembershipLifeCycleController(acc.Id);
        }
		TLR_AccountMembershipLifeCycleController con = new TLR_AccountMembershipLifeCycleController(new ApexPages.StandardController(acc));    
    }
    
    private static testMethod void TestTas()
    {
        Helper('TAS English', 'TAS English', new String[] {'Basic module', 'TDC - Reading orders', 'Integrated km calculation Europe with cartography (PTV 2)'},false,true);
    }
    private static testMethod void TestFX()
    {
        Helper('TFC_Offer', 'TFC', new String[] {'Address Book'}, true,true);
    }
    private static testMethod void TestCD()
    {
        Helper('CD_offer', 'T-PRO', new String[] {'CD_approved','Address Book', 'Products'},false,true);
    }
    private static testMethod void TestTW()
    {
        Helper('TWD', 'TWA', new String[] {'Basic module', 'TDC - Reading orders', 'PTV'},false,true);
    }
}