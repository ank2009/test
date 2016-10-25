@isTest
public class TST_Opportunity_Tests 
{
    private static Account acc;
    private static Contact cont;
    private static String stageValueNeedContactRoles;
    private static String stageValueNotNeedContactRoles;
    
	public static testMethod void CheckingContactRolesWhenUpdatingStageTest()
    {
        CreateTestData();
        Opportunity opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity'), true);
        boolean isError;
        FillStagesLists(opp.StageName);
        opp.StageName = stageValueNotNeedContactRoles;
        isError = false;
        try
        {
            update opp;
        }
        catch(Exception e)
        {
            isError = true;
        }
        system.assert(!isError, 'No error must occur during update of StageName if it is not in the custom setting');
        opp = [select Id, StageName from Opportunity where Id = : opp.Id];
        system.assertEquals(stageValueNotNeedContactRoles, opp.StageName, 'StageName must be updated if it is not in the custom setting');
        opp.StageName = stageValueNeedContactRoles;
        isError = false;
        try
        {
            update opp;
        }
        catch(Exception e)
        {
            isError = true;
        }       
        system.assert(isError, 'An error must occur during update of StageName if it is in the custom setting and there are no Contact Roles attached to the Opportunity'); 
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = cont.Id;
        ocr.OpportunityId = opp.Id;
        insert ocr;       
        isError = false;
        try
        {
            update opp;
        }
        catch(Exception e)
        {
            isError = true;
        }       
        system.assert(!isError, 'An error must not occur during update of StageName if Contact Role is attached to the Opportunity');
        opp = [select Id, StageName from Opportunity where Id =: opp.Id];
        system.assertEquals(stageValueNeedContactRoles, opp.StageName, 'StageName must be updated if Contact Role is attached to the Opportunity'+opp.StageName);       
        delete ocr;
        system.assertEquals(0, [select count() from OpportunityContactRole], 'Contact role must be deleted');        
        isError = false;
        try
        {
            update opp;
        }
        catch(Exception e)
        {
            isError = true;
        }       
        system.assert(!isError, 'An error must not occur if Opportunity has been updated and the StageName has remained the same');
    }
    
    public static testMethod void CheckStageBeforeCreationTest()
    {
		CreateTestData();		        
        Opportunity opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity'), false);        
        FillStagesLists(null);
        opp.StageName = stageValueNeedContactRoles;
        Exception excep;
        try
        {
            insert opp;
        }
        catch(Exception e)
        {
            excep = e;
        }
        system.assertNotEquals(null, excep, 'An error must occur when trying to insert Opportunity with this stage name');
        opp.StageName = stageValueNotNeedContactRoles;
        excep = null;
        try
        {
            insert opp;
        }
        catch(Exception e)
        {
            excep = e;
        }
        system.assertEquals(null, excep, 'An error must not occur when trying to insert Opportunity with this stage name');
    }
    
