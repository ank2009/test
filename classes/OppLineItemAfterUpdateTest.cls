@isTest
public class OppLineItemAfterUpdateTest
{
    public static testMethod void testTrigger() 
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        // Data generation
        ID OpportunityID= TestData.createTestOpportunity(acc.Id).Id;
        
        List<Opportunity_Line_Item__c> oppLI = TestData.createTestOpportunityWithLI(acc.Id, 1);
        Opportunity_Line_Item__c Opp = [Select Id, Name
                                FROM Opportunity_Line_Item__c where Id in : oppLI ];
        
        //Opp.Opportunity__c=OpportunityID;
        Opp.Consolidation_Level__c ='Company';
        update Opp;

    }
}