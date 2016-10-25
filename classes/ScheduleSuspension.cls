global class ScheduleSuspension implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        doCallout();
    }
   
    @future (callout=true)
    static void doCallout()
    {
        String outputText = '';
       
        // Users suspension
       
        System.Debug('## Start Suspension');
       
        List<User_Profile__c> userProfiles = [SELECT Id,
                                                     Provisioning__c,
                                                     Provisioning__r.Subscription__c
                                              FROM User_Profile__c
                                              WHERE Suspension_Start_Date__c != null
                                              AND Suspension_Start_Date__c <= :date.today()
                                              AND (Suspension_End_Date__c = null
                                                   OR Suspension_End_Date__c >= :date.today())
                                              AND Status__c = 'Activated'];
       
        Map<ID, List<ID>> mapIdSubId = new Map<ID, List<ID>>();
        Set<ID> addedUP = new Set<ID>();
    
        for (User_Profile__c up : userProfiles)
        {  
            System.Debug('## Start Suspension User: ' + up.Id);
           
            if (up.Provisioning__c != null)
            {
            	if (!addedUP.contains(up.Id))
                {
                	if (mapIdSubId.get(up.Provisioning__r.Subscription__c) == null && mapIdSubId.keySet().size() < 10)
                    	mapIdSubId.put(up.Provisioning__r.Subscription__c, new List<Id>());
                          
                    if (mapIdSubId.get(up.Provisioning__r.Subscription__c) != null)
                    {
                    	mapIdSubId.get(up.Provisioning__r.Subscription__c).add(up.Id);
                        addedUP.add(up.Id);
                    }              
                }
                 
                System.Debug('## End Suspension User: ' + up.Id + ' added');
            }
            else
                System.Debug('## End Suspension User: ' + up.Id + ' discarded');           
        }
       
        ProvisioningMessages.SuspendUsersInSubscription(mapIdSubId, 'SuspendAll');
       
        outputText += 'User suspension task: ' + mapIdSubId.Values() + '<br/>';
       
        System.Debug('## End Suspension');
 
       
        // Services suspension
 
        System.Debug('## Start Service Suspension');
       
        List<User_Profile_Service__c> upServices = [SELECT Id, User_Profile__c,
                                                    User_Profile__r.Suspension_Start_Date__c,
                                                    User_Profile__r.Suspension_End_Date__c,
                                                    User_Profile__r.Provisioning__c,
                                                    User_Profile__r.Provisioning__r.Subscription__c
                                                    FROM User_Profile_Service__c
                                                    WHERE Suspension_Start_Date__c != null
                                                    AND Suspension_Start_Date__c <= :date.today()
                                                    AND (Suspension_End_Date__c = null
                                                         OR Suspension_End_Date__c >= :date.today())
                                                    AND Provisioning_Status__c = 'Activated'];
                                                        
        List<User_Profile_Service_Attribute__c> upServiceAttrs = [SELECT Id,
                                                                  User_Profile_Service__r.User_Profile__c,
                                                                  User_Profile_Service__r.User_Profile__r.Suspension_Start_Date__c,
                                                                  User_Profile_Service__r.User_Profile__r.Suspension_End_Date__c,
                                                                  User_Profile_Service__r.User_Profile__r.Provisioning__c,
                                                                  User_Profile_Service__r.User_Profile__r.Provisioning__r.Subscription__c
                                                                  FROM User_Profile_Service_Attribute__c
                                                                  WHERE Suspension_Start_Date__c != null
                                                                  AND Suspension_Start_Date__c <= :date.today()
                                                                  AND (Suspension_End_Date__c = null
                                                                       OR Suspension_End_Date__c >= :date.today())
                                                                  AND Provisioning_Status__c = 'Activated'];
       
        Integer sent = mapIdSubId.keySet().size();
        mapIdSubId.clear();
    
        for (User_Profile_Service__c upService : upServices)
        {
            if (upService.User_Profile__r.Suspension_Start_Date__c == null ||
                upService.User_Profile__r.Suspension_Start_Date__c > Date.Today() ||
                upService.User_Profile__r.Suspension_End_Date__c < Date.Today())
            {           
                System.Debug('## Start Suspension User Service: ' + upService.Id);
               
                if (upService.User_Profile__r.Provisioning__c != null)
                {
				    if (!addedUP.contains(upService.User_Profile__c))
				    {
				    	if (mapIdSubId.get(upService.User_Profile__r.Provisioning__r.Subscription__c) == null && mapIdSubId.keySet().size() < 10 - sent)
				      		mapIdSubId.put(upService.User_Profile__r.Provisioning__r.Subscription__c, new List<Id>());
				     
				      	if (mapIdSubId.get(upService.User_Profile__r.Provisioning__r.Subscription__c) != null)
				      	{
				        	mapIdSubId.get(upService.User_Profile__r.Provisioning__r.Subscription__c).add(upService.User_Profile__c);
				          	addedUP.add(upService.User_Profile__c);
				      	}   
				  	}
				  	
				  	System.Debug('## End Suspension User Service: ' + upService.Id + ' added');
                }
                else
                  	System.Debug('## End Suspension User Service: ' + upService.Id + ' discarded');
            }
        }
       
        for (User_Profile_Service_Attribute__c upServiceAttr : upServiceAttrs)
        {
            if (upServiceAttr.User_Profile_Service__r.User_Profile__r.Suspension_Start_Date__c == null ||
                upServiceAttr.User_Profile_Service__r.User_Profile__r.Suspension_Start_Date__c > Date.Today() ||
                upServiceAttr.User_Profile_Service__r.User_Profile__r.Suspension_End_Date__c < Date.Today())
            {           
                System.Debug('## Start Suspension User Service Attribute: ' + upServiceAttr.Id);
               
                if (upServiceAttr.User_Profile_Service__r.User_Profile__r.Provisioning__c != null)
                {
              		if (!addedUP.contains(upServiceAttr.User_Profile_Service__r.User_Profile__c))
              		{
                  		if (mapIdSubId.get(upServiceAttr.User_Profile_Service__r.User_Profile__r.Provisioning__r.Subscription__c) == null && mapIdSubId.keySet().size() < 10 - sent)
                      		mapIdSubId.put(upServiceAttr.User_Profile_Service__r.User_Profile__r.Provisioning__r.Subscription__c, new List<Id>());
                 
                  		if (mapIdSubId.get(upServiceAttr.User_Profile_Service__r.User_Profile__r.Provisioning__r.Subscription__c) != null)
                  		{
                      		mapIdSubId.get(upServiceAttr.User_Profile_Service__r.User_Profile__r.Provisioning__r.Subscription__c).add(upServiceAttr.User_Profile_Service__r.User_Profile__c);
                      		addedUP.add(upServiceAttr.User_Profile_Service__r.User_Profile__c);
                  		}   
              		}
                     
                    System.Debug('## End Suspension User Service Attribute: ' + upServiceAttr.Id + ' added');
                }
                else
                	System.Debug('## End Suspension User Service Attribute: ' + upServiceAttr.Id + ' discarded');
            }
        }
       
        ProvisioningMessages.SuspendUsersInSubscription(mapIdSubId, 'Standard');
       
        outputText += 'Service (attribute) suspension task: ' + mapIdSubId.Values();
       
        System.Debug('## End Service Suspension');
       
        
        // Email sending
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
        String[] toAddresses = new String[] {'thomas.crm20@gmail.com'};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Scheduled Suspension Support');
        mail.setSubject('Scheduled Suspension Report');
        mail.setHtmlBody(outputText);
       
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}