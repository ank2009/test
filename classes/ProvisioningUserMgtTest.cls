/**
 * @author Nicolas Dolet
 * @date 20/12/2011
 * @description Test ProvisioningUserMgt
 */
@isTest
public class ProvisioningUserMgtTest
{
    public static testMethod void test()
    {
        // -------------
        // Data creation
        // -------------

        // Services
        List<ID> services = TestData.createTestServices(10);

        // Service Attributes
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);

        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);

        // Product
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;

        // Account
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount('France',true);
		List<Contact> cList = TST_ContactTestHelper.createDummyContactList(a, 10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        // Contacts
        List<ID> contactsForSub = new List<Id>();
        for(integer i=0;i<5;i++)
        	contactsForSub.add(cList[i].Id);
        List<ID> contacts       = new List<Id>();
        for(integer i=5;i<10;i++)
        	contacts.add(cList[i].Id);

        // Contract
        Id contractId = TestData.createTestContract(a.Id).Id;

        // Subscription
        Id subsId = TestData.createTestSubscription(productId, contractId).Id;

        // Subscription Users
        List<ID> subsUsers = TestData.createTestSubscriptionUsers(subsId, contactsForSub);

        // Provisioning
        Provisioning__c provisioning = TestData.createTestProvisioningAndServices(subsId, contractId, a.Id);
        Map<ID, List<ID>> provServices = TestData.createTestProvisioningHierarchy(provisioning.Id, servWithServAttributes);

        // Rights Template
        Rights_Template__c rightsTpl = TestData.createRightsTemplate(provisioning, true);

        // Page preparation
        PageReference pageRef = Page.ProvisioningWizardS1;

        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', provisioning.Id);

        ProvisioningUserMgt controller = new ProvisioningUserMgt(new ApexPages.StandardController(provisioning));

        // Test Cancel
        String cancelPage = controller.Cancel().getUrl();
        System.AssertEquals('/' + provisioning.Id, cancelPage);

        // First checks via getters Page 1
        controller.init0();

        System.AssertEquals(1, controller.getFilterFldOpt().size());
        System.AssertEquals(4, controller.getFilterOpOpt().size());
        System.AssertEquals(5, controller.getContactPreList().size());
        System.AssertEquals(5, controller.getDisplayedList().size());
        System.AssertEquals(5, controller.getContactList().size());
       // System.AssertEquals(2, controller.accountOptions.size());
        //System.AssertEquals(2, controller.accountNbOptions.size());
        //System.AssertEquals(2, controller.tlrNbOptions.size());
        //System.AssertEquals(1, controller.dnOptions.size());
        //System.AssertEquals(2, controller.bilCtrOptions.size());
       // System.AssertEquals(2, controller.cityOptions.size());

        // Test selectAll and selectAllPre methods
        controller.selAll    = true;
        controller.selAllPre = true;
        controller.selectAll();
        controller.selectAllPre();
/*
        Integer nbSelected    = 0;
        Integer nbSelectedPre = 0;
        for (ProvisioningUserMgt.WrapperSelectedContact u : controller.getContactList())
        {
            if (u.selected)
                nbSelected++;
        }
        for (ProvisioningUserMgt.WrapperSelectedContact u : controller.getContactPreList())
        {
            if (u.selected)
                nbSelectedPre++;
        }
        System.AssertEquals(5, nbSelected);
        System.AssertEquals(5, nbSelectedPre);

        // First checks via getters Page 2
        controller.init2();

        System.AssertEquals(6, controller.getFieldsContact().size());
        System.AssertEquals(1, controller.getNewContacts().size());
        System.AssertEquals(1, controller.nbCreated);

        // Test addNewContact
        controller.addNewContact();
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.Assert(messages[messages.size() - 1].getSummary().contains('Missing Field:'));

        controller.getNewContacts()[0].getFields()[0].value = 'Test';
        controller.getNewContacts()[0].getFields()[1].value = 'User';
        controller.getNewContacts()[0].getFields()[2].value = 'Male';
        controller.getNewContacts()[0].getFields()[3].value = 'French';
        controller.getNewContacts()[0].getFields()[4].value = 'Phone';
        controller.getNewContacts()[0].getFields()[5].value = 'Email';

        controller.addNewContact();
        messages = ApexPages.getMessages();
        System.AssertEquals('Phone must be International format, e.g: +99 12345678', messages[messages.size() - 1].getSummary());

        controller.getNewContacts()[0].getFields()[4].value = '+33 123456789';

        controller.addNewContact();
        messages = ApexPages.getMessages();
        System.AssertEquals('Invalid Email Address', messages[messages.size() - 1].getSummary());

        controller.getNewContacts()[0].getFields()[5].value = 'test@test.com';

        controller.addNewContact();
        System.AssertEquals(2, controller.getNewContacts().size());
        System.AssertEquals(2, controller.nbCreated);

        // Test rmvContact
        controller.indexContact = 1;
        controller.rmvContact();
        System.AssertEquals(1, controller.getNewContacts().size());
        System.AssertEquals(1, controller.nbCreated);

        // Test checkAndRedirect
        String checkAndRedirectPage = controller.checkAndRedirect(true).getUrl();
        System.AssertEquals(Page.ProvisioningWizardS3.getUrl(), checkAndRedirectPage);

        // First checks via getters Page 3
        controller.init3();

        System.Assert(controller.getAvailableCUGs().size() > 1);
        System.Assert(controller.getAvailablePUGs().size() > 0);
        System.AssertEquals(10, controller.getServiceHeaders().size());
        for (ProvisioningUserMgt.WrapperService ws : controller.getServiceHeaders())
            System.AssertEquals(2, ws.serviceAttr.size());

        System.AssertEquals(0, controller.getPackageHeaders().size());
        System.AssertEquals(true, controller.noPackages);
        System.AssertEquals(1, controller.getRightsTemplates().size());
        System.AssertEquals(10, controller.getUsers().size());

        // Test selectAllContact method
        controller.selAllUsers = true;
        controller.selectAllContacts();

        nbSelected = 0;
        for (ProvisioningUserMgt.WrapperUser u : controller.getUsers())
        {
            if (u.userSelected)
                nbSelected++;
        }
        System.AssertEquals(10, nbSelected);

        // Test applyRT
        for (ProvisioningUserMgt.WrapperUser u : controller.getUsers())
        {
            for (ProvisioningUserMgt.WrapperService s : u.getCurrentSelection().services)
            {
                s.checked = true;

                for (ProvisioningUserMgt.WrapperServiceAttr sa : s.serviceAttr)
                    sa.checked = true;
            }
        }

        System.AssertEquals(true, controller.getUsers()[0].getCurrentSelection().services[0].checked);

        controller.rightsTemplate = controller.getRightsTemplates()[0].getValue();
        controller.applyRT();

        System.AssertEquals(false, controller.getUsers()[0].getCurrentSelection().services[0].checked);
        messages = ApexPages.getMessages();
        System.AssertEquals('User Rights applied to 10 contacts.', messages[messages.size() - 1].getSummary());

        // Test applyCUG
        System.AssertEquals(controller.getAvailableCUGs()[0].getValue(), controller.getUsers()[0].getCurrentSelection().cug);

        controller.selectedCUG = controller.getAvailableCUGs()[2].getValue();
        controller.applyCUG();

        System.AssertEquals(controller.getAvailableCUGs()[2].getValue(), controller.getUsers()[0].getCurrentSelection().cug);

        // Test applyPUGs
        System.AssertEquals(0, controller.getUsers()[0].getCurrentSelection().pugs.size());

        controller.selectedPUGs = new List<String>{controller.getAvailablePUGs()[2].getValue()};
        controller.applyPUGs();

        System.AssertEquals(1, controller.getUsers()[0].getCurrentSelection().pugs.size());

        // Test applyService
        System.AssertEquals(false, controller.getUsers()[0].getCurrentSelection().services[3].checked);

        controller.serviceToApply = 3;
        controller.getServiceHeaders()[3].checked = true;
        controller.applyService();

        System.AssertEquals(true, controller.getUsers()[0].getCurrentSelection().services[3].checked);

        // Test applyServiceAttribute
        System.AssertEquals(false, controller.getUsers()[0].getCurrentSelection().services[4].checked);
        System.AssertEquals(false, controller.getUsers()[0].getCurrentSelection().services[4].serviceAttr[1].checked);

        controller.serviceToApply = 4;
        controller.serviceAttrToApply = 1;
        controller.getServiceHeaders()[4].serviceAttr[1].checked = true;
        controller.applyServiceAttribute();

        System.AssertEquals(true, controller.getUsers()[0].getCurrentSelection().services[4].serviceAttr[1].checked);
        System.AssertEquals(true, controller.getUsers()[0].getCurrentSelection().services[4].checked);

        // Test Finish
        controller.Finish();
        System.AssertEquals(10, controller.userProfileIds.size());

        Map<ID, List<User_Profile_Service__c>> upServices = ProvisioningMessages.getUserProfileServices(new List<Id>{controller.userProfileIds[0]});
        System.AssertEquals(2, upServices.get(controller.userProfileIds[0]).size());
        System.AssertEquals(0, upServices.get(controller.userProfileIds[0])[0].User_Profile_Service_Attributes__r.size());
        System.AssertEquals(1, upServices.get(controller.userProfileIds[0])[1].User_Profile_Service_Attributes__r.size());

        // Test CreateUserProfile
        Contact contactUnique = TestData.createTestContact(accountId);
        Id createdUpId = controller.CreateUserProfile(contactUnique.Id);
        List<User_Profile__c> insertedUp = [SELECT Id
                                            FROM User_Profile__c
                                            WHERE Provisioning__c = :provisioning.Id
                                            AND Contact__c = :contactUnique.Id];

        System.AssertEquals(1, insertedUp.size());
        System.AssertEquals(createdUpId, insertedUp[0].Id);

        // Test AddProductRights
        Map<ID, List<Id>> rtServices = TestData.createTestRightsTemplateHierarchy(rightsTpl.Id, servWithServAttributes);

        controller.AddProductRights(createdUpId);
        upServices = ProvisioningMessages.getUserProfileServices(new List<Id>{createdUpId});
        System.AssertEquals(10, upServices.get(createdUpId).size());
*/
        // Test AddFlashRights
        /*controller.AddFlashRights(createdUpId, 'Flash_subscription', '1 Month');
        upServices = ProvisioningMessages.getUserProfileServices(new List<Id>{createdUpId});
        System.AssertEquals(21, upServices.get(createdUpId).size());*/
    }
}