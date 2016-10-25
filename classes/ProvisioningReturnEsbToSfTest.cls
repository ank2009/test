/**
 * @author Nicolas Dolet
 * @date 23/12/2011
 * @description Test ProvisioningReturnEsbToSf
 */
@isTest
public class ProvisioningReturnEsbToSfTest {

    /**
     * @author Nicolas Dolet
     * @date 23/12/2011
     * @description test provisioningReturn
     */
    public static testMethod void testProvisioningReturn()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
    	
        List<ID> services            = TestData.createTestServices(10);
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        Id productId                             = TestData.createTestProductAndLineItems(services, false, true).Id;
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        Id accountId                             = acc.Id;
        List<Contact> cList = TST_ContactTestHelper.createDummyContactList(acc, 3, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
        List<ID> contacts                        = new List<Id>();
        for(Contact c : cList) contacts.add(c.Id);
        Id contractId                            = TestData.createTestContract(accountId).Id;
        Id subsId                                = TestData.createTestSubscription(productId, contractId).Id;
        Provisioning__c provisioning             = TestData.createTestProvisioningAndServices(subsId, contractId, accountId);
        Map<ID, List<ID>> provServices           = TestData.createTestProvisioningHierarchy(provisioning.Id, servWithServAttributes); 
        Rights_Template__c rightsTpl             = TestData.createRightsTemplate(provisioning, true);
        List<ID> userProfiles                    = TestData.createTestUserProfiles(contacts, provisioning.Id, provServices);


        String login = 'FAKE LOGIN';
        Contact c = [SELECT Username__c FROM Contact WHERE Id =: contacts[0]];
        c.Username__c = login;
        update c;

        String transId = 'FAKE';
        Provisioning_Transaction__c pt = new Provisioning_Transaction__c();
        pt.TransactionId__c = transId;
        pt.Account__c = accountId;
        pt.Subscription__c = subsId;
        pt.Login__c = login;
        insert pt;
    
        ProvisioningReturnEsbToSf.AWL_CRM_ESB_Provisioning_Return_Type input = new ProvisioningReturnEsbToSf.AWL_CRM_ESB_Provisioning_Return_Type();
        input.transactionId = transId;
        input.objectId = accountId;
//        input.objectType = ;
//        input.status = ;
//        input.errorMessage = ;
//        input.login = ;

        ProvisioningReturnEsbToSf.provisioningReturn(input);
        pt.Contact__c = contacts[0];
        update pt;
        input.objectId = contacts[0];
        ProvisioningReturnEsbToSf.provisioningReturn(input);
        pt.Account__c = null;
        pt.Contact__c = null;
        update pt;
        input.objectId = subsId;
        ProvisioningReturnEsbToSf.provisioningReturn(input);

    }
}