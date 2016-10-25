/** 
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2014 April 16
* @description  contains static convertor methods from ESB_DataClasses objects to SFDC objects
*/
public class ESB_ConvertHelper
{
	public static string composePhoneNumber(ESB_DataClasses.communicationDetails phone)
	{
		string retVal = '';
		if(string.isEmpty(phone.prefixNumber))
			retVal = string.format('{0} {1} {2}', new string[] { phone.countryNumber, phone.localNumber.substring(0,3) , phone.localNumber.substring(3)});
		else
			retVal = string.format('{0} {1} {2}', new string[] { phone.countryNumber, phone.prefixNumber, phone.localNumber});
		
		// to conform validation rules - add + sign if it not exists
		if(!retVal.startsWith('+'))
			retVal = '+' + retVal;
		
		return retVal;
	} //getPhoneNumber
	
	public static Account extractAccount(ESB_DataClasses.company company)
	{
		return extractAccount(company, null);
	}
	
	/** 
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2014 April 20
	* @description  extracts account from webservice packet and if it exist in database - combine it with 
	*               what we got.
	*/
	public static Account extractAccount(ESB_DataClasses.company company, Id existingId)
	{
		system.debug('----------- ESB_ConvertHelper: extractAccount: company: ' + company);
		Account acc;
		if(existingId == null)
			acc = new Account();
		else
		{
			acc = [
				SELECT
					Id, Name, BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry,
					Company_Registration_Number__c, Transport_Licence__c, VAT__c, Email__c, Fax, Phone, Website,
					Customer_Since__c, ESB_Company_Type__c, ESB_Company_status__c,
					ESB_Billing_Address_ID__c, ESB_ShippingAddress_ID__c, Parent_TWA__r.AccountNumber 
				FROM Account
				WHERE Id = :existingId
			];
		}
		
		if(company.addresses != null && company.addresses.address != null && company.addresses.address.size() > 0)
		{
			system.debug('----------- ESB_ConvertHelper: extractAccount: found ' + company.addresses.address.size() + ' addresses. processing.');
			
			// 1st we need to extract countries list
			Map<string, string> countriesMap = new Map<string, string>();
			for(integer i = 0; i < company.addresses.address.size(); i++)
			{
				string c = company.addresses.address.get(i).country;
				if(c != null)
					if(!countriesMap.containsKey(c))
						countriesMap.put(c, '');
			} // first address loop
			
			// 2nd we need to map country codes to country names
			List<Country_Parameters__c> countries = Country_Parameters__c.getAll().values();
			for(Country_Parameters__c cntry : countries/*[SELECT Name, ISO2_code__c FROM Country_Parameters__c WHERE ISO2_code__c IN :countriesMap.keySet()]*/)
			{
				countriesMap.put(cntry.ISO2_code__c, cntry.Name);
			}
			// and 3rd we need to set proper country values
			for(integer i = 0; i < company.addresses.address.size(); i++)
			{
				if(company.addresses.address.get(i).country != null)
					company.addresses.address.get(i).country = countriesMap.get(company.addresses.address.get(i).country);
			}
			
			system.debug('----------- ESB_ConvertHelper: extractAccount: countries map: ' + countriesMap);
			
			for(integer i = 0; i < company.addresses.address.size(); i++)
			{
				ESB_DataClasses.address addr = company.addresses.address.get(i);
				
				boolean useDefLocationType = false;
				system.debug('----------- ESB_ConvertHelper: extractAccount: addr.locationTypes: ' + addr.locationTypes);
				if(addr.locationTypes == null) 
					useDefLocationType = true;
				else
				{
					system.debug('----------- ESB_ConvertHelper: extractAccount: addr.locationTypes.addressLocationType: ' + addr.locationTypes.addressLocationType);
					if(addr.locationTypes.addressLocationType == null)
						useDefLocationType = true;
					else if(addr.locationTypes.addressLocationType.size() == 0)
						useDefLocationType = true;
				}
				system.debug('----------- ESB_ConvertHelper: extractAccount: useDefLocationType: ' + useDefLocationType);
				Set<ESB_DataClasses.addressLocationTypeEnum> addrSet;
				if(useDefLocationType)
				{
					addrSet = new Set<ESB_DataClasses.addressLocationTypeEnum>();
					addrSet.add(ESB_DataClasses.addressLocationTypeEnum.postal);
				}
				else
					addrSet = new Set<ESB_DataClasses.addressLocationTypeEnum>(addr.locationTypes.addressLocationType);
				
				system.debug('----------- ESB_ConvertHelper: extractAccount: addrSet: ' + addrSet);
				/*if(addrSet.contains(ESB_DataClasses.addressLocationTypeEnum.billing))
						SetBillingAddress(acc, addr);*/
				if(addrSet.contains(ESB_DataClasses.addressLocationTypeEnum.postal))
						SetShippingAddress(acc, addr);
			}
		}
		
		if(company.name != null) acc.Name = company.name;
		if(company.tradeRegistrationNumber != null) acc.Company_Registration_Number__c = company.tradeRegistrationNumber;
		if(company.transportLicenseNumber != null) acc.Transport_Licence__c = company.transportLicenseNumber;
		if(company.vat != null) acc.VAT__c = company.vat;
		if(company.email != null) acc.Email__c = company.email;
		if(company.fax != null) 
			acc.Fax = composePhoneNumber(company.fax);
		if(company.phone != null) 
			acc.Phone = composePhoneNumber(company.phone);
		if(company.website != null) acc.Website = company.website;
		if(company.customerSince != null) acc.Customer_Since__c = company.customerSince.date();
		if(company.companyType != null) acc.ESB_Company_Type__c = string.valueOf(company.companyType);
		if(company.companyState != null) acc.ESB_Company_status__c = string.valueOf(company.companyState);
		if(company.operationalParentCompanyBusinessAccount != null)
		{
			// we do not need to do additional SOQL query every time, so to minimize impact condition below is added
			if(acc.Parent_TWA__r.AccountNumber != company.operationalParentCompanyBusinessAccount.id)
			{
				Account parent = [SELECT Id, Name FROM Account WHERE AccountNumber = :company.operationalParentCompanyBusinessAccount.id LIMIT 1];
				// if account is found
				if(parent != null)
					acc.Parent_TWA__c = parent.Id;
			}
		}
		// 3) other stuff
		// remainder is not relevant for an account
		
		return acc;
	} //extractAccount
	
