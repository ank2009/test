@isTest
public class CreateProvisioningExtTest
{
    public static testMethod void testCreateProvisioningExt()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        // Data preparation
        // Services
        List<ID> services = TestData.createTestServices(3);
        ID serviceAddOn   = TestData.createTestService().Id;

        // Service Attribute
        Service_Attribute_Template__c ServAttrTpl = new Service_Attribute_Template__c();
        ServAttrTpl.Name                          = 'Test Service Attribute Template';
        ServAttrTpl.Parent__c                     = services[0];
        ServAttrTpl.Start_Date__c                 = Date.Today();
        insert ServAttrTpl;

        Service_Attribute__c servAttribute = TestData.createTestServiceAttribute(services[0]);

        Service_Attribute_Template_Line_Item__c ServAttrTplLI = new Service_Attribute_Template_Line_Item__c();
        ServAttrTplLI.Service_Attribute__c                    = servAttribute.Id;
        ServAttrTplLI.Service_Attribute_Template__c           = ServAttrTpl.Id;
        insert ServAttrTplLI;

        // Product
        Product__c product = TestData.createTestProductAndLineItems(services, false, true);
        Product__c addOn   = TestData.createTestProductAndLineItems(new List<ID>{serviceAddOn}, true, false);
        Add_on_Parent__c parent = new Add_on_Parent__c();
        parent.Product__c = product.Id;
        parent.Add_on__c  = addOn.Id;
        insert parent;
        addOn.Status__c = 'Pending Activation Approval';
        update addOn;
        addOn.Status__c = 'Active';
        update addOn;

        services.add(serviceAddOn);

        // Offer Template
        Offer_Template__c ot              = TestData.createOfferTemplate(product, false);
        Rights_Template_Default__c rtD    = TestData.createRightsTemplateDefault(ot,true);
        List<Offer_Line_Item__c> offerLIs = TestData.createTestOfferTemplateHierarchy(ot.Id, services);

        Offer_Line_Item__c oliToUpdate = [SELECT Id, Service_Attribute_Template__c
                                          FROM Offer_Line_Item__c
                                          WHERE Id IN :offerLIs AND Service__c = :services[0]];

        oliToUpdate.Service_Attribute_Template__c = ServAttrTpl.Id;
        update oliToUpdate;
        //if(ot.Status__c != 'Active') ot.Status__c = 'Active';
        update ot;

        List<ID> offerLineItems = new List<ID>();
        for (Offer_Line_Item__c oli : offerLIs)
            offerLineItems.add(oli.Id);

        // Opportunity  (and Account)
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        Opportunity opp = TestData.createTestOpportunity(acc.Id);
        List<Opportunity_Line_Item__c> oppLIs = TestData.createTestOpportunityHierarchy(opp.Id, offerLineItems);

        opp.Offer_Template__c = ot.Id;
        update opp;

        List<ID> oppLineItems = new List<ID>();
        for (Opportunity_Line_Item__c oppli : oppLIs)
            oppLineItems.add(oppli.Id);

        // Contract
        Contract contract = TestData.createTestContract(opp.AccountId);
		Test.StartTest();
        // Subscriptions
        Subscription__c subs   = TestData.createTestSubscription(product.Id, contract.Id);
        subs.Offer_Template__c = null;
        subs.Product__c        = null;
        subs.Status__c         = 'Sent';
        update subs;
        subs.Status__c         = 'Waiting For Verification';
        update subs;
        subs.Flag_IntegrityChecks__c  = true;
        subs.Required_Documents__c  = true;
        subs.Payment_information__c = true;
        subs.Status__c              = 'Waiting For Provisioning';
        update subs;

        Subscription__c subs2   = TestData.createTestSubscription(product.Id, contract.Id);
        subs2.Offer_Template__c = ot.Id;
        subs2.Product__c        = null;
        subs2.Status__c         = 'Sent';
        update subs2;
        subs2.Status__c         = 'Waiting For Verification';
        update subs2;

        // Start Test
        

        PageReference pageRef = Page.CreateProvisioning;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', subs.Id);

        CreateProvisioningExt controller  = new CreateProvisioningExt(new ApexPages.StandardController(subs));
        CreateProvisioningExt controller2 = new CreateProvisioningExt(subs.Id);

        // Test 1 : Cancel
        System.AssertEquals('/' + subs.ID, controller.Cancel().getUrl());

        // Test 2 : init Fail - No Product
        try
        {
            controller.init();
            System.AssertEquals(true, false);
        }
        catch (Generic.StandardException e)
        {
            System.AssertEquals('Subscription error: Product field should not be empty', e.getMessage());
        }

        // Test 3 : init Fail - No Offer Template
        Subscription__c subsToUpdate = [SELECT Product__c FROM Subscription__c WHERE Id = : subs.Id];
        subsToUpdate.Product__c = product.Id;
        update subsToUpdate;

        controller  = new CreateProvisioningExt(new ApexPages.StandardController(subs));

        try
        {
            controller.init();
            System.AssertEquals(true, false);
        }
        catch (Generic.StandardException e)
        {
            System.AssertEquals('Subscription error: Offer Template field should not be empty', e.getMessage());
        }

        // Test 4 : init Success
        subsToUpdate = [SELECT Offer_template__c FROM Subscription__c WHERE Id = : subs.Id];
        subsToUpdate.Offer_template__c = ot.Id;
        update subsToUpdate;

