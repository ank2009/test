/**
 * @author Nicolas Dolet
 * @date 16/01/2012
 * @description Test trigger CheckBillableSubservicesBeforeActivation
 */
@isTest
public class CheckBillableSubsrvBeforeActivationTest {

    public static testMethod void testTrigger() {
    
        Service__c s = TestData.createTestService();
        s.Status__c = 'On Notice';
        update s;


        // TODO: cover whole code of the trigger
        //s.Status__c = 'Inactive';
        //update s;
        //s.Status__c = 'Pending';
        //s.Billable_Service__c = true;
        //update s;
        //s.Status__c = 'Active';
        //update s;
    
    }

}