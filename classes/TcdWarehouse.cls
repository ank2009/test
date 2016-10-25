public class TcdWarehouse {

	// inner classes
	public class Address
	{
		public String street { get; set; }
		public String address1 { get; set; }
		public String address2 { get; set; }
		public String address3 { get; set; }
		public String zipCode { get; set; }
		public String province { get; set; }
	}
	
	public class Location
	{
		public String country
		{
			get
			{
				if(!Generic.StringNotEmpty(country) && Generic.StringNotEmpty(countryCode))
				{
					List<pw_cc__CountryObject__c> existingCountries = [
						SELECT Name
						FROM pw_cc__CountryObject__c
						WHERE IRU_Country_Code__c = :countryCode
					];
					if(existingCountries.size() > 0)
						country = existingCountries[0].Name;
					else
						country = 'Missing country: ' + countryCode;
				}
				return country;
			}
			set;
		}
		public String countryCode { get; set; }
		public String region { get; set; }
		public String city { get; set; }
		public String coordX { get; set; }
		public String coordY { get; set; }
	}
	
	// class vars
	public Address address
	{
		get
		{
			if (address == null)
				address = new Address();
			return address;
		}
		set;
	}
	public Location location
	{
		get
		{
			if (location == null)
				location = new Location();
			return location;
		}
		set;
	}
	public String companyId { get; set; }
	public String warehouseName { get; set; }
	public Boolean storageIndoor { get; set; }
	public Boolean storageOutdoor { get; set; }
	public String storageSuperficie { get; set; }
	public String loadCode { get; set; }
	public Boolean accessibilityRoad { get; set; }
	public Boolean accessibilityTrain { get; set; }
	public Boolean accessibilityWater { get; set; }
	public Boolean accessibilityAir { get; set; }
	public Boolean distributionRegional { get; set; }
	public Boolean distributionNational { get; set; }
	public Boolean distributionInternational { get; set; }
	public String contact { get; set; }
	public String facilities { get; set; }
	public String services { get; set; }
	
	public List<String> days
	{
		get
		{
			if (days == null)
				days = new List<String>();
			return days;
		}
		set;
	}
	
	public String email { get; set; }
	public String phone { get; set; }
	public Integer Index { get; set; }
}