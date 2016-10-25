public with sharing class ProvisioningMessagesAsync 
{
 	@Future(callout=true) public static void SendInitialProvisioningRequests(List<Id> userProfileIds)
 	{
 		System.debug('## >>> ProvisioningMessagesAsync SendInitialProvisioningRequests : '+userProfileIds);
        ProvisioningMessages.SendInitialProvisioningRequests(userProfileIds);
        System.debug('## >>> ProvisioningMessagesAsync SendInitialProvisioningRequests : END <<<');
	}
	
	@Future(callout=true) public static void SendReProvisioning(List<Id> userProfileIds)
 	{
 		System.debug('## >>> ProvisioningMessagesAsync SendInitialProvisioningRequests : '+userProfileIds);
        ProvisioningMessages.SendReProvisioning(userProfileIds);
        System.debug('## >>> ProvisioningMessagesAsync SendInitialProvisioningRequests : END <<<');
	}
	
	@Future(callout=true) public static void SendUpdateAccount(Id subsId)
 	{
 		System.debug('## >>> ProvisioningMessagesAsync UpdateAccount (from subs) : ' + subsId);
        ProvisioningMessages.UpdateAccount(subsId);
        System.debug('## >>> ProvisioningMessagesAsync UpdateAccount : END <<<');
	}
	@Future(callout=true) public static void SendUpdateContact(List <Id> upuIds)
 	{
 		System.debug('## >>> ProvisioningMessagesAsync UpdateContact (from subs) : ' + upuIds);
        ProvisioningMessages.UpdateContact(upuIds);
        System.debug('## >>> ProvisioningMessagesAsync UpdateContact : END <<<');
	}	
}