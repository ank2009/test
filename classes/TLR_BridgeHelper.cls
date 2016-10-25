/**
* @author       Anton Solovyev (anton_soloveyv@epam.com)
* @date         2013 October 7
* @description  Bridge operations helper
**/
public without sharing class TLR_BridgeHelper
{
	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 October 7-9
	* @description  Assign pridge profile to user profile
	**/
	@future(callout = true)
	public static void AssignBridgeProfiles(List<Id> userProfileIds, Map<string, string> bridgeProfileMap)
	{
		List<User_Profile__c> userProfiles = [
			SELECT
				Id, Name, Bridge_Error__c,
				User_Login__c, Contact__r.Account.AccountNumber, WKTS_Profiles__c
			FROM User_Profile__c
			WHERE Id IN :userProfileIds
		];

		for(User_Profile__c up : userProfiles)
		{
			string accNumber = up.Contact__r.Account.AccountNumber;
			string fxLogin = up.User_Login__c;
			up.Bridge_Error__c = ''; // clean up error state
			// picklist is multiselect.
			List<string> givenProfiles = up.WKTS_Profiles__c.split(';');
			for(string profile : givenProfiles)
			{
				if(!bridgeProfileMap.containsKey(profile))
				{
					//throw new Generic.BridgeInternalException('Incorrect Bridge profile string: ' + profile + '. Check FXSettings.');
					up.Bridge_Error__c += 'Incorrect Bridge profile string: ' + profile + '. Check FXSettings.\n';
					continue;
				}
				try { TcdStub.assignWKTSBridgeProfile(accNumber, fxLogin, string.ValueOf(bridgeProfileMap.get(profile)), true); }
				catch(Exception ex)
				{
					up.Bridge_Error__c += 'Bridge returned an error for profile ' + profile + '\n';
					up.Bridge_Technical_Error__c += profile + 
						' assign operation caused an exception: ' + ex.getMessage() +
						'. Location: ' + ex.getLineNumber() + 
						'. Call stack: ' + ex.getStackTraceString() + '\n'; 
				}
			}
			System.debug('---- TLR_BridgeHelper.AssignBridgeProfiles: current user profile errors: ' + up.Bridge_Error__c);
			up.Bridge_processing_status__c = 'Done';
		} //for(User_Profile__c up : userProfiles)
		update userProfiles;
	} // AssignBridgeProfile

	/**
	* @author       Anton Solovyev (anton_soloveyv@epam.com)
	* @date         2013 October 7
	* @description  Suppress pridge profiles
	* @ parameter   userProfilesBridgeMap - map with user_profile Id and corresponding WKTS_Profile field.
	                since it will be called from trigger, and in fact call will be performed after trigger will updates a record
	**/
	@future(callout = true)
	public static void SuppressBridgeProfiles(Map<Id, string> userProfilesBridgeMap, Map<string, string> bridgeProfileMap)
	{
		List<User_Profile__c> userProfiles = [
			SELECT
				Id, Name, Bridge_Error__c,
				User_Login__c, Contact__r.Account.AccountNumber, WKTS_Profiles__c
			FROM User_Profile__c
			WHERE Id IN :userProfilesBridgeMap.keySet()
		];

		for(User_Profile__c up : userProfiles)
		{
			string fxLogin = up.User_Login__c;
			up.Bridge_Error__c = ''; // clean up error state
			System.debug('---- TLR_BridgeHelper.SuppressBridgeProfiles: User Profile: ' + up);
			System.debug('---- TLR_BridgeHelper.SuppressBridgeProfiles: userProfilesBridgeMap: ' + userProfilesBridgeMap);
			System.debug('---- TLR_BridgeHelper.SuppressBridgeProfiles: userProfilesBridgeMap.get(up.Id): ' + userProfilesBridgeMap.get(up.Id));
			// picklist is multiselect.
			List<string> givenProfiles = userProfilesBridgeMap.get(up.Id).split(';');
			for(string profile : givenProfiles)
			{
				if(!bridgeProfileMap.containsKey(profile))
				{
					//throw new Generic.BridgeInternalException('Incorrect Bridge profile string: ' + profile + '. Check FXSettings.');
					up.Bridge_Error__c += 'Incorrect Bridge profile string: ' + profile + '. Check FXSettings.';
					continue;
				}
				try { TcdStub.suppressAssignationOfWKTSBridgeProfile(fxLogin, string.ValueOf(bridgeProfileMap.get(profile)), true); }
				catch(Exception ex)
				{
					up.Bridge_Error__c += 'Bridge returned an error for profile ' + profile + '\n';
					up.Bridge_Technical_Error__c += profile + 
						' suppress operation caused an exception: ' + ex.getMessage() +
						'. Location: ' + ex.getLineNumber() + 
						'. Call stack: ' + ex.getStackTraceString() + '\n';
				}
			}
			System.debug('---- TLR_BridgeHelper.SuppressBridgeProfiles: current user profile errors: ' + up.Bridge_Error__c);
			up.Bridge_processing_status__c = 'Done';
		} //for(User_Profile__c up : userProfiles)
		update userProfiles;
	} // SuppressBridgeProfiles
}