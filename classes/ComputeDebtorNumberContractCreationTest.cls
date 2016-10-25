/**
 * @author Nicolas Dolet
 * @date 17/01/2012
 * @description Test triggers ComputeDebtorNumber & ContractCreation
 */
@isTest
public class ComputeDebtorNumberContractCreationTest 
{
    public static testMethod void testTrigger()
    {
    	TST_CustomSettingTestHelper.initAll(new string[] {'France', 'Belgium'});
        Account acc = TST_AccountTestHelper.createDummyAccount(true);
        Contract ctr = TestData.createTestContract(acc.Id);
    }
}