    public static testMethod void OfferTemplateAttachmentNotTasOppTest()
    {
        CreateTestData();
        Offer_Template__c ot_1 = TST_OfferTemplateTestHelper.createFullOfferTemplate('TestProduct', 'TestTFXOffer' , new String[]{'CD_approved', 'CD_guest'});
        Offer_Template__c ot_2 = TST_OfferTemplateTestHelper.createFullOfferTemplate('TestProduct', 'TestTFXOffer' , new String[]{'CD_approved', 'CD_guest'});
        Opportunity opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, ot_1, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity'), false);
        opp.Product_Interest__c = 'TFX';
        insert opp;        
        List<Opp_Package_And_Fee__c> oppfs = [select Id from Opp_Package_And_Fee__c where Offer_Package_And_Fee__r.Offer_Template__c =: ot_1.Id];
        List<Opportunity_Line_Item__c> oplis = [select Id from Opportunity_Line_Item__c where Offer_Line_Item__r.Offer_Template__c =: ot_1.Id];
        system.assertEquals(2, oppfs.size(), 'Opportunity Packages and fees are not created for first Offer Template');
        system.assertEquals(1, oplis.size(), 'Opportunity Line item is not created for first Offer Template');
        
        opp.Offer_Template__c = ot_2.Id;
        update opp;
        oppfs = [select Id from Opp_Package_And_Fee__c where Offer_Package_And_Fee__r.Offer_Template__c =: ot_1.Id];
        oplis = [select Id from Opportunity_Line_Item__c where Offer_Line_Item__r.Offer_Template__c =: ot_1.Id];
        system.assertEquals(0, oppfs.size(), 'Opportunity Packages and fees created for first Offere Template are not deleted');
        system.assertEquals(0, oplis.size(), 'Opportunity Line item created for first Offere Template is not deleted');
        oppfs = [select Id from Opp_Package_And_Fee__c where Offer_Package_And_Fee__r.Offer_Template__c =: ot_2.Id];
        oplis = [select Id from Opportunity_Line_Item__c where Offer_Line_Item__r.Offer_Template__c =: ot_2.Id];
        system.assertEquals(2, oppfs.size(), 'Opportunity Packages and fees are not created for second Offer Template');
        system.assertEquals(1, oplis.size(), 'Opportunity Line item is not created for second Offer Template');
        
        opp.Offer_Template__c = null;
        update opp;
        oppfs = [select Id from Opp_Package_And_Fee__c where Offer_Package_And_Fee__r.Offer_Template__c =: ot_2.Id];
        oplis = [select Id from Opportunity_Line_Item__c where Offer_Line_Item__r.Offer_Template__c =: ot_2.Id];
        system.assertEquals(0, oppfs.size(), 'Opportunity Packages and fees created for first Offere Template are not deleted');
        system.assertEquals(0, oplis.size(), 'Opportunity Line item created for first Offere Template is not deleted');
        
        opp.Offer_Template__c = ot_2.Id;
        update opp;
        oppfs = [select Id from Opp_Package_And_Fee__c where Offer_Package_And_Fee__r.Offer_Template__c =: ot_2.Id];
        oplis = [select Id from Opportunity_Line_Item__c where Offer_Line_Item__r.Offer_Template__c =: ot_2.Id];
        system.assertEquals(2, oppfs.size(), 'Opportunity Packages and fees are not created for second Offer Template');
        system.assertEquals(1, oplis.size(), 'Opportunity Line item is not created for second Offer Template');
    }
    
    public static testMethod void OfferTemplateAttachmentTasOppTest()
    {
        CreateTestData();
        Offer_Template__c ot_1 = TST_OfferTemplateTestHelper.createFullOfferTemplate('TestProduct', 'TestTFXOffer' , new String[]{'CD_approved', 'CD_guest'});
        Offer_Template__c ot_2 = TST_OfferTemplateTestHelper.createFullOfferTemplate('TestProduct', 'TestTFXOffer' , new String[]{'CD_approved', 'CD_guest'});
        Opportunity opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, ot_1, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity'), false);
        opp.Product_Interest__c = 'TAS';
        insert opp;       
        List<Opp_Package_And_Fee__c> oppfs = [select Id from Opp_Package_And_Fee__c where Offer_Package_And_Fee__r.Offer_Template__c =: ot_1.Id];
        List<Opportunity_Line_Item__c> oplis = [select Id from Opportunity_Line_Item__c where Offer_Line_Item__r.Offer_Template__c =: ot_1.Id];
        system.assertEquals(0, oppfs.size(), 'Opportunity Packages and fees must not be created for TAS opportunities during insertion');
        system.assertEquals(0, oplis.size(), 'Opportunity Line item must not be created for TAS opportunities during insertion'); 
        
        opp.Offer_Template__c = ot_2.Id;
        update opp;
        oppfs = [select Id from Opp_Package_And_Fee__c where Offer_Package_And_Fee__r.Offer_Template__c =: ot_2.Id];
        oplis = [select Id from Opportunity_Line_Item__c where Offer_Line_Item__r.Offer_Template__c =: ot_2.Id];
        system.assertEquals(0, oppfs.size(), 'Opportunity Packages and fees must not be created for TAS opportunities during update');
        system.assertEquals(0, oplis.size(), 'Opportunity Line item must not be created for TAS opportunities during update');
    }
    
    private static void CreateTestData()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        acc = TST_AccountTestHelper.createDummyAccount('Belgium', false);       
        cont = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TWD Contact'), true);
    }
    
    private static void FillStagesLists(string StageNotToSet)
    {
        List<string> allStageValues = Utilities.getPicklistValues('Opportunity', 'StageName');   
        for(string stageValue : allStageValues)
        {
            if(Opportunity_Stages_Need_Contact_Roles__c.getValues(stageValue) == null && stageValue != StageNotToSet)
            {
                stageValueNeedContactRoles = stageValue;
            }      
        }
        
        for(string stageValue : allStageValues)
        {
            if(Opportunity_Stages_Need_Contact_Roles__c.getValues(stageValue) != null && stageValue != StageNotToSet)
            {
                stageValueNotNeedContactRoles = stageValue;
            }      
        }      
    }
}