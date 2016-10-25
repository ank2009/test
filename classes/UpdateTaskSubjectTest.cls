/**
 * @author Nicolas Dolet
 * @date 17/01/2012
 * @description Test trigger UpdateTaskSubject
 */
@isTest
public class UpdateTaskSubjectTest {

    public static testMethod void testTrigger() 
    {
    	TST_CustomSettingTestHelper.initAll(new string[]{'France'});
    	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      	User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
      	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      	LocaleSidKey='en_US', ProfileId = p.Id, 
      	TimeZoneSidKey='America/Los_Angeles', UserName='standarduser111@testorg.com');
      	insert u;
		Account acc = TST_AccountTestHelper.createDummyAccount('France', false);
		acc.ESB_Company_Type__c = 'SHIPPER';
		insert acc;
		Contact cont = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
		Offer_Template__c ot = TST_OfferTemplateTestHelper.createDummyOfferTemplate(TLR_RecordTypeHelper.getId('Offer_template__c', 'TLR Offer Template'), true);
		Opportunity opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, ot, TLR_RecordTypeHelper.getId('Opportunity', 'WKTS Opportunity'), true);
        Task t = new Task();
        t.OwnerId = u.id;
        t.Type = '21 Screen sharing';
        t.Product__c = 'FX';
        t.Subject_Group__c = 'Data Quality';
        t.ActivityDate = Date.today();
        t.whatid = opp.id;
        insert t; 
    }
}