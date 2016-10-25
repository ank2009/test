global class ScheduleUnsuspension implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
    	doCallout();
    }
    
    @future (callout=true)
    static void doCallout()
    {
    	String outputText = '';
    	
        // Users unsuspension
        
        System.Debug('## Start Unsuspension');
        
        List<User_Profile__c> userProfiles = [SELECT Id,
                                                     Provisioning__c,
                                                     Provisioning__r.Subscription__c 
                                              FROM User_Profile__c 
                                              WHERE Suspension_End_Date__c != null
                                              AND Suspension_End_Date__c <= :date.today()
                                              AND Status__c = 'Suspended'];
        
        Map<ID, List<ID>> mapIdSubId = new Map<ID, List<ID>>();
        Set<ID> addedUP = new Set<ID>();
     
        for (User_Profile__c up : userProfiles)
        {            
            System.Debug('## Start Unsuspension User: ' + up.Id);
            
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
	            
	            System.Debug('## End Unsuspension User: ' + up.Id + ' added');
            }
            else
                System.Debug('## End Unsuspension User: ' + up.Id + ' discarded');
        }
        
        ProvisioningMessages.UnsuspendUsersInSubscription(mapIdSubId);
        
        outputText += 'User unsuspension task: ' + mapIdSubId.Values() + '<br/>';
        
        System.Debug('## End Unsuspension');
        
        
        // Services unsuspension
        
        System.Debug('## Start Service Unsuspension');
        
        List<User_Profile_Service__c> upServices = [SELECT Id, User_Profile__c, 
        											User_Profile__r.Suspension_Start_Date__c, 
        											User_Profile__r.Suspension_End_Date__c, 
        											User_Profile__r.Provisioning__c,
        											User_Profile__r.Provisioning__r.Subscription__c 
        											FROM User_Profile_Service__c 
        											WHERE Suspension_End_Date__c != null
        											AND Suspension_End_Date__c <= :date.today()
													AND Provisioning_Status__c = 'Suspended'];
        											
        List<User_Profile_Service_Attribute__c> upServiceAttrs = [SELECT Id, 
        														  User_Profile_Service__r.User_Profile__c, 
        														  User_Profile_Service__r.User_Profile__r.Suspension_Start_Date__c, 
        														  User_Profile_Service__r.User_Profile__r.Suspension_End_Date__c, 
                                                                  User_Profile_Service__r.User_Profile__r.Provisioning__c,
        														  User_Profile_Service__r.User_Profile__r.Provisioning__r.Subscription__c 
        														  FROM User_Profile_Service_Attribute__c 
        														  WHERE Suspension_End_Date__c != null 
        														  AND Suspension_End_Date__c <= :date.today()
																  AND Provisioning_Status__c = 'Suspended'];
        
        Integer sent = mapIdSubId.keySet().size();
        mapIdSubId.clear();
     
        for (User_Profile_Service__c upService : upServices)
        {
            if (upService.User_Profile__r.Suspension_Start_Date__c == null || 
                upService.User_Profile__r.Suspension_Start_Date__c > Date.Today() || 
                upService.User_Profile__r.Suspension_End_Date__c < Date.Today())
            {            
                System.Debug('## Start Unsuspension User Service: ' + upService.Id);
                
                if (upService.User_Profile__r.Provisioning__c != null)
                {
	                if (!addedUP.contains(upService.User_Profile__c))
	                {
	                    if (mapIdSubId.get(upService.User_Profile__r.Provisioning__r.Subscription__c) == null && mapIdSubId.keySet().size() < 10)
	                        mapIdSubId.put(upService.User_Profile__r.Provisioning__r.Subscription__c, new List<Id>());
	                    
	                    if (mapIdSubId.get(upService.User_Profile__r.Provisioning__r.Subscription__c) != null)
	                    {
	                        mapIdSubId.get(upService.User_Profile__r.Provisioning__r.Subscription__c).add(upService.User_Profile__c);
	                        addedUP.add(upService.User_Profile__c);
	                    }   
	                }
	                
                	System.Debug('## End Unsuspension User Service: ' + upService.Id + ' added');
                }
                else
                	System.Debug('## End Unsuspension User Service: ' + upService.Id + ' discarded');
            }
        }
        
        for (User_Profile_Service_Attribute__c upServiceAttr : upServiceAttrs)
        {
            if (upServiceAttr.User_Profile_Service__r.User_Profile__r.Suspension_Start_Date__c == null || 
                upServiceAttr.User_Profile_Service__r.User_Profile__r.Suspension_Start_Date__c > Date.Today() || 
                upServiceAttr.User_Profile_Service__r.User_Profile__r.Suspension_End_Date__c < Date.Today())
            {            
                System.Debug('## Start Unsuspension User Service Attribute: ' + upServiceAttr.Id);
                
                if (upServiceAttr.User_Profile_Service__r.User_Profile__r.Provisioning__c != null)
                {
                	if (!addedUP.contains(upServiceAttr.User_Profile_Service__r.User_Profile__c))
	                {
	                    if (mapIdSubId.get(upServiceAttr.User_Profile_Service__r.User_Profile__r.Provisioning__r.Subscription__c) == null && mapIdSubId.keySet().size() < 10)
	                        mapIdSubId.put(upServiceAttr.User_Profile_Service__r.User_Profile__r.Provisioning__r.Subscription__c, new List<Id>());
	                    
	                    if (mapIdSubId.get(upServiceAttr.User_Profile_Service__r.User_Profile__r.Provisioning__r.Subscription__c) != null)
	                    {
	                        mapIdSubId.get(upServiceAttr.User_Profile_Service__r.User_Profile__r.Provisioning__r.Subscription__c).add(upServiceAttr.User_Profile_Service__r.User_Profile__c);
	                        addedUP.add(upServiceAttr.User_Profile_Service__r.User_Profile__c);
	                    }   
	                }
	                
	                System.Debug('## End Unsuspension User Service Attribute: ' + upServiceAttr.Id + ' added');
                }
                else
                	System.Debug('## End Unsuspension User Service Attribute: ' + upServiceAttr.Id + ' discarded');
            }
        }
        
        ProvisioningMessages.SuspendUsersInSubscription(mapIdSubId, 'Standard');
        
        outputText += 'Service (attribute) suspension task: ' + mapIdSubId.Values();
        
        System.Debug('## End Service Unsuspension');
       
       
        // Email sending
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
        String[] toAddresses = new String[] {'thomas.crm20@gmail.com'};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Scheduled Unsuspension Support');
        mail.setSubject('Scheduled Unsuspension Report');
        mail.setHtmlBody(outputText);
       
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}