/**
* @author       Andrei Lobkis (andrei_lobkis@epam.com)
* @date         2015 October 21
* @description  Test for CtrlSubscriptionStatusChange
**/
@isTest
public class CtrlSubscriptionStatusChangeTest 
{
    static Subscription__c subs;
    static Contract contract;
    static Account acc;
    static Opportunity opp;
    public static testMethod void test()
    {
        CtrlSubscriptionStatusChange cssc;
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        createTestObjects();
        acc = [Select Id, Name, AccountNumber From Account];
        subs = [Select Id, Status__c, Name From Subscription__c];
        cssc = new CtrlSubscriptionStatusChange();
        List<system.SelectOption> options = cssc.getOptions();
        system.assert(options.size() != 0,'controller hasn\'t returned correct number of statuses');
        system.assert(apexpages.getMessages().size() == 0,'there must not be messages');
        cssc.strSubsId='1';
        cssc.selectSubs();
        system.assert(apexpages.getMessages().size() == 1,'there must be 1 message');
        cssc.strSubsId=acc.id;
        cssc.selectSubs();
        system.assert(apexpages.getMessages().size() == 2,'there must be 2 messages');
        cssc.strSubsId = subs.Id;
        cssc.selectSubs();
        system.assert(cssc.subsName == subs.Name,'controller returned wrong subscription name');
        system.assert(cssc.subsAccName == acc.Name,'controller returned wrong account name');
        system.assert(cssc.subsAccNumber == acc.AccountNumber,'controller returned wrong account number');
        system.assert(cssc.choosenStatus == subs.Status__c,'controller returned wrong subscription status');
        cssc.choosenStatus='Active';
        cssc.save();
        subs=[Select Id, Status__c From Subscription__c];
        system.assert(subs.Status__c == 'Active','controller returned wrong subscription status');
    }
    private static void createTestObjects()
    {
        acc = TST_AccountTestHelper.createDummyAccount('Belgium', true);
        opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'name';
        opp.StageName = '01 New';
        opp.CloseDate = date.today();
        insert opp;
        contract = new Contract();
        contract.AccountId = acc.id;
        insert contract;
        contract = [Select Id from Contract];
        subs = new Subscription__c();
        subs.Name ='test subs';
        subs.Contract__c = contract.id;
        subs.Account__c = acc.id;
        insert subs;
    }
}