@isTest
public class CampaignMemberFollowUpTestData
{
    public static testMethod void createTestData()
    {
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        // Create Campaign, Account and Group Test Records
        Campaign testCampaign = new Campaign(name='test_campaign',status='Planned');
        Account testAccount = TST_AccountTestHelper.createDummyAccount(true);
        testAccount.NumberOfEmployees = 190;
        /*new Account(name='test_account', NumberOfEmployees=190, 
                                          BillingStreet = 'Rue de la pointe', BillingCity = 'Seclin',
                                          BillingPostalCode = '59113', BillingState = 'Nord',
                                          BillingCountry = 'France');*/
        //Group testQueueName = new Group(name='test_queue', Type='Queue');
        insert testCampaign;
        //insert testAccount;
        //insert testQueueName;
        
        //create Queue
        //testQueueName =[Select Type, Name, Id From Group where name = 'test_queue' order by name desc limit 1];
        //QueueSobject testQueue = new QueueSobject(QueueId=testQueueName.Id, SobjectType='Lead');
        //insert testQueue;
                    
        // Define Lists for Contact Lead and Campaign Member Test Records
        Contact[] testContactList = TST_ContactTestHelper.createDummyContactList(testAccount, 30, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        Lead[] testLeadList = TST_LeadTestHelper.createLeadList(30, true);
        CampaignMember[] testCampaignMemberList = new CampaignMember[]{};   
            
        // Query for newly created Test Campaign and Account
        testCampaign = [select id, name, status, ownerId from campaign where name = 'test_campaign' order by name desc limit 1];
        //testAccount = [select id, name from account where name = 'test_account'];
        //testQueue = [Select SobjectType, QueueId, Id From QueueSobject where QueueId =:testQueueName.Id limit 1];
        
        //insert testContactList;
            
        // Create 30 Test Leads
        /*for(Integer i = 0; i < 30; i++){
            testLeadList.add(new Lead(lastname='test_lead_' + i, Title='Sales Manager', company='test_company_' + i, NumberOfEmployees=150, PostalCode='806'+i, Phone='+33 000000000' ));
        }*/
        //testLeadList.add(new Lead(lastname='test_lead_Queue', company='test_company_Queue', OwnerId=testQueueName.Id));       
        //insert testLeadList;
            
        // Query for newly created Test Contacts and Leads
        testContactList = [select id, name from contact where name like 'test_contact_%' order by name];
        testLeadList = [select id, name from lead where name like 'test_lead_%' order by name];
            
        // Assign Test Contacts to Test Campaign
        for(Integer x = 0; x < testContactList.size(); x++){
            testCampaignMemberList.add(new CampaignMember(
                campaignId = testCampaign.Id,
                contactId = testContactList[x].Id, 
                status = 'Sent'));
        }
            
        // Assign Test Leads to Test Campaign
        for(Integer y = 0; y < testLeadList.size(); y++){
            testCampaignMemberList.add(new CampaignMember(
                campaignId = testCampaign.Id,
                leadId = testleadList[y].Id,
                status = 'Sent'));
        }       
            
        // Insert List of Test Campaign Members
        insert testCampaignMemberList;
    }
}