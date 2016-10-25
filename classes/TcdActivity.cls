public class TcdActivity 
{
	// inner classes
	public class CompanyIdentifier {
		public String companyId {get;set;}
		public String lastUpdaterName {get;set;}
		public String lastUpdateDate {get;set;} 
	}
	
	public virtual class Departure {
		public String country {
			get{
				if(!Generic.StringNotEmpty(country))
				{
					country = '';
					List<pw_cc__CountryObject__c> countryList = [select Name from pw_cc__CountryObject__c where IRU_Country_Code__c=:countryCode];
					system.debug('>>> ## Country List for countryCode : '+countryCode+' : '+countryList);
					if(countryList.size()>0 && Generic.StringNotEmpty(countryList[0].Name))
						country = countryList[0].Name;
				}
				return country;
			}
			set;
		}
		public String countryCode {get;set;}
		public String regionLabel {
			get{
				if(!Generic.StringNotEmpty(regionLabel))
				{
					regionLabel = '';
					List<Teleroute_Region__c> regionList = [select Label__c from Teleroute_Region__c where Level__c='2' and Parent_Code__c=:countryCode and Name=:region];
					system.debug('>>> ## Region List for region : '+region+' : '+regionList);
					if(regionList.size()>0 && Generic.StringNotEmpty(regionList[0].Label__c))
						regionLabel = regionList[0].Label__c;
				}
				return regionLabel;
			}
			set;
		}
		public String region {get;set;}
		public String city {get;set;}
		public String coordX {get;set;}
		public String coordY {get;set;}
	}
	
	public class Arrival extends Departure {}
	
	public class RegularRoute 
	{
		public Departure departure { get; set; }
		public Arrival arrival { get; set; }
		public Integer Index { get; set; }
		public TcdActivity activityParent { get; set; }
		public List<String> days
		{
			get
			{
				if(days == null)
				{
					days = new List<String>();
				}
				return days;
			}
			set;
		} // days property
		
		/*public void updateRegularRoute()
		{
			activityParent.manager.updateRegularRouteId(this.Index);
		}*/
		
		/*public void deleteRegularRoute()
		{
			activityParent.manager.deleteRegularRouteId(this.Index);
		}*/
		
		public RegularRoute()
		{
			departure = new TcdActivity.Departure();
			arrival = new TcdActivity.Arrival();
			Index = 0;
		}
		public RegularRoute(TcdActivity parent)
		{
			this();
			activityParent = parent;
		} // ctor
	} // RegularRoute
	
	public class Country {
		
		public Country()
		{
			regions = new List<String>();
		}
		public String countryCode {get;set;}
		public List<String> regions {get;set;}
		//public Integer Index{get;set;}
		public TcdActivity activityParent{get;set;}
		public String countryLabel {
			get{
				if(!Generic.StringNotEmpty(countryLabel))
				{
					countryLabel = '';
					if(Generic.StringNotEmpty(countryCode))
					{						
						List<pw_cc__CountryObject__c> countryList = [select Name from pw_cc__CountryObject__c where IRU_Country_Code__c=:countryCode];
						system.debug('>>> ## Country List for countryCode : '+countryCode+' : '+countryList);
						if(countryList.size()>0 && Generic.StringNotEmpty(countryList[0].Name))
							countryLabel = countryList[0].Name;
					}
				}
				return countryLabel;
			}
			set;
		}
		public String regionLabel {
			get{
//				if(!Generic.StringNotEmpty(regionLabel))
//				{
					regionLabel = '';
					if(Generic.StringNotEmpty(countryCode) && regions.size()>0)
					{
						List<Teleroute_Region__c> regionList = [select Label__c from Teleroute_Region__c where Level__c='2' and Parent_Code__c=:countryCode and Name in :regions];
						system.debug('>>> ## Region List for region : '+regions+' : '+regionList);
						for(Teleroute_Region__c reg : regionList)
						{
							if(regionLabel!='')
	                           regionLabel += ',';
							regionLabel += reg.Label__c;
						}
					}
//				}
				return regionLabel;
			}
			set;
		}
		
		/*public void updateCountryActivity()
		{
			activityParent.manager.updateCountryActivityId(this.countryCode);
		}
		
		public void deleteCountryActivity()
		{
			activityParent.manager.deleteCountryActivityId(this.countryCode);
		}*/
	}
	
	// class vars
	public CompanyIdentifier companyIdentifier {
		get {
			if (companyIdentifier == null) {
				companyIdentifier = new CompanyIdentifier();
			}
			return companyIdentifier;
		}
		set;
	}
	public String numberOfTruck {get;set;}
	public String[] specializationCodes {
		get {
			if (specializationCodes == null) {
				specializationCodes = new String[]{};
			}
			return specializationCodes;
		}
		set;
	}
	public Map<Integer,RegularRoute> regularRoutes {
		get {
			if (regularRoutes == null) {
				regularRoutes = new Map<Integer,RegularRoute>();
			}
			return regularRoutes;
		}
		set;
	}
	
	public Map<String,Country> countryMap {
		get {
			if (countryMap == null) {
				countryMap = new Map<String,Country>();
			}
			return countryMap;
		}
		set;
	}
	
	public Country[] countries {
		get {
			if (countries == null) {
				countries = new Country[]{};
			}
			return countries;
		}
		set;
	}
	public String nbWarehouse {get;set;}
	public String specializationComments {get;set;}
	//used to know which regular route have to be deleted or be updated
	//public TcdCaller manager;
}

