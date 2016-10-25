/**
 * @author AK
 * @date 26/12/2011
 */
@isTest
public class CtrlProvisioningLinksTest{

    public static testMethod void testCtrlProvisioningLinks(){

    Test.startTest(); 
    // Data generation
    TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
    List<ID> servIds=TestData.createTestServices(1);
    Product__c prod=TestData.createTestProductAndLineItems(servIds, false, true);
    Account acc = TST_AccountTestHelper.createDummyAccount(true);
    Contact con = TST_ContactTestHelper.createDummyContact(acc, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
    Contract contr =TestData.createTestContract(acc.Id);
    Subscription__c subs=TestData.createTestSubscription(prod.Id, contr.Id);
    Provisioning__c Prov=TestData.createTestProvisioningAndServices(subs.Id,contr.Id,acc.Id); 
    User_Profile__c UserProfile=new User_Profile__c();
    UserProfile.Provisioning__c=Prov.Id;
    UserProfile.Contact__c=con.Id;
    UserProfile.Product__c=prod.Id;
    UserProfile.Username__c=con.Username__c;
    UserProfile.Account_name__c=acc.Id;
    
    // Page preparation
    PageReference pageRef=Page.ProvisioningLinks;
    Test.setCurrentPage(pageRef);
    
    ApexPages.currentPage().getParameters().put('id', con.Id);
    CtrlProvisioningLinks controller = new CtrlProvisioningLinks(new ApexPages.StandardController(con));
    
    controller.getLinks();
    
    // Test save
    subs.Status__c = 'Sent';
    update subs;
    subs.Status__c = 'Waiting For Verification';
    subs.Flag_IntegrityChecks__c =true;
    subs.Required_Documents__c=true;
    subs.Payment_information__c=true;
    update subs;
    subs.Status__c = 'Waiting For Provisioning';
    update subs;
    subs.Status__c = 'Provisioning initiated';
    update subs;
    controller = new CtrlProvisioningLinks(new ApexPages.StandardController(con));
    controller.getLinks();
    
    Test.stopTest();
        
    }
}