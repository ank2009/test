/**
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2014 Feb 12
* @description  Controller for pages in AdminApp custom application
**/
public with sharing class TLR_AdminAppController 
{
	public class StringIntWrapper
	{
		public string strValue { get; set; }
		public integer intValue { get; set; }
		
		public StringIntWrapper() { strValue = ''; intValue = 0; }
		public StringIntWrapper(string sVal, integer iVal) 
		{
			this();
			strValue = sVal;
			intValue = iVal;
		}
	} // StringIntWrapper
	
	public TLR_AdminAppController()
	{
		
	}
	
	//=======================================================================================
	// Bridge settings properties
	//=======================================================================================
	private string oldBridgeURL;
	public string bridgeURL { get; set; }
	
	public boolean wsError { get; set; }
	
	private string oldCustomSettingsValues;
	public string customSettingsValues { get; set; }
	public string userProfileValues { get; set; }
	public string rightsTemplateValues { get; set; }
	public string rightsTemplateDefaultsValues { get; set; }
	public string selectedValue { get; set; } // not used but required for selectList
	public List<SelectOption> realWSSelOptions { get; set; }
	//=======================================================================================
	
	
	//=======================================================================================
	// Bridge settings methods
	//=======================================================================================
	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2014 Feb 12
	* @description  fills lists with existing values
	**/
	public PageReference initBridgeSettingsPage()
	{
		wsError = false;
		selectedValue = '';
		bridgeURL = '';
		customSettingsValues = '';
		userProfileValues = '';
		rightsTemplateValues = '';
		rightsTemplateDefaultsValues = '';
		realWSSelOptions = new List<SelectOption>();
		
		bridgeURL = FXSettings__c.getInstance('FXSettings').WKTS_Bridge_Profile__c;
		// custom settings
		Map<string, Bridge_Profile_Settings__c> bpsMap = Bridge_Profile_Settings__c.getAll();
		for(string name : bpsMap.keySet())
			customSettingsValues += name + ' => ' + bpsMap.get(name).value__c + '\n';
		
		// user profiles
		for(string s : Utilities.getPicklistValues('User_Profile__c', 'WKTS_Profiles__c'))
			userProfileValues += s + '\n';
		
		// right Templates
		for(string s : Utilities.getPicklistValues('Rights_Template__c', 'WKTS_Profiles__c'))
			rightsTemplateValues += s + '\n';
			
		// right Templates defaults
		for(string s : Utilities.getPicklistValues('Rights_Template_Default__c', 'WKTS_Profiles__c'))
			rightsTemplateDefaultsValues += s + '\n';
		
		// webservice request to get real values
		try
		{
			Map<string, integer> wsValues = TcdStub.getAllWKTSBridgeProfiles(false);
			for(string key : wsValues.keySet())
			{
				string s = key + ' => ' + string.valueOf(wsValues.get(key));
				realWSSelOptions.add(new SelectOption(s ,s));
			}
		}
		catch(Exception ex)
		{
			wsError = true;
		}
		return null;
	} //initBridgeSettingsPage
	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2014 Feb 12
	* @description  save all changed values
	**/
	public PageReference saveBridgeSettings()
	{
		// save custom settinsg values
		if(!customSettingsValues.equals(oldCustomSettingsValues))
		{
			List<Bridge_Profile_Settings__c> toDel = new List<Bridge_Profile_Settings__c>();
			List<Bridge_Profile_Settings__c> toAdd = new List<Bridge_Profile_Settings__c>();
			for(string bpsName : Bridge_Profile_Settings__c.getAll().keySet())
				toDel.add(Bridge_Profile_Settings__c.getInstance(bpsName));
			
			for(string val : customSettingsValues.split('\r\n', -1))
			{
				if(string.isEmpty(val.trim()))
					continue;
				system.debug('========= TLR_AdminAppController: saveBridgeSettings: val: ' + val);
				string[] elements = val.split('=>', -1);
				system.debug('========= TLR_AdminAppController: saveBridgeSettings: elements: ' + elements);
				Bridge_Profile_Settings__c bps = new Bridge_Profile_Settings__c();
				bps.Name = elements[0].trim();
				bps.value__c = elements[1].trim();
				toAdd.add(bps);
			} // for
			
			
			// picklists sync
			/*List<metadataservice.PicklistValue> newPickValues = new List<metadataservice.PicklistValue>();
			for(string val : customSettingsValues.split('\r\n', -1))
			{
				if(string.isEmpty(val.trim()))
					continue;
				MetadataService.PicklistValue pval = new MetadataService.PicklistValue();
				string[] elements = val.split('=>', -1);
				pval.fullName = elements[0].trim();
				pval.default_x = false;
				newPickValues.add(pval);
			} // for
			// init metadata connection
			MetadataService.MetadataPort service = new MetadataService.MetadataPort();
			service.SessionHeader = new MetadataService.SessionHeader_element();
			service.SessionHeader.sessionId = UserInfo.getSessionId();
			// init field 
			MetadataService.CustomField upField = new MetadataService.CustomField();
			upField.fullName = 'User_Profile__c.WKTS_Profiles__c';
			upField.label = 'WKTS Profiles';
			upField.type_x = 'Picklist';
			metadataservice.Picklist upPickList = new metadataservice.Picklist();
			upPickList.sorted= false;
			upPickList.picklistValues = newPickValues;
			upField.picklist = upPickList;
			// init updateMetadata command
			MetadataService.UpdateMetadata upUpdate = new MetadataService.UpdateMetadata();
			upUpdate.currentName='User_Profile__c.WKTS_Profiles__c';
			upUpdate.metadata= upField;
			
			// calling update emtadata
			List<MetadataService.updateMetadata> metadataToUpdate = new List<MetadataService.updateMetadata>();
			metadataToUpdate.add(upUpdate);
			MetadataService.AsyncResult[] results = service.updateMetadata(metadataToUpdate);
			system.debug('========= TLR_AdminAppController: saveBridgeSettings: results: ' + results);
			*/
			
			// now we can call DML operations
			delete toDel;
			insert toAdd;
			
			// save url (if changed)
		} // if settings changed
		
		
		if(!bridgeURL.equals(oldBridgeUrl))
		{
			FXSettings__c settings = FXSettings__c.getInstance('FXSettings');
			settings.WKTS_Bridge_Profile__c = bridgeURL;
			update settings;
		}
		return null;
	} //saveBridge
}