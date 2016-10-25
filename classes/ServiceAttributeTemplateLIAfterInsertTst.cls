/**
 * @author Nicolas Dolet
 * @date 16/01/2012
 * @description Test trigger ServiceAttributeTemplateLIAfterInsert
 */
@isTest
public class ServiceAttributeTemplateLIAfterInsertTst {

    public static testMethod void testTrigger() {
    
        // Data generation
        Service__c s = TestData.createTestService();
        Service_Attribute_Template__c sat = TestData.createServiceAttributeTemplate(s);        
        Service_Attribute__c sa = TestData.createTestServiceAttribute(s.Id);
        Service_Attribute_Template_Line_Item__c satli = TestData.createServiceAttributeTemplateLineItem(sa, sat);
    
    }
    
}