/**
 * @author Nicolas Dolet
 * @date 16/01/2012
 * @description Test trigger UpdateDefaultFlagsDelete
 */
@isTest
public class UpdateDefaultFlagsDeleteTest {

    public static testMethod void testTrigger() {
    
        // Data generation
        Service__c s = TestData.createTestService();
        Service_Attribute_Template__c sat = TestData.createServiceAttributeTemplate(s);
        delete sat;
    
    }
    
}