	public static Contact extractContact(ESB_DataClasses.company company) { return extractContact(company, null); }
	
	public static Contact extractContact(ESB_DataClasses.company company, Id existingId)
	{
		system.debug('----------- ESB_ConvertHelper: extractContact: company: ' + company);
		ESB_DataClasses.user myUser = company.users.user.get(0);
		return extractContact(myUser, existingId);
	} //extractContact (from company)
	
	public static Contact extractContact(ESB_DataClasses.user user) { return extractContact(user, null); }
	public static Contact extractContact(ESB_DataClasses.user user, Id existingId)
	{
		system.debug('----------- ESB_ConvertHelper: extractContact: user: ' + user);
		Contact cont;
		if(existingId == null)
			cont = new Contact();
		else
		{
			cont = [
				SELECT
					Id, Name, Salutation, FirstName, LastName, Username__c, Email, Fax, Phone, MobilePhone,
					Department__c, ESB_User_status__c, Gender__c, Time_Zone__c,Product__c
				FROM Contact
				WHERE Id = :existingId
			];
		}
		
		try
		{
			system.debug('----------- ESB_ConvertHelper: extractContact: companyBusinessAccount: ' + user.companyBusinessAccount);
			if(user.companyBusinessAccount != null && !user.companyBusinessAccount.id.equalsIgnoreCase('FAKE'))
			{
				Account a = [SELECT Id, Name FROM Account WHERE AccountNumber = :user.companyBusinessAccount.id];
				cont.AccountId = a.Id;
			}
		}
		catch(Exception ex)
		{
			throw new ESB_CompanyOperations.AccountNotFoundException();
		}
		
		// 2) userShortInfo data
		if(user.firstName != null) cont.FirstName = user.firstName;
		if(user.lastName != null) cont.lastName = user.lastName;
		if(user.login != null) cont.Username__c = user.login;
		// userRole - do we need it?
		
		cont.ESB_BuisnessID__c = user.businessId.id;
		// 3) remaining fields
		if(user.email != null) cont.Email = user.email;
		/*if(user.fax != null)  // we need to ignore fax, since WKTSA don't have this field and it cause
			cont.Fax = composePhoneNumber(user.fax);*/
		if(user.phone != null) 
			cont.Phone = composePhoneNumber(user.phone);
		if(user.mobile != null) 
			cont.MobilePhone = composePhoneNumber(user.mobile);
		if(user.userPosition != null) cont.Department__c = user.userPosition.value.get(0);
		if(user.userTitle != null) 
        {
            cont.Salutation = user.userTitle.value.get(0);
            if(cont.Salutation == 'Mr' || cont.Salutation == 'Dr')
            {
                cont.Gender__c = 'Male';
            }
            else if(cont.Salutation == 'Ms' || cont.Salutation == 'Mrs')
            {
                cont.Gender__c = 'Female';
            }
        }
		if(user.status != null) cont.ESB_User_status__c = string.valueOf(user.status);
		cont.Type_of_User__c = '';
		if(user.userRoles !=  null)
        {
            if(user.userRoles.userRole != null)
            {
                Set<string> roles = new Set<string>();
                for(string s:user.userRoles.userRole)
                { 
                    System.Debug('-------' + s);
                    if(s.toLowerCase().startsWith('fx'))
                        roles.add('TFX');
                    if(s.toLowerCase().startsWith('shipper'))
                        roles.add('TWA');
                    if(s.toLowerCase().startsWith('wktsadmin'))
                        roles.add('CD');
                    if(s.toLowerCase().startsWith('spot'))
                        roles.add('SPOT');   
                    if(s.toLowerCase().startsWith('freightcentral'))
                        roles.add('TFC');
                        
                    if(s.toLowerCase().startsWith('wktsdmin_superUser'))
                        cont.Type_of_User__c = 'Super User';    
                    if(s.toLowerCase().startsWith('wktsadmin_user'))
                        cont.Type_of_User__c = 'User';    
                                          
                }
            	cont.Admin_Products__c = String.join(new List<String>(roles), ', ');
            }
            else
            {
                cont.Admin_Products__c = '';
            }
        }
		if(user.preferredLanguage != null)
		{
			List<Language_parameters__c> lpLangs = Language_parameters__c.getAll().values();
			system.debug('----------- ESB_ConvertHelper: extractContact: preferredLanguage: ' + user.preferredLanguage.trim());
			system.debug('----------- ESB_ConvertHelper: extractContact: languages: ' + lpLangs);
			string sLang = 'Other';
			for(Language_parameters__c lp : lpLangs)
				if(lp.Locale__c == user.preferredLanguage.trim())
					sLang = lp.Name;
			cont.Language__c = sLang;
		}
        if(user.preferredTimezone != null) cont.Time_Zone__c = user.preferredTimezone;
        
		
		return cont;
	} //extractContact (from user)
    
    
	private static void SetShippingAddress(Account acc, ESB_DataClasses.address addr)
	{
		system.debug('----------- ESB_ConvertHelper: SetShippingAddress: addr: ' + addr);
		if(addr.streetName != null)
		{
			if(addr.homeNumber != null)
				acc.ShippingStreet = string.format('{0} {1}', new string[] { addr.streetName, addr.homeNumber });
			else
				acc.ShippingStreet = addr.streetName;
		}
		if(addr.district != null ) acc.ShippingState = addr.district;
		if(addr.city != null ) acc.ShippingCity = addr.city;
		if(addr.postCode != null ) acc.ShippingPostalCode = addr.postCode;
		if(addr.country != null ) acc.ShippingCountry = addr.country;
		if(addr.timezone != null ) acc.Time_Zone__c = addr.timezone;
		
		//if(acc.ESB_ShippingAddress_ID__c == 'FAKE' || string.isEmpty(acc.ESB_ShippingAddress_ID__c)) 
		acc.ESB_ShippingAddress_ID__c = addr.businessId.id;
	} //SetBillingAddress
	
