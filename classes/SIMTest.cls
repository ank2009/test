/**
 * @author Nicolas Dolet
 * @date 23/12/2011
 * @description Test CtrlEditRightsTemplate
 */
@isTest
public class SIMTest
{
    public static testMethod void test()
    {
		Test.setMock(WebServiceMock.class, new TST_GenericWebSericeMock());
        // Data generation
        List<ID> services = TestData.createTestServices(10);
        Map<ID, Integer> serviceNbSA = new Map<ID, Integer>();
        for (ID id : services)
            serviceNbSA.put(id, 2);
            
        Map<ID, List<ID>> servWithServAttributes = TestData.createTestServiceAttributes(serviceNbSA);
        Id productId = TestData.createTestProductAndLineItems(services, false, true).Id;
        TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account a = TST_AccountTestHelper.createDummyAccount(true);
		List<Contact> cList = TST_ContactTestHelper.createDummyContactList(a, 10, TLR_RecordTypeHelper.getId('Contact', 'TLR Contact'), true);
		Test.StartTest();
        SIM.IndividualSoap indivSoap = new SIM.IndividualSoap();
        
        SIM.ArrayOfProperty changes = new SIM.ArrayOfProperty();
        indivSoap.createUser(cList[0].Id, changes);
        
        SIM.ArrayOfProperty inputData = new SIM.ArrayOfProperty();
        SIM.TriggerCampaignForUserResponse_element response = indivSoap.TriggerCampaignForUser(cList[0].Id,'APPROVAL_PROCESS_QUALIF', inputData);
        
        Test.StopTest();
    }

}