/**
XML file looks like this:
<?xml version="1.0" encoding="UTF-8"?>
-<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">-<soapenv:Body>-<di:getTCDActivityResponse xmlns:di="http://teleroute.com/telerouteCompanyDirectory" xmlns:co="http://company.teleroute.com">-<co:responseGetActivity>-<co:activity>-<co:companyIdentifier><companyId>400007999</companyId><lastUpdaterName>CMS</lastUpdaterName><lastUpdateDate>2008-06-03T18:43:26Z</lastUpdateDate></co:companyIdentifier><numberOfTruck>5</numberOfTruck><specializationCodes>ADR</specializationCodes><specializationCodes>COT</specializationCodes><specializationCodes>CTR</specializationCodes><specializationCodes>ECS</specializationCodes><specializationCodes>ELO</specializationCodes><specializationCodes>GME</specializationCodes><specializationCodes>GRO</specializationCodes><specializationCodes>HCT</specializationCodes><specializationCodes>TRU</specializationCodes><specializationComments/>-<regularRoutes>-<departure><country>D</country><region>60</region><city>FRANKFURT AM MAIN</city><coordX>0</coordX><coordY>0</coordY></departure>-<arrival><country>I</country><region>24</region><city>BERGAMO</city><coordX>0</coordX><coordY>0</coordY></arrival></regularRoutes>-<regularRoutes>-<departure><country>D</country><region>60</region><city>FRANKFURT AM MAIN</city><coordX>0</coordX><coordY>0</coordY></departure>-<arrival><country>GB</country><region>E</region><city>LONDON</city><coordX>0</coordX><coordY>0</coordY></arrival></regularRoutes>-<regularRoutes>-<departure><country>D</country><region>60</region><city>FRANKFURT AM MAIN</city><coordX>0</coordX><coordY>0</coordY></departure>-<arrival><country>NL</country><region>59</region><city>VENLO</city><coordX>0</coordX><coordY>0</coordY></arrival></regularRoutes>-<countries><countryCode>I</countryCode><regions/></countries>-<countries><countryCode>GB</countryCode><regions/></countries>-<countries><countryCode>NL</countryCode><regions/></countries>-<countries><countryCode>F</countryCode><regions/></countries>-<countries><countryCode>PL</countryCode><regions/></countries><nbWarehouse>1</nbWarehouse></co:activity></co:responseGetActivity></di:getTCDActivityResponse></soapenv:Body></soapenv:Envelope>
**/