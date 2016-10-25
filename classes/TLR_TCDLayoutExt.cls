/**	
* @author		Anton Solovyev (anton_soloveyv@epam.com)
* @date			2013 November 28
* @description	Controller extension for Account, to display TCD Data on TLR Account layouts
**/
public with sharing class TLR_TCDLayoutExt 
{
	//======================================================================================================
	// CompanyDirectory properfies/fields
	//======================================================================================================
	private Account acc;
	private String currentId { get { return acc.Id; } set; }

	public String[] languagesResult { get; set; }
	public String LanguagesSpoken { get; set; }
	public List<SelectOption> LanguageOptions { get; set; }

	// activities table
	public TcdActivity activityResult { get; set; }
	
	public TcdActivity.RegularRoute currentRegularRoute { get; set; }
	public Integer currentRegularRouteIndex
	{ 
		get; 
		set
		{
			currentRegularRouteIndex = value;
			currentRegularRoute = activityResult.regularRoutes.get(value);
		}
	}
	//Activity Regions
	public TcdActivity.Country currentCountry { get; set; }
	public String currentCountryCode
	{ 
		get; 
		set
		{
			currentCountryCode = value;
			currentCountry = activityResult.countryMap.get(value);
		}
	}
	public List<SelectOption> CountryOptions { get; set; }
	public List<SelectOption> regionActivityOptions { get; set; }
	public List<SelectOption> regionDepartureOptions
	{
		get
		{
			List<SelectOption> regionValues= new List<SelectOption>();
			//We take only the regions (level 2, which depend directly from country Code)
			for(Teleroute_Region__c region: [SELECT Label__c,Name FROM Teleroute_Region__c WHERE Level__c='2' AND Parent_Code__c=:currentRegularRoute.departure.countryCode ORDER BY Label__c ASC])
			{
				if(region.Name  != null && region.Name !='')
					regionValues.add(new SelectOption(region.Name, region.Label__c));
			}
			return regionValues;
		} 
		set; 
	}
	public List<SelectOption> regionArrivalOptions
	{
		get
		{
			List<SelectOption> regionValues= new List<SelectOption>();
			//We take only the regions (level 2, which depend directly from country Code)
			for(Teleroute_Region__c region: [SELECT Label__c,Name FROM Teleroute_Region__c WHERE Level__c='2' AND Parent_Code__c=:currentRegularRoute.arrival.countryCode ORDER BY Label__c ASC])
			{
				if(region.Name  != null && region.Name !='')
					regionValues.add(new SelectOption(region.Name, region.Label__c));
			}
			return regionValues;
		}
		set;
	}
	// TcdActivity mirror properties
	public List<TcdActivity.RegularRoute> Routes
	{
		get
		{
			if(activityResult != null && activityResult.regularRoutes != null)
				return activityResult.regularRoutes.values();
			else
				return null;
		}
		set;
	}
	public List<TcdActivity.Country> ActivityCountries
	{
		get
		{
			if(activityResult != null && activityResult.countryMap != null)
				return activityResult.countryMap.values();
			else
				return null;
		}
		set;
	}
	
	private Map<Integer, TcdWarehouse> warehousesResult;
	public TcdWarehouse currentWarehouse { get; set; }
	public Integer currentWarehouseIndex
	{ 
		get; 
		set
		{
			currentWarehouseIndex = value;
			currentWarehouse = warehousesResult.get(value);
		}
	}
	public List<TcdWarehouse> Warehouses
	{
		get
		{
			if(warehousesResult!= null)
				return warehousesResult.values();
			else
				return null;
		}
		set;
	}
	
	public String hidde { get; set; }
	public Boolean displayLanguagePopUp { get; set; }
	public Boolean displayActivitiesPopUp { get; set; }
	public Boolean displayRegularRoutePopUp { get; set; }
	public Boolean displayWarehousingPopUp { get; set; }
	public Boolean displayActivityCountryPopUp { get; set; }
	public Boolean CDavailableInTCD { get; set; }
	
	
	public List<SelectOption> weekDayList { get; set; }
	
	//public Boolean errorMessage { get; set; } NOT DISPLAYED
	private Boolean getLanguagesCalled;
	private Boolean getActivitiesCalled;
	private Boolean getWarehousesCalled;
	
	
	public List<String> Specialization
	{
		get
		{
			List<String> returnValue = new List<String>();
			if(activityResult != null && activityResult.specializationCodes.size()>0)
			{
				for(STring spec: activityResult.specializationCodes)
				{
					returnValue.add(Specialization_Code__c.getValues(spec).Label__c);
				}
			}
			return returnValue;
		}
		set;
	}
	public List<SelectOption> SpecializationOptions { get; set; }
	
	//======================================================================================================
	// CodeOfConduct properfies/fields
	//======================================================================================================
	public Boolean COCavailableInTCD { get; set; }
	public TcdCoC codeOfConductResult { get; set; }
	public List<Contact> contactsResult { get; set; }
	public Boolean COCdisplayPopup { get; set; }
	
	private Map<String, Contact> contactResultMap;
	private Map<String, Contact> contactResultCompleteMap;
	
	public List<SelectOption> ContactOptions
	{
		get
		{
			List<SelectOption> returnValues = new List<SelectOption>();
			if(contactsResult != null)
			{
				for(Contact contact: contactsResult)
				{
					returnValues.add(new SelectOption(contact.Contact_id__c,
						contact.LastName + ' ' + contact.FirstName + ', ' + contact.email + ', ' + contact.phone));
				}
			}
			return returnValues;
		}
		set;
	}
	
	public List<SelectOption> StatusOptions { get; set; }
	//======================================================================================================
	// CertificateManagement properfies/fields
	//======================================================================================================
	public Boolean CERavailableInTCD { get; set; }
	
	public Boolean displayCertificateList { get; set; }
	public Boolean CERdisplayPopup { get; set; }
	
	public string c_hidde { get; set; }
	
	public List<TcdCertificate> certificatesResult { get; set; }
	public TcdCertificate currentCertificate { get; set; }
	public Integer currentCertificateId
	{
		get;
		set
		{
			currentCertificateId = value;
			if(value == 999)
				currentCertificate = new TcdCertificate();
			else
				currentCertificate = certificatesResult.get(value);
		}
	}
	
	private boolean tcdQueried;
	private boolean vetoToStore;
	
	//======================================================================================================
	// UploadCertificateAttachment page properties/fields
	//======================================================================================================
	private Id parentCertificateId;
	public Document newDoc { get; set; }
	//======================================================================================================
	// constructor
	//======================================================================================================
	public TLR_TCDLayoutExt(ApexPages.StandardController controller)
	{
		this.acc = [SELECT Id, Name, AccountNumber FROM Account WHERE Id = :controller.getId()];
		System.debug('--------- TLR_TCDLayoutExt: ctor: acc: ' + acc);
		
		displayLanguagePopUp = false;
		displayActivitiesPopUp = false;
		displayActivityCountryPopUp = false;
		displayRegularRoutePopUp = false;
		
		getLanguagesCalled = false;
		getActivitiesCalled = false;
		getWarehousesCalled = false;
		
		weekDayList = new List<SelectOption>();
		weekDayList.add(new SelectOption('Monday', 'Monday'));
		weekDayList.add(new SelectOption('Tuesday', 'Tuesday'));
		weekDayList.add(new SelectOption('Wednesday', 'Wednesday'));
		weekDayList.add(new SelectOption('Thursday', 'Thursday'));
		weekDayList.add(new SelectOption('Friday', 'Friday'));
		weekDayList.add(new SelectOption('Saturday', 'Saturday'));
		weekDayList.add(new SelectOption('Sunday', 'Sunday'));
		
		LanguagesSpoken = '';
		hidde = '';
		activityResult = new TcdActivity();
		currentRegularRoute = new TcdActivity.RegularRoute();
		currentCountry = new TcdActivity.Country();
		
		LanguageOptions = new List<SelectOption>();
		for(Language_Code__c lang : [SELECT Name, Label__c FROM Language_Code__c ORDER BY Label__c ASC])
		{
			LanguageOptions.add(new SelectOption(lang.Name, lang.Label__c));
		}
		
		SpecializationOptions = new List<SelectOption>();
		for(Specialization_Code__c spec: [SELECT Name, Label__c FROM Specialization_Code__c ORDER BY Label__c ASC])
		{
			SpecializationOptions.add(new SelectOption(spec.Name, spec.Label__c));
		}
		CountryOptions = new List<SelectOption>();
		for(pw_cc__CountryObject__c country: [SELECT Name, IRU_Country_Code__c FROM pw_cc__CountryObject__c ORDER BY Name ASC])
		{
			if(country.IRU_Country_Code__c != null && country.IRU_Country_Code__c!='')
				CountryOptions.add(new SelectOption(country.IRU_Country_Code__c, country.Name));
		}
		regionActivityOptions = new List<SelectOption>();
		//We take only the regions (level 2, which depend directly from country Code)
		for(Teleroute_Region__c region : [SELECT Label__c, Name FROM Teleroute_Region__c WHERE Level__c='2' AND Parent_Code__c = :currentCountry.countryCode ORDER BY Label__c ASC])
		{
			if(region.Name != null && region.Name != '')
				regionActivityOptions.add(new SelectOption(region.Name, region.Label__c));
		}
		
		if(!Generic.StringNotEmpty(acc.AccountNumber))
		{
			hidde='display:none;';
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Company Directory item is only available when the reccord own an account number.'));
		}
		CDavailableInTCD = false;
		COCavailableInTCD = false;
		
		StatusOptions = new List<SelectOption>();
		StatusOptions.add(new SelectOption('U', 'Undecided'));
		StatusOptions.add(new SelectOption('A', 'Accepted'));
		StatusOptions.add(new SelectOption('S', 'Suspended by Teleroute'));
		StatusOptions.add(new SelectOption('R', 'Refused'));
		
		COCdisplayPopup = false;
		
		c_hidde = '';
		tcdQueried = false;
		CERdisplayPopup = false;
		vetoToStore = false;
	} // ctor
	//======================================================================================================
	// CompanyDirectory3 page methods. 'Company Directory' section of Account layout
	//======================================================================================================
	/**
		Class the webservice and submit the coorect address details
		this is also based on the given Id
	**/
	private void FillActivities()
	{
		try
		{
			List<TcdActivity> activitiesResult = TcdParser.queryActivities(acc.AccountNumber);
			activityResult = activitiesResult[0];
			//activityResult.manager = this; what for?
			system.debug('## >> countryMap :' + activityResult.countryMap);
			CDavailableInTCD = true;
			getActivitiesCalled = true;
		}
		catch(Generic.TCDException e) // invalid response
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No data available for this Company'));
		}
		catch(Exception e)
		{
			//ApexPages.addMessages(e);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Nothing to display'));
			CDavailableInTCD = false;
		}
	} //FillActivities
	
	private void FillLanguages()
	{
		try
		{
			getLanguagesCalled = true;
			languagesResult = TcdParser.queryLanguages(acc.AccountNumber);
			System.debug('##languages retrieved >>> : '+languagesResult);
			
			// refresh LanguagesSpoken
			LanguagesSpoken = '';
			for(Language_Code__c lang : [SELECT Name, Label__c FROM Language_Code__c WHERE Name IN :languagesResult ORDER BY Label__c ASC])
			{
				if(LanguagesSpoken != '')
					LanguagesSpoken += ',';
				LanguagesSpoken += lang.Label__c;
			}
		}
		catch( Exception e ) {/* do we need exception handling? */}
	} //FillLanguages
	
	private void FillWarehouses()
	{
		try
		{
			getWarehousesCalled = true;
			warehousesResult = TcdParser.queryWarehouses(acc.AccountNumber);
			//We set the manager
			//for(TcdWarehouse wh : warehousesResult.values())
			//{
				//wh.manager = this;
			//}
		}
		catch( Exception e ) { }
	} //FillWarehouses
	
	// View button click
	public PageReference InitializeCompanyDirectory()
	{
		FillActivities();
		FillLanguages();
		FillWarehouses();
		return null;
	}
	
	// Update Languages button click
	public void showLanguagePopup()
	{
		//We call callLanguages if it hasn't already been done
		if(!getLanguagesCalled)
			FillLanguages();
		displayLanguagePopUp = true;
	}
	
	// Update Activities button click
	public void showActivitiesPopup()
	{
		//We call callActivities if it hasn't already been done
		if(!getActivitiesCalled)
			FillActivities();
		displayActivitiesPopUp = true;
	}
	
	public PageReference showRegularRoutePopup()
	{
		//We call callActivities if it hasn't already been done
		if(!getActivitiesCalled)
			FillActivities();
		displayRegularRoutePopUp = true;
		
		return null;
	}
	
	// New Regular Route button click
	public PageReference newRegularRoute()
	{
		showRegularRoutePopup();
		currentRegularRoute = new TcdActivity.RegularRoute(activityResult);
		
		for(Integer max : activityResult.regularRoutes.keySet())
		{
			if(max >= currentRegularRoute.Index)
				currentRegularRoute.Index = max + 1;
		}
		return null;
	} //newRegularRoute
	
	// New Activity Country button click
	public PageReference newActivityCountry()
	{
		showActivityCountryPopup();
		currentCountry = new TcdActivity.Country();
		currentCountry.activityParent = activityResult;
		return null;
	}
	
	
	public PageReference showActivityCountryPopup() 
	{
		//We call callActivities if it hasn't already been done
		if(!getActivitiesCalled)
			FillActivities();
		displayActivityCountryPopUp = true;
		return null;
	}
	
	// New Warehouse button click
	public PageReference newWarehouse() 
	{
		showWarehousePopup();
		
		currentWarehouse = new TcdWarehouse();
		currentWarehouse.address = new TcdWarehouse.Address();
		currentWarehouse.location = new TcdWarehouse.Location();
		currentWarehouse.companyId = acc.AccountNumber;
		currentWarehouse.Index = 0;
		
		if(warehousesResult != null)
		{
			for(Integer max : warehousesResult.keySet())
			{
				if(max >= currentWarehouse.Index)
					currentWarehouse.Index = max + 1;
			}
		}
		return null;
	}
	
	public PageReference showWarehousePopup() 
	{
		//We call callActivities if it hasn't already been done
		if(!getWarehousesCalled)
			FillWarehouses();
		displayWarehousingPopUp = true;
		return null;
	}
	
	public PageReference deleteRegularRoute()
	{
		activityResult.regularRoutes.remove(currentRegularRouteIndex);
		return null;
	}
	
	public PageReference deleteActivityCountry()
	{
		activityResult.countryMap.remove(currentCountryCode);
		return null;
	}
	public PageReference deleteWarehouse()
	{
		warehousesResult.remove(currentWarehouseIndex);
		return null;
	}
	public PageReference updateLanguages()
	{
		System.debug('>>> Languages checked : ' + languagesResult);
		displayLanguagePopUp = false;
		Dom.XmlNode response = TcdStub.updateLanguagesXml(acc.AccountNumber, languagesResult);
		FillLanguages();
		return null;
	}
	
	public PageReference closeAllPopups()
	{
		displayLanguagePopUp = false;
		displayActivitiesPopUp = false;
		displayRegularRoutePopUp = false;
		displayWarehousingPopUp = false;
		displayActivityCountryPopUp = false;
		
		return null;
	}
	
	public PageReference updateActivities()
	{
		System.debug('>>> activities result : '+activityResult );
		System.debug('>>> activityResult.regularRoutes result : '+activityResult.regularRoutes);
		//If the regular route isn't contained by regular route list, it is a new which needs to be added to the Map
		if((currentRegularRoute != null) && !activityResult.regularRoutes.containsKey(currentRegularRoute.Index))
		{
			system.debug('## >>> New Regular Route equals :'+currentRegularRoute);
			activityResult.regularRoutes.put(currentRegularRoute.Index,currentRegularRoute);
		}
		
		if((currentCountry!= null) && !activityResult.countryMap.containsKey(currentCountry.countryCode))
		{
			system.debug('## >>> New Activity Country equals :'+currentCountry);
			activityResult.countryMap.put(currentCountry.countryCode,currentCountry);
		}
		
		displayActivitiesPopUp = false;
		displayRegularRoutePopUp = false;
		displayActivityCountryPopUp = false;
		Dom.XmlNode response = TcdStub.updateActivitiesXml(activityResult);
		FillActivities();
		return null;
	}
	
	public PageReference updateWarehouses()
	{
		System.debug('>>> warehouse : '+currentWarehouse);
		displayWarehousingPopUp = false;
		Dom.XmlNode response = TcdStub.updateWarehousesXml(currentWarehouse);
		FillWarehouses();
		return null;
	}
	
	//======================================================================================================
	// CodeOfConduct page methods. 'Code Of Conduct' section of Account layout
	//======================================================================================================
	public PageReference InitCodeOfConduct()
	{
		FillCodeOfConduct();
		FillContacts();
		return null;
	}
	
	public PageReference FillCodeOfConduct()
	{
		try
		{
			codeOfConductResult = TcdParser.queryCodeOfConduct(acc.AccountNumber);
			
			if(codeOfConductResult == null)
				throw new Generic.TCDException();
			
			COCavailableInTCD = true;
		}
		catch(Generic.TCDException e)
		{
			system.debug('Webservice callout failed : ' + e);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'There is no Code of Conduct informations to display.'));
		}
		catch(Exception e)
		{
			system.debug(e);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'There is no Code of Conduct informations to display.'));
		}
		return null;
	} //FillCodeOfConduct
	
	public PageReference FillContacts()
	{
		try
		{
			contactResultMap = TcdParser.queryContacts(acc.AccountNumber, true);
			contactResultCompleteMap = TcdParser.queryContacts(acc.AccountNumber, false);
			
			if(contactResultMap == null)
				throw new Generic.TCDException('There is no contacts informations to display.');
			else
			{
				contactResultCompleteMap.putAll(contactResultMap);
				contactsResult = contactResultMap.values();
				if(codeOfConductResult.DeciderId != null && codeOfConductResult.DeciderId != '')
				{
					Contact contactDecider = contactResultCompleteMap.get(codeOfConductResult.DeciderId);
					if(contactDecider != null)
						codeOfConductResult.Decider = contactDecider.LastName + ' ' + 
							contactDecider.FirstName + ', ' + contactDecider.email + ', ' + contactDecider.phone;
					else
						codeOfConductResult.Decider = codeOfConductResult.DeciderId;
				}
				else
				{
					throw new Generic.StandardException('There is no decider currently.');
				}
			}
		}
		catch(Generic.TCDException e)
		{
			System.debug('There is no contacts informations to display :' + e);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'There is no contacts informations to display.'));
		}
		catch(Exception e)
		{
			System.debug('Error getting contact infocmation :' + e);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'There is no contacts informations to display.'));
		}
		return null;
	} //FillContacts
	
	public void COCclosePopup()
	{
		COCdisplayPopup = false;
	}
	
	public void COCshowPopup() 
	{
		COCdisplayPopup = true;
	}
	
	public PageReference saveCodeofConduct()
	{
		COCdisplayPopup = false;
		System.debug('>>> CodeofConduct update : ' + codeOfConductResult);
		Dom.XmlNode response = TcdStub.updateCodeOfConductXml(codeOfConductResult);
		InitCodeOfConduct();
		return null;
	}
	//======================================================================================================
	// CertivicateManagement2 page methods. 'Static Certification' section of Account layout
	//======================================================================================================
	public void InitCertificates()
	{
		if(!Generic.StringNotEmpty(acc.AccountNumber))
		{
			c_hidde='display:none;';
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Company Directory item is only available when the reccord own an account number.'));
		}
		currentCertificateId = 999;
		displayCertificateList = false;
		
		if(Generic.StringNotEmpty(System.currentPagereference().getParameters().get('reloadCertificate')) && 
		System.currentPagereference().getParameters().get('reloadCertificate') == 'true')
		{
			FillCertificates();
		}
	} //InitCertificates
	
	public void FillCertificates()
	{
		try
		{
			displayCertificateList = false;
			certificatesResult = TcdParser.queryCertificates(acc.AccountNumber);
			
			/*for(TcdCertificate certif : certificatesResult)
			{
			    certif.CertificateManager = this;
			}*/
			
			if(certificatesResult.size() > 0)
				displayCertificateList = true;
			else
				throw new Generic.TCDException('There is no certificate to display.');
			CERavailableInTCD = true;
		}
		catch(Generic.TCDException e)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Webservice callout failed: ' + e.getMessage()));
		}
		catch(Exception e)
		{
			ApexPages.addMessages(e);
		}
	} // FillCertificates
	
	public void viewCertificates()
	{
		if(!tcdQueried)
		{
			try
			{
				List<TcdActivity> activitiesResult = TcdParser.queryActivities(acc.AccountNumber);
				TcdActivity activityResult = activitiesResult[0];
				CERavailableInTCD = true;
			}
			catch(Exception e)
			{
				CERavailableInTCD = false;
			}
			tcdQueried = true;
		}
		if(CERavailableInTCD)
			FillCertificates();
	} //viewCertificates
	
	public void CERclosePopup() 
	{
		CERdisplayPopup = false;
		currentCertificateId = 999;
	}
	
	public void CERshowPopup() 
	{
		currentCertificate = new TcdCertificate();
		CERdisplayPopup = true;
	}
	
	public PageReference saveCurrentCertificate() 
	{
		if(!Generic.StringNotEmpty(currentCertificate.certif.Status__c) 
		|| !Generic.StringNotEmpty(currentCertificate.certif.PredefinedType__c) 
		|| currentCertificate.certif.Expiration_Date__c == null)
		{
			vetoToStore = true;
		}
		
		if(!vetoToStore)
		{
			CERdisplayPopup = false;
			currentCertificateId = 999;
			if(!Generic.StringNotEmpty(currentCertificate.SalesforceId))
			{
				Certificate__c certif = new Certificate__c();
				certif.Account__c = this.acc.Id;
				insert certif;
				currentCertificate.SalesforceId = certif.Id;
			}
		}
		return null;
	} //saveCurrentCertificate
	
	public void UpdateCurrentCertificate()
	{
		if(!vetoToStore)
		{
			system.debug('## >>> Provision ' + currentCertificate);
			currentCertificate.CompanyId = acc.AccountNumber;
			Dom.XMLNode response = TcdStub.updateCertificateXml(currentCertificate);
			system.debug('## >>> Update response ' + response);
			FillCertificates();
		}
		else
		{
			if(!Generic.StringNotEmpty(currentCertificate.certif.Status__c))
				currentCertificate.certif.Status__c.addError('You must enter a value');
			
			if(!Generic.StringNotEmpty(currentCertificate.certif.PredefinedType__c))
				currentCertificate.certif.PredefinedType__c.addError('You must enter a value');
			
			if(currentCertificate.certif.Expiration_Date__c == null)
				currentCertificate.certif.Expiration_Date__c.addError('You must enter a value');
			
			vetoToStore = false;
		}
	} //UpdateCurrentCertificate
	
	public PageReference updateCertificate()
	{
		CERshowPopup();
		return null;
	}
	
	public PageReference deleteCertificate()
	{
		//currentCertificateId = 999;
		currentCertificate.CompanyId = acc.AccountNumber;
		TcdStub.deleteCertificateXml(currentCertificate);
		
		try
		{
			Certificate__c certifToDelete = [SELECT Id FROM Certificate__c WHERE Id = :currentCertificate.SalesforceId];
			delete certifToDelete;
		}
		catch(Exception e)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'delete certificate error: ' + e.getMessage()));
		}
		return null;
	}
	
	public Pagereference uploadCertificate()
	{
		return Utilities.Redirect('apex/UploadCertificateAttachments?id='+acc.Id+'&certificateId='+currentCertificate.SalesforceId);
	}
	
	//======================================================================================================
	// UploadCertificateAtatchment page methods.
	//======================================================================================================
	public void InitUploadCertificateAttachments()
	{
		parentCertificateId = System.currentPagereference().getParameters().get('certificateId');
		newDoc = new Document();
	}
	
	public Pagereference saveNewDocument()
	{
		try
		{
			Attachment attach = new Attachment();
			attach.Body = this.newDoc.Body;
			attach.ContentType = this.newDoc.ContentType;
			attach.Name = this.newDoc.Name;
			attach.OwnerId = UserInfo.getUserId();
			attach.ParentId = parentCertificateId;
			insert attach;
		}
		catch (Exception e)
		{
			Generic.StandardException ex = new Generic.StandardException();
			ex.SetMessage('Error during upload! ' + e.getMessage() + parentCertificateId);
			system.debug('Error during upload! ' + e.getMessage());
			throw ex;
		}
		return Utilities.Redirect('apex/CertificateManagement2?id=' + acc.Id + '&reloadCertificate=true');
	} //saveNewDocument
	
	public Pagereference cancelUploadDocument()
	{
		return Utilities.Redirect('apex/CertificateManagement2?id=' + acc.Id);
	}
}