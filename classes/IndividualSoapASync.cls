public global with sharing class IndividualSoapASync {
	
    @Future(callout=true) public static void TriggerCampaignForUser(String List1,String GateName,String key,String value) {
       
       	System.debug('## >>> IndividualSoapASync : BEGIN <<<');
       	SIM.IndividualSoap iSoap = new SIM.IndividualSoap();
		SIM.AutomationAuthHeader authHeader = new SIM.AutomationAuthHeader();
		authHeader.Login = SIMSettings__c.getValues('SIMSettings').SIMUser__c;//'teleroute_admin';
		authHeader.Password = SIMSettings__c.getValues('SIMSettings').SIMPassword__c;//'tELEr0ute@2';
		iSoap.AutomationAuthHeader = authHeader;
		
        SIM.TriggerCampaignForUser_element request_x = new SIM.TriggerCampaignForUser_element();
        SIM.TriggerCampaignForUserResponse_element response_x;
        request_x.List1 = List1;
        //request_x.UserID = UserID;
        request_x.GateName = GateName;
        
        SIM.Property simProperty = new SIM.Property();
		simProperty.Key = key;
		//simProperty.Value = '003R000000VjkSgIAJ';
		simProperty.Value = value;
		System.debug('## simProperty : key : '+key);
		System.debug('## simProperty : value : '+value);
		request_x.InputData = new SIM.ArrayOfProperty();
		request_x.InputData.Property = new List<SIM.Property>();
		request_x.InputData.Property.add(simProperty);
		
        Map<String, SIM.TriggerCampaignForUserResponse_element> response_map_x = new Map<String, SIM.TriggerCampaignForUserResponse_element>();
        response_map_x.put('response_x', response_x);
        
        System.debug('## request_x : Before Invoke : '+request_x.List1);
        //System.debug('## request_x : Before Invoke : '+request_x.UserID);
        System.debug('## request_x : Before Invoke : '+request_x.GateName);
        System.debug('## request_x : Before Invoke : '+request_x.InputData);
        WebServiceCallout.invoke(
          iSoap,
          request_x,
          response_map_x,
          new String[]{iSoap.endpoint_x,
          'http://tempuri.org/TriggerCampaignForUser',
          'http://tempuri.org/',
          'TriggerCampaignForUser',
          'http://tempuri.org/',
          'TriggerCampaignForUserResponse',
          'SIM.TriggerCampaignForUserResponse_element'}
        );
        response_x = response_map_x.get('response_x');
        System.debug('## response_x : Result : '+response_x.TriggerCampaignForUserResult);
        System.debug('## response_x : Error : '+response_x.ErrorStr);
        System.debug('## >>> IndividualSoapASync : END <<<');
        //return response_x;
    }
    
}