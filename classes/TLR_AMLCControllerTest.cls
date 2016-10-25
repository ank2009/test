@isTest
public class TLR_AMLCControllerTest 
{
    private static Account acc;
    private static Subscription__c sub;
    private static Opportunity opp;
    private static Contact cont;
    private static Offer_template__c ot;
    private static TLR_OpportunityExt oppExt;
    private static Subs_Package_And_Fee__c SPF;
    private static List<Subs_Package_And_Fee__c> SPFs;
    private static Map<string, Subs_Package_And_Fee__c> SPFMap = new Map<string, Subs_Package_And_Fee__c>();
    private static Subs_Current_Fee__c SCF;
    private static List<Subs_Current_Fee__c> SCFs;
    private static TLR_AccountMembershipLifeCycleController con;
 
	public static testMethod void testFX_1()
    {
        createTestData('TFX', 'TFX Offer',  new List<string>{'FX_Act_Based'});
        checkPLCField('PLC_FX__c', 'Suspect-Color3; /');
        
        
        opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, ot, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Admin Opportunity'), true);
        oppExt = new TLR_OpportunityExt(opp.Id);
        test.startTest();
        oppExt.InitCreateContractPage();    
        
        sub = [Select ID, Status__c From Subscription__c Where Account__r.Id =: acc.Id];
        SPFs = [Select ID, Name, Subscription__r.Account__c From Subs_Package_And_Fee__c Where Subscription__c =: sub.Id];
        
        createSCFs(SPFs, 0);

        checkPLCField('PLC_FX__c', 'Prospect-Color4; /');
        
        sub.Status__c = 'Waiting For Verification';
        sub.Flag_IntegrityChecks__c = true;
        update sub;
        sub.Status__c = 'Waiting For Provisioning';
        update sub;
        
        checkPLCField('PLC_FX__c', 'Prospect-Color4; /');
        
        sub.Status__c = 'Active';
        update sub;
        
        checkPLCField('PLC_FX__c', 'Free Member-Color10; TFX; /');
        test.stopTest();

        sub.Status__c = 'On Notice';
        sub.End_Date__c = Date.today();
        update sub;
        checkPLCField('PLC_FX__c', 'On notice Member-Color7; /');
        
        sub.Status__c = 'Cancelled';
        update sub;
        checkPLCField('PLC_FX__c', 'Cancelled Member-Color8; TFX; /');
   
        
        
    }
    
    public static testMethod void testFX_2()
    {
        createTestData('TFX', 'TFX Offer',  new List<string>{'FX_Act_Based'});
        checkPLCField('PLC_FX__c', 'Suspect-Color3; /');
        
        
        opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, ot, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Admin Opportunity'), true);
        oppExt = new TLR_OpportunityExt(opp.Id);
        test.startTest();
        oppExt.InitCreateContractPage();    
        
        sub = [Select ID, Status__c From Subscription__c Where Account__r.Id =: acc.Id];
        SPFs = [Select ID, Name, Subscription__r.Account__c From Subs_Package_And_Fee__c Where Subscription__c =: sub.Id];
        createSCFs(SPFs, 100);
        SCFs = new List<Subs_Current_Fee__c>();

        checkPLCField('PLC_FX__c', 'Prospect-Color4; /');
        
        sub.Status__c = 'Waiting For Verification';
        sub.Flag_IntegrityChecks__c = true;
        update sub;
        sub.Status__c = 'Waiting For Provisioning';
        update sub;
        
        checkPLCField('PLC_FX__c', 'Prospect-Color4; /');
        
        sub.Status__c = 'Active';
        update sub;
        
        checkPLCField('PLC_FX__c', 'Customer-Color11; TFX; /');
        test.stopTest();
    }
    