	private static ESB_DataClasses.companyObjectsTypeEnum stringToCompanyObjectsType(string s)
	{
		for(ESB_DataClasses.companyObjectsTypeEnum v : ESB_DataClasses.companyObjectsTypeEnum.values())
			if(v.name() == s)
				return v;
		return null;
	} //stringToCompanyObjectsType
	
	private static ESB_DataClasses.addressLocationTypeEnum stringToLocationType(string s)
	{
		for(ESB_DataClasses.addressLocationTypeEnum v : ESB_DataClasses.addressLocationTypeEnum.values())
			if(v.name() == s)
				return v;
		return null;
	} //stringToLocationType
	
	private static ESB_DataClasses.userStatus stringToUserStatus(string s)
	{
		for(ESB_DataClasses.userStatus v : ESB_DataClasses.userStatus.values())
			if(v.name() == s)
				return v;
		return null;
	} //stringToUserStatus
	
	private static ESB_DataClasses.userType stringToUserType(string s)
	{
		for(ESB_DataClasses.userType v : ESB_DataClasses.userType.values())
			if(v.name() == s)
				return v;
		return null;
	} //stringToUserType
	
	private static dateTime stringToDateTime(string s)
	{
		if(string.isEmpty(s)) return null;
		s = s.replace('T', ' ');
		return dateTime.valueOf(s);
	} //stringToDateTime
	
	public static ESB_DataClasses.userRole stringToUserRole(string s)
	{
		for(ESB_DataClasses.userRole v : ESB_DataClasses.userRole.values())
			if(v.name() == s)
				return v;
		return null;
	} //stringToUserRole
}