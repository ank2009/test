/**
 * @author Nicolas Dolet
 * @date 16/01/2012
 * @description Test trigger UpdateDefaultFlagsUpdate
 */
@isTest
public class UpdateDefaultFlagsUpdateTest {

    public static testMethod void testTrigger() {
    
        // Data generation
        Service__c s = TestData.createTestService();
        Service_Attribute_Template__c sat = TestData.createServiceAttributeTemplate(s);
        sat.End_Date__c = Date.today() + 1;
        update sat;
    
    }

}