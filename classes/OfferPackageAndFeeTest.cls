/**
 * @author Nicolas Dolet
 * @date 16/01/2012
 * @description Test trigger OfferPackageAndFee
 */
@isTest
public class OfferPackageAndFeeTest {

     public static testMethod void testTrigger() {
     
        // Data generation
        List<ID> services = TestData.createTestServices(1);
        Product__c prod = TestData.createTestProductAndLineItems(services, false, true);
        Offer_Template__c ot = TestData.createOfferTemplate(prod, false);
        PackFee__c pf = TestData.createPackageAndFee();
        pf.Status__c = 'Active';
        update pf;
        Offer_Package_And_Fee__c opf = TestData.createOfferPackageAndFee(ot, pf);
        opf.Default_Price__c = 10;
        update opf;
        delete opf;
             
     }

}