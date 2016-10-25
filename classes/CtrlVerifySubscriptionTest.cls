/**
 * @author AK
 * @date 26/12/2011
 */

@isTest
public class CtrlVerifySubscriptionTest {

    public static testMethod void testCtrlVerifySubscription() {

    /* moved to new controller
        // Data generation
        List<ID> servIds = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(servIds, false, true);
        Account acc = TestData.createTestAccounts();
        Contract contr = TestData.createTestContract(acc.Id);
        Subscription__c subs = TestData.createTestSubscription(prod.Id, contr.Id);
        subs.Status__c = 'Sent';
        update subs;
        // Mandatory Integrity Checks(If at least one of Mandatory Checks is not checked shall be NOK )
        subs.AllDocuments_OK__c=true;
        subs.ComRegNum_OK__c=true;
        subs.ComFoundDate_6Months_OK__c=true;
        subs.TransLicNum_OK__c = true;
        subs.KeyContact_OK__c = true;
        subs.AddressInformation_OK__c = true;
        subs.BankAccountInformation_OK__c = true;
        subs.PhoneNumIsChecked_OK__c= true;
        subs.MobilePhoneNumIsChecked_OK__c = true;
        subs.EmailIsChecked_OK__c = true;
       //Background & Antecedents checks (If one of the two Background fields is not checked shall be NOK)
        subs.OldCustomer_OK__c = true;
        subs.DebtOutstanding_OK__c = true;
        //External Credit Report (If High Risk or Medium Risk shall be NOK)
        subs.Lrisk_OK__c = true;
        update subs;

        // Page preparation
        PageReference pageRef = Page.VerifySubscription;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', subs.Id);

        CtrlVerifySubscription controller = new CtrlVerifySubscription(new ApexPages.StandardController(subs));

        controller.init();
        subs.Status__c='Waiting For Verification';
        update subs;
        controller = new CtrlVerifySubscription(new ApexPages.StandardController(subs));
        controller.getSubs();
        // Test correct save
        String correctSave = controller.Save().getUrl();
        System.assertEquals('/' + subs.Id, correctSave);

        Account acc1 = TestData.createTestAccounts();
        Contract contr1 = TestData.createTestContract(acc1.Id);
        Subscription__c subs1 = TestData.createTestSubscription(prod.Id, contr1.Id);
        subs1.Status__c = 'Sent';
        update subs1;
        subs1.Status__c='Waiting For Verification';
        subs1.Mrisk_OK__c=true;
        update subs1;

        ApexPages.currentPage().getParameters().put('id', subs1.Id);
        controller = new CtrlVerifySubscription(new ApexPages.StandardController(subs1));
        controller.init();
        controller.getSubs();
        String SV = controller.Save().getUrl();
        System.assertEquals('/'+ subs1.Id, SV);
        */
    }

}