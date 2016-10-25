/**
 * @author Nicolas Dolet
 * @date 16/01/2012
 * @description Test trigger UpdateDefaultFlagsInsert
 */
@isTest
public class UpdateDefaultFlagsInsertTest {

    public static testMethod void testTrigger() {
    
        // Data generation
        Service__c s = TestData.createTestService();
        Service_Attribute_Template__c sat = TestData.createServiceAttributeTemplate(s);       
    
    }
}