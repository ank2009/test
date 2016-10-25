/**
	* @author		?
	* @date			?
	* @description	class contains some static utility methods
	*/
global class Utilities 
{
	/** 
	* @author		?
	* @date			?
	* @description	redirects user to some page. 
	* @param		url - URL to redirect to. Relative to SF instance root (like cs1.salesforce.com)
	*/
	global static PageReference Redirect(String url)
	{
		PageReference pageRef = new PageReference('/' + url);
		pageRef.setRedirect(true);
		
		return pageRef;
	}
	
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 September 24
	* @description	Redirects to standard edit page for object, with additional parameters
	*/
	global static PageReference RedirectToStandardEdit(Id objId, string additionalParams)
	{
		string url = string.valueOf(objId) + '/e?nooverride=1';
		if(!string.isEmpty(additionalParams))
			url += '&' + additionalParams;
		return Redirect(url);
	}
	
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 September 24
	* @description	Redirects to standard edit page for object, with additional parameters
	*/
	global static PageReference RedirectToStandardList(string objType)
	{
		String prefix = Schema.getGlobalDescribe().get(objType).getDescribe().getKeyPrefix();
		return Redirect(prefix + '/o');
	}
	
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 September 24
	* @description	Redirects to standard edit page for object, simple form.
	*/
	global static PageReference RedirectToStandardEdit(Id objId)
	{
		string url = string.valueOf(objId) + '/e?nooverride=1&retURL=/' + string.valueOf(objId);
		return Redirect(url);
	}
	
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 August 2
	* @description	gets Batch job status using its ID
	*/
	global static Generic.BatchStatus getBatchStatus(Id batchProcessId)
	{
		AsyncApexJob apexJob = [
			SELECT 
				Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
			FROM AsyncApexJob 
			WHERE ID = :batchProcessId 
		];
		Generic.BatchStatus retVal = Generic.BatchStatus.Error;
		if(apexJob.Status.toLowerCase() == 'queued')
			retVal = Generic.BatchStatus.Queued;
		if(apexJob.Status.toLowerCase() == 'processing')
			retVal = Generic.BatchStatus.Processing;
		if(apexJob.Status.toLowerCase() == 'aborted')
			retVal = Generic.BatchStatus.Aborted;
		if(apexJob.Status.toLowerCase() == 'completed')
			retVal = Generic.BatchStatus.Completed;
		if(apexJob.Status.toLowerCase() == 'failed')
			retVal = Generic.BatchStatus.Failed;
		if(apexJob.Status.toLowerCase() == 'preparing')
			retVal = Generic.BatchStatus.Preparing;
		
		return retVal;
	}
	
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 August 2
	* @description	wrapper for getBatchStatus, just to unterstand, whan Batch process is finished
	*/
	global static Boolean isBatchFinished(Id batchProcessId)
	{
		Generic.BatchStatus status = getBatchStatus(batchProcessId);
		system.debug('---- isBatchFinished: status is ' + string.ValueOf(status));
		return ( 
			status == Generic.BatchStatus.Completed ||
			status == Generic.BatchStatus.Failed ||
			status == Generic.BatchStatus.Aborted
		);
		
	}
	
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2013 September 12
	* @description	convert number to string with given decimal digits
	*/
	global static string DecimalToString(decimal num, integer precision)
	{
		string point = '.';
		integer firstInt = (integer)Math.ceil(num);
		integer secondInt = (integer)Math.abs(num - firstInt)*10000000;
		
		string secondStr = string.valueOf(secondInt).left(precision);
		
		return string.format('{0}{2}{1}', new string[]{string.valueOf(firstInt), secondStr, point});
	}
	
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2014 January 15
	* @description	predicate to compare lists
	* @param		useOrder - use order of elements while comparison. 
					If true - uses standard lists comparison, if no - custom implementation
	*/
	global static Boolean ListsAreTheSame(List<Object> a, List<Object> b, boolean useOrder)
	{
		system.debug('---- Utilities.ListsAreTheSame: parameters: a: ' + a + ', b: ' + b + ', useOrder: ' + useOrder);
		if(a == null && b == null)
			return true;
		
		if(a == null || b == null)
			return false;
		
		// here both lists are not null
		if(useOrder)
			return a.equals(b);
		
		if(a.size() != b.size())
			return false;
		
		boolean areTheSame = true;
		system.debug('---- Utilities.ListsAreTheSame: starting flat search.');
		for(Object o1 : a)
		{
			boolean found = false;
			for(Object o2 : b)
				if (o1 == o2)
					found = true;
			areTheSame &= found;
			system.debug('---- Utilities.ListsAreTheSame: flat search: element: ' + o1 + ', found: ' + found + ', areTheSame: ' + areTheSame);
		} // for each object
		
		return areTheSame;
	} //ListsAreTheSame
	
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2014 January 15
	* @description	method to cerate list from a string, using given delimiter
	*/
	global static string ListToString(List<Object> lst, string delimiter)
	{
		system.debug('---- Utilities.ListToString: parameters: lst: ' + lst + ', delimiter: ' + delimiter);
		if(lst == null)
			return '';
		if(lst.size() == 0)
			return '';
		
		string res = '';
		
		res = string.valueOf(lst[0]);
		for(integer i = 1; i < lst.size(); i++)
			res += delimiter + string.valueOf(lst[i]);
		
		system.debug('---- Utilities.ListToString: res: ' + res);
		return res;
	} //ListsToString
	
	// helper method for invoice level validation
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2014 February 6
	* @description	method to make invoice levels copmarsion easy: it provides numeric value for invoice levels with proper weigth.
	*/
	global static integer getInvoiceLevelValue(string level)
	{
		integer retVal = -1;
		if(level.equalsIgnoreCase('Site')) retVal = 1;
		if(level.equalsIgnoreCase('Company')) retVal = 2;
		if(level.equalsIgnoreCase('National')) retVal = 3;
		if(level.equalsIgnoreCase('International')) retVal = 4;
		return retVal;
	} // getInvoiceLevelValue
	
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2014 February 12
	* @description	gets object's picklist values list
	*/
	global static List<String> getPicklistValues(string objectName, string fieldName)
	{
		List<PicklistEntry> upValues = Schema.getGlobalDescribe().get(objectName) 
			.getDescribe().fields.getMap().get(fieldName).getDescribe().getPickListValues();
		
		List<String> retVal = new List<String>();
		for(PicklistEntry pe : upValues)
		{
			retVal.add(pe.getValue());
		}
		return retVal;
	} //getPicklistValues
	
	global enum randomStringAlphabets { alphaCaps, alphaSmallAndCaps, numbers, alphaCapsNumbers, alphaSmallCapsNumbers }
	
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2014 September 4
	* @description	gets randon string using alphabet type and required length
	*/
	global static string getRandomString(randomStringAlphabets alphabetType, integer len)
	{
		string alphabetString = '';
		string alphabetCaps  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
		string alphabetSmall = 'abcdefghijklmnopqrstuvwxyz';
		string alphabetNum   = '1234567890';
		
		if(alphabetType == randomStringAlphabets.alphaCaps)
			alphabetString = alphabetCaps;
		else if (alphabetType == randomStringAlphabets.alphaSmallAndCaps)
			alphabetString = alphabetCaps + alphabetSmall;
		else if (alphabetType == randomStringAlphabets.numbers)
			alphabetString = alphabetNum;
		else if (alphabetType == randomStringAlphabets.alphaCapsNumbers)
			alphabetString = alphabetCaps + alphabetNum;
		else if (alphabetType == randomStringAlphabets.alphaSmallCapsNumbers)
			alphabetString = alphabetCaps + alphabetSmall + alphabetNum;
		
		
		String retVal = '';
		while (retVal.length() < len) {
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), alphabetString.length());
			retVal += alphabetString.substring(idx, idx+1);
		}
		
		return retVal;
	} //getRandomString
	
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2014 September 5
	* @description	helper method to validate phone numbers inside triggers (replacement of validation formulas)
	*/
	global static boolean ValidatePhone(string phone, Set<integer> validCountryCodes)
	{
		// first check - regex match
		if(!Pattern.matches('^\\+[1-9][0-9]{0,3}( [0-9]*){1,2}\\z', phone))
			return false;
		
		// second check - length of meaningful characters should be less or equal to 15
		string trimmed = phone.replace('+','').replace(' ','');
		if(trimmed.length() > 15)
			return false;
			
		// third check - for validity of country code
		integer country = integer.valueof(phone.replace('+','').split(' ').get(0));
		if(!validCountryCodes.contains(country))
			return false;
		
		return true;
	}
	
	global static boolean ValidatePhone(string phone)
	{
		Set<integer> validCountryCodes = new Set<Integer>();
		for(Country_Parameters__c c : [SELECT Name, Phone_code__c FROM Country_Parameters__c])
			validCountryCodes.add(integer.valueOf(c.Phone_code__c));
		
		return ValidatePhone(phone, validCountryCodes);
	}
    
    global static boolean ValidateLanguage(string language)
    {
        Set<string> allLanguages = new Set<string>(utilities.getPicklistValues('Contact', 'Language__c'));
        return (language == null  || allLanguages.contains(language));
    }
	
	global static string getPhoneValidationErrorMessage()
	{
		return 'This phone number must be in international format with valid country code. Example: +32 2 1234567';
	}
	
	/** 
	* @author		Anton Solovyev (anton_soloveyv@epam.com)
	* @date			2015 March 30
	* @description	helper method to get offer template names for new provisioning
	*/
	global static set<string> getNewProvisioningOfferTemplatesLowerCase()
	{
		return new Set<string>{'cd offer', 'tw shipper', 'tw carrier', 'tfc starter', 'tfx offer', 'twa offer', 'tfx_se'};
	} //getNewProvisioningOfferTemplatesLowerCase
}