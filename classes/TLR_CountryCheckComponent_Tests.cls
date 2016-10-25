@isTest
public class TLR_CountryCheckComponent_Tests {
    public static testMethod void testCountryCheckComponentController() {
        createDummySettings();
        TLR_CountryCheckComponentController controller = New TLR_CountryCheckComponentController();
        Map<Integer, Map<Integer,String>> resultDiffList = New Map<Integer, Map<Integer,String>>();
        resultDiffList.putAll(controller.getDifferents());
        System.assertEquals(resultDiffList.size(),6);//A is good Country and other 6 with differents
    } 
    
    private static void createDummySettings(){        
        Country_Parameters__c dSC1 = New Country_Parameters__c (Name='A',ISO2_code__c = 'AA', Phone_code__c=123);
        Country_Parameters__c dSC2 = New Country_Parameters__c (Name='B',ISO2_code__c = 'BB', Phone_code__c=123);
        Country_Parameters__c dSC3 = New Country_Parameters__c (Name='C',ISO2_code__c = 'CC', Phone_code__c=123);
        Country_Parameters__c dSC4 = New Country_Parameters__c (Name='D',ISO2_code__c = 'DD', Phone_code__c=123);
        Country_Parameters__c dSC5 = New Country_Parameters__c (Name='H',ISO2_code__c = 'FF', Phone_code__c=123);
        List<Country_Parameters__c> dummyCountrySettings = New List<Country_Parameters__c>{dSC1,dSC2,dSC3,dSC4, dSC5};
        insert dummyCountrySettings;
        
        pw_cc__CountryObject__c dCO1 = New pw_cc__CountryObject__c (Name='A',pw_cc__IsoCode_2__c = 'AA', pw_cc__IsoCode_3__c='W');
        pw_cc__CountryObject__c dCO2 = New pw_cc__CountryObject__c (Name='E',pw_cc__IsoCode_2__c = 'BB', pw_cc__IsoCode_3__c='X');
        pw_cc__CountryObject__c dCO3 = New pw_cc__CountryObject__c (Name='C',pw_cc__IsoCode_2__c = 'FF', pw_cc__IsoCode_3__c='Y');
        pw_cc__CountryObject__c dCO4 = New pw_cc__CountryObject__c (Name='G',pw_cc__IsoCode_2__c = 'HH', pw_cc__IsoCode_3__c='Z');       
        pw_cc__CountryObject__c dCO5 = New pw_cc__CountryObject__c (Name='H',pw_cc__IsoCode_2__c = 'GG', pw_cc__IsoCode_3__c='V');
        List<pw_cc__CountryObject__c> dummyCountryObjects = New List<pw_cc__CountryObject__c>{dCO1,dCO2,dCO3,dCO4,dCO5};
        insert dummyCountryObjects;        
    }   
}