    public static testMethod void testCD_1()
    {
        createTestData('T-PRO', 'TestOT',  new List<string>{'TestCF'});
        checkPLCField('PLC_CD__c', 'Suspect-Color3; /');
        
        opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, ot, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Admin Opportunity'), true);
        oppExt = new TLR_OpportunityExt(opp.Id);
        test.startTest();
        oppExt.InitCreateContractPage();    
        
        sub = [Select ID, Status__c From Subscription__c Where Account__r.Id =: acc.Id];
        
        for(Subs_Package_And_Fee__c pf : [Select ID, Name, Subscription__c, Subscription__r.Account__c From Subs_Package_And_Fee__c Where Subscription__c =: sub.Id])
        {
            SPFMap.put(pf.Name, pf);
        }
        
        createSCFs(SPFMap.values(), 0);
        
        checkPLCField('PLC_CD__c', 'Suspect-Color3; /');
        sub.Status__c = 'Waiting For Verification';
        sub.Flag_IntegrityChecks__c = true;
        update sub;
        sub.Status__c = 'Waiting For Provisioning';
        update sub;
        
        checkPLCField('PLC_CD__c', 'Suspect-Color3; /');
        
        sub.Status__c = 'Active';
        update sub;
        
        checkPLCField('PLC_CD__c', 'Free Member-Color10; /');
        
       
        
        SCF = [select Id from Subs_Current_Fee__c where Id =: SCFs];
        SCF.Price__c = 100;
        update SCF;
        checkPLCField('PLC_CD__c', 'Customer-Color11; /');
        test.stopTest();
        sub.Status__c = 'On Notice';
        update sub;
        
        checkPLCField('PLC_CD__c', 'Suspect-Color3; /');
        
        sub.Status__c = 'Cancelled';
        update sub;
        
        checkPLCField('PLC_CD__c', 'Cancelled Member-Color8; /');
    }
    
    public static testMethod void testCD_2()
    {
        createTestData('TFX', 'TFX Offer',  new List<string>{'CD_approved', 'CD_guest', 'FX'});
        
        opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, ot, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Admin Opportunity'), true);
        oppExt = new TLR_OpportunityExt(opp.Id);
        test.startTest();
        oppExt.InitCreateContractPage();    
        
        sub = [Select ID, Status__c From Subscription__c Where Account__r.Id =: acc.Id];
        for(Subs_Package_And_Fee__c pf : [Select ID, Name, Subscription__r.Account__c From Subs_Package_And_Fee__c Where Subscription__c =: sub.Id])
        {
            SPFMap.put(pf.Name, pf);
        }
        
     //   SPD = SPFMap.get('CD_appr');
        
  
        
        sub.Status__c = 'Waiting For Verification';
        sub.Flag_IntegrityChecks__c = true;
        update sub;
        sub.Status__c = 'Waiting For Provisioning';
        update sub;
        
        sub.Status__c = 'Active';
        update sub;
        
        checkPLCField('PLC_CD__c', 'Free Member-Color10; Approved; /');
       
        SCF = [select Id from Subs_Current_Fee__c where Name = 'CD_approved'];
        delete SCF;
        
        SPF = SPFMap.get('CD_guest');
        createSCFs(new List<Subs_Package_And_Fee__c>{SPF}, 0);
        test.stopTest();
     
        checkPLCField('PLC_CD__c', 'Free Member-Color10; Guest; /');
         
        SPF = SPFMap.get('FX');
        createSCFs(new List<Subs_Package_And_Fee__c>{SPF}, 100);
           checkPLCField('PLC_CD__c', 'Customer-Color11; Guest; /');
        
        sub.Status__c = 'On Notice';
        update sub;
        
        sub.Status__c = 'Cancelled';
        update sub;
        
        checkPLCField('PLC_CD__c', 'Cancelled Member-Color8; Guest; /');
    }
    
    private static void checkPLCField(string fieldName, string expectedValue)
    {
        con = new TLR_AccountMembershipLifeCycleController(acc.Id);
        acc = Database.query('select Id, '+ fieldName + ' from Account where Id = \'' + acc.Id + '\'');
        system.assertEquals(expectedValue, acc.get(fieldName), fieldName + ' is wrong');
    }
    
    private static void createSCFs(List<Subs_Package_And_Fee__c> SubPFs, integer price)
    {
        SCFs = new List<Subs_Current_Fee__c>();
        for(Subs_Package_And_Fee__c PF : SubPFs)
        {
            SCF = new Subs_Current_Fee__c();
            SCF.Start_Date__c = date.today();
            SCF.Name = PF.Name;
            SCF.Account__c = PF.Subscription__r.Account__c;
            SCF.Subs_Package_And_Fee__c = PF.Id;
            SCF.Subscription__c = PF.Subscription__c;
            SCF.Price__c = price;
            SCFs.add(SCF);
        }
        if(SCFs.size() > 0)
            insert SCFs;
    }
    
    private static void createTestData(string productName, string offerName, List<string> packagesNames)
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Map<String,General_Settings__c> def = General_Settings__c.getAll();
        def.values()[0].Enable_PLC_Update__c = true;
        update def.values();
        acc = TST_AccountTestHelper.createDummyAccount('France', true);
        cont = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        ot = TST_OfferTemplateTestHelper.createFullOfferTemplate(productName,offerName, packagesNames);
    }
}