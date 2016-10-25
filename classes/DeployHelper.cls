global class DeployHelper
{
	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2015 May 22
	* @description	When jenkins builds this - it will pass version parameter here. We will store it inSF to display
	*/
	webservice static void SetVersion(string version)
	{
		ProdVersion__c ver = ProdVersion__c.getOrgDefaults();
		boolean isNew = ver.Id == null;
		ver.SVN_Tag__c = version;
		if(isNew)
			insert ver;
		else 
			update ver;
	}
	
	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 August - September
	* @description	performs tasks before build all (written primarily for Jenkins CI)
	*/
	webservice static void PreDeploy()
	{
		CreateSettings();

		CreateEntitlements();

		RemoveScheduleClass();
	}

	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 August - September
	* @description	performs tasks after successful build (written primarily for Jenkins CI)
	*/
	webservice static void PostDeploy()
	{
		EvocationOfScheduleClass();
	}

	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 September 27
	* @description	create custom settings for development and indegration sandboxes
	*/
	private static void CreateSettings()
	{
		CreateAccountNumberOrganization();
		CreateDebtorNumberOrganization();
		CreateMappingOrganizationCountry();
		CreateTelerouteNumberOrganization();
		CreateSubscriptionNumber();
		CreateBridgeProfiles();
		
		createDebtorNumberProduct();
		
		CreateAdminProfileSettings();
		CreateTLRHQProfileSettings();
		
		CreateStaticURLs();
		
		CreateFXSettings();
		
        CreateCountryParametersSettings();		
		
		CreateSpecializationCodes();
		
		CreateSepaUniqueNumber();
	}

	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 September 27
	* @description	create 2 instances of Account_Number_Organization__c custom settings
	*/
	private static void CreateAccountNumberOrganization()
	{
		Map<String, Account_Number_Organization__c> anoMap = Account_Number_Organization__c.getAll();

		if(!anoMap.containsKey('Account Belgium'))
		{
			Account_Number_Organization__c ano = new Account_Number_Organization__c();
			ano.Account_Numbering_Key__c = 'Account Belgium';
			ano.Name = 'Account Belgium';
			ano.First_Value__c = 250000000;
			ano.High_Value__c = 299999999;
			ano.Next_Value__c = 290000000;
			ano.Type__c = 'TR_ACCOUNT_NUM_ALG';
			ano.Active_Flag__c = true;
			insert ano;
		}

		if(!anoMap.containsKey('Account France'))
		{
			Account_Number_Organization__c ano = new Account_Number_Organization__c();
			ano.Account_Numbering_Key__c = 'Account France';
			ano.Name = 'Account France';
			ano.First_Value__c = 650000000;
			ano.High_Value__c = 699999999;
			ano.Next_Value__c = 690000000;
			ano.Type__c = 'TR_ACCOUNT_NUM_ALG';
			ano.Active_Flag__c = true;
			insert ano;
		}
	} //CreateAccountNumberOrganization

	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 September 27
	* @description	create 2 instances of Debtor_Number_Organization__c custom settings
	*/
	private static void CreateDebtorNumberOrganization()
	{
		Map<String, Debtor_Number_Organization__c> dnoMap = Debtor_Number_Organization__c.getAll();

		if(!dnoMap.containsKey('Account Belgium'))
		{
			Debtor_Number_Organization__c dno = new Debtor_Number_Organization__c();
			dno.Debtor_Numbering_Key__c = 'Account Belgium';
			dno.Name = 'Account Belgium';
			dno.First_Value__c = 250000000;
			dno.High_Value__c = 299999999;
			dno.Next_Value__c = 290000010;
			dno.Type__c = 'TR_DEBTOR_NUM_ALG';
			dno.Active_Flag__c = true;
			insert dno;
		}

		if(!dnoMap.containsKey('Account France'))
		{
			Debtor_Number_Organization__c dno = new Debtor_Number_Organization__c();
			dno.Debtor_Numbering_Key__c = 'Account France';
			dno.Name = 'Account France';
			dno.First_Value__c = 65000000;
			dno.High_Value__c = 69999999;
			dno.Next_Value__c = 69000021;
			dno.Type__c = 'TR_DEBTOR_NUM_ALG';
			dno.Active_Flag__c = true;
			insert dno;
		}
	} //CreateDebtorNumberOrganization
	
    private static void createDebtorNumberProduct()
    {
        Map<string, Debtor_Number_Products__c> debtorNumberProductMap = Debtor_Number_Products__c.getAll();
        List<Debtor_Number_Products__c> debtorNumberProductListToAdd = new List<Debtor_Number_Products__c>();
        if(!debtorNumberProductMap.containsKey('TAS'))
        {
        	debtorNumberProductListToAdd.add(new Debtor_Number_Products__c(Name='TAS', Current_Number__c = 0));
        }
        if(!debtorNumberProductMap.containsKey('TWD'))
        {
        	debtorNumberProductListToAdd.add(new Debtor_Number_Products__c(Name='TWD', Current_Number__c = 0));
        }
        
        if(debtorNumberProductListToAdd.size() > 0)
        	insert debtorNumberProductListToAdd;
    }

	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 September 27
	* @description	create 2 instances of Mapping_Organization_Country__c custom settings
	*/
	private static void CreateMappingOrganizationCountry()
	{
		Map<String, Mapping_Organization_Country__c> mocMap = Mapping_Organization_Country__c.getAll();

		if(!mocMap.containsKey('Belgium'))
		{
			System.debug('-----Test deploy helper------');
			Mapping_Organization_Country__c moc = new Mapping_Organization_Country__c();
			moc.Name = 'Belgium';
			moc.Account_Numbering_Key__c = 'Account Belgium';
			moc.Debtor_Numbering_Key__c = 'Account Belgium';
			moc.Geographical_Organization__c = 'North ->BeLux ->Belgium';
			moc.Organization_Country__c = 'Belgium';
			moc.Primary_Org_2_Area__c = 'North';
			moc.Primary_Org_3_TLR_Region__c = 'BeLux';
			moc.Primary_Org_4_Country__c = 'Belgium';
			moc.Primary_Org_5_Country_level2__c = 'Belgium';
			moc.Teleroute_Numbering_Key__c = 'TR_Teleroute_Numbering';
			insert moc;
		}

		if(!mocMap.containsKey('France'))
		{
			Mapping_Organization_Country__c moc = new Mapping_Organization_Country__c();
			moc.Name = 'France';
			moc.Account_Numbering_Key__c = 'Account France';
			moc.Debtor_Numbering_Key__c = 'Account France';
			moc.Geographical_Organization__c = 'West ->France International ->France';
			moc.Organization_Country__c = 'France';
			moc.Primary_Org_2_Area__c = 'West';
			moc.Primary_Org_3_TLR_Region__c = 'France International';
			moc.Primary_Org_4_Country__c = 'France';
			moc.Primary_Org_5_Country_level2__c = 'France';
			moc.Teleroute_Numbering_Key__c = 'TR_Teleroute_Numbering';
			insert moc;
		}
	} //CreateMappingOrganizationCountry

	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 September 27
	* @description	create 2 instances of Teleroute_Number_Organization__c custom settings
	*/
	private static void CreateTelerouteNumberOrganization()
	{
		Map<String, Teleroute_Number_Organization__c> tnoMap = Teleroute_Number_Organization__c.getAll();

		if(!tnoMap.containsKey('TR_Teleroute_Numbering'))
		{
			Teleroute_Number_Organization__c tno = new Teleroute_Number_Organization__c();
			tno.Name = 'TR_Teleroute_Numbering';
			tno.Teleroute_Numbering_Key__c = 'TR_Teleroute_Numbering';
			tno.First_Value__c = 550000;
			tno.High_Value__c = 999999;
			tno.Next_Value__c = 570001;
			tno.Type__c = 'TR_TELEROUTE_NUMBER_ALG';
			tno.Active_Flag__c = true;
			insert tno;
		}
	} //CreateTelerouteNumberOrganization

	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 September 27
	* @description	create Subscription_Number__c custom settings
	*/
	private static void CreateSubscriptionNumber()
	{
		Map<String, Subscription_Number__c> snMap = Subscription_Number__c.getAll();

		if(!snMap.containsKey('TLR Subscription'))
		{
			Subscription_Number__c sn = new Subscription_Number__c();
			sn.Name = 'TLR Subscription';
			sn.Subscription_Number__c = '2-100004770';
			insert sn;
		}
	} //CreateSubscriptionNumber

	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 September 27
	* @description	create Subscription_Number__c custom settings
	*/
	private static void CreateBridgeProfiles()
	{
		Map<String, Bridge_Profile_Settings__c> bpsMap = Bridge_Profile_Settings__c.getAll();

		List<Bridge_Profile_Settings__c> settings = new List<Bridge_Profile_Settings__c>();
		if(!bpsMap.containsKey('All <-> EE'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'All <-> EE', value__c = '32'));

		if(!bpsMap.containsKey('Bursa Direct All -> All'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'Bursa Direct All -> All', value__c = '15'));

		if(!bpsMap.containsKey('Bursa Direct K+N Road'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'Bursa Direct K+N Road', value__c = '21'));

		if(!bpsMap.containsKey('Bursa Direct 3'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'Bursa Direct 3', value__c = '11'));

		if(!bpsMap.containsKey('Default Bursa All -> EE'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'Default Bursa All -> EE', value__c = '20'));

		if(!bpsMap.containsKey('FR <-> FR Nolis'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'FR <-> FR Nolis', value__c = '33'));

		if(!bpsMap.containsKey('Nolis - 2nd Uplift'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'Nolis - 2nd Uplift', value__c = '36'));

		if(!bpsMap.containsKey('Nolis Direct All'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'Nolis Direct All', value__c = '18'));

		if(!bpsMap.containsKey('Nolis Direct FR -> FR'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'Nolis Direct FR -> FR', value__c = '19'));

		if(!bpsMap.containsKey('Nolis Direct 6'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'Nolis Direct 6', value__c = '14'));

		if(!bpsMap.containsKey('Test Popup'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'Test Popup', value__c = '39'));

		if(!bpsMap.containsKey('Test Popup EN'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'Test Popup EN', value__c = '40'));

		if(!bpsMap.containsKey('Test 2nd Bursa'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'Test 2nd Bursa', value__c = '38'));

		if(!bpsMap.containsKey('Copy (1) of Test Nougat'))
			settings.add(new Bridge_Profile_Settings__c(Name = 'Copy (1) of Test Nougat', value__c = '37'));

		if(settings.size() > 0)
			insert settings;
	} //CreateBridgeProfiles

	private static void CreateAdminProfileSettings()
	{
		Map<String, AdminProfileSettings__c> apsMap = AdminProfileSettings__c.getAll();

		if(!apsMap.containsKey('SysAdmin'))
		{
			AdminProfileSettings__c aps = new AdminProfileSettings__c();
			aps.Name = 'SysAdmin';
			aps.Profile_ID__c = '00e20000001NsIkAAK';
			insert aps;
		}
	} // CreateAdminProfileSettings

	private static void CreateTLRHQProfileSettings()
	{
		Map<String, TLRHQProfileSettings__c> tpsMap = TLRHQProfileSettings__c.getAll();

		if(!tpsMap.containsKey('TLR HQ'))
		{
			TLRHQProfileSettings__c tps = new TLRHQProfileSettings__c();
			tps.Name = 'TLR HQ';
			tps.Profile_ID__c = '00eD0000001PRwKIAW';
			insert tps;
		}
	} // CreateTLRHQProfileSettings

	private static void CreateStaticURLs()
	{
		Map<String, STATIC_URLS__c> suMap = STATIC_URLS__c.getAll();

		if(!suMap.containsKey('Qualif v1'))
		{
			STATIC_URLS__c su = new STATIC_URLS__c();
			su.Name = 'Qualif v1';
			su.URL_ESB_Provisioning_v1__c = 'https://liv-interface-proxy.teleroute.com/SFToESB';
			su.URL_ESB_Provisioning_v2__c = 'https://liv-gateway.teleroute.com/CRM2IAMManageWeb/sca/SFToESBv2Export2';
			insert su;
		}

		if(!suMap.containsKey('Qualif v2'))
		{
			STATIC_URLS__c su = new STATIC_URLS__c();
			su.Name = 'Qualif v2';
			su.URL_ESB_Provisioning_v1__c = 'https://liv-gateway.teleroute.com/SFToESB';
			su.URL_ESB_Provisioning_v2__c = 'http://mosfdc.wkts.eu/OneWayProvisionning/mockoneWayProvisionningSOAP';
			insert su;
		}
	} // CreateStaticURLs

	private static void CreateFXSettings()
	{
		Map<String, FXSettings__c> fsMap = FXSettings__c.getAll();

		if(!fsMap.containsKey('FXSettings'))
		{
			FXSettings__c FXSettings = new FXSettings__c();
			FXSettings.Name = 'FXSettings';
			// this setting readed by TcdStub.deleteDocumentFromTCD(documentId)
			FXSettings.Delete_Doc_ESB_WSDL__c = 'https://liv-gateway.teleroute.com/webServices/DocumentManagement';
			// and this one - from SoapHttp.sendSOAPRequest(body, endPoint, timeOut)
			FXSettings.Proxy_ESB_Certificate__c = ''; //'xLocate_CA';
			// bridge webservice endpoint (dev environment mock service)
			FXSettings.WKTS_Bridge_Profile__c = 'http://mosfdc.wkts.eu/bridgeMock/bridgeMock';
			FXSettings.Company_Directory_ESB_WSDL__c = 'http://mosfdc.wkts.eu/TCDmock/TCDMashup';
			FXSettings.Forward_Code_of_Conduct_Url__c = 'http://';
			FXSettings.SSP_Partial_Registration_URL__c = 'http://';
			FXSettings.User_Repository_ESB_WSDL__c = 'https://liv-gateway.teleroute.com/UserRepositoryWeb/sca/SoapExport?WSDL';
			FXSettings.ESB_Url__c = 'https://esbqa.transwide.info/ESB/OBSS/proxy/NotifyWKTSFromOBSS'; // dev url: http://mosfdc.wkts.eu/esbMock/mocknotifyWKTSSOAP
			insert FXSettings;
		}
	} // CreateFXSettings
	
    /**
    * @author       Aleh Tsilko (aleh_tsilko@epam.com)
    * @date         2014 November 18
    * @description  create Country_Parameters__c custom settings for France & 
    */  
    private static void CreateCountryParametersSettings()
    {
        Map<String, Country_Parameters__c> countryParamMap = Country_Parameters__c.getAll();
        List<Country_Parameters__c> countrySettingsList = New List<Country_Parameters__c>();        
        if(!countryParamMap.containsKey('France')) countrySettingsList.add(new Country_Parameters__c(Name = 'France', ISO2_code__c = 'FR', Phone_code__c = 33));
        if(!countryParamMap.containsKey('Belgium')) countrySettingsList.add(new Country_Parameters__c(Name = 'Belgium', ISO2_code__c = 'BE', Phone_code__c = 32));
        if(!countrySettingsList.isEmpty()) insert countrySettingsList; 
    } // CreateCountryParametersSettings

	private static void CreateEntitlements()
	{
		Id complaintSLOAccId = null, supportSLOAccId = null, dmsSLOAccId = null;
		// 1 - check accounts
		List<Account> existingAccts = [SELECT Id, Name FROM Account WHERE Name IN ('TLR Complaint SLO', 'TLR DMS SLO', 'TLR Support SLO')];
		for(Account a : existingAccts)
		{
			if(a.Name == 'TLR Support SLO')
				supportSLOAccId = a.Id;
			if(a.Name == 'TLR Complaint SLO')
				complaintSLOAccId = a.Id;
			if(a.Name == 'TLR DMS SLO')
				dmsSLOAccId = a.Id;
		}
		List<Account> newAccts = new List<Account>();
		if(supportSLOAccId == null)
			newAccts.add(new Account( Name = 'TLR Support SLO' ));
		if(complaintSLOAccId == null)
			newAccts.add(new Account( Name = 'TLR Complaint SLO' ));
		if(dmsSLOAccId == null)
			newAccts.add(new Account( Name = 'TLR DMS SLO' ));

		if(newAccts.size() > 0)
		{
			for(Account a : newAccts)
			{
				a.Account_Level__c = 'Site';
				a.Teleroute_Name__c = a.Name;
				a.Account_Life_Cycle__c = 'Prospect';
				
				a.BillingCountry = 'France';
				a.Organization_Country__c = 'France';
				a.ShippingCountry = 'France';
				
				a.BillingCity = 'Paris';
				a.ShippingCity = 'Paris';
				
				a.BillingState = 'Paris';
				a.ShippingState = 'Paris';
				
				a.BillingStreet = 'Rab';
				a.ShippingStreet = 'Rab';
				
				a.BillingPostalCode = '12312';
				a.ShippingPostalCode = '123123';
			}
			insert newAccts;
			for(Account a : newAccts)
			{
				if(a.Name == 'TLR Support SLO')
					supportSLOAccId = a.Id;
				if(a.Name == 'TLR Complaint SLO')
					complaintSLOAccId = a.Id;
				if(a.Name == 'TLR DMS SLO')
					dmsSLOAccId = a.Id;
			}
		}

		List<Entitlement> existingEnt = [SELECT Id, Name FROM Entitlement];
		Set<string> entNames = new Set<string>();
		for(Entitlement e : existingEnt)
			if(!entNames.contains(e.Name))
				entNames.add(e.Name);

		List<Entitlement> newEnt = new List<Entitlement>();
		if(!entNames.contains('TLR Support SLO'))
			newEnt.add(new Entitlement( AccountId = supportSLOAccId, Name = 'TLR Support SLO' ));
		if(!entNames.contains('TLR Complaint SLO'))
			newEnt.add(new Entitlement( AccountId = complaintSLOAccId, Name = 'TLR Complaint SLO' ));
		if(!entNames.contains('TLR DMS SLO'))
			newEnt.add(new Entitlement( accountId = dmsSLOAccId, Name = 'TLR DMS SLO' ));

		if(newEnt.size() > 0)
			insert newEnt;
	} //CreateEntitlements

	/**
	* @author		Andrey Gordienko (andrey_gordienko@epam.com)
	* @date			2013 October 9
	* @description	Remove active Apex schedule Class
	*/
	private class ScheduleInfo
	{
		public ScheduleInfo(string cr, string name, Type t)
		{
			Cron = cr;
			JobName = name;
			ScheduleClassType = t;
		}
		public String Cron {get;set;}
		public String JobName {get;set;}
		public Type ScheduleClassType {get;set;}
	}

	private static final Map<string, ScheduleInfo> mapScheduleInfo =
		new Map<string, ScheduleInfo>{
			'0 0 1 ? * 1,2,3,4,5,6,7' => new ScheduleInfo('0 0 1 ? * 1,2,3,4,5,6,7', 'SubsCurrentFee recalculation (TAS)', Type.forName('TLR_SubsCurrentFeesTotalMaintSchedulable')),
			'0 0 0 ? * 1,2,3,4,5,6,7' => new ScheduleInfo('0 0 0 ? * 1,2,3,4,5,6,7', 'Daily User Suspension Task - 12AM', Type.forName('ScheduleSuspension')),
			'0 0 23 ? * 1,2,3,4,5,6,7' => new ScheduleInfo('0 0 23 ? * 1,2,3,4,5,6,7', 'Daily User Unsuspension Task - 11PM', Type.forName('ScheduleUnsuspension'))
		};

	private static void RemoveScheduleClass()
	{
		List<CronTrigger> ct = [select  id, CronExpression from CronTrigger where CronExpression=:mapScheduleInfo.keySet()];
		for(CronTrigger tr: ct)
		{
			System.abortJob(tr.Id);
		}
	}

	private static void EvocationOfScheduleClass()
	{
		for(String key :mapScheduleInfo.keySet())
		{
			System.schedule(mapScheduleInfo.get(key).JobName, key, (Schedulable)mapScheduleInfo.get(key).ScheduleClassType.newInstance());
		}
	}
	
	/**
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 December 2
	* @description	custom setting to store good specialization codes. Used in TCD mashup for Account
	*/
	private static void CreateSpecializationCodes()
	{
		Map<String, Specialization_Code__c> settingsMap = Specialization_Code__c.getAll();
		List<Specialization_Code__c> settingsToInsert = new List<Specialization_Code__c>();
		
		if(!settingsMap.containsKey('ADR'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'ADR', Label__c = 'Dangerous goods'));
		if(!settingsMap.containsKey('AIC'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'AIC', Label__c = 'Air cargo'));
		if(!settingsMap.containsKey('BTR'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'BTR', Label__c = 'Bulk transport'));
		if(!settingsMap.containsKey('COG'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'COG', Label__c = 'Common goods'));
		if(!settingsMap.containsKey('COM'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'COM', Label__c = 'Construction Materials'));
		if(!settingsMap.containsKey('COT'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'COT', Label__c = 'Conditioned Transport'));
		if(!settingsMap.containsKey('CTR'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'CTR', Label__c = 'Container Transport'));
		if(!settingsMap.containsKey('ECS'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'ECS', Label__c = 'Express/Courier services'));
		if(!settingsMap.containsKey('ELO'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'ELO', Label__c = 'Exceptional Transport'));
		if(!settingsMap.containsKey('FEF'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'FEF', Label__c = 'Freight Forwarding'));
		if(!settingsMap.containsKey('FLA'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'FLA', Label__c = 'Flat Bed'));
		if(!settingsMap.containsKey('GME'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'GME', Label__c = 'General Merchandise'));
		if(!settingsMap.containsKey('GRO'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'GRO', Label__c = 'Groupage'));
		if(!settingsMap.containsKey('HAM'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'HAM', Label__c = 'Hazardous materials'));
		if(!settingsMap.containsKey('HCT'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'HCT', Label__c = 'High cube transport'));
		if(!settingsMap.containsKey('INT'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'INT', Label__c = 'Intermodal'));
		if(!settingsMap.containsKey('LIV'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'LIV', Label__c = 'Livestock'));
		if(!settingsMap.containsKey('LOM'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'LOM', Label__c = 'Loose materials'));
		if(!settingsMap.containsKey('MOV'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'MOV', Label__c = 'Movers'));
		if(!settingsMap.containsKey('PHD'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'PHD', Label__c = 'Physical distribution'));
		if(!settingsMap.containsKey('REM'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'REM', Label__c = 'Removal'));
		if(!settingsMap.containsKey('SIT'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'SIT', Label__c = 'Silo Transport'));
		if(!settingsMap.containsKey('TEC'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'TEC', Label__c = 'Temperature Controlled'));
		if(!settingsMap.containsKey('TRU'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'TRU', Label__c = 'Trucking'));
		if(!settingsMap.containsKey('TTR'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'TTR', Label__c = 'Tank Transport'));
		if(!settingsMap.containsKey('VOG'))
			settingsToInsert.add(new Specialization_Code__c(Name = 'VOG', Label__c = 'Volume goods'));
		
		if(settingsToInsert.size() > 0)
			insert settingsToInsert;
	} //CreateSpecializationCodes
	
	/**
	* @author		Andrey Gordienko (andrey_gordienko@epam.com)
	* @date			2014 January 20
	* @description	custom setting to store Sepa Unique Number
	*/
	private static void CreateSepaUniqueNumber()
	{
		Map<string,Sepa_Unique_Number__c> maps = Sepa_Unique_Number__c.getAll(); 
		List<Sepa_Unique_Number__c> settingsToInsert = new List<Sepa_Unique_Number__c>();
		if(!maps.containsKey('Spain'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Spain', Unique_Number__c = 1));
		if(!maps.containsKey('Netherlands'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Netherlands', Unique_Number__c = 1));
		if(!maps.containsKey('Portugal'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Portugal', Unique_Number__c = 1));
		if(!maps.containsKey('Italy'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Italy', Unique_Number__c = 1));
		if(!maps.containsKey('Monaco'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Monaco', Unique_Number__c = 1));
		if(!maps.containsKey('Switzerland FR'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Switzerland FR', Unique_Number__c = 1));
		if(!maps.containsKey('Germany'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Germany', Unique_Number__c = 1));
		if(!maps.containsKey('Switzerland DE'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Switzerland DE', Unique_Number__c = 1));
		if(!maps.containsKey('Austria'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Austria', Unique_Number__c = 1));
			if(!maps.containsKey('Belgium'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Belgium', Unique_Number__c = 1));
		if(!maps.containsKey('Denmark'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Denmark', Unique_Number__c = 1));
		if(!maps.containsKey('Eastern Europe'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Eastern Europe', Unique_Number__c = 1));
		if(!maps.containsKey('Finland'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Finland', Unique_Number__c = 1));
		if(!maps.containsKey('France'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'France', Unique_Number__c = 1));
		if(!maps.containsKey('Norway'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Norway', Unique_Number__c = 1));
		if(!maps.containsKey('Poland'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Poland', Unique_Number__c = 1));
		if(!maps.containsKey('Sweden'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'Sweden', Unique_Number__c = 1));
		if(!maps.containsKey('United Kingdom'))
			settingsToInsert.add(new Sepa_Unique_Number__c(Name = 'United Kingdom', Unique_Number__c = 1));
		if(settingsToInsert.size() > 0)
			insert settingsToInsert;	
	}
}