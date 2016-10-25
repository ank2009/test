@isTest
private class TLR_MassCreationSubscCurrentFeesTest
{
    static testMethod void massCreationTest() 
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'st111', Email='standarduse1r@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1111', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Disable_Validation_Rules_and_Workflows__c = true,
            Disable_All_Triggers__c = true, Disable_ESB_Company_Type_Validation_Rule__c = true, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduse111@testorg.com');

        System.runAs(u)     
        {   //prepare test data
            TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
            Account acc = TST_AccountTestHelper.createDummyAccount(true);
            Product__c product = TST_ProductTestHelper.createDummyProduct('FX',TLR_RecordTypehelper.getId('Product__c', 'TLR Product'), true);
            TST_ProductTestHelper.updateDummyProductStatus(product, 'Pending Activation Approval', true);
            TST_ProductTestHelper.activateDummyProduct(product, true);
            Offer_Template__c off = TST_OfferTemplateTestHelper.createDummyOfferTemplate(product, TLR_RecordTypehelper.getId('Offer_Template__c', 'TLR Offer Template'), true);
            TST_OfferTemplateTestHelper.activateOfferTemplate(off);
            Opportunity opp = TST_OpportunityTestHelper.createDummyOpportunity(acc, off, TLR_RecordTypehelper.getId('Opportunity', 'WKTS Opportunity'), true);
            Contract con = TST_ContractTestHelper.createDummyContract(opp, TLR_RecordTypehelper.getId('Contract', 'TLR Contract'), true);
            Subscription__c sub = TST_SubscriptionTestHelper.createDummySubscription(con, opp, TLR_RecordTypehelper.getId('Subscription__c', 'TLR Subscription'), false);
            Subscription__c subNoPF = TST_SubscriptionTestHelper.createDummySubscription(con, opp, TLR_RecordTypehelper.getId('Subscription__c', 'TLR Subscription'), false);
            sub.Status__c = 'Pending';
            subNoPF.Status__c = 'Pending';
            insert (sub);
            insert(subNoPF);
            
            TST_SubscriptionTestHelper.AddPackagesAndLineItems(sub);            
            List<Subs_Package_And_Fee__c> subPack = [Select ID, Name From Subs_Package_And_Fee__c Where Subscription__c =: sub.Id];
            List<Subs_Current_Fee__c> fees = new List<Subs_Current_Fee__c>();
            for(Subs_Package_And_Fee__c f:subPack)
            {
                Subs_Current_Fee__c fee1 = new Subs_Current_Fee__c();
                fee1.Start_Date__c = date.today();
                fee1.End_Date__c = date.today().addDays(1);
                fee1.Name =  sub.Name = 'CD_' + f.Name;
                fee1.Subs_Package_And_Fee__c = f.Id;
                fee1.Account__c = sub.Account__c;
                fee1.Subscription__c = sub.Id;
                fee1.Price__c = 100;
                fees.add(fee1);
            }
            List<Subscription_Line_Item__c> subLine = [Select ID, Name From Subscription_Line_Item__c Where Subscription__c =: sub.Id];           
            for(Subscription_Line_Item__c f:subLine)
            {
                Subs_Current_Fee__c fee1 = new Subs_Current_Fee__c();
                fee1.Start_Date__c = date.today();
                fee1.End_Date__c = date.today().addDays(1);
                fee1.Name = f.Name;
                fee1.Subscription_Line_Item__c = f.Id;
                fee1.Account__c = sub.Account__c;
                fee1.Subscription__c = sub.Id;
                fee1.Price__c = 100;
                fees.add(fee1);
            }
            insert fees;
            
            
            //test
            PageReference pageRef = Page.MassCreationCurrentFees;
            Test.setCurrentPage(pageRef);
            // No PF
            ApexPages.currentPage().getParameters().put('id', subNoPF.Id);    
            TLR_MassCreationSubscCurrentFees controller1 = new TLR_MassCreationSubscCurrentFees(new ApexPages.StandardSetController(new List<Subscription__c>()));
    
            ApexPages.currentPage().getParameters().put('id', sub.Id);    
            TLR_MassCreationSubscCurrentFees controller = new TLR_MassCreationSubscCurrentFees(new ApexPages.StandardSetController(new List<Subscription__c>()));
            for(Integer i=0; i < 1; i++)
            {
                controller.viewPack.get(i).isSelected = true;
            }
            for(Integer i=0; i < 1; i++)
            {
                controller.viewLine.get(i).isSelected = true;
            }

            controller.Save();
            controller.commonStartDate = '12/20/2014';
            controller.ChangeDatePattern();
            controller.Cancel(); 
                        
            controller.viewPack.get(0).isSelected = true;
            controller.viewPack.get(0).isExist = false;
            controller.viewPack.get(0).subCurrFee.Name = 'DMS_Test_P_F';
            controller.viewPack.get(0).subCurrFee.End_Date__c = null;
            controller.viewLine.get(0).isSelected = true;
            controller.viewLine.get(0).isExist = false;
            controller.viewLine.get(0).subCurrFee.End_Date__c = Date.Today(); 
            controller.Save();
            
            Integer count = [Select Count() From Subs_Current_Fee__c where Subscription__c =: sub.Id];
            System.assertEquals(4,count);
            
            controller.getMaxEndDate('CD_', fees);

        }
    }    
}