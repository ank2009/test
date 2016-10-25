/**
 * @author Nicolas Dolet
 * @date 17/01/2012
 * @description Test trigger UpdateEventSubject
 */
@isTest
public class UpdateEventSubjectTest {

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
		Event e = new Event ();
		e.OwnerId = u.id;
		e.ActivityDateTime = Date.today();
		 e.Type = '21 Screen sharing';
        e.Product__c = 'FX';
        e.Subject_Group__c = 'Data Quality';
        e.EndDateTime = Date.today();
        e.StartDateTime = Date.today();
		e.whatid = opp.Id;
		insert e;
    
    }
}