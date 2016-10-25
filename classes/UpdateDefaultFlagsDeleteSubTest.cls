/**
 * @author Nicolas Dolet
 * @date 16/01/2012
 * @description Test trigger UpdateDefaultFlagsDeleteSub
 */
@isTest
public class UpdateDefaultFlagsDeleteSubTest {

    public static testMethod void testTrigger() {
    
        Service__c s = TestData.createTestService();
        Subservice_Template__c sst = [SELECT Id FROM Subservice_Template__c WHERE Parent_Service__c =: s.Id];
        delete sst;
    
    }
    
}