        controller  = new CreateProvisioningExt(new ApexPages.StandardController(subs));

        controller.init();

        String keyPrefix = Schema.getGlobalDescribe().get('Provisioning__c').getDescribe().getKeyPrefix();
        System.Assert(((String)controller.getProv().Id).startsWith(keyPrefix));

        List<Provisioning_Service__c> provServs                = [SELECT Id FROM Provisioning_Service__c WHERE Provisioning__c = :controller.getProv().Id];
        List<Provisioning_Service_Attribute__c> provServAttrs  = [SELECT Id FROM Provisioning_Service_Attribute__c WHERE Provisioning_Service__c IN :provServs];
        List<Rights_Template__c> rightsTpls                    = [SELECT Id FROM Rights_Template__c WHERE Provisioning__c = :controller.getProv().Id];
        List<Rights_Template_Service__c> rtServs               = [SELECT Id FROM Rights_Template_Service__c WHERE Rights_Template__c IN :rightsTpls];
        List<Rights_Template_Service_Attribute__c> rtServAttrs = [SELECT Id FROM Rights_Template_Service_Attribute__c WHERE Rights_Template_Service__c IN :rtServs];

        System.AssertEquals(4, provServs.size());
        System.AssertEquals(1, provServAttrs.size());
        System.AssertEquals(1, rightsTpls.size());
       // System.AssertEquals(1, rtServs.size());
       // System.AssertEquals(1, rtServAttrs.size());

        String subsStatus = [SELECT Status__c FROM Subscription__c WHERE Id = : subs.Id].Status__c;
        System.AssertEquals('Provisioning initiated', subsStatus);

        // Test 5 : init Fail - Existing prov
        try
        {
            controller.init();
            System.AssertEquals(true, false);
        }
        catch (Generic.StandardException e)
        {
            System.AssertEquals('Provisioning already initiated, check the corresponding related list in subscription', e.getMessage());
        }

        // Test 6 : initInternal Fail - Bas Status
        ApexPages.currentPage().getParameters().put('id', subs2.Id);
        controller2 = new CreateProvisioningExt(new ApexPages.StandardController(subs2));

        controller2.initInternal();
        List<ApexPages.Message> lstMessages = ApexPages.getMessages();
        String lastMessage = lstMessages[lstMessages.size() - 1].getSummary();
        System.AssertEquals('Provisioning can be started only on subscriptions under \'Waiting for Provisioning\' status', lastMessage);

        // Test 7 : initInternal Fail - No Product
        subsToUpdate = [SELECT Data_Quality__c, Required_Documents__c, Payment_information__c, Status__c
                        FROM Subscription__c WHERE Id = : subs2.Id];
        subsToUpdate.Flag_IntegrityChecks__c = true;
        subsToUpdate.Status__c              = 'Waiting For Provisioning';
        update subsToUpdate;

        controller2 = new CreateProvisioningExt(new ApexPages.StandardController(subsToUpdate));

        controller2.initInternal();
        lstMessages = ApexPages.getMessages();
        lastMessage = lstMessages[lstMessages.size() - 1].getSummary();
        System.AssertEquals('Product field should not be empty', lastMessage);

        // Test 8 : initInternal Success
        subsToUpdate = [SELECT Product__c FROM Subscription__c WHERE Id = : subs2.Id];
        subsToUpdate.Product__c = product.Id;
        update subsToUpdate;

        controller2 = new CreateProvisioningExt(new ApexPages.StandardController(subsToUpdate));

        //lstMessages = ApexPages.getMessages();
        //lastMessage = lstMessages[lstMessages.size() - 1].getSummary();
        //System.AssertEquals('', lastMessage);

        String retUrl = controller2.initInternal().getUrl();
        keyPrefix     = Schema.getGlobalDescribe().get('Provisioning__c').getDescribe().getKeyPrefix();
        System.Assert(retUrl.startsWith('/' + keyPrefix));

        provServs      = [SELECT Id FROM Provisioning_Service__c WHERE Provisioning__c = :controller2.getProv().Id];
        provServAttrs  = [SELECT Id FROM Provisioning_Service_Attribute__c WHERE Provisioning_Service__c IN :provServs];
        rightsTpls     = [SELECT Id FROM Rights_Template__c WHERE Provisioning__c = :controller2.getProv().Id];
        rtServs        = [SELECT Id FROM Rights_Template_Service__c WHERE Rights_Template__c IN :rightsTpls];
        rtServAttrs    = [SELECT Id FROM Rights_Template_Service_Attribute__c WHERE Rights_Template_Service__c IN :rtServs];

        System.AssertEquals(4, provServs.size());
        System.AssertEquals(1, provServAttrs.size());
        System.AssertEquals(1, rightsTpls.size());
        //System.AssertEquals(1, rtServs.size());
       // System.AssertEquals(1, rtServAttrs.size());

        // Test 9 : initInternal Fail - Existing prov
        controller2.initInternal();
        lstMessages = ApexPages.getMessages();
        lastMessage = lstMessages[lstMessages.size() - 1].getSummary();
        System.AssertEquals('Provisioning already initiated, check the corresponding related list in subscription', lastMessage);

        Test.StopTest();
    }
}