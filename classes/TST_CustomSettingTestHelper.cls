/**
* @author       Brian Kessler (Brian_Kessler@epam.com)
* @date         2013 July 04
* @description  This class is intended to facilitate testing by creating a uniform method of preparing Custom Settings 
**/
@isTest
public with sharing class TST_CustomSettingTestHelper
{
    /**
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 July 04
    * @description  This method is intended to facilitate testing by creating a uniform method of preparing Custom Settings
    * @param        List<String> countryList : List of countries to include in custom setting.
    * @return       None
    **/
    public static void initAll(List<String> countryList)
    {
        createVatNotAllowedCountry(countryList);
        createMappingOrganizationCountry(countryList);
        createAccountNumberOrganization(countryList); 
        createDebtorNumberOrganization(countryList);
        createDebtorNumberProduct();
        
        createTelerouteNumberOrg();
        createSubscriptionNumber(); 
        createCountryParams();
        createLanguageParams();
        
        createGeneralSettings();
        
        createFXSettings();
        createStaticURLs();
        
        createSEPAParams(countryList);
        
        createCountryCompleteCountries(countryList);
        FillProductList();
            
        createCommynityProfilesSetting();
        
        createOpportunityStages();
    }
    
    public static void createVatNotAllowedCountry(List<String> countryList)
    {
        List<TLR_VatNotAllowedCountryList__c> vatNotAllowedCountryList = new List<TLR_VatNotAllowedCountryList__c>();
        
        for (String country : countryList)
        {
            TLR_VatNotAllowedCountryList__c vatNotAllowedCountry = new TLR_VatNotAllowedCountryList__c();
                                            vatNotAllowedCountry.Name            = country;
                                            vatNotAllowedCountry.Country_Name__c = country;
            vatNotAllowedCountryList.add(vatNotAllowedCountry);
        }
        insert vatNotAllowedCountryList;
    }
    
    /**
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 July 03
    * @description  This method is intended to facilitate creating and populating dummy Mapping_Organization_Country__c  for unit testing.
    * @param        String country : Country to include in custom setting.
    * @param        String accountCountry : "Account Country" to include in custom setting.
    * @param        String internationalCountry : "International Country" to include in custom setting.
    * @param        String area : "Area" to include in custom setting.          
    * @param        Boolean insertNow : Whether to insert now or wait for further processing.
    * @return       Mapping_Organization_Country__c
    **/
    public static Mapping_Organization_Country__c createMappingOrganizationCountry(
                                                        String country, String accountCountry, String internationalCountry, 
                                                        String area,    Boolean insertNow
                                                    )
    {
        Mapping_Organization_Country__c mappingOrganizationCountry = new Mapping_Organization_Country__c();
                                            mappingOrganizationCountry.Name                            = country;
                                            mappingOrganizationCountry.Organization_Country__c         = country;
                                            mappingOrganizationCountry.Account_Numbering_Key__c        = accountCountry;
                                            mappingOrganizationCountry.Debtor_Numbering_Key__c         = accountCountry;
                                            mappingOrganizationCountry.Primary_Org_2_Area__c           = area;
                                            mappingOrganizationCountry.Primary_Org_3_TLR_Region__c     = internationalCountry;
                                            mappingOrganizationCountry.Primary_Org_4_Country__c        = country;
                                            mappingOrganizationCountry.Primary_Org_5_Country_level2__c = country;
                                            mappingOrganizationCountry.Geographical_Organization__c    = area + '->' + internationalCountry + '->' + country;
                                            mappingOrganizationCountry.Teleroute_Numbering_Key__c      = 'TR_Teleroute_Numbering';
                                            mappingOrganizationCountry.CurrencyIsoCode                 = 'EUR';
        
        if (insertNow) {insert mappingOrganizationCountry;}
        return mappingOrganizationCountry;
    }

    /**
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 July 03
    * @description  This method is intended to facilitate creating and populating dummy Mapping_Organization_Country__c  for unit testing.
    * @param        String country : Country to include in custom setting.
    * @param        Boolean insertNow : Whether to insert now or wait for further processing.
    * @return       Mapping_Organization_Country__c
    **/
    public static Mapping_Organization_Country__c createMappingOrganizationCountry(String country, Boolean insertNow)
    {
        return createMappingOrganizationCountry(country, 'Account ' + country, 'International ' + country, 'West', insertNow);
    }


    /**
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 July 03
    * @description  This method is intended to facilitate creating and populating dummy Mapping_Organization_Country__c  for unit testing.
    * @param        List<String> countryList : List of countries to include in custom setting.
    * @return       None
    **/
    public static void createMappingOrganizationCountry(List<String> countryList)
    {
        List<Mapping_Organization_Country__c> mappingOrganizationCountryList = new List<Mapping_Organization_Country__c>();
        
        for (String country : countryList)
        {
               mappingOrganizationCountryList.add(createMappingOrganizationCountry(country,false));
        }   
        
        insert mappingOrganizationCountryList;
    }
    
    /**
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 July 04
    * @description  This method is intended to facilitate creating and populating dummy TLR_VatNotAllowedCountry for unit testing.
    * @param        List<String> countryList : List of countries to include in custom setting.
    * @return       None
    **/
    public static void createAccountNumberOrganization(List<String> countryList)
    {
        List<Account_Number_Organization__c> accountNumberOrganizationList = new List<Account_Number_Organization__c>();
        
        Integer i = 1;
        for (String country : countryList)
        {
            Integer firstValue = i*100000000;
            Integer highValue  = firstValue +  90000000;
            Integer nextValue  = firstValue + ((Integer) Math.random() * (highValue - firstValue));
            
            Account_Number_Organization__c accountNumberOrganization = new Account_Number_Organization__c();
                                           accountNumberOrganization.Name                       = 'Account ' + country;
                                           accountNumberOrganization.Account_Numbering_Key__c   = 'Account ' + country;
                                           accountNumberOrganization.First_Value__c             = firstValue;
                                           accountNumberOrganization.High_Value__c              = highValue;
                                           accountNumberOrganization.Next_Value__c              = nextValue;
                                           accountNumberOrganization.Active_Flag__c = true;
                                           accountNumberOrganization.CurrencyIsoCode = 'EUR';
                                           accountNumberOrganization.Type__c = 'TR_ACCOUNT_NUM_ALG';
            
            accountNumberOrganizationList.add(accountNumberOrganization);
            i++;
        }   
        
        insert accountNumberOrganizationList;
    }
    
    /**
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 July 04
    * @description  This method is intended to facilitate creating and populating dummy TLR_VatNotAllowedCountry for unit testing.
    * @param        List<String> countryList : List of countries to include in custom setting.
    * @return       None
    **/
    public static void createDebtorNumberOrganization(List<String> countryList)
    {
        List<Debtor_Number_Organization__c> debtorNumberOrganizationList = new List<Debtor_Number_Organization__c>();
        
        Integer i = 1;
        for (String country : countryList)
        {
            Integer firstValue = i*100000000;
            Integer highValue  = firstValue +  99999999;
            Integer nextValue  = firstValue + ((Integer) Math.random() * (highValue - firstValue));
            
            Debtor_Number_Organization__c debtorNumberOrganization = new Debtor_Number_Organization__c();
                                          debtorNumberOrganization.Name                         = 'Account ' + country;
                                          debtorNumberOrganization.Debtor_Numbering_Key__c      = 'Account ' + country;
                                          debtorNumberOrganization.First_Value__c               = firstValue;
                                          debtorNumberOrganization.High_Value__c                = highValue;
                                          debtorNumberOrganization.Next_Value__c                = nextValue;
                                          debtorNumberOrganization.Active_Flag__c               = true;
                                          debtorNumberOrganization.CurrencyIsoCode              = 'EUR';
                                          debtorNumberOrganization.Type__c                      = 'TR_DEBTOR_NUM_ALG';
               
            debtorNumberOrganizationList.add(debtorNumberOrganization);
            i++;
        }   
        
        insert debtorNumberOrganizationList;
    }
    
    public static void createDebtorNumberProduct()
    {
        List<Debtor_Number_Products__c> debtorNumberProductList = new List<Debtor_Number_Products__c>();
        Debtor_Number_Products__c debtorNumberProduct1 = new Debtor_Number_Products__c(Name='TAS', Current_Number__c = 1);
        Debtor_Number_Products__c debtorNumberProduct2 = new Debtor_Number_Products__c(Name='TWD', Current_Number__c = 1);
        debtorNumberProductList.add(debtorNumberProduct1);        
        debtorNumberProductList.add(debtorNumberProduct2);
        insert debtorNumberProductList;
    }   
    
    /**
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 July 03
    * @description  This method is intended to facilitate creating and populating dummy TLR_VatNotAllowedCountry for unit testing.
    * @param        List<String> countryList : List of countries to include in custom setting.
    * @return       None
    **/
    public static void createTelerouteNumberOrg()
    {
        Integer firstValue = 550000;
        Integer highValue  = firstValue +  999999;
        Integer nextValue  = firstValue + ((Integer) Math.random() * (highValue - firstValue)); 
        
        Teleroute_Number_Organization__c numberOrganization = new Teleroute_Number_Organization__c();
                                         numberOrganization.Name                        = 'TR_Teleroute_Numbering';
                                         numberOrganization.Teleroute_Numbering_Key__c  = 'TR_Teleroute_Numbering';
                                         numberOrganization.Type__c                     = 'TR_TELEROUTE_NUMBERING_ALG';
                                         numberOrganization.First_Value__c              = firstValue;
                                         numberOrganization.High_Value__c               = highValue;
                                         numberOrganization.Next_Value__c               = nextValue;
                                         numberOrganization.Order_By__c                 = 1;
                                         numberOrganization.CurrencyIsoCode             = 'EUR';
                                         numberOrganization.Active_Flag__c              = true;

        insert  numberOrganization;
    }
    
    /**
    * @author       Brian Kessler (Brian_Kessler@epam.com)
    * @date         2013 July 03
    * @description  This method is intended to facilitate creating and populating dummy Subscription_Number__c for unit testing.
    * @param        List<String> countryList : List of countries to include in custom setting.
    * @return       None
    **/
    public static void createSubscriptionNumber()
    {
        Subscription_Number__c subscriptionNumber = new Subscription_Number__c();
                                         subscriptionNumber.Name                        = 'TLR Subscription';
                                         subscriptionNumber.Subscription_Number__c      = (
                                                                  ((Integer) Math.random() * (9))
                                                                + '-' 
                                                                + ((Integer) Math.random() * (900000000))
                                                    );
                                         subscriptionNumber.CurrencyIsoCode             = 'EUR';

        insert  subscriptionNumber; 
    }
    
    public static void createCountryParams()
    {
        List<Country_Parameters__c> params = new List<Country_Parameters__c>();
        
        Country_Parameters__c p1 = new Country_Parameters__c();
        p1.Name = 'France';
        p1.ISO2_code__c = 'FR';
        p1.Phone_code__c = 33;
        p1.Time_Zone__c = 'Europe/Paris';
        params.add(p1);
        
        Country_Parameters__c p2 = new Country_Parameters__c();
        p2.Name = 'Belgium';
        p2.ISO2_code__c = 'BE';
        p2.Time_Zone__c = 'Europe/Brussels';
        p2.Phone_code__c = 32;
        params.add(p2);
        
        insert params;
    }
    public static void createLanguageParams()
    {
        Language_parameters__c params = new Language_parameters__c();
        params.Name = 'English';
        params.Locale__c = 'en_GB';
        insert params;
    }
    
    public static void createGeneralSettings()
    {
        Profile commProfile = [SELECT Id FROM Profile WHERE Name='DMS Community User'];
        General_Settings__c gs = new General_Settings__c();
        gs.Enable_PLC_Update__c = false;
        gs.Name = 'Default';
        gs.Enable_Bridge_calls__c = true;
        gs.Enable_IKA_NKA_calculation__c = true;
        gs.DMS_Community_User_Profile_Id__c = commProfile.Id;
        
        insert gs;
    }
    
    public static void createFXSettings()
    {
        FXSettings__c FXSettings = new FXSettings__c();
        // this setting readed by TcdStub.deleteDocumentFromTCD(documentId)
        FXSettings.Delete_Doc_ESB_WSDL__c = 'http://test.test.test/test-test';
        // and this one - from SoapHttp.sendSOAPRequest(body, endPoint, timeOut)
        FXSettings.Proxy_ESB_Certificate__c = '';
        // other fields are required, but unused for now
        FXSettings.Name = 'FXSettings';
        FXSettings.Company_Directory_ESB_WSDL__c = 'http://test.test.test/test-test';
        FXSettings.Forward_Code_of_Conduct_Url__c = 'http://test.test.test/test-test';
        FXSettings.SSP_Partial_Registration_URL__c = 'http://test.test.test/test-test';
        FXSettings.User_Repository_ESB_WSDL__c = 'http://test.test.test/test-test';
        FXSettings.WKTS_Bridge_Profile__c = 'http://test.test.test/test-test';
        FXSettings.ESB_Url__c = 'http://test.test.test/test-test';
        FXSettings.ESB_Certificate_name__c = '';
        insert FXSettings;
    }
    
    public static void createStaticURLs()
    {
        STATIC_URLS__c settings = new STATIC_URLS__c();
        settings.URL_ESB_Provisioning_v2__c = 'http://test.test.test/test-test';
        settings.URL_ESB_Provisioning_v1__c = 'http://test.test.test/test-test';
        settings.Name = 'Qualif v1';
        insert settings;
        
        STATIC_URLS__c settings2 = new STATIC_URLS__c();
        settings2.URL_ESB_Provisioning_v2__c = 'http://test.test.test/test-test';
        settings2.URL_ESB_Provisioning_v1__c = 'http://test.test.test/test-test';
        settings2.Name = 'Qualif v2';
        insert settings2;
    }
    
    public static void createSIMSetting()
    {
        SIMSettings__c SIMSetting = New SIMSettings__c(); 
        SIMSetting.Name='SIMSettings'; 
        SIMSetting.Approval_Process_Name__c='test';
        SIMSetting.Forward_CoC_Process_Name__c='test';
        SIMSetting.SIMAuthURL__c='test';
        SIMSetting.SIMInstanceName__c='test';
        SIMSetting.SIMPassword__c='test';
        SIMSetting.SIMURL__c='test';
        SIMSetting.SIMUser__c='test';
        SIMSetting.Suspension_Process_Name__c='test';
        SIMSetting.TLR_Contact_List_Identifier__c='test';
        SIMSetting.TLR_Lead_List_Identifier__c='test';
        insert SIMSetting;                        
    }                   
    
    public static void createCountryCompleteCountries(List<String> countryList)
    {
        List<pw_cc__CountryObject__c> ccList = new List<pw_cc__CountryObject__c>();
        
        for(string s : countryList)
        {
            pw_cc__CountryObject__c country = new pw_cc__CountryObject__c();
            country.Name = s;
            country.pw_cc__IsoCode_2__c = s.toUpperCase().substring(0,1);
            country.pw_cc__IsoCode_3__c = s.toUpperCase().substring(0,2);
            ccList.add(country);
        }
        insert ccList;
    }
    
    public static void FillProductList()
    {
    	List<Product_Mapping__c> prodMap = new List<Product_Mapping__c>();
    	prodMap.add(new Product_Mapping__c(Name = 'Basic module', Product_Family__c = 'TAS', Product_Full_Name__c =	'TAS'));
		prodMap.add(new Product_Mapping__c(Name = 'CD_approved', Product_Family__c = 'CD', Product_Full_Name__c ='Approved'));
		prodMap.add(new Product_Mapping__c(Name = 'CD_guest', Product_Family__c = 'CD', Product_Full_Name__c ='Guest'));
		prodMap.add(new Product_Mapping__c(Name = 'FX', Product_Family__c = 'FX', Product_Full_Name__c ='FX'));
		prodMap.add(new Product_Mapping__c(Name = 'Integration', Product_Family__c = 'TW', Product_Full_Name__c ='Integration'));
		prodMap.add(new Product_Mapping__c(Name = 'NOLIS', Product_Family__c = 'FX', Product_Full_Name__c = 'Nolis'));
		prodMap.add(new Product_Mapping__c(Name = 'PTV', Product_Family__c = 'TAS', Product_Full_Name__c ='PTV'));
		prodMap.add(new Product_Mapping__c(Name = 'ShipperTMS_CO', Product_Family__c = 'TW', Product_Full_Name__c =	'Call Off'));
		prodMap.add(new Product_Mapping__c(Name = 'ShipperTMS_COST', Product_Family__c = 'TW', Product_Full_Name__c ='Cost'));
		prodMap.add(new Product_Mapping__c(Name = 'ShipperTMS_DOC', Product_Family__c = 'TW', Product_Full_Name__c ='Doc'));
		prodMap.add(new Product_Mapping__c(Name = 'ShipperTMS_FMETRICS', Product_Family__c = 'TW', Product_Full_Name__c ='Flowmetrics'));
		prodMap.add(new Product_Mapping__c(Name = 'ShipperTMS_ROUTE', Product_Family__c = 'TW', Product_Full_Name__c ='Route'));
		prodMap.add(new Product_Mapping__c(Name = 'ShipperTMS_Slot', Product_Family__c = 'TW', Product_Full_Name__c ='Slot'));
        prodMap.add(new Product_Mapping__c(Name = 'SPOTBIDDING_CREATE_SPOT', Product_Family__c = 'Spot Bidding', Product_Full_Name__c ='Create'));
        prodMap.add(new Product_Mapping__c(Name = 'SPOTBIDDING_REPLY_SPOT', Product_Family__c = 'Spot Bidding', Product_Full_Name__c ='Reply'));
		prodMap.add(new Product_Mapping__c(Name = 'T-ACTIVE', Product_Family__c = 'FX', Product_Full_Name__c ='T-ACTIVE'));
		prodMap.add(new Product_Mapping__c(Name = 'TDC - Reading orders', Product_Family__c = 'TAS', Product_Full_Name__c =	'TDC'));
		prodMap.add(new Product_Mapping__c(Name = 'TFC', Product_Family__c = 'FX', Product_Full_Name__c ='TFC'));
        prodMap.add(new Product_Mapping__c(Name = 'TFC_MVP_12M', Product_Family__c = 'TFC', Product_Full_Name__c ='MVP_12M'));
        prodMap.add(new Product_Mapping__c(Name = 'TFC_MVP_24M', Product_Family__c = 'TFC', Product_Full_Name__c ='MVP_24M'));
		prodMap.add(new Product_Mapping__c(Name = 'TFX', Product_Family__c = 'FX', Product_Full_Name__c ='TFX'));
        prodMap.add(new Product_Mapping__c(Name = 'T-PRO', Product_Family__c = 'TFC', Product_Full_Name__c =	'TPRO'));
		prodMap.add(new Product_Mapping__c(Name = 'TW_Support', Product_Family__c = 'Support', Product_Full_Name__c ='TWD'));
		insert prodMap;
    }
    
    public static void createSEPAParams(List<String> countryList)
    {
        integer counter = 1; // to skip sign city and creditor ID for some countries
        List<Sepa_Unique_Number__c> sepaList = new List<Sepa_Unique_Number__c>();
        for(string s : countryList)
        {
            Sepa_Unique_Number__c param = new Sepa_Unique_Number__c();
            param.Name = s;
            param.Unique_Number__c = 10;
            if(counter > 1) // wil be created for first country only, just because =)
            { 
                param.Sign_City__c = 'Honolulu';
                param.Creditor_ID__c = 'HH123123123';
            }
            sepaList.add(param);
            counter++;
        }
        
        insert sepaList;
    } //createSEPAParams
    
        public static void createCommynityProfilesSetting()
    {
        List<Community_Users_Profiles__c> commUserProfiles= New List<Community_Users_Profiles__c>();
        commUserProfiles.add(New Community_Users_Profiles__c(Name='Customer Community Login User'));
        commUserProfiles.add(New Community_Users_Profiles__c(Name='DMS Community User'));
        insert commUserProfiles;        
    }
    
    public static void createOpportunityStages()
    {
        List<Opportunity_Stages_Need_Contact_Roles__c> oppStages = new List<Opportunity_Stages_Need_Contact_Roles__c>();
        oppStages.add(new Opportunity_Stages_Need_Contact_Roles__c(Name = '01 New'));
        oppStages.add(new Opportunity_Stages_Need_Contact_Roles__c(Name = '02 Prospecting'));
        oppStages.add(new Opportunity_Stages_Need_Contact_Roles__c(Name = '03 Qualifying'));
        oppStages.add(new Opportunity_Stages_Need_Contact_Roles__c(Name = '04 Specifying'));
        oppStages.add(new Opportunity_Stages_Need_Contact_Roles__c(Name = 'Contract request'));
        oppStages.add(new Opportunity_Stages_Need_Contact_Roles__c(Name = 'New not worked'));       
        oppStages.add(new Opportunity_Stages_Need_Contact_Roles__c(Name = '13 Closed No Bid'));       
        insert oppStages;
    }
}