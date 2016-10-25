@isTest
public class CtrlTechnicalSalesTest {
    
    static Account acc;
    static Opportunity opp;
    static Event eventacc;
    static Event eventopp;
    
    
	public static testMethod void TestUpdatingFromAccount()
    {
        createTestData();
        ApexPages.currentPage().getParameters().put('id', acc.Id);
        acc.TMS_Other__c = '1';
        update acc;
        CtrlTechnicalSales  controller = new CtrlTechnicalSales();
        controller.editMode = true;
        controller.acc.TMS_Other__c = '2';
        PageReference ref = controller.Save();
        acc = [select Id, TMS_Other__c from Account where Id =: acc.Id];
        system.assert(acc.TMS_Other__c == '2', 'Field wasn\'t updated from Account page');
        system.assert(ref.getUrl() == (new PageReference ('/'+acc.Id)).getUrl(),'Return URL is incorrect: must be Account page');
        
    }
    
    public static testMethod void TestCancelFromAccount()
    {
        createTestData();
        ApexPages.currentPage().getParameters().put('id', acc.Id);
        CtrlTechnicalSales  controller = new CtrlTechnicalSales();
        controller.editMode = true;
        PageReference ref = controller.Cancel();
        string u = ref.getUrl();
        string h = (new PageReference ('/apex/TechnicalSales?id='+acc.Id)).getUrl();
        system.assert(ref.getUrl() == (new PageReference ('/apex/TechnicalSales?id='+acc.Id)).getUrl(),'Return URL is incorrect: must be Technical Sales page');
        controller.editMode = false;
        ref = controller.Cancel();
        system.assert(ref.getUrl() == (new PageReference ('/'+acc.Id)).getUrl(),'Return URL is incorrect: must be Account page');
        
    }
    
    public static testMethod void TestUpdatingFromAccountsEvent()
    {
        createTestData();
        ApexPages.currentPage().getParameters().put('id', eventacc.WhatId);
        ApexPages.currentPage().getParameters().put('activityId', eventacc.Id);
        acc.TMS_Other__c = '1';
        update acc;
        CtrlTechnicalSales  controller = new CtrlTechnicalSales();
        controller.acc.TMS_Other__c = '2';
        controller.editMode = true;
        PageReference ref = controller.Save();
        acc = [select Id, TMS_Other__c from Account where Id =: acc.Id];
        system.assert(acc.TMS_Other__c == '2', 'Field wasn\'t updated from Account\'s Event page');
        system.assert(ref.getUrl() == (new PageReference ('/'+eventacc.Id)).getUrl(),'Return URL is incorrect: must be Event page');        
    }
    
    public static testMethod void TestCancelFromAccountsEvent()
    {
        createTestData();
        ApexPages.currentPage().getParameters().put('id', eventacc.WhatId);
        ApexPages.currentPage().getParameters().put('activityId', eventacc.Id);
        CtrlTechnicalSales  controller = new CtrlTechnicalSales();
        controller.editMode = false;
        PageReference ref = controller.Cancel();
        system.assert(ref.getUrl() == (new PageReference ('/'+eventacc.Id)).getUrl(),'Return URL is incorrect: must be Event page');        
    }
    
	public static testMethod void TestUpdatingFromOpprtunityEvent()
    {    
        createTestData();
        ApexPages.currentPage().getParameters().put('id', eventopp.WhatId);
        ApexPages.currentPage().getParameters().put('activityId', eventopp.Id);
        acc.TMS_Other__c = '1';
        update acc;
        try
        {
            CtrlTechnicalSales  controller = new CtrlTechnicalSales();
            system.assert(false,'Attempt to open page from Opportunity Event didn\'t cause exception'); 
        }
        catch(Exception e)
        {
        }
        eventopp.WhatId = null;
        update eventopp;
        ApexPages.currentPage().getParameters().put('id', eventopp.WhatId);
        ApexPages.currentPage().getParameters().put('activityId', eventopp.Id);
        try
        {
            CtrlTechnicalSales  controller = new CtrlTechnicalSales();
            system.assert(false,'Attempt to open page from the Event with empty WhatId field didn\'t cause exception'); 
        }
        catch(Exception e)
        {
        }
    }
    
   
    
    private static void createTestData()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
		acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
        eventacc = TST_TaskAndEventTestHelper.createEvent(acc.Id, true);
        opp = TestData.createTestOpportunity(acc.Id);
        eventopp = TST_TaskAndEventTestHelper.createEvent(opp.Id, true);
    }
    
}