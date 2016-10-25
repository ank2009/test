/**
 * @author Nicolas Dolet
 * @date 19/12/2011
 * @description Test ChooseOfferTemplateExt
 */
@isTest
public class ChooseOfferTemplateExtTest
{
	public static testMethod void test()
	{
        // Data generation
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        Opportunity opp = TestData.createTestOpportunity(acc.Id);

        createData();

        // Page preparation
        PageReference pageRef = Page.ChooseOfferTemplate;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', opp.Id);

        List<ID> services = TestData.createTestServices(10);
        Product__c product = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(product, true);
        // Test with TGO for method 'handleReturn'
        ApexPages.currentPage().getParameters().put('returnedList', ot.Id + ';');

        ChooseOfferTemplateExt controller = new ChooseOfferTemplateExt(new ApexPages.StandardController(opp));
        ChooseOfferTemplateExt webServicecontroller = new ChooseOfferTemplateExt(opp.Id);

        ChooseOfferTemplateExt.algo(opp.AccountId);

        controller.getOptionsOT();
        controller.handleReturn();

        controller.save();

        controller.cancel();

        // TODO: perform assertions...
        // NYI
    }

    /**
     * @author Nicolas Dolet
     * @date 20/12/2011
     * @description Create some Offer Templates for testing all eligibility criteria
     */
    private static void createData() 
    {
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        acc.S_Score__c = 30; // Type is Percent
        update acc;

        List<ID> servIds = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(servIds, false, true);

        Offer_Template__c ot1 = TestData.createOfferTemplate(prod, false);
        ot1.Eligibility_Criteria_Int__c = '1 OR 2 OR 3 OR 4 OR 5 OR 6<br>' +
                                          'account;billingcountry;eq;Belgium,France<br>' +
                                          'account;NumberOfEmployees;eq;100<br>' +
                                          'account;S_Score__c;eq;30<br>' +
                                          'account;Account_Created_On__c;eq;2011-01-01<br>' +
                                          'account;Billing_Address_Validated__c;eq;true<br>' +
                                          'account;Deactivation_Date__c;eq;2011-01-01 08:00:00<br>';

        TST_OfferTemplateTestHelper.activateOfferTemplate(ot1);

        Offer_Template__c ot2 = TestData.createOfferTemplate(prod, false);
        ot2.Eligibility_Criteria_Int__c = '1 OR 2 OR 3 OR 4 OR 5 OR 6<br>' +
                                          'account;billingcountry;neq;Belgium,France<br>' +
                                          'account;NumberOfEmployees;neq;100<br>' +
                                          'account;S_Score__c;neq;30<br>' +
                                          'account;Account_Created_On__c;neq;2011-01-01<br>' +
                                          'account;Billing_Address_Validated__c;neq;true<br>' +
                                          'account;Deactivation_Date__c;neq;2011-01-01 08:00:00<br>';
        TST_OfferTemplateTestHelper.activateOfferTemplate(ot2);

        Offer_Template__c ot3 = TestData.createOfferTemplate(prod, false);
        ot3.Eligibility_Criteria_Int__c = '1 OR 2 OR 3 OR 4<br>' +
                                          'account;NumberOfEmployees;lt;100<br>' +
                                          'account;S_Score__c;lt;30<br>' +
                                          'account;Account_Created_On__c;lt;2011-01-01<br>' +
                                          'account;Deactivation_Date__c;lt;2011-01-01 08:00:00<br>';
        TST_OfferTemplateTestHelper.activateOfferTemplate(ot3);

        Offer_Template__c ot4 = TestData.createOfferTemplate(prod, false);
        ot4.Eligibility_Criteria_Int__c = '1 OR 2 OR 3 OR 4<br>' +
                                          'account;NumberOfEmployees;gt;100<br>' +
                                          'account;S_Score__c;gt;30<br>' +
                                          'account;Account_Created_On__c;gt;2011-01-01<br>' +
                                          'account;Deactivation_Date__c;gt;2011-01-01 08:00:00<br>';
        TST_OfferTemplateTestHelper.activateOfferTemplate(ot4);

        Offer_Template__c ot5 = TestData.createOfferTemplate(prod, false);
        ot5.Eligibility_Criteria_Int__c = '1 OR 2 OR 3 OR 4<br>' +
                                          'account;NumberOfEmployees;leq;100<br>' +
                                          'account;S_Score__c;leq;30<br>' +
                                          'account;Account_Created_On__c;leq;2011-01-01<br>' +
                                          'account;Deactivation_Date__c;leq;2011-01-01 08:00:00<br>';
        TST_OfferTemplateTestHelper.activateOfferTemplate(ot5);

        Offer_Template__c ot6 = TestData.createOfferTemplate(prod, false);
        ot6.Eligibility_Criteria_Int__c = '1 OR 2 OR 3 OR 4<br>' +
                                          'account;NumberOfEmployees;geq;100<br>' +
                                          'account;S_Score__c;geq;30<br>' +
                                          'account;Account_Created_On__c;geq;2011-01-01<br>' +
                                          'account;Deactivation_Date__c;geq;2011-01-01 08:00:00<br>';
        TST_OfferTemplateTestHelper.activateOfferTemplate(ot6);


        Offer_Template__c ot7 = TestData.createOfferTemplate(prod, false);
        ot7.Eligibility_Criteria_Int__c = '1 OR 2 OR 3 OR 4 OR 5 OR 6<br>' +
                                          'account;billingcountry;cont;Belgium,France<br>' +
                                          'account;NumberOfEmployees;cont;100<br>' +
                                          'account;S_Score__c;cont;30<br>' +
                                          'account;Account_Created_On__c;cont;2011-01-01<br>' +
                                          'account;Billing_Address_Validated__c;cont;true<br>' +
                                          'account;Deactivation_Date__c;cont;2011-01-01 08:00:00<br>';
        TST_OfferTemplateTestHelper.activateOfferTemplate(ot7);

        Offer_Template__c ot8 = TestData.createOfferTemplate(prod, false);
        ot8.Eligibility_Criteria_Int__c = '1 OR 2 OR 3 OR 4<br>' +
                                          'account;billingcountry;ncont;Belgium,France<br>' +
                                          'account;NumberOfEmployees;ncont;100<br>' +
                                          'account;S_Score__c;ncont;30<br>' +
                                          'account;Account_Created_On__c;ncont;2011-01-01<br>';
        TST_OfferTemplateTestHelper.activateOfferTemplate(ot8);

        Offer_Template__c ot9 = TestData.createOfferTemplate(prod, false);
        ot9.Eligibility_Criteria_Int__c = '1 OR 2 OR 3 OR 4<br>' +
                                          'account;billingcountry;str;Belgium,France<br>' +
                                          'account;NumberOfEmployees;str;100<br>' +
                                          'account;S_Score__c;str;30<br>' +
                                          'account;Account_Created_On__c;str;2011-01-01<br>';
        TST_OfferTemplateTestHelper.activateOfferTemplate(ot9);

        Offer_Template__c ot10 = TestData.createOfferTemplate(prod, false);
        ot10.Eligibility_Criteria_Int__c = '1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 9<br>' +
                                           'user;email;eq;nicolas.dolet@atos.net<br>' +
                                           'user;phone;eq;+33 123456789<br>' +
                                           'user;Name;lt;foo<br>' +
                                           'user;Name;gt;bar<br>' +
                                           'user;Division;leq;foo<br>' +
                                           'user;Division;geq;bar<br>' +
                                           'user;isActive;eq;true<br>' +
                                           'user;PostalCode;cont;11<br>' +
                                           'user;Username;ncont;test<br>';

        TST_OfferTemplateTestHelper.activateOfferTemplate(ot10);

    }

}