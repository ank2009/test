/**
 * @author Nicolas Dolet
 * @date 17/01/2012
 * @description Test trigger deleteCampaignPromoSubservices
 */
@isTest
public class DeleteCampaignPromoSubservicesTest {

    public static testMethod void testTrigger() {
    
        Campaign_Promotion__c cp = new Campaign_Promotion__c();
        cp.SalesPrice__c = 1;
        insert cp;
        
        cp.SalesPrice__c = 10;
        update cp;
    
    }
}