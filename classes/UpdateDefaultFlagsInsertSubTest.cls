/**
 * @author Nicolas Dolet
 * @date 16/01/2012
 * @description Test trigger UpdateDefaultFlagsInsertSub
 */
@isTest
public class UpdateDefaultFlagsInsertSubTest {

    public static testMethod void testTrigger() {
    
        // This test method creates Subservice Templates
        Service__c s = TestData.createTestService();
        Subservice_Template__c sst = [SELECT Id FROM Subservice_Template__c WHERE Parent_Service__c =: s.Id];
    
    }

}